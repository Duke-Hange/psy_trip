function pac = yh_phase2power_coupling(signal_low, signal_high, method, window, noverlap)
% 输入参数：
%   signal_low: 低频相位信号（列向量）
%   signal_high: 高频幅度信号（列向量）
%   method: 方法选择，'direct' 或 'windowed'
%   window_len: 窗口长度（仅用于 'windowed' 方法，默认值为低频信号的两个周期）
%   step: 滑动步长（仅用于 'windowed' 方法，默认值为窗口长度的一半）
% 输出：
%   pac: 相位-幅度耦合指数（直接法返回MI，滑窗法返回筛选后的均值）

n = length(signal_low);
if n ~= length(signal_high)
    error('输入信号长度必须相同');
end

% 默认方法为 'direct'
if nargin < 3 || isempty(method)
    method = 'direct';
end

% 根据方法选择计算PAC
if strcmpi(method, 'direct')
    % 直接计算全局PAC
    phase_low = angle(hilbert(signal_low));
    amp_high = abs(hilbert(signal_high));
    pac = compute_mi(phase_low, amp_high);
    
elseif strcmpi(method, 'windowed')
    % 滑动窗口方法
    % 设置默认窗口长度和步长
    if nargin < 4 || isempty(window)
        window = floor(n / 10);
    end
    if nargin < 5 || isempty(noverlap)
        noverlap = floor(window / 2);
    end

    % 参数有效性检查
    window = max(1, min(window, n));
    noverlap = max(1, noverlap);
    
    % 计算窗口数量
    num_windows = floor((n - window)/noverlap) + 1;
    mis = zeros(num_windows, 1);
    
    % 滑动窗口计算PAC
    for k = 1:num_windows
        range = (k-1)*noverlap + 1 : (k-1)*noverlap + window;
        phase_win = angle(hilbert(signal_low(range)));
        amp_win = abs(hilbert(signal_high(range)));
        mis(k) = compute_mi(phase_win, amp_win);
    end
    
    % 筛选高耦合窗口（前50%）
    sorted_mi = sort(mis, 'descend');
    keep_num = ceil(num_windows/2);
    pac = mean(sorted_mi(1:keep_num));
    
else
    error('未知方法，请选择 ''direct'' 或 ''windowed''');
end

end

%% 子函数：计算调制指数
function MI = compute_mi(phase, amp)
% 动态分箱策略
valid_length = numel(phase);
n_bins = max(10, min(36, round(valid_length/50))); % 确保至少10个bin

% 相位分箱统计
phase_bins = linspace(-pi, pi, n_bins+1);
mean_amp = zeros(1, n_bins);

for bin = 1:n_bins
    if bin == n_bins
        idx = (phase >= phase_bins(bin)) & (phase <= phase_bins(bin+1));
    else
        idx = (phase >= phase_bins(bin)) & (phase < phase_bins(bin+1));
    end
    
    if sum(idx) > 3 % 至少需要3个样本才统计
        mean_amp(bin) = mean(amp(idx));
    else
        mean_amp(bin) = nan;
    end
end

% 插值处理空区间
mean_amp = fillmissing(mean_amp, 'movmean', 3);
mean_amp(isnan(mean_amp)) = 0;

% 计算标准化调制指数
P = mean_amp / sum(mean_amp);
P(P == 0) = eps; % 避免log(0)
H = -sum(P .* log(P));
Hmax = log(n_bins);
MI = (Hmax - H) / Hmax;
end