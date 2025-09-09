%% analysis -- The GC between 17 ROIs
%%% step 1 - calculate the ROIS (7 regions, and 8 thalumus subregion )
clear;clc;close all

%% calculate rois we need
parent_sub_path='F:\广西医科大\TM_new\GS\result\topo\cohere';
parent_result_path='F:\广西医科大\TM_new\GS\result\topo\GStopo';
mkdir(parent_result_path)
cd(parent_result_path)
sub_path_A=fullfile(parent_sub_path,'CONTROL');
sub_path_B=fullfile(parent_sub_path,'TM');
mkdir(parent_result_path);
sub_file_A=dir(sub_path_A);sub_file_A(1:2)=[];
sub_file_B=dir(sub_path_B);sub_file_B(1:2)=[];

for i=1:length(sub_file_A)
    a_a=load(fullfile(sub_file_A(i).folder,sub_file_A(i).name));
    topo_HC(i,:,:)=a_a.gs_topo.C; %C
end

for i=1:length(sub_file_B)
    a_b=load(fullfile(sub_file_B(i).folder,sub_file_B(i).name));
    topo_SLE(i,:,:)=a_b.gs_topo.C; %C
end

for roi=1:246
    roi
    for fre=1:257
        [h,p,ci,stats]=ttest2(topo_HC(:,roi,fre),topo_SLE(:,roi,fre),0.05);
        P_result(roi,fre)=p;
        T_result(roi,fre)=stats.tstat;
        %         T_result(roi,fre)=stats.tstat.*(p<0.05/49);
    end
end
[P_result_fdr,T_result_fdr]=y_FDR(P_result,T_result);
clearvars -except T_result_fdr

nonZeroCount_Row = sum(T_result_fdr ~= 0, 2); % 计算每行的非零元素数量
totalCount_Row = size(T_result_fdr, 2); % 每行总元素数量
nonZeroRatio = nonZeroCount_Row / totalCount_Row;
resultRowIndices_Row = find(nonZeroRatio >= 0.1);  % 找到非零元素占比大于等于 10% 的行

nonZeroCount_Col = sum(T_result_fdr ~= 0, 1); % 计算每列的非零元素数量
resultColIndices_Col = find(nonZeroCount_Col >= 3);  

resultColIndices_Col_cell = {};  
startIdx = 1; % 用于储存每个连续段的起始索引  

for i = 2:length(resultColIndices_Col)  
    % 检查当前数字是否与前一个数字连续（差1）  
    if resultColIndices_Col(i) ~= resultColIndices_Col(i-1) + 1  
        % 如果不连续，保存当前段（从 startIdx 到 i-1）  
        resultColIndices_Col_cell{end+1} = [resultColIndices_Col(startIdx), resultColIndices_Col(i-1)];  
        startIdx = i; % 更新起始索引  
    end  
end  

% 处理最后一段  
resultColIndices_Col_cell{end+1} = [resultColIndices_Col(startIdx), resultColIndices_Col(end)];  


%%
save_path='F:\广西医科大\TM_new\GS\result\GCA';
mkdir(save_path)

TR=[2];
% Band=[0.001,0.05; 0.051,0.1; 0.101,0.15;0.151,0.2;0.201,0.25];
Band=[0.022,0.049; 0.074,0.096; 0.122,0.136;0.162,0.171;0.194,0.201];

region_label={27;47:48;59:60;207:208;1:246};
labels=["MFG","OrG","PrG","LOcC",'Globle'];

numsub=0;
subnum=1;
batch=[];

%%% step 1 - calculate rois
% load nii data

% parent_sub_path='F:\广西医科大\TM_new\GS\result\roi\TM';
parent_sub_path='F:\广西医科大\TM_new\GS\result\roi\CONTROL';
parent_sub_file= dir(parent_sub_path);
parent_sub_file(1:2)=[];


% 5 region
roi_pos=[];
for iroi = 1:5
    label_now=cell2mat(region_label(iroi));
    for i=1:length(parent_sub_file)
        sub_file=load(fullfile(parent_sub_path,parent_sub_file(i).name));
        brain=sub_file.roisignals;
        dim=size(brain);
        tp_num=dim(2);
        roi_pos(i,:)=mean(brain(label_now,:),1);
    end
    rois(iroi,:) = mean(roi_pos,1);
end

%%% step2 -Calculate gc
fs=1./TR;
fres  = 256;
freqs = sfreqs(fres,fs);  % Get frequency vector according to the sampling rate.

for iroi=1:5
    for jroi=1:5
        if iroi~=jroi
            % Estimate SS model order and model paramaters using CCA SS-SS algorithm
            try
                f=y_specGC(rois([iroi,jroi],:));
                SpecGC(iroi,jroi,:)=squeeze(f(1,2,:));   % GC{i,j} indicata from roi-j to roi-i
                %                         SpecGC(jroi,iroi,:,subnum)=f(2,1,:);
            catch
                SpecGC(iroi,jroi,:)=0;   % GC{i,j} indicata from roi-j to roi-i
                %                         SpecGC(jroi,iroi,:,subnum)=0;
            end
        end
    end
end

% diff band
for iband=1:5
    freLow=Band(iband,1);  freHigh=Band(iband,2);
    [~,freLowLabel]=min(abs(freqs-freLow));
    [~,freHighLabel]=min(abs(freqs-freHigh));
    %             SpecGC_band(:,:,iband,subnum)=mean(SpecGC(:,:,freLowLabel:freHighLabel),3);
    SpecGC_band(:,:,iband)=mean(SpecGC(:,:,freLowLabel:freHighLabel),3);
end

%% 
% 创建一个新的图形窗口  
figure;  
% 循环绘制每个切片  
% 定义标题  
% titles = {'0-0.05', '0.05-0.1', '0.1-0.15', '0.15-0.2','0.2-0.25'};  
titles = {'slow1', 'slow2', 'slow3', 'slow4','slow5'};  

% 循环绘制每个切片  
for i = 1:5  
    subplot(2, 3, i); % 创建2×2的子图布局  
    imagesc(SpecGC_band(:, :, i)); % 绘制第i个切片  
    colorbar; % 添加颜色条  
    caxis([0, 0.05]); 
    title(titles{i}); % 设置标题  
    axis equal tight; % 设置坐标轴等比例并紧凑排列  

    % 设置横纵坐标的刻度和标签  
    set(gca, 'XTick', 1:5, 'XTickLabel', labels); % 设置横轴刻度标签  
    set(gca, 'YTick', 1:5, 'YTickLabel', labels); % 设置
end  

cd(save_path)
save SpecGC_17.mat SpecGC_band  DemographicMat score