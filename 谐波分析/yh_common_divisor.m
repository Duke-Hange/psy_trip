function [factors_group, non_factors_group] = yh_common_divisor(f)
% 转置输入数组
f = f(:);  % 确保 f 为列向量
n = length(f);

% 生成所有不重复元素对 (i,j) 且 i < j
[i_idx, j_idx] = find(tril(true(n), -1));  % 生成下三角索引，排除对角线

% pairs = [f(i_idx), f(j_idx)];              % 生成所有候选对 [f(i), f(j)]
pairs = [f(j_idx), f(i_idx)];              % 生成所有候选对 [f(i), f(j)]


% 预筛选条件 (直接过滤无效对)
valid_pairs = ~(pairs(:,1) == 0 | pairs(:,1) == 1 | pairs(:,1) == 0.5 | ...
    pairs(:,1) == 50 | pairs(:,1) >= 100 | ...
    pairs(:,2) == 0 | pairs(:,2) == 1 | pairs(:,2) == 0.5 | ...
    pairs(:,2) == 50 | pairs(:,2) >= 100 );

pairs = pairs(valid_pairs, :);  % 应用预筛选

is_factor = (mod(pairs(:,1), pairs(:,2)) == 0 | ...
   mod(pairs(:,2), pairs(:,1)) == 0 );

% 分割结果
factors_group = pairs(is_factor, :);
non_factors_group = pairs(~is_factor, :);

end
