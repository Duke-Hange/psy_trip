function plv = yh_phase2phase_coupling(x,y,method,window,noverlap)
%% Phase to Phase
% 输入参数：
%   x, y: 输入的两个时间序列（列向量）
%   method: 方法选择，'direct' 或 'windowed'
%   window_len: 窗口长度（仅用于 'windowed' 方法，默认值为总长度的1/10）
%   step: 滑动步长（仅用于 'windowed' 方法，默认值为窗口长度的一半）
% 输出：
%   plv: 相位锁定值（PLV）
n = length(x);
if n ~= length(y)
    error('输入信号x和y的长度必须相同');
end

% 默认方法为 'direct'
if nargin < 3 || isempty(method)
    method = 'direct';
end

% 根据方法选择计算PLV
if strcmpi(method, 'direct')
    % 原始方法：直接计算整个时间序列的PLV
    phase_x = angle(hilbert(x));
    phase_y = angle(hilbert(y));
    phase_diff = phase_x - phase_y;
    plv = abs(mean(exp(1i * phase_diff)));
    
elseif strcmpi(method, 'windowed')
    % 滑动窗口方法
    % 设置默认窗口长度和步长
    if nargin < 4 || isempty(window)
        window = floor(n / 10);
    end
    if nargin < 5 || isempty(noverlap)
        noverlap = floor(window / 2);
    end
    
    % 确保窗口和步长有效
    window = max(1, min(window, n));
    noverlap = max(1, noverlap);
    
    % 计算窗口数量
    num_windows = floor((n - window) / noverlap) + 1;
    plvs = zeros(num_windows, 1);
    
    % 对每个窗口计算PLV
    for k = 1:num_windows
        start_idx = (k-1)*noverlap + 1;
        end_idx = start_idx + window - 1;
        x_win = x(start_idx:end_idx);
        y_win = y(start_idx:end_idx);
        
        % 希尔伯特变换提取相位
        phase_x = angle(hilbert(x_win));
        phase_y = angle(hilbert(y_win));
        
        % 计算相位差并求PLV
        phase_diff = phase_x - phase_y;
        plv = abs(mean(exp(1i * phase_diff)));
        plvs(k) = plv;
    end
    
    % 排除低PLV部分（使用中位数作为阈值）
    threshold = median(plvs);
    plvs_filtered = plvs(plvs >= threshold);
    
    % 计算筛选后的均值
    if isempty(plvs_filtered)
        plv = 0; % 若无剩余窗口，返回0
    else
        plv = mean(plvs_filtered);
    end
    
else
    error('未知方法，请选择 ''direct'' 或 ''windowed''');
end

end