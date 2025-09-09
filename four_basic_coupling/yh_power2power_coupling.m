function corr_coeff = yh_power2power_coupling(signal_low, signal_high, method, window, noverlap)


% 输入：x, y为原始信号；band1/band2为频段范围[low, high]
% 输出：能量相关系数
n = length(signal_low);
if n ~= length(signal_high)
    error('输入信号长度必须相同');
end

% 默认方法为 'direct'
if nargin < 3 || isempty(method)
    method = 'direct';
end

if strcmpi(method, 'direct')
    % 计算能量（振幅平方）
    power_x = abs(hilbert(signal_low)).^2;
    power_y = abs(hilbert(signal_high)).^2;

    % 计算相关系数
    corr_coeff = corr(power_x, power_y);


elseif strcmpi(method, 'windowed')
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
    corr_values = zeros(num_windows, 1);

    for k = 1:num_windows
        range = (k-1)*noverlap + 1 : (k-1)*noverlap + window;

        % 对窗口内的信号计算能量
        power_x = abs(hilbert(signal_low(range))).^2;
        power_y = abs(hilbert(signal_high(range))).^2;

        % 计算窗口内的相关系数
        corr_values(k) = corr(power_x, power_y);
    end

    % 筛选高耦合窗口（前50%）
    sorted_corr = sort(corr_values, 'descend');
    keep_num = ceil(num_windows/2);
    corr_coeff = mean(sorted_corr(1:keep_num));

else
    error('未知方法，请选择 ''direct'' 或 ''windowed''');
end
end

% 振幅调制：若需分析振幅包络的线性相关性，应提取振幅（Hilbert包络的绝对值）并计算其相关系数。
%
% 功率耦合：若关注能量变化的同步性，则计算振幅平方（功率）的相关系数。