%% 组间差异箱线图
figure('Position', [100 100 600 400]);
boxplot([group1_min; group2_min], [ones(n1,1); 2*ones(length(group2_min),1)],...
    'Labels', {'Group 1', 'Group 2'}, 'Whisker', 1.5);
hold on;
scatter(ones(n1,1), group1_min, 'r', 'filled', 'jitter','on');
scatter(2*ones(length(group2_min),1), group2_min, 'b', 'filled', 'jitter','on');
title('组间最小互相关值比较');
ylabel('最小互相关值');
grid on;
% saveas(gcf, 'Group_Comparison.png'); % 保存图片

%% 置换检验结果直方图（组间差异）
figure('Position', [100 100 800 400]);
histogram(perm_diffs_min, 'Normalization', 'pdf', 'BinWidth', 0.02);
hold on;
xline(obs_diff_min, 'r', 'LineWidth', 2);
xline(prctile(perm_diffs_min, [2.5 97.5]), '--k', 'LineWidth', 1);
xlabel('组间差异（Group1 - Group2）');
ylabel('概率密度');
legend('置换分布', '观测差异', '95% CI');
title(sprintf('置换检验结果 (p=%.4f)', p_min));
grid on;
% saveas(gcf, 'Permutation_Test.png');

%% 所有受试者最优延迟分布
figure('Position', [100 100 600 400]);
histogram(corr(:,2), 'BinWidth', 0.5, 'FaceColor', [0.5 0.5 0.5]);
xlabel('最优延迟时间（秒）');
ylabel('受试者数量');
title('所有受试者最优延迟时间分布');
grid on;
% saveas(gcf, 'Optimal_Lag_Distribution.png');

%% 个体反相关系数与延迟时间散点图
figure('Position', [100 100 600 400]);
scatter(corr(:,2), corr(:,1), 50, 'filled', 'MarkerEdgeColor','k');
xlabel('最优延迟时间（秒）');
ylabel('最小互相关值');
title('个体水平延迟与相关性关系');
grid on;
saveas(gcf, 'Correlation_vs_Lag.png');%% 1. 组间差异箱线图
figure('Position', [100 100 600 400]);
boxplot([group1_min; group2_min], [ones(n1,1); 2*ones(length(group2_min),1)],...
    'Labels', {'Group 1', 'Group 2'}, 'Whisker', 1.5);
hold on;
scatter(ones(n1,1), group1_min, 'r', 'filled', 'jitter','on');
scatter(2*ones(length(group2_min),1), group2_min, 'b', 'filled', 'jitter','on');
title('组间最小互相关值比较');
ylabel('最小互相关值');
grid on;
% saveas(gcf, 'Group_Comparison.png'); % 保存图片

%% 置换检验结果直方图（组间差异）
figure('Position', [100 100 800 400]);
histogram(perm_diffs_min, 'Normalization', 'pdf', 'BinWidth', 0.02);
hold on;
xline(obs_diff_min, 'r', 'LineWidth', 2);
xline(prctile(perm_diffs_min, [2.5 97.5]), '--k', 'LineWidth', 1);
xlabel('组间差异（Group1 - Group2）');
ylabel('概率密度');
legend('置换分布', '观测差异', '95% CI');
title(sprintf('置换检验结果 (p=%.4f)', p_min));
grid on;
% saveas(gcf, 'Permutation_Test.png');

%% 所有受试者最优延迟分布
figure('Position', [100 100 600 400]);
histogram(corr(:,2), 'BinWidth', 0.5, 'FaceColor', [0.5 0.5 0.5]);
xlabel('最优延迟时间（秒）');
ylabel('受试者数量');
title('所有受试者最优延迟时间分布');
grid on;
% saveas(gcf, 'Optimal_Lag_Distribution.png');

%% 个体反相关系数与延迟时间散点图
figure('Position', [100 100 600 400]);
scatter(corr(:,2), corr(:,1), 50, 'filled', 'MarkerEdgeColor','k');
xlabel('最优延迟时间（秒）');
ylabel('最小互相关值');
title('个体水平延迟与相关性关系');
grid on;
% saveas(gcf, 'Correlation_vs_Lag.png');

