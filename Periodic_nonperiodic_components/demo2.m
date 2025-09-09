% 生成测试信号
fs = 1000;
t = 0:1/fs:10;
x = pinknoise(length(t)) + 2*sin(2*pi*10*t) + 1.5*sin(2*pi*25*t);

% 运行IRASA
[freq, mixd, frac, osci] = yh_irasa(x, fs, 'frange', [1 45]);

% 专业可视化
plot_irasa2(freq, mixd, frac, osci, ...
    'title', '测试信号IRASA分析', ...
    'showfit', true, ...
    'logplot', true);

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