function relative_power=yh_Relative_Power(Pxx,f)
% 定义频段范围 (单位：Hz)
band_def = {
    'Delta',  0.5,  4;
    'Theta',  4,    8;
    'Alpha',  8,   12;
    'Beta',  12,   30;
    'Gamma', 30,  100
    };

relative_power = struct();

% 计算总功率（包含所有定义频段）
total_power = 0;
band_powers = zeros(1, size(band_def,1));

% 遍历每个频段
for bidx = 1:size(band_def,1)
    % 找到频率索引
    freq_mask = (f >= band_def{bidx,2}) & (f <= band_def{bidx,3});

    % 计算绝对功率（积分面积）
    band_power = sum(Pxx(freq_mask)) * (f(2)-f(1)); % 积分计算

    % 存储结果
    band_powers(bidx) = band_power;
    total_power = total_power + band_power;
end

% 计算相对功率
for bidx = 1:size(band_def,1)
    relative_power.(band_def{bidx,1})= band_powers(bidx) / total_power;
end

end
