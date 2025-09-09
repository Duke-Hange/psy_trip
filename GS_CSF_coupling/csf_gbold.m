%% 第一步 预处理


%% 第二步 提取GS
clear
path_data='F:\教学数据\dpabi';
gs_path = dir(fullfile(path_data, '*ARCW'));   %%需要改，ARCWS
out_path = fullfile(path_data,'GS');
mkdir(out_path)
% mask_path = 'D:\yuhang\ADHD-GS计算\data\MASK\BN_Atlas_246_3mm';
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

%% 第三步 提取CSF
CSF_mask_path = dir(fullfile(path_data,'Masks','Segment*'));
CSF_mask_file=dir(fullfile(CSF_mask_path.folder,CSF_mask_path.name));
CSF_mask_file(1:2)=[];
CSF_mask_file = dir(fullfile(CSF_mask_path.folder,CSF_mask_path.name,'*ThrdMask_sub*CSF*'));

CSF_Funpath = dir(fullfile(path_data, '*ARC'));    %%  ARC  
CSF_Funfile=dir(fullfile(CSF_Funpath.folder,CSF_Funpath.name));
CSF_Funfile(1:2)=[];

out_path = fullfile(path_data,'CSF');
mkdir(out_path)

for sub= 1:length(CSF_mask_file)
    [CBF_mask,~]=y_Read(fullfile(CSF_mask_file(sub).folder,CSF_mask_file(sub).name));

    CSF_Fundata=dir(fullfile(CSF_Funfile(sub).folder,CSF_Funfile(sub).name,'*.nii'));
    [Fundata,~]=y_Read(fullfile(CSF_Fundata(1).folder,CSF_Fundata(1).name));

    has_value = squeeze(any(any(CBF_mask, 1), 2)); % 检查每个z层是否存在1
    start_z = find(has_value, 1, 'first');     % 找到第一个出现1的z层索引
    disp(['第一个出现有值区域的z轴平面是：', num2str(start_z)]);

    mask_slice = CBF_mask(:, :, start_z);
    se = strel('disk', 2);
    closed_slice = imclose(mask_slice, se);
    mask_new = zeros(size(CBF_mask));
    if start_z>=2
        mask_new(:, :, start_z-1) = closed_slice;  % 仅保留目标层  %%
    else
        mask_new(:, :, 1) = closed_slice;  % 仅保留目标层  %%
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

%% 第四步 计算互相关
clear

% 参数设置
TR = 2; % 重复时间（秒）
max_hrf_delay = 10; % 最大预期HRF延迟（秒）
max_lag = ceil(max_hrf_delay/TR); % 转换为lag单位

% 计算GS负导数（强调GS变化率）使用中心差分保持时间对齐
gs_deriv = -gradient(gs); 

% 标准化
gs_z = zscore(gs_deriv);
CSF_z = zscore(CSF);

figure
plot(gs_z,'r')
hold on
plot(CSF_z,'b')

%% 计算互相关（限定生理合理范围）

[xc, lags] = xcorr(CSF_z, gs_z, max_lag, 'coeff'); % 注意输入顺序 先CSF 
lags_time = lags * TR; % 转换为时间单位

% 提取正向时延（CSF滞后于GS的情况）
pos_lags = lags >= 0;
xc_pos = xc(pos_lags);
lags_pos = lags_time(pos_lags);

% 找到最大反相关点（最小值）
[min_val, min_idx] = min(xc_pos);
optimal_lag = lags_pos(min_idx);

%% 置换检验（考虑时间依赖性）
num_perm = 5000;
null_dist = zeros(num_perm, 1);
block_size = 10; % 与低频信号周期匹配

for i = 1:num_perm
    % 块置换保持时间结构
    N = length(CSF_z);
    num_blocks = floor(N / block_size);
    blocks = reshape(CSF_z(1:block_size*num_blocks), block_size, []);
    shuffled_blocks = blocks(:, randperm(num_blocks));
    permuted_csf = [shuffled_blocks(:); CSF_z(block_size*num_blocks+1:end)];
    % 计算互相关
    [xc_shuff, ~] = xcorr(permuted_csf, gs_z, max_lag, 'coeff');
    xc_shuff_pos = xc_shuff(pos_lags);

    % 记录极值
    null_dist(i) = min(xc_shuff_pos);
end


%% 统计评估
% 计算p值（带连续性校正）
p_val = (sum(null_dist <= min_val) + 1) / (num_perm + 1);

% 置信区间
ci = prctile(null_dist, [2.5 97.5]);

%% 可视化
figure('Position', [100 100 800 400]);

% 互相关曲线
subplot(1,2,1);
plot(lags_pos, xc_pos, 'LineWidth', 1.5);
hold on;
plot(optimal_lag, min_val, 'ro', 'MarkerSize', 8);
xline(0, '--k', 'LineWidth', 1);
xlabel('CSF延迟时间 (秒)');
ylabel('归一化互相关');
title(sprintf('最优延迟: %.1f秒 (p=%.4f)', optimal_lag, p_val));
grid on;

% Null分布
subplot(1,2,2);
histogram(null_dist, 'Normalization', 'pdf', 'BinWidth', 0.02);
hold on;
xline(min_val, 'r', 'LineWidth', 2);
xline(ci(1), '--k'); xline(ci(2), '--k');
xlabel('最小互相关值');
ylabel('概率密度');
legend('Null分布', '观测值', '95% CI');
title('置换检验结果');
grid on;

