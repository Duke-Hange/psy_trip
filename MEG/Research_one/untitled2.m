spm

clear all
addpath 'E:\22级\Yu_Hang\新建文件夹\Research_one'
sub_total='D:\MEG数据\Omega_mni16\';
sub_total=dir(sub_total);
sub_total(1:2)=[];
% sub=3;
for sub=1:length(sub_total)
    save_path = fullfile('D:\MEG数据\', 'result', num2str(sub));
    if ~exist(save_path, 'dir')
        mkdir(save_path);
    end

    %% 1 preprossing MEG data
    sub_path = fullfile(sub_total(sub).folder,sub_total(sub).name);
    data_clean=yh_meg1_preprossing(sub_path);

    %% 2 Coregistration of MEG-MRI spaces
    [mri_csr2n,brain_mesh] =yh_meg2_Coregistration(sub_path);
    % do you want to change the anatomical labels for the axes [Y, n]? Y (r,a,s,i)
    % f n l r z
    close(gcf);
    close(gcf);
    %% 3 Beamforming
    [source,grad_c,headmodel,leadfield] =yh_meg3_Beamforming(brain_mesh,data_clean);

    figure
    ft_plot_sens(grad_c, 'unit', 'mm', 'coilsize', 10);
    hold on
    plot3 (headmodel.bnd.pos(:,1), headmodel.bnd.pos(:,2), headmodel.bnd.pos(:,3), '.','MarkerEdgeColor',[0 0 0.8]);
    hold on
    plot3 (leadfield.pos(leadfield.inside,1), leadfield.pos(leadfield.inside,2), leadfield.pos(leadfield.inside,3), '+k')
    % 设置俯视视角
    view(0, 90);  % 俯视视角

    filename = fullfile(save_path, 'Beamforming.png');  % 你可以更改文件名和扩展名
    saveas(gcf, filename);  % gcf 获取当前图形的句柄

    close(gcf);

    %% 4.1 ve_compute_AAL  (基于解剖)
    atlas_brainnetome = 'D:\toolbox_matlab\fieldtrip-master\template\atlas\aal\ROI_MNI_V4.nii';
    % [sourcemodel_aal,sourcemodel_aal2,data_AAL] =yh_meg4_ve(source,data_clean,mri_csr2n,atlas_brainnetome);

    [source_aal, source_aal2, data_AAL] = yh_meg4_ve2(...
        source, data_clean, mri_csr2n, atlas_brainnetome, ...
        'aggregation_method', 'weighted_mean_corr');

    cfg = [];
    cfg.funparameter = 'tissue';
    cfg.funcolormap = 'jet';
    ft_sourceplot(cfg, source_aal2);  % 显示模板 sourcemodel_aal2

    filename = fullfile(save_path, 'AAL.png');
    saveas(gcf, filename);

    close(gcf);


    %% 4.2 ve_compute_yeo （基于功能网络）
    yao_brainnetome ='D:\toolbox_matlab\fieldtrip-master\template\atlas\yeo\Yeo2011_17Networks_MNI152_FreeSurferConformed1mm_LiberalMask_colin27.nii';
    [sourcemodel_yeo,sourcemodel_yeo2,data_yeo] =yh_meg4_ve(source,data_clean,mri_csr2n,yao_brainnetome);

    cfg = [];
    cfg.funparameter = 'tissue';
    cfg.funcolormap = 'jet';
    ft_sourceplot(cfg, sourcemodel_yeo2);  % 显示模板 sourcemodel_aal2

    filename = fullfile(save_path, 'yeo.png');  % 你可以更改文件名和扩展名
    saveas(gcf, filename);  % gcf 获取当前图形的句柄

    close(gcf);

    %% 5 first_save
    cd(save_path)
    filename = fullfile(save_path, ['sub' num2str(sub)]);  % 你可以更改文件名和扩展名
    save(filename, 'source_aal', 'data_AAL');
    % save(filename, 'source_aal', 'data_AAL', 'sourcemodel_yeo','data_yeo');

    % save(save_path, 'mri_csr2n', 'brain_mesh', 'source', ...
    %     'headmodel', 'leadfield', 'sourcemodel_aal', 'sourcemodel_aal2', 'data_AAL','sourcemodel_yeo',...
    %     'sourcemodel_yeo2','data_yeo', '-v7.3');

    clearvars -except data_yeo data_AAL sub save_path sub_total

    %% 5 ROI_divisor_ALL
    ROI_divisor = readcell('E:\22级\Yu_Hang\新建文件夹\Research_one\ROI.xlsx');
    ROIname=unique(ROI_divisor(:,2));

    ROI_pairs = {};

    for i = 1:length(ROIname)
        for j = 1:length(ROIname)
            ROI_pairs = [ROI_pairs; {ROIname{i}, ROIname{j}}];
        end
    end

    %% 6 fre_divisor
    Fs = 300;
    window = hamming(600);
    noverlap = 300;
    NFFT = 600;
    data_AAL2=data_AAL.trial{1,1};


    if sub==2
        [factors_group,fre_pairs]=yh_freseeker(data_AAL2,Fs,window,noverlap,NFFT);
    end

    % 滤波（提前滤波以减少后期迭代次数）
    numChannels = size(data_AAL2, 1);
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
        signal = squeeze(data_AAL2(ch, :))';
        [filtered_signals, ~] = yh_freq_filter(signal, Fs, factors_group);
        filtered_signals_all{ch} = filtered_signals;
    end

    % filename = fullfile(save_path, 'filtered_signals_all');  % 你可以更改文件名和扩展名
    % save(filename, 'filtered_signals_all','-v7.3');

    delete(gcp('nocreate'));


    %% 7 caculate coulping
    %% 计算指标
    % 初始化结果表格
    frepair_name = fieldnames(fre_pairs);
    headers = {'sub' 'ROI_Range','ROI_1','ROI_2', 'FreqLow', 'FreqHigh','fre_range','PLV', 'PAC', 'Corr', 'P2F_MI'};
    unique_freq = unique([factors_group(:,1); factors_group(:,2)]);

    % numWorkers = 4; % 指定使用 4 个工作进程
    % parpool(numWorkers);
    % 
    % pool = gcp('nocreate'); % 获取当前并行池，如果未启动则返回空
    % if isempty(pool)
    %     disp('并行池未启动');
    % else
    %     disp(['并行池已启动，工作进程数量：', num2str(pool.NumWorkers)]);
    % end

    for ROI = 1:size(ROI_pairs,1)     % 索引脑区对

        resultTable = table('Size', [0, numel(headers)], 'VariableNames', headers, 'VariableTypes', repmat({'double'}, 1, numel(headers)));

        ROI_1_range=ROI_pairs(ROI,1);
        ROI_1_index = find(strcmp(ROI_divisor(:, 2), ROI_1_range));
        ROI_1=filtered_signals_all(ROI_1_index);
        ROI_1_name1=ROI_divisor(ROI_1_index,4);

        ROI_2_range=ROI_pairs(ROI,2);
        ROI_2_index = find(strcmp(ROI_divisor(:, 2), ROI_2_range));
        ROI_2=filtered_signals_all(ROI_2_index);
        ROI_2_name1=ROI_divisor(ROI_2_index,4);

        ROI_range = [ROI_1_range{1} '_' ROI_2_range{1}];

        ROI_range

        for ROI_1_i = 1:size(ROI_1,1)

            for ROI_2_i = ROI_1_i:size(ROI_2,1)
                ROI_1_name2=ROI_1_name1(ROI_1_i,1);
                ROI_1_name2 = ROI_1_name2{1};
                ROI_2_name2=ROI_2_name1(ROI_2_i,1);
                ROI_2_name2 = ROI_2_name2{1};

                if strcmp(ROI_1_name2, ROI_2_name2)
                    continue;
                end

                ROI_1_data=ROI_1(ROI_1_i,1);
                ROI_2_data=ROI_2(ROI_2_i,1);

                for fre_range = 1:length(frepair_name)         % 索引频率对
                    current_name = frepair_name{fre_range};
                    current__fre = fre_pairs.(current_name);
                    current_name

                    if isempty(current__fre.data)
                        continue;
                    end

                    for fre=1:size(current__fre.data,1)   %% 频率点索引
                        fre_slow=current__fre.data(fre,1);
                        % fre_slow
                        fre_high=current__fre.data(fre,2);
                        % fre_high

                        fre_slow_index=find(unique_freq==fre_slow);
                        fre_high_index=find(unique_freq==fre_high);

                        current_name2 = fieldnames(ROI_1_data{1,1});

                        data_slow = ROI_1_data{1,1}.(current_name2{fre_slow_index});
                        data_high = ROI_2_data{1,1}.(current_name2{fre_high_index});

                        %% 频率点间相互关系计算
                        % 计算指标
                        Fs = 300;
                        window = round(1/fre_slow*Fs*10);
                        noverlap = round(window/2);
                        NFFT = 600;

                        % Fs = 300;
                        % window = 800;
                        % noverlap = 200;
                        % NFFT = 600;

                        plv = yh_phase2phase_coupling(data_slow, data_high, 'windowed',window,noverlap);

                        pac = yh_phase2power_coupling(data_slow, data_high, 'windowed',window,noverlap);

                        corr = yh_power2power_coupling(data_slow, data_high, 'windowed',window,noverlap);

                        p2f = yh_phase2frequency_coupling2(data_slow, data_high,Fs, 'windowed',window,noverlap);

                        % 添加到表格
                        newRow = {sub  ROI_range ROI_1_name2 ROI_2_name2 fre_slow fre_high current_name plv pac corr p2f};
                        resultTable = [resultTable; newRow];

                    end
                end
            end
        end
        %% 
        filename = fullfile(save_path, [ROI_range '_combined.mat']);
        save(filename, 'resultTable');

        %% 绘制 PLV、PAC、Corr 和 P2F 的箱线图
        plot_metrics(resultTable, save_path, ROI_range);

        %% 在这里开始提取topo图

    end
    % delete(gcp('nocreate'));
end

% %%在这里开始提取topo图
%
% % 假设您的表格名为 resultTable
% data = resultTable{:, 9};  % 提取第9列数据
% sortedData = sort(data, 'descend');  % 对第9列数据进行降序排序
%
% % 计算前30%的阈值
% thresholdIndex = floor(0.2 * length(sortedData));  % 前30%的索引
% thresholdValue = sortedData(thresholdIndex);  % 前30%的阈值
%
% % 找到第9列值大于等于阈值的行
% rowsInTop30Percent = resultTable{:, 9} >= thresholdValue;
%
% % 提取符合条件的行
% top30PercentRows = resultTable(rowsInTop30Percent, :);