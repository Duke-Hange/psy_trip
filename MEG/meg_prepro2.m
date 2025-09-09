clear
dbclear all
%% find the MEG
file_path='E:\22级\Yu_Hang\新建文件夹\demo数据\ds000247_R1.0.0';
sub_folder=dir(fullfile(file_path,'*sub-0*'));

%% lock to our sub
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
    data_resample = ft_resampledata(cfg_rs,data_orig);

    %% ICA
    disp('About to run ICA using the FASTICA method')
    cfg            = [];
    cfg.numcomponent = 20;
    cfg.method     = 'fastica';
    comp           = ft_componentanalysis(cfg, data_resample);

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
    comp_orig     = ft_componentanalysis(cfg, data_resample);

    % the original data can now be reconstructed, excluding specified components
    % This asks the user to specify the components to be removed
    %     disp('Enter components in the form [1 2 3]')
    comp2remove = input('Which components would you like to remove?\n');
    cfg           = [];
    cfg.component = [comp2remove]; %these are the components to be removed
    data_clean    = ft_rejectcomponent(cfg, comp_orig,data_resample);

    %     %% resample2
    %     cfg_rs = [];
    %     cfg_rs.resamplefs = 300;
    %     cfg_rs.detrend = 'yes';
    %     data_resample2 = ft_resampledata(cfg_rs,data_clean);

    %% bandstop filter
    % bandstop filter to remove line noise
    cfg_flt = [];
    cfg_flt.bsfilter = 'yes';
    cfg_flt.bsfreq = [49.5 50.5; 99.5 100.5];
    cfg_flt.bsinstabilityfix = 'split';
    data_clean_f1 = ft_preprocessing(cfg_flt,data_clean);

    % highpass filter
    cfg_flt = [];
    cfg_flt.hpfilter = 'yes';
    cfg_flt.hpfreq = [0.5];
    cfg_flt.hpinstabilityfix = 'split';
    data_clean_f2 = ft_preprocessing(cfg_flt,data_clean_f1);

    % lowpass filter
    cfg_flt = [];
    cfg_flt.lpfilter = 'yes';
    cfg_flt.lpfreq = [149.5];
    cfg_flt.lpinstabilityfix = 'split';
    data_clean_f3 = ft_preprocessing(cfg_flt,data_clean_f2);

    clearvars -except data_clean_f3 sub_folder sub

    % data reshape
    X1 = cell2mat(data_clean_f3.trial);

    X2 = permute(reshape(X1.', [14700, 11, 270]), [3, 2, 1]);

    %     clearvars -except X1 X2 sub
    %     % Display clean data
    %     cfg = [];
    %     cfg.channel = 'MEGGRAD';
    %     cfg.viewmode = 'vertical';
    %     ft_databrowser(cfg,data_bs_hp_lp)

    %% 空间降维()


    %% 特征工程
    Fs = 300;
    window = hamming(300);
    noverlap = 150;
    NFFT = 600;

    for session=1:size(X2,2)
        for channel=1:size(X1,2)
            signal=squeeze(X2(channel,session,:));
            %% FFT
            [Pxx,f] = pwelch(signal, window, noverlap, NFFT, Fs);
            %% 传统频带相对功率计算
            relative_power=yh_Relative_Power(Pxx,f) ;
        end

        %% 频率点检索
        [factors_group, non_factors_group] = yh_common_divisor(f);
        % 两组通道
        for channel1 = 1:size(X1,1)-1
            signal_1=squeeze(X2(channel1,session,:));
            [filtered_signals_1,unique_freq] = yh_freq_filter(signal_1, Fs, factors_group);
            for channel2 = channel1+1:size(X1,1)
                signal_2=squeeze(X2(channel2,session,:));

                [filtered_signals_2,unique_freq] = yh_freq_filter(signal_2, Fs, factors_group);
                %% 相干性计算，提供相干性矩阵（提供权重）
                [coherence, f] = mscohere(signal_1, signal_2,window, noverlap, NFFT, Fs);

%                 绘制相干性图
%                 figure;
%                 plot(f, coherence);
%                 xlabel('Frequency (Hz)');
%                 ylabel('Coherence');
%                 title('Coherence between Signal 1 and Signal 2');
%                 grid on;
%                 axis([0 150 0 1]);
                fields = fieldnames(filtered_signals_1);

                fre_range=unique(factors_group(:,1));

                for fre_low=1:length(fre_range)
                    fre_slow_range=factors_group(factors_group(:,1)==fre_range(fre_low),:);

                    for fre_pair=1:length(fre_slow_range)

                        fre_slow=fre_slow_range(fre_pair,1);
                        fre_high=fre_slow_range(fre_pair,2);

                        if length(fre_slow_range) >= 3
                            fre_slow_index=find(unique_freq==fre_slow);
                            fre_high_index=find(unique_freq==fre_high);

                            data_slow = filtered_signals_1.(fields{fre_slow_index});
                            data_high = filtered_signals_2.(fields{fre_high_index});
                           
                            %% 频率点间相互关系计算

                            plv(:,fre_pair) = yh_phase2phase_coupling(data_slow,data_high,'windowed');
                            % plv = yh_phase2phase_coupling(data1,data2,'windowed',length(window),noverlap);
                            % plv = yh_phase2phase_coupling(data1,data2,'direct',length(window),noverlap);
                            pac(:,fre_pair) = yh_phase2power_coupling(data_slow,data_high,'windowed');
                            % pac = yh_phase2power_coupling(data1, data2, 'windowed',length(window),noverlap);
                            % pac = yh_phase2power_coupling(data1, data2, 'direct');
                            corr_coeff(:,fre_pair) = yh_power2power_coupling(data_slow, data_high);
                            
                            P2F_MI(:,fre_pair)=yh_phase2frequency_coupling(data_slow, data_high, Fs);

                            % 存储结果到对称位置
                            result(channel1, channel2) = metric;
                            result(channel2, channel1) = metric;

                        end
                    end
                end
            end
        end
    end



    figure;
    subplot(2,1,1);
    plot(fdcomp.freq, abs(fdcomp.cohspctrm));
    subplot(2,1,2);
    imagesc(abs(fdcomp.cohspctrm));

    %% MVPA 鍒嗘瀽

    %% SVM鏉垮潡

end

