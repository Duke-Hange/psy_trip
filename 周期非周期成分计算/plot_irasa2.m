function plot_irasa(freq, mixd, frac, osci, varargin)
% 增强版IRASA可视化 - 专业科研级图表
% 输入：
%   freq : 频率向量
%   mixd : 混合功率谱
%   frac : 分形成分
%   osci : 振荡成分
% 可选参数：
%   'logplot' : 是否使用对数坐标 (默认=true)
%   'title'   : 图表标题
%   'showfit' : 是否显示幂律拟合 (默认=true)

% 解析可选参数
p = inputParser;
addParameter(p, 'logplot', true, @islogical);
addParameter(p, 'title', 'IRASA频谱分解', @ischar);
addParameter(p, 'showfit', true, @islogical);
parse(p, varargin{:});

% 创建专业科研图表
figure('Position', [100, 100, 900, 700], 'Color', 'w');
set(gcf, 'DefaultAxesFontSize', 12, 'DefaultAxesFontName', 'Arial');

% 主频谱图
subplot(3,1,[1,2]);
hold on;

% 绘制频谱曲线
h_mixd = plot(freq, mixd, 'Color', [0, 0.45, 0.74], 'LineWidth', 2.5, 'DisplayName', '混合频谱');
h_frac = plot(freq, frac, 'Color', [0.85, 0.33, 0.1], 'LineWidth', 2.5, 'DisplayName', '分形成分');
h_osci = plot(freq, osci, 'Color', [0.49, 0.18, 0.56], 'LineWidth', 2.5, 'DisplayName', '振荡成分');

% 添加填充区域
fill_x = [freq; flipud(freq)];
fill_y = [frac; mixd];
fill(fill_x, fill_y, [0.93, 0.69, 0.13], 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'DisplayName', '振荡区域');

% 添加幂律拟合（如果启用）
if p.Results.showfit
    % 幂律拟合：log(P) = β*log(f) + c
    logf = log10(freq(freq > 1)); % 避免log(0)
    logP = log10(frac(freq > 1));
    coeffs = polyfit(logf, logP, 1);
    beta = -coeffs(1); % 负斜率
    fit_line = 10.^(coeffs(2) * freq.^(coeffs(1)));
    
    % 绘制拟合线
    plot(freq, fit_line, '--', 'Color', [0.64, 0.08, 0.18], 'LineWidth', 2, ...
        'DisplayName', sprintf('幂律拟合 (β=%.2f)', beta));
end

% 设置坐标轴
if p.Results.logplot
    set(gca, 'XScale', 'log', 'YScale', 'log');
end

% 专业格式设置
grid on;
box on;
set(gca, 'Layer', 'top', 'GridLineStyle', ':', 'LineWidth', 1.2);
xlabel('频率 (Hz)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('功率', 'FontSize', 14, 'FontWeight', 'bold');
title(p.Results.title, 'FontSize', 16, 'FontWeight', 'bold');

% 添加专业图例
% legend('Location', 'southwest', 'Box', 'off', 'FontSize', 12);

% 添加科学标注
text(0.02, 0.95, sprintf('最大振荡功率: %.2f Hz', freq(osci == max(osci))), ...
    'Units', 'normalized', 'FontSize', 12, 'BackgroundColor', [1, 1, 1, 0.7]);

% 振荡成分频谱分析
subplot(3,1,3);
hold on;

% 计算带通滤波后的振荡成分
[b, a] = butter(4, [2, 45]/(srate/2), 'bandpass');
osci_filt = filtfilt(b, a, osci);

% 绘制振荡频谱
plot(freq, osci_filt, 'Color', [0.49, 0.18, 0.56], 'LineWidth', 2);

% 标注峰值
[peaks, locs] = findpeaks(osci_filt, 'MinPeakProminence', max(osci_filt)/10);
for i = 1:min(3, length(peaks)) % 最多标注3个主要峰值
    plot(freq(locs(i)), peaks(i), 'v', 'MarkerSize', 10, ...
        'MarkerFaceColor', [0.93, 0.69, 0.13], 'MarkerEdgeColor', 'k');
    text(freq(locs(i)), peaks(i)*1.15, sprintf('%.1f Hz', freq(locs(i))), ...
        'FontSize', 11, 'HorizontalAlignment', 'center');
end

% 设置坐标轴
xlim([1, 50]);
grid on;
box on;
set(gca, 'Layer', 'top', 'GridLineStyle', ':', 'LineWidth', 1.2);
xlabel('频率 (Hz)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('振荡功率', 'FontSize', 14, 'FontWeight', 'bold');
title('振荡成分频谱分析', 'FontSize', 14, 'FontWeight', 'bold');

% 添加统一注释
annotation('textbox', [0.01, 0.01, 0.4, 0.03], 'String', ...
    sprintf('IRASA分析 | 采样率: %d Hz | 频率范围: %.1f-%.1f Hz', srate, min(freq), max(freq)), ...
    'FitBoxToText', 'on', 'EdgeColor', 'none', 'FontSize', 10);
end