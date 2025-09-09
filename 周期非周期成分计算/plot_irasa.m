function plot_irasa(freq, mixd, frac, osci)
% 绘制IRASA频谱分析结果
% 参数：
%   freq : 频率向量
%   mixd : 混合功率谱
%   frac : 分形成分
%   osci : 振荡成分

% 创建图形窗口
figure('Position', [100, 100, 900, 700], 'Color', 'w', 'Name', 'IRASA频谱分析');
set(gcf, 'DefaultAxesFontSize', 12, 'DefaultTextFontSize', 14);

% ========================= 对数坐标图 =========================
ax1 = subplot(2,1,1);
hold on;

% 绘制频谱曲线
h1 = plot(freq, mixd, 'b-', 'LineWidth', 2, 'DisplayName', '混合功率谱');
h2 = plot(freq, frac, 'r-', 'LineWidth', 2, 'DisplayName', '分形成分');
h3 = plot(freq, osci, 'g-', 'LineWidth', 2, 'DisplayName', '振荡成分');

% 设置坐标轴和标签
set(ax1, 'XScale', 'log', 'YScale', 'log');
xlabel('频率 (Hz)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('功率谱密度', 'FontSize', 12, 'FontWeight', 'bold');
title('IRASA频谱分析 (对数坐标)', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
box on;

% 设置坐标轴范围
xlim([min(freq) max(freq)]);
ylim_vals = [mixd; frac; osci];
ylim([max(1e-10, min(ylim_vals))*0.8, max(ylim_vals)*1.2]);

% 添加图例 (修正版本)
leg1 = legend([h1, h2, h3], 'Location', 'southwest');
set(leg1, 'FontSize', 10, 'Box', 'off');

% ========================= 线性坐标图 =========================
ax2 = subplot(2,1,2);
hold on;

% 绘制频谱曲线
plot(freq, mixd, 'b-', 'LineWidth', 2);
plot(freq, frac, 'r-', 'LineWidth', 2);
h_osci = plot(freq, osci, 'g-', 'LineWidth', 2);

% 设置坐标轴和标签
xlabel('频率 (Hz)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('功率谱密度', 'FontSize', 12, 'FontWeight', 'bold');
title('IRASA频谱分析 (线性坐标)', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
box on;

% 设置坐标轴范围
xlim([min(freq) max(freq)]);
ylim([0 max([mixd; frac; osci])*1.1]);

% 添加振荡成分填充
yyaxis right;
pos_osci = max(osci, 0);  % 确保非负值
fill([freq; flipud(freq)], [pos_osci; zeros(size(pos_osci))], ...
     [0.2 0.8 0.2], 'FaceAlpha', 0.15, 'EdgeColor', 'none');
ylabel('振荡成分功率', 'FontSize', 10);
set(gca, 'YColor', [0.2 0.6 0.2]);

% 添加图例 (修正版本)
leg2 = legend('混合功率谱', '分形成分', '振荡成分', 'Location', 'northeast');
set(leg2, 'FontSize', 10, 'Box', 'off');

% 统一坐标轴样式
set([ax1, ax2], 'LineWidth', 1.5, 'TickDir', 'out', ...
    'XMinorTick', 'on', 'YMinorTick', 'on');

% 优化布局
linkaxes([ax1, ax2], 'x');
set(gcf, 'Color', 'w');
end