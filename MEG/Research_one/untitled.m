clear
dbclear all
%% find the MEG
file_path='E:\22级\Yu_Hang\新建文件夹\demo数据\ds000247_R1.0.0';
sub_folder=dir(fullfile(file_path,'*sub-0*'));

for sub=1:length(sub_folder)
    sub_file_fold1=dir(fullfile(sub_folder(sub).folder,sub_folder(sub).name));
    sub_file_fold1(1:2)=[];
    sub_file_fold2=dir(fullfile(sub_file_fold1(sub).folder,sub_file_fold1(sub).name,'*meg*'));
    sub_file=dir(fullfile(sub_file_fold2(sub).folder,sub_file_fold2(sub).name,'*meg.ds'));
    sub_file=fullfile(sub_file.folder,sub_file.name);

    %% remove channel jump
    cfg = [];
    cfg.dataset = sub_file;
    %     cfg.trialdef.eventtype = 'trial';
    cfg = ft_definetrial(cfg);
    cfg= ft_artifact_jump(cfg);
    cfg = ft_rejectartifact(cfg);
    % cfg.trl([3 11 23],:) = [];
    cfg.channel= {'MEG', 'ECG'};
    cfg.continuous = 'yes';

    data = ft_preprocessing(cfg);

    %     [layout, cfg] = ft_prepare_layout(cfg, data);
    %% split the ECG and MEG datasets, since ICA will be performed on MEG data but not on ECG channel
    % 1 - ECG dataset
    %     cfg              = [];
    %     cfg.channel      = {'ECG'};
    %     ecg              = ft_selectdata(cfg, data);
    %     ecg.label{1}     = 'ECG'; % for clarity and consistency rename the label of the ECG channel

    % 2 - MEG dataset
    cfg              = [];
    cfg.channel      = {'MEG'};
    data_orig        = ft_selectdata(cfg, data);

    %% resample 1
    cfg_rs = [];
    cfg_rs.resamplefs = 300;
    cfg_rs.detrend = 'yes';
    data_resampled = ft_resampledata(cfg_rs,data_orig);

    %% ICA
    disp('About to run ICA using the FASTICA method')
    cfg            = [];
    cfg.numcomponent = 20;
    cfg.method     = 'fastica';
    comp           = ft_componentanalysis(cfg, data_resampled);

    %     save('comp.mat','comp','-v7.3')

    % Display Components - change layout as needed
    cfg = [];
    cfg.preproc.demean = 'yes';
    cfg.preproc.lpfilter = 'yes';
    cfg.preproc.lpfreq = 30;
    cfg.preproc.hpfilter = 'yes';
    cfg.preproc.hpfreq = 0.5;

    cfg.viewmode = 'component';
    cfg.layout = 'CTF275.lay';
    ft_databrowser(cfg, comp);

    % Decompose the original data as it was prior to downsampling
    diary on;
    cfg           = [];
    cfg.unmixing  = comp.unmixing;
    cfg.topolabel = comp.topolabel;
    comp_orig     = ft_componentanalysis(cfg, data_resampled);

    % the original data can now be reconstructed, excluding specified components
    % This asks the user to specify the components to be removed
    %     disp('Enter components in the form [1 2 3]')
    comp2remove = input('Which components would you like to remove?\n');
    cfg           = [];
    cfg.component = [comp2remove]; %these are the components to be removed
    data_clean    = ft_rejectcomponent(cfg, comp_orig,data_resampled);

    %     %% resample2
    %     cfg_rs = [];
    %     cfg_rs.resamplefs = 300;
    %     cfg_rs.detrend = 'yes';
    %     data_resample2 = ft_resampledata(cfg_rs,data_clean);

    %% bandstop filter
    % bandstop filter to remove line noise
    cfg_flt = [];
    cfg_flt.bsfilter = 'yes';
    cfg_flt.bsfreq = [49 51; 99 101];
    cfg_flt.bsinstabilityfix = 'split';
    data_clean_f1 = ft_preprocessing(cfg_flt,data_clean);

    %     % highpass filter
    %     cfg_flt = [];
    %     cfg_flt.hpfilter = 'yes';
    %     cfg_flt.hpfreq = [0.5];
    %     cfg_flt.hpinstabilityfix = 'split';
    %     data_clean_f2 = ft_preprocessing(cfg_flt,data_clean_f1);
    %
    %     % lowpass filter
    %     cfg_flt = [];
    %     cfg_flt.lpfilter = 'yes';
    %     cfg_flt.lpfreq = [149.5];
    %     cfg_flt.lpinstabilityfix = 'split';
    %     data_clean_f3 = ft_preprocessing(cfg_flt,data_clean_f2);

    clearvars -except data_clean_f1 sub_folder sub

    % data reshape
    X1 = cell2mat(data_clean_f1.trial);

    %     X2 = permute(reshape(X1.', [14700, 11, 270]), [3, 2, 1]);

    %     clearvars -except X1 X2 sub
    %     % Display clean data
    %     cfg = [];
    %     cfg.channel = 'MEGGRAD';
    %     cfg.viewmode = 'vertical';
    %     ft_databrowser(cfg,data_bs_hp_lp)

    Fs = 300;
    window = hamming(300);
    noverlap = 150;
    NFFT = 600;

    %% 频率点检索
    signal_1=squeeze(X1(1,:))'; %只取频率采样
    [~,f] = pwelch(signal_1, window, noverlap, NFFT, Fs);

    [factors_group, non_factors_group] = yh_common_divisor(f);

    %% 保留质数基波
    % 检查第一列是否为质数，并保留质数行
    factors_group2 = []; % 初始化存储质数行的矩阵
    for row = 1:size(factors_group, 1)
        if isPrime(factors_group(row, 1),factors_group) % 检查第一列是否为质数
            factors_group2 = [factors_group2; factors_group(row, :)]; % 保留该行
        end
    end

   
    %% 强谐波选择
   
    base_fre_range=unique(factors_group2(:,1));


    for x=1:length(unique(factors_group2(:,1)))
        x
        f0=base_fre_range(x,1);
        count = sum(factors_group2(:, 1) == 2); % 计算第一列中等于2的数量
        if count>=3
            num_harmonics=3;

        else
            num_harmonics=count;
        end

        best_harmonics=yh_best_harmonics(X1, window, noverlap, NFFT, Fs,f0,num_harmonics);

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

    %% 分类
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

    %
    %         fprintf('\n===== 跨频段配对 =====\n');
    %         for ib = 1:num_bands-1
    %             for ih = ib+1:num_bands
    %                 pair_name = sprintf('%s_%s', bands(ib).name, bands(ih).name);
    %                 fprintf('%-12s: %d\n', pair_name, pairs.(pair_name).count);
    %             end
    %         end

    %% 滤波（提前滤波以减少后期迭代次数）
    numChannels = size(X1, 1);
    filtered_signals_all = cell(numChannels, 1);
    unique_freq = [];

    numWorkers = 4; % 指定使用 4 个工作进程
    parpool(numWorkers);

    pool = gcp('nocreate'); % 获取当前并行池，如果未启动则返回空
    if isempty(pool)
        disp('并行池未启动');
    else
        disp(['并行池已启动，工作进程数量：', num2str(pool.NumWorkers)]);
    end

    parfor ch = 1:numChannels
        signal = squeeze(X1(ch, :))';
        [filtered_signals, unique_freq] = yh_freq_filter(signal, Fs, factors_group2);
        filtered_signals_all{ch} = filtered_signals;
    end

    delete(gcp('nocreate'));

    fields = fieldnames(filtered_signals_all{1}); % 假设所有通道滤波后的字段相同

    %% 计算指标
    % 初始化结果表格
    headers = {'sub' 'Channel1', 'Channel2', 'FreqLow', 'FreqHigh', 'PLV', 'PAC', 'Corr', 'P2F_MI'};
    resultTable = table('Size', [0, numel(headers)], 'VariableNames', headers, 'VariableTypes', repmat({'double'}, 1, numel(headers)));

    [~,unique_freq] = yh_freq_filter(squeeze(X1(1,:))', Fs, factors_group2);
    goal_group=pairs.Delta_theta.data;

    numWorkers = 4; % 指定使用 4 个工作进程
    parpool(numWorkers);

    pool = gcp('nocreate'); % 获取当前并行池，如果未启动则返回空
    if isempty(pool)
        disp('并行池未启动');
    else
        disp(['并行池已启动，工作进程数量：', num2str(pool.NumWorkers)]);
    end


    parfor channel1 = 1:size(X1,1)-1

         filtered_signals_1= filtered_signals_all{channel1,1} ;

        for channel2 = channel1+1:size(X1,1)

           filtered_signals_2= filtered_signals_all{channel2,1} ;

            fre_range=unique(goal_group(:,1));

            for fre_low=1:size(fre_range,1)
              
                fre_slow_range=goal_group(goal_group(:,1)==fre_range(fre_low),:);

                for fre_pair=1:size(fre_slow_range,1)

                    fre_slow=fre_slow_range(fre_pair,1);
                    fre_slow
                    fre_high=fre_slow_range(fre_pair,2);
                    fre_high

                    fre_slow_index=find(unique_freq==fre_slow);
                    fre_high_index=find(unique_freq==fre_high);

                    data_slow = filtered_signals_1.(fields{fre_slow_index});
                    data_high = filtered_signals_2.(fields{fre_high_index});

                    %% 频率点间相互关系计算
                    % 计算指标
                    plv = yh_phase2phase_coupling(data_slow, data_high, 'windowed',length(window),noverlap);
%                     plv = yh_phase2phase_coupling(data_slow, data_high, 'windowed');
%                     plv = yh_phase2phase_coupling(data_slow, data_high, 'direct');

                    pac = yh_phase2power_coupling(data_slow, data_high, 'windowed',length(window),noverlap);
%                     pac = yh_phase2power_coupling(data_slow, data_high, 'windowed');
%                     pac = yh_phase2power_coupling(data_slow, data_high, 'direct');

                    corr = yh_power2power_coupling(data_slow, data_high);

                    p2f = mean(yh_phase2frequency_coupling(data_slow, data_high, Fs));

                    % 添加到表格
                    newRow = {sub channel1, channel2, fre_slow, fre_high, plv, pac, corr, p2f};
                    resultTable = [resultTable; newRow];

                    clear fre_slow fre_high

                end
            end
        end
    end

    delete(gcp('nocreate'));
end