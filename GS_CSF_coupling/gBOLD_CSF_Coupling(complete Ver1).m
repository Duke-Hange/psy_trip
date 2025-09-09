%% 第一步 预处理 (略)

%% 第二步 提取GS
clear
path_data='D:\教学数据\dpabi';
gs_path = dir(fullfile(path_data, '*ARglobalCFSD'));   %%需要改
out_path = fullfile(path_data,'GS');
mkdir(out_path)
% mask_path = 'D:\教学数据\BN_Atlas_246_3mm.nii\BN_Atlas_246_3mm';
% mask_data=y_Read(mask_path);
% label_0=find(mask_data==0);

sub_file=dir(fullfile(gs_path.folder,gs_path.name));
sub_file(1:2)=[];

for sub=1:length(sub_file)
    Fun_Data=dir(fullfile(sub_file(sub).folder,sub_file(sub).name,'*.nii'));
    [Fun_Data,~]=y_Read(fullfile(Fun_Data.folder,Fun_Data.name));
    dim=size(Fun_Data);

    Fun_Data=reshape(Fun_Data,[],dim(4));
    Fun_Data(isnan(Fun_Data))=0;

    % Fun_Data(label_0,:)=[];
    gs=mean(Fun_Data,1);
    fname=fullfile(out_path,sub_file(sub).name);

    save(fname,'gs');
    clear brain_data gs
end


%% 第三步 提取CSF (第四脑室底部ROI一层)

clear
path_data='D:\教学数据\dpabi';
CSF_mask_path = dir(fullfile(path_data,'Masks','Segment*'));
CSF_mask_file=dir(fullfile(CSF_mask_path.folder,CSF_mask_path.name));
CSF_mask_file(1:2)=[];
CSF_mask_file = dir(fullfile(CSF_mask_path.folder,CSF_mask_path.name,'*ThrdMask_sub*CSF*'));
CSF_Funpath = dir(fullfile(path_data, '*ARglobalCF'));  %%需要改
CSF_Funfile=dir(fullfile(CSF_Funpath.folder,CSF_Funpath.name));
CSF_Funfile(1:2)=[];
out_path = fullfile(path_data,'CSF');
mkdir(out_path)
for sub= 1:length(CSF_mask_file)
[CBF_mask,~]=y_Read(fullfile(CSF_mask_file(sub).folder,CSF_mask_file(sub).name));
CSF_Fundata=dir(fullfile(CSF_Funfile(sub).folder,CSF_Funfile(sub).name,'*.nii'));
[Fundata,~]=y_Read(fullfile(CSF_Fundata(1).folder,CSF_Fundata(1).name));
has_value = squeeze(any(any(CBF_mask, 1), 2)); % 检查每个z层是否存在1
start_z = find(has_value, 1, 'first'); % 找到第一个出现1的z层索引
disp(['第一个出现有值区域的z轴平面是：', num2str(start_z)]);
mask_slice = CBF_mask(:, :, start_z);
se = strel('disk', 2);
closed_slice = imclose(mask_slice, se);
mask_new = zeros(size(CBF_mask));
if start_z>=2
mask_new(:, :, start_z-1) = closed_slice; % 仅保留目标层 %%
else
mask_new(:, :, 1) = closed_slice; % 仅保留目标层 %%
end
for slice=1:size(Fundata,4)
CSFdata(:,:,:,slice)= Fundata(:,:,:,slice).*mask_new;
end
dim=size(CSFdata);
CSFdata=reshape(CSFdata,[],dim(4));
CSFdata(isnan(CSFdata))=0;
% CBFdata(label_0,:)=[];
CSF=mean(CSFdata,1);
fname=fullfile(out_path,CSF_Funfile(sub).name);
save(fname,'CSF');
clear CSFdata CSF
end

%% 第四步 耦合计算

clear
Gs_path='D:\教学数据\dpabi\GS'; %% 放入路径
CSF_path='D:\教学数据\dpabi\CSF'; %% 同理，放入路径
CSF_files = dir(CSF_path); %% ARC 
CSF_files(1:2)=[];
Gs_files = dir(Gs_path); %% ARC 
Gs_files(1:2)=[];
% 参数设置
TR = 2; % 重复时间（秒）
max_hrf_delay = 10; % 最大预期HRF延迟（秒）
max_lag = ceil(max_hrf_delay/TR); % 转换为lag单位
for sub=1:length(Gs_files)
load(fullfile(CSF_files(sub).folder,CSF_files(sub).name));
load(fullfile(Gs_files(sub).folder,Gs_files(sub).name));
gs_deriv = -gradient(gs);
gs_z = zscore(gs_deriv);
CSF_z = zscore(CSF);
[xc, lags] = xcorr(CSF_z, gs_z, max_lag, 'coeff'); % 注意输入顺序 先CSF
lags_time = lags * TR; % 转换为时间单位
% 提取正向时延（CSF滞后于GS的情况）
pos_lags = lags >= 0;
xc_pos = xc(pos_lags);
lags_pos = lags_time(pos_lags);
% 找到最大反相关点（最小值）
[min_val, min_idx] = min(xc_pos);
optimal_lag = lags_pos(min_idx);
corr(sub,1)=min_val;
corr(sub,2)=optimal_lag;
end
save('correlation_results.mat', 'corr'); %%这里存在了当前路径，可以自己调整

%% 第五步 统计分析

n1 = 49; % 组1样本量 
group1_min = corr(1:n1, 1); % 反相关系数
group2_min = corr(n1+1:end, 1);
num_perm = 5000; % 置换次数
combined_min = [group1_min; group2_min]; % 合并数据
%% 对min_val进行置换检验
% 计算观察差异
obs_diff_min = mean(group1_min) - mean(group2_min);
perm_diffs_min = zeros(num_perm, 1);
for i = 1:num_perm
% 随机置换并重新分组
perm_order = randperm(length(combined_min));
perm_group1 = combined_min(perm_order(1:n1));
perm_group2 = combined_min(perm_order(n1+1:end));
% 计算差异
perm_diffs_min(i) = mean(perm_group1) - mean(perm_group2);
end
% 计算p值（双侧检验）
p_min = (sum(abs(perm_diffs_min) >= abs(obs_diff_min)) + 1) / (num_perm + 1);