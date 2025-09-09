function plot_metrics(resultTable, save_path, ROI_range2)
% 绘制 PLV、PAC、Corr 和 P2F 的箱线图
% figure;

% 通用参数设置
boxColor = [0, 0.4470, 0.7410];     % 箱线颜色（蓝色）
scatterColor = [0.5, 0.5, 0.5];     % 散点颜色（灰色）
scatterAlpha = 0.4;                 % 散点透明度
jitterWidth = 0.15;                 % 散点抖动宽度
markerSize = 15;                    % 散点大小
fontSize = 12;                      % 坐标轴字体大小（稍大一些）
titleFontSize = 14;                 % 标题字体大小（稍大一些）

% 调整图像尺寸
set(gcf, 'Position', [100, 100, 1600, 1400]);  % 设置更大的图像尺寸

% 调整子图位置
subplotHeight = 0.35;               % 子图高度保持0.35不变
subplotWidth = 0.4;                 % 子图宽度从0.42减小到0.4

% 设置四周留白参数
leftMargin = 0.08;                  % 左侧留白8%
rightMargin = 0.04;                 % 右侧留白4%
horizontalGap = 0.06;               % 左右子图水平间距6%
verticalGap = 0.12;                 % 上下子图垂直间距8%
% 计算垂直布局参数
bottomRowY = 0.08;                  % 下排子图底部位置
topRowY = bottomRowY + subplotHeight + verticalGap;

% 1. 绘制 PLV
subplot('Position', [leftMargin, topRowY, subplotWidth, subplotHeight]);
boxplot(resultTable.PLV, resultTable.fre_range,...
    'Colors', boxColor,...
    'Symbol', '',...               % 不显示异常值
    'Widths', 0.6);

% 美化中位线
h = findobj(gca, 'Tag', 'Median');
set(h, {'Color'}, {[1,0,0]}, {'LineWidth'}, {1.5}); % 红色中位线

% 设置标签和标题
set(gca, 'FontSize', fontSize);
xtickangle(45);
title('PLV Distribution', 'FontSize', titleFontSize, 'FontWeight', 'normal')
ylabel('PLV Value', 'FontSize', fontSize)
% ylim([0.05, 0.75]); % 设置 y 轴范围
% ylim([min(resultTable.PLV) - 0.1 * range(resultTable.PLV),...
%     max(resultTable.PLV) + 0.1 * range(resultTable.PLV)]);
grid on
box on

% 2. 绘制 PAC
subplot('Position', [leftMargin + subplotWidth + horizontalGap, topRowY, subplotWidth, subplotHeight]);
boxplot(resultTable.PAC, resultTable.fre_range,...
    'Colors', boxColor,...
    'Symbol', '',...               % 不显示异常值
    'Widths', 0.6);
% 美化中位线
h = findobj(gca, 'Tag', 'Median');
set(h, {'Color'}, {[1,0,0]}, {'LineWidth'}, {1.5}); % 红色中位线

% 设置标签和标题
set(gca, 'FontSize', fontSize);
xtickangle(45);
title('PAC Distribution', 'FontSize', titleFontSize, 'FontWeight', 'normal')
ylabel('PAC Value', 'FontSize', fontSize)
% ylim([0.05, 0.15]); % 设置 y 轴范围
% ylim([min(resultTable.PAC) - 0.1 * range(resultTable.PAC),...
%     max(resultTable.PAC) + 0.1 * range(resultTable.PAC)]);
grid on
box on

% 3. 绘制 Corr
subplot('Position', [leftMargin, bottomRowY, subplotWidth, subplotHeight]);
boxplot(resultTable.Corr, resultTable.fre_range,...
    'Colors', boxColor,...
    'Symbol', '',...               % 不显示异常值
    'Widths', 0.6);
% 美化中位线
h = findobj(gca, 'Tag', 'Median');
set(h, {'Color'}, {[1,0,0]}, {'LineWidth'}, {1.5}); % 红色中位线

% 设置标签和标题
set(gca, 'FontSize', fontSize);
xtickangle(45);
title('Corr Distribution', 'FontSize', titleFontSize, 'FontWeight', 'normal')
ylabel('Corr Value', 'FontSize', fontSize)
% ylim([0.05, 0.7]); % 设置 y 轴范围
% ylim([min(resultTable.Corr) - 0.1 * range(resultTable.Corr),...
%     max(resultTable.Corr) + 0.1 * range(resultTable.Corr)]);
grid on
box on

% 4. 绘制 P2F
subplot('Position', [leftMargin + subplotWidth + horizontalGap, bottomRowY, subplotWidth, subplotHeight]);
boxplot(resultTable.P2F_MI, resultTable.fre_range,...
    'Colors', boxColor,...
    'Symbol', '',...               % 不显示异常值
    'Widths', 0.6);
% 美化中位线
h = findobj(gca, 'Tag', 'Median');
set(h, {'Color'}, {[1,0,0]}, {'LineWidth'}, {1.5}); % 红色中位线

% 设置标签和标题
set(gca, 'FontSize', fontSize);
xtickangle(45);
title('P2F Distribution', 'FontSize', titleFontSize, 'FontWeight', 'normal')
ylabel('P2F Value', 'FontSize', fontSize)
% ylim([0.04, 0.2]); % 设置 y 轴范围
% ylim([min(resultTable.P2F_MI) - 0.1 * range(resultTable.P2F_MI),...
%     max(resultTable.P2F_MI) + 0.1 * range(resultTable.P2F_MI)]);
grid on
box on

% 保存图像（更高分辨率和更大尺寸）
filename = fullfile(save_path, [ROI_range2 '_combined.png']);
exportgraphics(gcf, filename, 'Resolution', 600);  % 保存高分辨率图像

% 关闭图形
close(gcf);
end