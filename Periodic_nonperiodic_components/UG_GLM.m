clear
% ==== �������� ====
snirf_dir = 'C:\Users\62428\Desktop\���ݷ�������\����������\���������2���£�\snirf';  
file_list = dir(fullfile(snirf_dir, '*.snirf'));
n_subj = length(file_list);
trange = [-2 15];         % HRF ��������
baseline = -5;            % ����
ppf = [6, 6];             % ·������

beta_UG_all = cell(n_subj, 1);  % �������б��Ե�UG ��ֵ

for sub = 1:n_subj
    fprintf('Processing: %s\n', file_list(sub).name);
    file_path = fullfile(snirf_dir, file_list(sub).name);
    
    % === ���� Snirf �ļ� ===
    snirf = SnirfClass(file_path);
    fs = 1 / (snirf.data.time(2) - snirf.data.time(1));
    time = snirf.data.time;
    probe = snirf.probe;

    % === ���� Stim name Ϊ '1' �� UG ���� ===
    stim_idx = find(strcmp({snirf.stim.name}, '1'));
    if isempty(stim_idx)
        warning('? δ�ҵ� UG ���� stim name ''1''�������ñ��ԡ�');
        continue;
    end

    % === ���� UG �� s ���� ===
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

    % === ��ǿ �� OD ===
    dod = hmrR_Intensity2OD(snirf.data);

    % === �˶�αӰУ�� ===
    [~, tIncCh] = hmrR_MotionArtifactByChannel(dod, probe, [], [], [], ...
                                               0.5, 1.0, 50, 5);
    dod_corr = hmrR_MotionCorrectSpline(dod, [], tIncCh, 0.99, 1);

    % === �˲� ===
    dod_filt = hmrR_BandpassFilt(dod_corr, 0.01, 0.2);

    % === OD �� Ѫ��Ũ�� ===
    dc = hmrR_OD2Conc(dod_filt, probe, ppf);

    % === GLM ��������һ�������� ===
    [~, ~, ~, ~, ~, beta] = hmrR_GLM(dc, s, time, probe);

    % === ��ȡ UG �����µ� HbO �� ===
    beta_HbO = squeeze(beta(:,1,1));  % [ͨ�� �� 1]

    beta_UG_all{sub,1} = beta_HbO;
    beta_UG_all{sub,2} = file_list(sub).name;
end

% ==== ������ ====
save('glm_beta_UG_only.mat', 'beta_UG_all');
fprintf('? ���б���UG������ֵ��ȡ��ɲ����档\n');
