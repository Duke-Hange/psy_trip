#!/bin/bash
# gedit script.sh  
# 批处理DTI分析脚本
# 使用方法: ./dti_batch.sh
# # # 1. dos2unix dti_batch.sh
# # # 2. chmod +x dti_batch.sh
# # # 3. ./dti_batch.sh
# 设置错误处理和日志记录    
set -e

# ======================= 配置参数 =======================
FSLDIR="/home/yuhang/fsl"
BASE_DIR="/mnt/d/桌面文件夹/学术帮帮帮/output"  # 当前目录，包含TM文件夹
RAW_DIR="${BASE_DIR}/TM"
PROC_DIR="${BASE_DIR}/result"
PE_DIR="j-"                 # 与 JSON 的 PhaseEncodingDirection 一致
READOUT_TIME="0.08692997"  # TotalReadoutTime（单位：秒）

# 创建输出目录
mkdir -p ${PROC_DIR}

# 获取所有被试列表
SUBJECTS=($(ls -d ${RAW_DIR}/sub* | xargs -n 1 basename))

echo "找到 ${#SUBJECTS[@]} 个被试: ${SUBJECTS[*]}"

## 测试用：SUB_ID=sub001

# 遍历所有被试
for SUB_FOLDER in "${SUBJECTS[@]}"; do
    # 从文件夹名提取被试ID (例如从 "sub001_LuGuangHao" 提取 "sub001")
    SUB_ID=$(echo "${SUB_FOLDER}" | cut -d'_' -f1)
    echo "===== 开始处理被试: ${SUB_ID} ====="
    
    # ======================= 设置路径 =======================
    # 输入文件路径
    T1_DIR="${RAW_DIR}/${SUB_FOLDER}/T1raw"
    DTI_DIR="${RAW_DIR}/${SUB_FOLDER}/DTI"
    
    # 查找T1文件 (假设只有一个.nii或.nii.gz文件)
    T1_INPUT=$(find ${T1_DIR} -name "*3D.nii" -o -name "*3D.nii.gz" | head -1)
    
    # 查找DTI文件
    DTI_INPUT=$(find ${DTI_DIR} -name "*.nii" -o -name "*.nii.gz" | head -1)
    BVAL=$(find ${DTI_DIR} -name "*.bval" | head -1)
    BVEC=$(find ${DTI_DIR} -name "*.bvec" | head -1)
    
    # 检查是否找到必要文件
    if [ -z "${T1_INPUT}" ] || [ -z "${DTI_INPUT}" ] || [ -z "${BVAL}" ] || [ -z "${BVEC}" ]; then
        echo "警告: 未找到 ${SUB_ID} 的必要文件，跳过处理"
        continue
    fi
    
    echo "T1文件: ${T1_INPUT}"
    echo "DTI文件: ${DTI_INPUT}"
    echo "BVAL文件: ${BVAL}"
    echo "BVEC文件: ${BVEC}"
    
    # 输出目录
    T1_PROC_DIR="${PROC_DIR}/${SUB_ID}/T1"
    MRTRIX_DIR="${PROC_DIR}/${SUB_ID}/MRtrix"
    REG_DIR="${T1_PROC_DIR}/registration"
    mkdir -p ${T1_PROC_DIR} ${REG_DIR} ${MRTRIX_DIR}
    
    # ======================= 1. T1处理 =======================
    echo "1. T1重新定向到标准空间"
    # 重新定向到标准MNI空间方向
    fslreorient2std ${T1_INPUT} ${T1_PROC_DIR}/${SUB_ID}_T1_reoriented.nii.gz
    
    echo "2. T1去颅骨 (BET)"
    bet ${T1_PROC_DIR}/${SUB_ID}_T1_reoriented.nii.gz \
       ${T1_PROC_DIR}/${SUB_ID}_T1_brain.nii.gz -f 0.4 -m -o
    if [ ! -f "${T1_PROC_DIR}/${SUB_ID}_T1_brain.nii.gz" ]; then
        echo "错误: T1去颅骨失败!"
        continue
    fi
    
    # ======================= 2. T1配准到MNI空间 =======================
    echo "3. T1配准到MNI空间"
    # 线性配准
    flirt -in ${T1_PROC_DIR}/${SUB_ID}_T1_brain.nii.gz \
        -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz \
        -omat ${REG_DIR}/${SUB_ID}_T1_to_MNI.mat \
        -out ${REG_DIR}/${SUB_ID}_T1_to_MNI.nii.gz \
        -dof 12 -interp spline
    
    # 非线性配准
    fnirt --in=${T1_PROC_DIR}/${SUB_ID}_T1_brain.nii.gz \
        --aff=${REG_DIR}/${SUB_ID}_T1_to_MNI.mat \
        --ref=${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz \
        --cout=${REG_DIR}/${SUB_ID}_T1_to_MNI_warp \
        --config=${FSLDIR}/etc/flirtsch/T1_2_MNI152_2mm.cnf
    
    # 生成反向变换
    invwarp -w ${REG_DIR}/${SUB_ID}_T1_to_MNI_warp \
        -o ${REG_DIR}/${SUB_ID}_MNI_to_T1_warp \
        -r ${T1_PROC_DIR}/${SUB_ID}_T1_brain.nii.gz
    
    # ======================= 3. MRtrix DTI处理流程 =======================
    echo "4. MRtrix DTI处理流程"
    
    # 步骤1: 数据转换和预处理
    echo "4.1 数据转换和去噪"
    mrconvert ${DTI_INPUT} ${MRTRIX_DIR}/raw_dwi.mif -fslgrad ${BVEC} ${BVAL} -force
    dwidenoise ${MRTRIX_DIR}/raw_dwi.mif ${MRTRIX_DIR}/dwi_den.mif -noise ${MRTRIX_DIR}/noise.mif
    
    # 去吉布斯振铃
    mrdegibbs $MRTRIX_DIR/dwi_den.mif $MRTRIX_DIR/dwi_den_degibbs.mif -force

    # 提取b0图像
    dwiextract ${MRTRIX_DIR}/dwi_den_degibbs.mif - -bzero | mrmath - mean ${MRTRIX_DIR}/mean_b0_AP.mif -axis 3 -force
    
    # 涡流和畸变校正 *
    echo "4.2 涡流和畸变校正"
    dwifslpreproc ${MRTRIX_DIR}/dwi_den_degibbs.mif ${MRTRIX_DIR}/dwi_den_preproc.mif \
        -pe_dir ${PE_DIR} \
        -readout_time ${READOUT_TIME} \
        -rpe_none \
        -eddy_options " --repol --slm=linear --data_is_shelled"  \
        -nocleanup

    # 偏置场校正
    dwibiascorrect ants ${MRTRIX_DIR}/dwi_den_preproc.mif ${MRTRIX_DIR}/dwi_den_preproc_unbiased.mif \
        -bias ${MRTRIX_DIR}/bias.mif
    
    # 创建脑掩膜
    dwi2mask ${MRTRIX_DIR}/dwi_den_preproc_unbiased.mif ${MRTRIX_DIR}/mask.mif
    
    # 步骤2: FOD估计  ***
    echo "4.3 FOD估计"
    dwi2response dhollander ${MRTRIX_DIR}/dwi_den_preproc_unbiased.mif \
        ${MRTRIX_DIR}/wm.txt ${MRTRIX_DIR}/gm.txt ${MRTRIX_DIR}/csf.txt \
        -voxels ${MRTRIX_DIR}/response_voxels.mif
    
    dwi2fod msmt_csd ${MRTRIX_DIR}/dwi_den_preproc_unbiased.mif \
        ${MRTRIX_DIR}/wm.txt ${MRTRIX_DIR}/wmfod.mif \
        ${MRTRIX_DIR}/gm.txt ${MRTRIX_DIR}/gmfod.mif \
        ${MRTRIX_DIR}/csf.txt ${MRTRIX_DIR}/csffod.mif -force

    # mtnormalise ${MRTRIX_DIR}/wmfod.mif ${MRTRIX_DIR}/wmfod_norm.mif \
    #     ${MRTRIX_DIR}/gmfod.mif ${MRTRIX_DIR}/gmfod_norm.mif \
    #     ${MRTRIX_DIR}/csffod.mif ${MRTRIX_DIR}/csffod_norm.mif \
    #     -mask ${MRTRIX_DIR}/mask.mif -force

    mtnormalise ${MRTRIX_DIR}/wmfod.mif ${MRTRIX_DIR}/wmfod_norm.mif \
        -mask ${MRTRIX_DIR}/mask.mif -force

    mrconvert ${MRTRIX_DIR}/wmfod.mif ${MRTRIX_DIR}/wmfod_single.mif

    # 步骤5: 结构像处理
    echo "4.4 结构像处理"
    mrconvert ${T1_PROC_DIR}/${SUB_ID}_T1_brain.nii.gz ${MRTRIX_DIR}/anat.mif -force
    #_T1_brain
    5ttgen fsl ${MRTRIX_DIR}/anat.mif ${MRTRIX_DIR}/5tt_nocoreg.mif -premasked -force
    # 5ttgen fsl ${MRTRIX_DIR}/anat.mif ${MRTRIX_DIR}/5tt_nocoreg.mif -force

    # 配准
    dwiextract ${MRTRIX_DIR}/dwi_den_preproc_unbiased.mif - -bzero | mrmath - mean ${MRTRIX_DIR}/mean_b0_processed.mif -axis 3
    mrconvert ${MRTRIX_DIR}/mean_b0_processed.mif ${MRTRIX_DIR}/mean_b0_processed.nii.gz 
    mrconvert ${MRTRIX_DIR}/5tt_nocoreg.mif ${MRTRIX_DIR}/5tt_nocoreg.nii.gz -force
    
    fslroi ${MRTRIX_DIR}/5tt_nocoreg.nii.gz ${MRTRIX_DIR}/5tt_vol0.nii.gz 0 1
    flirt -in ${MRTRIX_DIR}/mean_b0_processed.nii.gz -ref ${MRTRIX_DIR}/5tt_vol0.nii.gz \
        -interp nearestneighbour -dof 12 -omat ${MRTRIX_DIR}/diff2struct_fsl.mat
    
    transformconvert ${MRTRIX_DIR}/diff2struct_fsl.mat ${MRTRIX_DIR}/mean_b0_processed.nii.gz \
        ${MRTRIX_DIR}/5tt_nocoreg.nii.gz flirt_import ${MRTRIX_DIR}/diff2struct_mrtrix.txt  -force
    
    # mrtransform ${MRTRIX_DIR}/5tt_nocoreg.mif -linear ${MRTRIX_DIR}/diff2struct_mrtrix.txt \
    #     -inverse ${MRTRIX_DIR}/5tt_coreg.mif -force

    mrtransform ${MRTRIX_DIR}/5tt_nocoreg.mif \
    -linear ${MRTRIX_DIR}/diff2struct_mrtrix.txt \
    -inverse -template ${MRTRIX_DIR}/mean_b0_processed.mif \
    ${MRTRIX_DIR}/5tt_coreg.mif -force

    5tt2gmwmi ${MRTRIX_DIR}/5tt_coreg.mif ${MRTRIX_DIR}/gmwmSeed_coreg.mif -force
    
    # 步骤4: 纤维追踪
    echo "4.5 纤维追踪"
    tckgen -act ${MRTRIX_DIR}/5tt_coreg.mif -backtrack \
        -seed_gmwmi ${MRTRIX_DIR}/gmwmSeed_coreg.mif \
        -nthreads 8 -maxlength 250 -cutoff 0.06 -select 500000 \
        ${MRTRIX_DIR}/wmfod_norm.mif ${MRTRIX_DIR}/tracks_2M.tck -force

    # 步骤5: SIFT2权重计算
    echo "4.6 SIFT2权重计算"
    tcksift2 -act ${MRTRIX_DIR}/5tt_coreg.mif -out_mu ${MRTRIX_DIR}/sift_mu.txt \
        -out_coeffs ${MRTRIX_DIR}/sift_coeffs.txt -nthreads 8 \
        ${MRTRIX_DIR}/tracks_2M.tck ${MRTRIX_DIR}/wmfod_norm.mif ${MRTRIX_DIR}/sift_weights.txt -force

    # ======================= 4.7 图谱处理 =======================
    echo "4.7 图谱配准"
    
    AAL_ATLAS="${FSLDIR}/data/atlases/AAL/aal.nii"

    flirt -in ${AAL_ATLAS}  \
          -ref ${MRTRIX_DIR}/mean_b0_processed.nii.gz \
          -omat ${MRTRIX_DIR}/AAL_to_dwi.mat \
          -out ${MRTRIX_DIR}/atlas_in_dwi2.nii.gz \
          -dof 9 -interp spline

    applywarp \
        --ref=${MRTRIX_DIR}/mean_b0_processed.nii.gz \
        --in=${AAL_ATLAS} \
        --premat=${MRTRIX_DIR}/AAL_to_dwi.mat \
        --out=${MRTRIX_DIR}/atlas_in_dwi.nii.gz \
        --interp=nn
         # 可视化纤维密度 (AFD)

        # mrview ${MRTRIX_DIR}/atlas_in_dwi.nii.gz   -fixel.load ${MRTRIX_DIR}/fixel_mask/directions.mif \

    # 转换到MRtrix格式
    mrconvert ${MRTRIX_DIR}/atlas_in_dwi.nii.gz ${MRTRIX_DIR}/nodes.mif -force

    # ======================= 4.8 生成结构连接矩阵 =======================
    echo "4.8 生成结构连接矩阵"
    tck2connectome \
      ${MRTRIX_DIR}/tracks_2M.tck \
      ${MRTRIX_DIR}/nodes.mif \
      ${MRTRIX_DIR}/connectome.csv \
      -symmetric \
      -zero_diagonal \
      -tck_weights_in ${MRTRIX_DIR}/sift_weights.txt \
      -nthreads 8 -force -assignment_radial_search 1 -force \
      -scale_invnodevol
    
    echo "结构连接矩阵已生成: ${MRTRIX_DIR}/connectome.csv"

    # ======================= 4.9 可选：Fixel分析 =======================
    echo "4.9 Fixel分析（可选）"
    fod2fixel ${MRTRIX_DIR}/wmfod_norm.mif \
               ${MRTRIX_DIR}/fixel_mask \
               -mask ${MRTRIX_DIR}/mask.mif \
               -afd fd.mif \
               -nthreads 8 

    fixelconnectivity ${MRTRIX_DIR}/fixel_mask \
                     ${MRTRIX_DIR}/tracks_2M.tck \
                     ${MRTRIX_DIR}/fixel_matrix\
                     -nthreads 8 
                     
     #mrview ${MRTRIX_DIR}/fixel_matrix/fixels.mif

    # ======================= 5. 质量控制 =======================
    echo "5. 质量控制"
    
    echo "5.1 检查离群切片"
    DWIPREPROC_TMP_DIR=$(find ${MRTRIX_DIR} -name "dwifslpreproc-tmp-*" -type d | head -1)
    if [ -n "$DWIPREPROC_TMP_DIR" ] && [ -d "$DWIPREPROC_TMP_DIR" ]; then
        cd "$DWIPREPROC_TMP_DIR"
        if [ -f "dwi_post_eddy.eddy_outlier_map" ]; then
            totalSlices=$(mrinfo dwi.mif | grep Dimensions | awk '{print $6 * $8}')
            totalOutliers=$(awk '{ for(i=1;i<=NF;i++)sum+=$i } END { print sum }' dwi_post_eddy.eddy_outlier_map 2>/dev/null || echo "0")
            outlier_percent=$(echo "scale=2; ($totalOutliers / $totalSlices * 100)" | bc 2>/dev/null || echo "0")
            echo "离群切片比例: ${outlier_percent}%"
        fi
        cd - > /dev/null
    else
        echo "警告: 未找到dwifslpreproc临时目录"
    fi
    
    # ======================= 6. 完成当前被试处理 =======================
    echo "=== ${SUB_ID} 处理完成 ==="
    echo "主要输出文件:"
    echo "  - 结构连接矩阵: ${MRTRIX_DIR}/connectome.csv"
    echo "  - 节点图像: ${MRTRIX_DIR}/nodes.mif"
    echo "  - 纤维轨迹: ${MRTRIX_DIR}/tracks_2M.tck"
    echo "  - SIFT权重: ${MRTRIX_DIR}/sift_weights.txt"
    
    # 检查最终输出文件
    if [ -f "${MRTRIX_DIR}/connectome.csv" ]; then
        echo "===== 处理成功完成: ${SUB_ID} ====="
    else
        echo "警告: 连接矩阵文件未生成，请检查处理流程"
    fi
    
    echo ""
done

echo "===== 所有被试处理完成 ====="
echo "结果保存在: ${PROC_DIR}"

