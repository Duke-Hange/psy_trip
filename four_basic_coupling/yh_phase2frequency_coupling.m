function mi = yh_phase2frequency_coupling(x, y,Fs)
    % 改进版相位-频率互信息计算
    % 输入：
    %   x,y: 原始信号（需同长度）
    %   Fs: 采样率(Hz)
    %   band_phase: 相位信号频段 [f_low, f_high] (Hz)
    %   band_freq: 频率信号频段 [f_low, f_high] (Hz)
    % 输出：
    %   mi: 标准化互信息值（0~1）
    
    %% 步骤1: 提取相位信号
    phase = angle(hilbert(x));  % 相位信号（-pi~pi）
   
    %% 步骤2: 提取瞬时频率（改进方法）
    analytic = hilbert(y);
    % 更稳健的瞬时频率计算（避免边界效应）
    unwrapped_phase = unwrap(angle(analytic));
    instantaneous_freq = Fs/(2*pi) * gradient(unwrapped_phase);
    
    % 去除边缘效应（丢弃前5%和后5%数据）
    n = length(instantaneous_freq);
    idx = round(0.05*n):round(0.95*n);
    phase = phase(idx);
    instantaneous_freq = instantaneous_freq(idx);
    
    %% 步骤3: 互信息计算（基于自适应分箱）
    % 数据标准化
    phase_norm = (phase + pi)/(2*pi);   % 转换到0-1范围
    freq_norm = (instantaneous_freq - mean(instantaneous_freq))/std(instantaneous_freq);
      
    % 基于分箱法的MI计算
    n_bins = floor(sqrt(length(phase)/5));  % 自适应分箱
    [mi, H_xy, H_x, H_y] = mutualinfo(phase_norm, freq_norm, n_bins);
    
    % 标准化到0-1范围
%     mi = mi / log(min(n_bins, length(unique(phase_norm)))); 
    mi = 2 * mi / (H_x + H_y);  % Symmetric NMI
end

%% 互信息计算子函数
function [mi, H_xy, H_x, H_y] = mutualinfo(x, y, n_bins)
    % 基于直方图的互信息计算
    x_edges = linspace(min(x), max(x), n_bins+1);
    y_edges = linspace(min(y), max(y), n_bins+1);
    
    % 联合直方图
    [counts_xy, ~, ~] = histcounts2(x, y, x_edges, y_edges);
    P_xy = counts_xy / sum(counts_xy(:)) + eps;  % 避免log(0)
    
    % 边缘分布
    P_x = sum(P_xy, 2);
    P_y = sum(P_xy, 1);
    
    % 计算熵值
    H_xy = -sum(P_xy(:) .* log2(P_xy(:)));
    H_x = -sum(P_x .* log2(P_x));
    H_y = -sum(P_y .* log2(P_y));
    
    % 互信息
    mi = H_x + H_y - H_xy;
end