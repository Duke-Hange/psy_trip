function [sourcemodel_aal, sourcemodel_aal2, data_AAL] = yh_meg4_ve2(source, data_clean, mri_csr2n, brainnetome, varargin)
% YH_MEG4_VE: 将脑网络模板插值到源模型，并提取 ROI 虚拟通道信号（支持多种聚合方法）
%
% 输入参数:
%   source:          源模型（带 pos/dim 等字段）
%   data_clean:      预处理后的传感器数据（FieldTrip 格式）
%   mri_csr2n:       MRI 结构（用于插值的参考空间）
%   brainnetome:     Brainnetome/AAL 模板文件路径或已加载的模板结构
%   varargin:        可选参数（键值对）
%
% 可选参数:
%   'aggregation_method': ROI 信号聚合方法，支持以下选项：
%                        - 'mean' (默认)
%                        - 'weighted_mean_corr'
%                        - 'pca'
%                        - 'max'
%                        - 'hub'
%                        - 'temporal_cluster'
%                        - 'spatial_pattern'
%   'filters':       自定义滤波器矩阵（覆盖源模型中的滤波器）

% 解析输入参数
p = inputParser;
addParameter(p, 'aggregation_method', 'mean', @ischar);
addParameter(p, 'filters', [], @isnumeric);
parse(p, varargin{:});

% 加载模板
brainnetome = ft_read_atlas(brainnetome);

% 插值模板到 MRI 空间和源模型
cfg = [];
cfg.interpmethod = 'nearest';
cfg.parameter = 'tissue';
sourcemodel_aal2 = ft_sourceinterpolate(cfg, brainnetome, mri_csr2n);
sourcemodel_aal = ft_sourceinterpolate(cfg, brainnetome, source);

% 初始化 data_roi 结构
data_roi = struct();
data_roi.label = brainnetome.tissuelabel;
data_roi.fsample = data_clean.fsample;
data_roi.time = data_clean.time;
data_roi.trial = cell(1, length(data_clean.trial));

% 提取滤波器（优先使用用户提供的 filters）
if isempty(p.Results.filters)
    all_filters = cat(1, source.avg.filter{source.inside});
else
    all_filters = p.Results.filters;
end

% 对每个 ROI 处理信号
num_rois = length(sourcemodel_aal.tissuelabel);
roi_signals = zeros(num_rois, size(data_clean.trial{1}, 2));

for roi_id = 1:num_rois
    mask = (sourcemodel_aal.tissue == roi_id);
    if ~any(mask)
        roi_signals(roi_id, :) = 0;
        continue;
    end

    % 提取当前 ROI 的滤波器
    roi_filters = all_filters(mask(source.inside), :);
    if isempty(roi_filters)
        roi_signals(roi_id, :) = 0;
        continue;
    end

    % 根据聚合方法计算信号
    projected = roi_filters * data_clean.trial{1};

    switch p.Results.aggregation_method
        case 'mean'
            roi_signals(roi_id, :) = mean(projected, 1);

        case 'weighted_mean_corr'
            n_voxels = size(projected, 1);

            if n_voxels == 0
                roi_signals(roi_id, :) = 0;
                continue;
            elseif n_voxels == 1
                roi_signals(roi_id, :) = projected;
                continue;
            end

            corr_matrix = corrcoef(projected'); % 体素 x 体素
            abs_corr = abs(corr_matrix);        % 取绝对值
            % abs_corr(abs_corr < 0.3) = 0; % 过滤弱连接
            abs_corr = abs_corr - diag(diag(abs_corr));

            strength = sum(abs_corr, 2);

            total_strength = sum(strength);
            if total_strength == 0
                weights = ones(n_voxels, 1) / n_voxels; % 退化为平均
            else
                weights = strength / total_strength;     % 归一化权重
            end

            roi_signals(roi_id, :) = sum(projected .* weights, 1); % 加权求和

        case 'pca'
            [~, score, ~] = pca(projected');
            roi_signals(roi_id, :) = score(:, 1)';

        case 'temporal_cluster'  % 改进的时间聚类
            % 数据标准化
            projected_z = zscore(projected, 0, 2);

            % 增加聚类鲁棒性参数
            opts = statset('MaxIter', 200, 'Display', 'off');
            [~, centroids] = kmeans(projected_z', 1, 'Options', opts, 'Replicates', 5);
            roi_signals(roi_id, :) = centroids';

        otherwise
            error('Unknown aggregation method: %s', p.Results.aggregation_method);
    end
end

% 填充 data_roi 并转换为 data_AAL
data_roi.trial{1} = roi_signals;
data_AAL = data_roi;
end