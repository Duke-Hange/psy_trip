
function   [sourcemodel_aal,sourcemodel_aal2,data_AAL] =yh_meg4_ve(source,data_clean,mri_csr2n,brainnetome)

brainnetome = ft_read_atlas (brainnetome);

cfg = [];
% cfg.voxelcoord   = 'no';
cfg.interpmethod = 'nearest';
cfg.parameter = 'tissue';
% cfg.parameter    = 'avg.pow';
sourcemodel_aal2 = ft_sourceinterpolate(cfg, brainnetome, mri_csr2n);

cfg = [];
% cfg.voxelcoord   = 'no';
cfg.interpmethod = 'nearest';
cfg.parameter = 'tissue';
% cfg.parameter    = 'avg.pow';
sourcemodel_aal = ft_sourceinterpolate(cfg, brainnetome, source);

% 初始化data_roi结构
data_roi = [];
data_roi.label = brainnetome.tissuelabel; % 直接使用模板标签
data_roi.fsample = data_clean.fsample;
data_roi.time = data_clean.time;
data_roi.trial = cell(1, length(data_clean.trial));

% 预处理：提取所有体点对应的滤波器
all_filters = cat(1, source.avg.filter{source.inside});

% 对每个ROI进行处理
num_rois = length(sourcemodel_aal.tissuelabel);
roi_signals = zeros(num_rois, size(data_clean.trial{1},2)); % 预分配

for roi_id = 1:num_rois
    roi_id
    mask = (sourcemodel_aal.tissue == roi_id);
    if ~any(mask)
        roi_signals(roi_id, :) = 0;
        continue;
    end
    % 提取该ROI内的滤波器
    roi_filters = all_filters(mask(source.inside), :);
    if isempty(roi_filters)
        roi_signals(roi_id, :) = 0;
        continue;
    end
    % 计算PCA主成分  %% 需要优化
    projected = roi_filters * data_clean.trial{1};
    [coeff, score, latent]  = pca(projected');
    explained(roi_id,1) = max(latent / sum(latent) * 100); 
    roi_signals(roi_id, :) = score(:,1)';
end

data_roi.trial{1} = roi_signals;

% data reshape
data_AAL = cell2mat(data_roi.trial);

end