%% 寻找公因数
factors_group = []; % 存放有因数关系的数字对
non_factors_group = []; % 存放没有因数关系的数字对

% 设置范围
f = f';

% 遍历所有数字对
for i = 1:length(f)
    for j = i+1:length(f)
        % 检查是否存在因数关系
        if mod(f(j), f(i)) == 0
            factors_group = [factors_group; f(i), f(j)];
        else
            non_factors_group = [non_factors_group; f(i), f(j)];
        end
    end
end

% 显示结果  
disp('有因数关系的数字对:');  
disp(factors_group);  

disp('没有因数关系的数字对:');  
disp(non_factors_group);

%% Phase to Phase

function plv = computePhaseCoupling(x, y, Fs, freq_bands)
% 输入参数：
%   x, y: 输入的两个时间序列（列向量）
%   Fs: 采样频率（Hz）
%   freq_bands: 频带矩阵，每行定义[low, high]，如[1 4; 4 8; ...]
% 输出：
%   plv: 各频段的相位锁定值数组

% 预处理：去趋势
x = detrend(x);
y = detrend(y);

num_bands = size(freq_bands, 1);
plv = zeros(num_bands, 1);
filter_order = 4; % Butterworth滤波器阶数

for band = 1:num_bands
    low = freq_bands(band, 1);
    high = freq_bands(band, 2);
    
    % 设计带通滤波器
    nyquist = Fs / 2;
    [b, a] = butter(filter_order, [low, high]/nyquist, 'bandpass');
    
    % 零相位滤波
    x_filt = filtfilt(b, a, x);
    y_filt = filtfilt(b, a, y);
    
    % 希尔伯特变换提取相位
    phase_x = angle(hilbert(x_filt));
    phase_y = angle(hilbert(y_filt));
    
    % 计算相位差并求PLV
    phase_diff = phase_x - phase_y;
    plv(band) = abs(mean(exp(1i * phase_diff)));
end
end

%% Power to Power
function corr_coeff = power_to_power_coupling(x, y, Fs, band1, band2)
    % 输入：x, y为原始信号；band1/band2为频段范围[low, high]
    % 输出：能量相关系数
    
    % 带通滤波（零相位）
    x_band1 = bandpass_filter(x, Fs, band1);
    y_band2 = bandpass_filter(y, Fs, band2);
    
    % 计算能量（振幅平方）
    power_x = abs(hilbert(x_band1)).^2;
    power_y = abs(hilbert(y_band2)).^2;
    
    % 计算相关系数
    corr_coeff = corr(power_x, power_y);
end

%% Phase to Frequency
function mi = phase_to_frequency_coupling(x, y, Fs, band_phase, band_freq)
    % 输入：x为相位信号，y为频率信号；band_phase/freq为频段
    % 输出：调制指数（MI）
    
    % 提取频段A的相位
    x_phase = angle(hilbert(bandpass_filter(x, Fs, band_phase)));
    
    % 提取频段B的瞬时频率（示例用Hilbert法）
    y_filt = bandpass_filter(y, Fs, band_freq);
    analytic_signal = hilbert(y_filt);
    instantaneous_freq = diff(unwrap(angle(analytic_signal))) * Fs / (2*pi);
    instantaneous_freq = [instantaneous_freq(1); instantaneous_freq]; % 对齐长度
    
    % 计算相位-频率互信息
    [~, ~, mi] = mi_gg([x_phase(1:end-1), instantaneous_freq], true);
end

%% Phase to Power
function pac = phase_to_power_coupling(x, y, Fs, band_phase, band_power)
    % 输入：x为相位信号，y为能量信号；band_phase/power为频段
    % 输出：相位-能量调制指数
    
    % 提取频段A的相位
    phase = angle(hilbert(bandpass_filter(x, Fs, band_phase)));
    
    % 提取频段B的能量
    power = abs(hilbert(bandpass_filter(y, Fs, band_power))).^2;
    
    % 分箱（18 bins为例）
    [~, bin_edges] = histcounts(phase, 18);
    [~, bin_idx] = histc(phase, bin_edges);
    mean_power = accumarray(bin_idx, power, [], @mean);
    
    % 计算调制指数（归一化熵）
    pac = (log(18) + sum(mean_power .* log(mean_power))) / log(18);
end