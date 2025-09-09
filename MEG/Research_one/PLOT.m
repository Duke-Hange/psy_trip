clear
save_path = 'D:\MEG数据\result\2';
cd(save_path)

% 获取所有结果文件
file_list = dir(fullfile(save_path, '*_combined.mat'));
all_roi_ranges = cellfun(@(x) strrep(x, '_combined.mat', ''), {file_list.name}, 'UniformOutput', false);

% 收集所有唯一的fre_range和ROI_range
unique_roi = unique(all_roi_ranges);
all_fre_ranges = cell(0);

% 预遍历以收集所有频率范围
for i = 1:length(file_list)
    data = load(fullfile(save_path, file_list(i).name), 'resultTable');
    all_fre_ranges = union(all_fre_ranges, unique(data.resultTable.fre_range));
end
unique_fre = all_fre_ranges;
new_order = [4, 6, 5, 3, 12, 10, 11, 8, 9, 1, 2, 7];  
unique_fre2 = unique_fre(new_order);  

% 初始化PLV矩阵（NaN占位）
plv_matrix = nan(length(unique_fre2), length(unique_roi));

% 填充矩阵数据
for i = 1:length(file_list)
    file_name = file_list(i).name;
    roi_range = strrep(file_name, '_combined.mat', '');
    roi_idx = find(strcmp(unique_roi, roi_range));
    
    data = load(fullfile(save_path, file_name), 'resultTable');
    resultTable = data.resultTable;
    
    for f = 1:length(unique_fre2)
        fre = unique_fre2{f};
        fre_mask = strcmp(resultTable.fre_range, fre);
        if any(fre_mask)
            avg_plv = mean(resultTable.PLV ...
                (fre_mask));
            plv_matrix(f, roi_idx) = avg_plv;
        end
    end
end

% 绘制拓扑图（热图）
figure;
h = heatmap(unique_roi, unique_fre2, plv_matrix, ...
    'Colormap', parula, ...
    'ColorLimits', [min(plv_matrix(:)) max(plv_matrix(:))], ...
    'CellLabelColor', 'none'); % 隐藏数值标签，若需显示可移除

title('PLV Topography across ROI and Frequency Ranges');
xlabel('ROI Range');
ylabel('Frequency Range');
colorbar;

% 调整坐标标签旋转（防止重叠）
set(gca, 'FontSize', 10);
h.XDisplayLabels = strrep(h.XDisplayData, '_', '-'); % 替换下划线
h.YDisplayLabels = strrep(h.YDisplayData, '_', '-');


%%
clear
save_path = 'D:\MEG数据\result\1';

% 获取所有结果文件
file_list = dir(fullfile(save_path, '*_combined.mat'));
all_roi_ranges = cellfun(@(x) strrep(x, '_combined.mat', ''), {file_list.name}, 'UniformOutput', false);

% 收集所有唯一的fre_range和ROI_range
unique_roi = unique(all_roi_ranges);
all_fre_ranges = cell(0);

% 预遍历以收集所有频率范围
for i = 1:length(file_list)
    data = load(fullfile(save_path, file_list(i).name), 'resultTable');
    all_fre_ranges = union(all_fre_ranges, unique(data.resultTable.fre_range));
end
unique_fre = all_fre_ranges;
new_order = [4, 6, 5, 3, 12, 10, 11, 8, 9, 1, 2, 7];  
unique_fre2 = unique_fre(new_order);  


remove_indices = [10, 20, 30, 40, 50, 60, 70, 80, 90:100];
keep_mask = true(1, length(unique_roi)); % 初始化为全 true
keep_mask(remove_indices) = false; % 将需要删除的列标记为 false
unique_roi2 = unique_roi(keep_mask);

% 初始化PLV矩阵（NaN占位）
plv_matrix = nan(length(unique_fre2), length(unique_roi2));

% 填充矩阵数据
for i = 1:length(file_list)
    file_name = file_list(i).name;
    roi_range = strrep(file_name, '_combined.mat', '');
    roi_idx = find(strcmp(unique_roi2, roi_range));
    
    data = load(fullfile(save_path, file_name), 'resultTable');
    resultTable = data.resultTable;
    
    for f = 1:length(unique_fre2)
        fre = unique_fre2{f};
        fre_mask = strcmp(resultTable.fre_range, fre);
        if any(fre_mask)
            avg_plv = mean(resultTable.PLV(fre_mask));
            plv_matrix(f, roi_idx) = avg_plv;
        end
    end
end

% % 对每一行进行Z-score标准化（忽略NaN）
plv_matrix_z = zeros(size(plv_matrix));
for i_row = 1:size(plv_matrix, 1)
    row_data = plv_matrix(i_row, :);
    mu = nanmean(row_data);      % 忽略NaN计算均值
    sigma = nanstd(row_data);    % 忽略NaN计算标准差
    if sigma == 0
        plv_matrix_z(i_row, :) = 0;  % 若标准差为0，设为0避免除以0
    else
        plv_matrix_z(i_row, :) = (row_data - mu) / sigma;
    end
end

% mu = nanmean(plv_matrix(:));      % 计算整个矩阵的均值（忽略NaN）
% sigma = nanstd(plv_matrix(:));    % 计算整个矩阵的标准差（忽略NaN）
% 
% if sigma == 0
%     plv_matrix_z = zeros(size(plv_matrix));  % 若标准差为0，设为0避免除以0
% else
%     plv_matrix_z = (plv_matrix - mu) / sigma; % 对整个矩阵进行标准化
% end

% 绘制标准化后的拓扑图
figure;
h = heatmap(unique_roi2, unique_fre2, plv_matrix_z, ...
    'Colormap', parula, ...
    'ColorLimits', [-3, 3], ... % 固定颜色范围适应Z-score
    'CellLabelColor', 'none');

title('Normalized PLV Topography (Z-score by Frequency)');
xlabel('ROI Range');
ylabel('Frequency Range');
colorbar;

% 调整坐标标签
h.XDisplayLabels = strrep(h.XDisplayData, '_', '-');
h.YDisplayLabels = strrep(h.YDisplayData, '_', '-');