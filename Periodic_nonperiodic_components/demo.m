% IRASA工具箱使用示例
clear; clc;
 
% 1. 生成测试信号
srate = 1000;           % 采样率
t = 0:1/srate:10;       % 10秒时长
fractal_component = pinknoise(length(t));  % 分形成分
osc_component = 0.5 * sin(2*pi*10*t) + 0.3 * sin(2*pi*20*t); % 振荡成分
signal = fractal_component + osc_component; % 混合信号

% 2. 运行IRASA
[freq, mixd, frac, osci] = yh_irasa(signal, srate, 'frange', [1 45]);

% 3. 可视化结果
plot_irasa(freq, mixd, frac, osci);

% 辅助函数：生成粉红噪声
function y = pinknoise(n)
    % 生成粉红噪声 (1/f噪声)
    x = randn(1, n);
    x_fft = fft(x);
    n_over2 = floor(n/2);
    magnitudes = [0, 1./(1:n_over2), 1./(n_over2:-1:1)];
    y = real(ifft(x_fft .* magnitudes));
    y = y - mean(y);
end