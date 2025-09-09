function [factors_group2,pairs]=yh_freseeker(data_AAL,Fs,window,noverlap,NFFT)
eg_signal=squeeze(data_AAL(1,:)); %只取频率采样
[~,f] = pwelch(eg_signal, window, noverlap, NFFT, Fs);
[factors_group, non_factors_group] = yh_common_divisor(f);

factors_group2 = []; % 初始化存储质数行的矩阵
for row = 1:size(factors_group, 1)
    if isPrime(factors_group(row, 1),factors_group) % 检查第一列是否为质数
        factors_group2 = [factors_group2; factors_group(row, :)]; % 保留该行
    end
end

clear non_factors_group factors_group eg_signal

base_fre_range=unique(factors_group2(:,1));

for x=1:length(base_fre_range)
    x
    f0=base_fre_range(x,1);
    count = sum(factors_group2(:, 1) == f0); % 计算第一列中等于2的数量
    if count>=3
        num_harmonics=3;

    else
        num_harmonics=count;
    end

    best_harmonics=yh_best_harmonics(data_AAL, window, noverlap, NFFT, Fs,f0,num_harmonics);

    % 排除条件：第一列等于 f0 且第二列不属于 best_harmonics
    rows_to_keep = true(size(factors_group2, 1), 1); % 初始化逻辑索引，默认保留所有行

    for row = 1:size(factors_group2, 1)
        if factors_group2(row, 1) == f0 && ~ismember(factors_group2(row, 2), best_harmonics)
            rows_to_keep(row) = false; % 标记为不保留
        end
    end

    % 提取保留的行
    factors_group2 = factors_group2(rows_to_keep, :);
end

bands = struct(...
    'name',  {'Delta', 'theta', 'alpha', 'Beta', 'Gamma'},...
    'range', {[0.5,4], [4,7],   [8,12],  [12,30], [30,100]}...
    );

% 提取基频和谐频
f_base     = factors_group2(:, 1);
f_harmonic = factors_group2(:, 2);

% 预分配逻辑索引矩阵
num_bands = length(bands);
[num_pairs, ~] = size(factors_group2);
in_band_base = false(num_pairs, num_bands);
in_band_harmonic = false(num_pairs, num_bands);

% 生成波段逻辑索引
for ib = 1:num_bands
    in_band_base(:, ib) = f_base >= bands(ib).range(1) & f_base <= bands(ib).range(2);
    in_band_harmonic(:, ib) = f_harmonic >= bands(ib).range(1) & f_harmonic <= bands(ib).range(2);
end

% 自动生成所有组合对
pairs = struct();
for ib = 1:num_bands
    for ih = ib:num_bands
        pair_name = sprintf('%s_%s', bands(ib).name, bands(ih).name);

        if ib == ih
            logic_idx = in_band_base(:, ib) & in_band_harmonic(:, ih); % 同波段配对
        else
            logic_idx = in_band_base(:, ib) & in_band_harmonic(:, ih); % 跨波段配对
        end

        pairs.(pair_name).indices = logic_idx;
        pairs.(pair_name).data = factors_group2(logic_idx, :);
        pairs.(pair_name).count = sum(logic_idx);
    end
end
end