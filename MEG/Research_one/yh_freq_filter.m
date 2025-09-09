function [filtered_signals,unique_freq] = yh_freq_filter(signal, Fs, factors_group)
% 输入参数:
%   data: 原始时域信号 (N_samples × 1)
%   Fs: 采样率
%   factors_group: 需要滤波的频率对 (n×2矩阵)
% 输出:
%   filtered_signals: 滤波后信号结构体

% 提取唯一中心频率
unique_freq = unique([factors_group(:,1); factors_group(:,2)]);

% 预分配存储结构
filtered_signals = struct();

% % 设计滤波器参数
% bandwidth = 0.5; % ±0.02Hz → 总带宽0.04Hz
% filter_order = 2; % 高阶FIR保证窄带特性

for f = 1:length(unique_freq)
    fc = unique_freq(f); % 当前中心频率

    % % 滤波器设计
    % fir_filter = designfilt('bandpassfir',...
    %     'FilterOrder', filter_order,...
    %     'CutoffFrequency1', fc - 0.05,...
    %     'CutoffFrequency2', fc + 0.05,...
    %     'SampleRate', Fs);


    % 预分配存储结构
    % filtered_signals = struct();

    % 参数设置
    bandwidth = 0.5; % 通带带宽 (e.g., 10 ±0.05 Hz)
    stopband_attenuation = 60; % 阻带衰减 (dB)
    passband_ripple = 1; % 通带波纹 (dB)

    for f = 1:length(unique_freq)
        fc = unique_freq(f); % 当前中心频率

        % 设计 IIR 椭圆滤波器
        iir_filter = designfilt('bandpassiir',...
            'FilterOrder', 4,...
            'PassbandFrequency1', fc - bandwidth/2,...
            'PassbandFrequency2', fc + bandwidth/2,...
            'StopbandAttenuation1', stopband_attenuation,...
            'PassbandRipple', passband_ripple,...
            'StopbandAttenuation2', stopband_attenuation,...
            'SampleRate', Fs,...
            'DesignMethod', 'ellip');

        % 零相位滤波
        filtered = filtfilt(iir_filter, signal);

        fc=fc*10;
        % 存储结果
        field_name = sprintf('f%.fHz', fc);
        filtered_signals.(field_name) = filtered;
    end
end


