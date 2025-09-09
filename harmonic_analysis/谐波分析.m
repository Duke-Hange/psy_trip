% 参数设置（示例值，需根据实际信号调整）
Fs = 300;          % 采样频率
f0 = 1.5;             % 基频（2Hz）
window = hann(300);% 汉宁窗（长度1024）
noverlap = 150;     % 50%重叠
NFFT = 600;        % FFT点数

% 假设 signal_1 是输入信号
% 使用 pwelch 计算功率谱密度
[Pxx, f] = pwelch(signal_1, window, noverlap, NFFT, Fs);

% 确定最大谐波次数（不超过奈奎斯特频率）
k_max = floor((Fs/2) / f0);
harmonics = 1:k_max; % 包括基频（k=1）

% 计算频率分辨率（单位：Hz/点）
df = f(2) - f(1); 

% 分析各次谐波功率
harmonic_power = zeros(size(harmonics));
n = round(1 / df); % 搜索范围：±1Hz内的点

for i = 1:length(harmonics)
    k = harmonics(i);
    target_freq = k * f0;
    % 找到目标频率附近的索引
    [~, idx] = min(abs(f - target_freq));
    % 确定搜索范围（防止越界）
    start_idx = max(1, idx - n);
    end_idx = min(length(f), idx + n);
    % 提取附近的最大功率
    harmonic_power(i) = max(Pxx(start_idx:end_idx));
end

% 忽略基频（若只需分析谐波，从k=2开始）
harmonic_power(1) = 0; 

% 确定最大影响谐波
[max_power, max_idx] = max(harmonic_power);
max_harmonic = harmonics(max_idx);

% 显示结果
disp(['最大影响的谐波是第', num2str(max_harmonic), '次，频率为', ...
    num2str(max_harmonic*f0), 'Hz，功率为', num2str(max_power)]);