clear
% ==== 参数设置 ====
snirf_dir = 'C:\Users\62428\Desktop\数据分析材料\近红外数据\近红外玩家2（新）\snirf';  
file_list = dir(fullfile(snirf_dir, '*.snirf'));
n_subj = length(file_list);
trange = [-2 15];         % HRF 分析窗口
baseline = -5;            % 基线
ppf = [6, 6];             % 路径因子

beta_UG_all = cell(n_subj, 1);  % 保存所有被试的UG β值

for sub = 1:n_subj
    fprintf('Processing: %s\n', file_list(sub).name);
    file_path = fullfile(snirf_dir, file_list(sub).name);
    
    % === 加载 Snirf 文件 ===
    snirf = SnirfClass(file_path);
    fs = 1 / (snirf.data.time(2) - snirf.data.time(1));
    time = snirf.data.time;
    probe = snirf.probe;

    % === 查找 Stim name 为 '1' 的 UG 条件 ===
    stim_idx = find(strcmp({snirf.stim.name}, '1'));
    if isempty(stim_idx)
        warning('? 未找到 UG 条件 stim name ''1''，跳过该被试。');
        continue;
    end

    % === 构建 UG 的 s 矩阵 ===
    s = zeros(length(time), 1);
    onset = snirf.stim(stim_idx).data(:,1);
    dur = snirf.stim(stim_idx).data(:,2);
    for j = 1:length(onset)
        idx_start = find(time >= onset(j), 1);
        idx_end = find(time >= (onset(j) + dur(j)), 1);
        if ~isempty(idx_start) && ~isempty(idx_end)
            s(idx_start:idx_end) = 1;
        end
    end

    % === 光强 → OD ===
    dod = hmrR_Intensity2OD(snirf.data);

    % === 运动伪影校正 ===
    [~, tIncCh] = hmrR_MotionArtifactByChannel(dod, probe, [], [], [], ...
                                               0.5, 1.0, 50, 5);
    dod_corr = hmrR_MotionCorrectSpline(dod, [], tIncCh, 0.99, 1);

    % === 滤波 ===
    dod_filt = hmrR_BandpassFilt(dod_corr, 0.01, 0.2);

    % === OD → 血氧浓度 ===
    dc = hmrR_OD2Conc(dod_filt, probe, ppf);

    % === GLM 分析（仅一个条件） ===
    [~, ~, ~, ~, ~, beta] = hmrR_GLM(dc, s, time, probe);

    % === 提取 UG 条件下的 HbO β ===
    beta_HbO = squeeze(beta(:,1,1));  % [通道 × 1]

    beta_UG_all{sub,1} = beta_HbO;
    beta_UG_all{sub,2} = file_list(sub).name;
end

% ==== 保存结果 ====
save('glm_beta_UG_only.mat', 'beta_UG_all');
fprintf('? 所有被试UG条件β值提取完成并保存。\n');
