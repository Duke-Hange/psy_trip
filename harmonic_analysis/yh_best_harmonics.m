function y=yh_best_harmonics(signal, window, noverlap, NFFT, Fs,f0,num_harmonics)
% % 参数设置（示例值，需根据实际信号调整）
% Fs = 300;          % 采样频率
% f0 = 13;             % 基频（2Hz）
% window = hann(300);% 汉宁窗（长度1024）
% noverlap = 150;     % 50%重叠
% NFFT = 600;        % FFT点数
% num_harmonics = 3;  % 提取前3强谐波

num_channels = size(signal,1);  % 通道数


% 初始化结果存储
% results = cell(num_channels, 1); % 每个通道的结果存储在 cell 中
results=[];

% 遍历每个通道
for ch = 1:num_channels
    ch
    % 提取当前通道信号
    signal1 = signal(ch,:);

    % 使用 pwelch 计算功率谱密度
    [Pxx, f] = pwelch(signal1, window, noverlap, NFFT, Fs);

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

    % 提取前3强谐波
    [sorted_power, sorted_idx] = sort(harmonic_power, 'descend');
    top3_idx = sorted_idx(1:num_harmonics);
    top3_harmonics = harmonics(top3_idx); % 谐波次数
    top3_power = sorted_power(1:num_harmonics); % 谐波功率

    % 保存结果
    %     results{ch} = [top3_harmonics; top3_power]; % 存储谐波次数和功率
    results(ch,1:num_harmonics) = top3_harmonics; % 存储谐波次数和功率
end

y=unique(results)*f0;

