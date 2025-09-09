%HR-CbAT%2024.6.13
%wangzhuofan  data analysis
%%%四个实验的预处理部分
%% T1
%% 删除休息段step1
clear;clc;
alldata=dir(['E:\EXP4\awzf_2024data\T1\','*.vhdr']);
for i =25%1:length(alldata)
    thisname=alldata(i).name;
    EEG = pop_loadbv('E:\EXP4\awzf_2024data\T1\', thisname, [], [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64]);
    EEG.setname=strcat(num2str(i));
    EEG = eeg_checkset( EEG );  %%
    % transfer boundary mark
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString',{ 'boundary' } );
    %Remove segments of EEG during the break periods in between trial blocks (defined as 2 seconds or longer in between successive stimulus event codes)
    EEG  = pop_erplabDeleteTimeSegments( EEG , 'displayEEG', 0, 'endEventcodeBufferMS', 3000, 'ignoreUseEventcodes',[1 21 22 3 10 20 30 40 102 100 101 4], 'ignoreUseType', 'Use', 'startEventcodeBufferMS',  3000, 'timeThresholdMS', 3000);
    EEG = eeg_checkset( EEG ); 
    %自定义命名
    if i<10
       setname2=strcat('sub0',num2str(i),'_Derest');  %%自定义重命名
    else
       setname2=strcat('sub',num2str(i),'_Derest');  %%自定义重命名
    end
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\S1_delete\');
    EEG = eeg_checkset( EEG );
end
fprintf('done!');


%% 滤波 重参考 使用erplab进行 step2
clear,clc; %eeglab
alldata=dir(['E:\EXP4\ana222\S1_delete\','*.set']);
for i=25%1:length(alldata)
     thisname=alldata(i).name;
      EEG = pop_loadset(thisname,'E:\EXP4\ana222\S1_delete\');
    % 滤波 
    EEG= pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );% Script: 13-Dec-2021 09:58:53
    EEG = eeg_checkset( EEG );
    EEG  = pop_basicfilter( EEG,  1:64 , 'Boundary', 'boundary', 'Cutoff', [0.1 30], 'Design', 'butter', 'Filter', 'bandpass', 'Order',  4 ); % GUI: 13-Dec-2021 10:15:09
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, 'locutoff',49,'hicutoff',51,'revfilt',1,'plotfreqz',1);  % Notch filter the data instead of pass band, 去除工频干扰（50Hz)
    EEG.setname=strcat(num2str(i),'_filter'); 
    EEG = eeg_checkset( EEG );   
    % 重参考
    EEG = pop_reref(EEG, [31 32]);   %%重参考，双侧乳突
    EEG.setname=strcat(EEG.setname,'_filter_refer'); 
    EEG = eeg_checkset( EEG );
    setname2=strcat(strtok(thisname(1:5),'.'),'_filter_refer.set');
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\S2_filter_re\');
    EEG = eeg_checkset( EEG );      
end
fprintf('done!');

%% 手动删除IO 
%eeglab
clear,clc;
alldata2=dir(['E:\EXP4\ana222\S2_filter_re\','*.set']);
for i=25%1:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\EXP4\ana222\S2_filter_re\');
    EEG = pop_select (EEG,'rmchannel',{'IO'});
    %保存
    setname2=strcat(strtok(thisname(1:5),'.'),'_filter_refer_deIO.set');
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\S3_deIO\');
    EEG = eeg_checkset( EEG );      
end
fprintf('done!');



%% T2
%% 删除休息段step1
clear;clc;
alldata=dir(['E:\EXP4\awzf_2024data\T2\','*.vhdr']);
for i =25%1:length(alldata)
    thisname=alldata(i).name;
    EEG = pop_loadbv('E:\EXP4\awzf_2024data\T2\', thisname, [], [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64]);
    EEG.setname=strcat(num2str(i));
    EEG = eeg_checkset( EEG );  %%
    % transfer boundary mark
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString',{ 'boundary' } );
    %Remove segments of EEG during the break periods in between trial blocks (defined as 2 seconds or longer in between successive stimulus event codes)
    EEG  = pop_erplabDeleteTimeSegments( EEG , 'displayEEG', 0, 'endEventcodeBufferMS', 3000, 'ignoreUseEventcodes',[1 21 22 3 10 20 30 40 102 100 101 4], 'ignoreUseType', 'Use', 'startEventcodeBufferMS',  3000, 'timeThresholdMS', 3000);
    EEG = eeg_checkset( EEG ); 
    %自定义命名
    if i<10
       setname2=strcat('sub0',num2str(i),'_Derest');  %%自定义重命名
    else
       setname2=strcat('sub',num2str(i),'_Derest');  %%自定义重命名
    end
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\T2_A\S1_delete\');
    EEG = eeg_checkset( EEG );
end
fprintf('done!');


%% 滤波 重参考 使用erplab进行 step2
clear,clc; %eeglab
alldata2=dir(['E:\EXP4\ana222\T2_A\S1_delete\','*.set']);
for i=25%23:length(alldata2)
     thisname=alldata2(i).name;
      EEG = pop_loadset(thisname,'E:\EXP4\ana222\T2_A\S1_delete\');
    % 滤波 
    EEG= pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );% Script: 13-Dec-2021 09:58:53
    EEG = eeg_checkset( EEG );
    EEG  = pop_basicfilter( EEG,  1:64 , 'Boundary', 'boundary', 'Cutoff', [0.1 30], 'Design', 'butter', 'Filter', 'bandpass', 'Order',  4 ); % GUI: 13-Dec-2021 10:15:09
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, 'locutoff',49,'hicutoff',51,'revfilt',1,'plotfreqz',1);  % Notch filter the data instead of pass band, 去除工频干扰（50Hz)
    EEG.setname=strcat(num2str(i),'_filter'); 
    EEG = eeg_checkset( EEG );   
    % 重参考
    EEG = pop_reref(EEG, [31 32]);   %%重参考，双侧乳突
    EEG.setname=strcat(EEG.setname,'_filter_refer'); 
    EEG = eeg_checkset( EEG );
    setname2=strcat(strtok(thisname(1:5),'.'),'_filter_refer.set');
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\T2_A\S2_filter_re\');
    EEG = eeg_checkset( EEG );      
end
fprintf('done!');

%% 手动删除IO 
%eeglab
clear,clc;
alldata2=dir(['E:\EXP4\ana222\T2_A\S2_filter_re\','*.set']);
for i=25%1:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\EXP4\ana222\T2_A\S2_filter_re\');
    EEG = pop_select (EEG,'rmchannel',{'IO'});
    %保存
    setname2=strcat(strtok(thisname(1:5),'.'),'_filter_refer_deIO.set');
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\T2_A\S3_deIO\');
    EEG = eeg_checkset( EEG );      
end
fprintf('done!');



%% T3
%% 删除休息段step1
clear;clc;
alldata=dir(['E:\EXP4\awzf_2024data\T3\','*.vhdr']);
for i =25%1:length(alldata)
    thisname=alldata(i).name;
    EEG = pop_loadbv('E:\EXP4\awzf_2024data\T3\', thisname, [], [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64]);
    EEG.setname=strcat(num2str(i));
    EEG = eeg_checkset( EEG );  %%
    % transfer boundary mark
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString',{ 'boundary' } );
    %Remove segments of EEG during the break periods in between trial blocks (defined as 2 seconds or longer in between successive stimulus event codes)
    EEG  = pop_erplabDeleteTimeSegments( EEG , 'displayEEG', 0, 'endEventcodeBufferMS', 3000, 'ignoreUseEventcodes',[1 21 22 3 10 20 30 40 102 100 101 4], 'ignoreUseType', 'Use', 'startEventcodeBufferMS',  3000, 'timeThresholdMS', 3000);
    EEG = eeg_checkset( EEG ); 
    %自定义命名
    if i<10
       setname2=strcat('sub0',num2str(i),'_Derest');  %%自定义重命名
    else
       setname2=strcat('sub',num2str(i),'_Derest');  %%自定义重命名
    end
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\T3_A\S1_delete\');
    EEG = eeg_checkset( EEG );
end
fprintf('done!');


%% 滤波 重参考 使用erplab进行 step2
clear,clc; %eeglab
alldata2=dir(['E:\EXP4\ana222\T3_A\S1_delete\','*.set']);
for i=25%ength(alldata2)
     thisname=alldata2(i).name;
      EEG = pop_loadset(thisname,'E:\EXP4\ana222\T3_A\S1_delete\');
    % 滤波 
    EEG= pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );% Script: 13-Dec-2021 09:58:53
    EEG = eeg_checkset( EEG );
    EEG  = pop_basicfilter( EEG,  1:64 , 'Boundary', 'boundary', 'Cutoff', [0.1 30], 'Design', 'butter', 'Filter', 'bandpass', 'Order',  4 ); % GUI: 13-Dec-2021 10:15:09
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, 'locutoff',49,'hicutoff',51,'revfilt',1,'plotfreqz',1);  % Notch filter the data instead of pass band, 去除工频干扰（50Hz)
    EEG.setname=strcat(num2str(i),'_filter'); 
    EEG = eeg_checkset( EEG );   
    % 重参考
    EEG = pop_reref(EEG, [31 32]);   %%重参考，双侧乳突
    EEG.setname=strcat(EEG.setname,'_filter_refer'); 
    EEG = eeg_checkset( EEG );
    setname2=strcat(strtok(thisname(1:5),'.'),'_filter_refer.set');
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\T3_A\S2_filter_re\');
    EEG = eeg_checkset( EEG );      
end
fprintf('done!');

%% 手动删除IO 
%eeglab
clear,clc;
alldata2=dir(['E:\EXP4\ana222\T3_A\S2_filter_re\','*.set']);
for i=25%1:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\EXP4\ana222\T3_A\S2_filter_re\');
    EEG = pop_select (EEG,'rmchannel',{'IO'});
    %保存
    setname2=strcat(strtok(thisname(1:5),'.'),'_filter_refer_deIO.set');
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\T3_A\S3_deIO\');
    EEG = eeg_checkset( EEG );      
end
fprintf('done!');


%% T4
%% 删除休息段step1
clear;clc;
alldata=dir(['E:\EXP4\awzf_2024data\T4\','*.vhdr']);
for i =25%1:length(alldata)
    thisname=alldata(i).name;
    EEG = pop_loadbv('E:\EXP4\awzf_2024data\T4\', thisname, [], [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64]);
    EEG.setname=strcat(num2str(i));
    EEG = eeg_checkset( EEG );  %%
    % transfer boundary mark
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString',{ 'boundary' } );
    %Remove segments of EEG during the break periods in between trial blocks (defined as 2 seconds or longer in between successive stimulus event codes)
    EEG  = pop_erplabDeleteTimeSegments( EEG , 'displayEEG', 0, 'endEventcodeBufferMS', 3000, 'ignoreUseEventcodes',[1 21 22 3 10 20 30 40 102 100 101 4], 'ignoreUseType', 'Use', 'startEventcodeBufferMS',  3000, 'timeThresholdMS', 3000);
    EEG = eeg_checkset( EEG ); 
    %自定义命名
    if i<10
       setname2=strcat('sub0',num2str(i),'_Derest');  %%自定义重命名
    else
       setname2=strcat('sub',num2str(i),'_Derest');  %%自定义重命名
    end
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\T4_A\S1_delete\');
    EEG = eeg_checkset( EEG );
end
fprintf('done!');


%% 滤波 重参考 使用erplab进行 step2
clear,clc; %eeglab
alldata2=dir(['E:\EXP4\ana222\T4_A\S1_delete\','*.set']);
for i=25%1:length(alldata2)
     thisname=alldata2(i).name;
      EEG = pop_loadset(thisname,'E:\EXP4\ana222\T4_A\S1_delete\');
    % 滤波 
    EEG= pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );% Script: 13-Dec-2021 09:58:53
    EEG = eeg_checkset( EEG );
    EEG  = pop_basicfilter( EEG,  1:64 , 'Boundary', 'boundary', 'Cutoff', [0.1 30], 'Design', 'butter', 'Filter', 'bandpass', 'Order',  4 ); % GUI: 13-Dec-2021 10:15:09
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, 'locutoff',49,'hicutoff',51,'revfilt',1,'plotfreqz',1);  % Notch filter the data instead of pass band, 去除工频干扰（50Hz)
    EEG.setname=strcat(num2str(i),'_filter'); 
    EEG = eeg_checkset( EEG );   
    % 重参考
    EEG = pop_reref(EEG, [31 32]);   %%重参考，双侧乳突
    EEG.setname=strcat(EEG.setname,'_filter_refer'); 
    EEG = eeg_checkset( EEG );
    setname2=strcat(strtok(thisname(1:5),'.'),'_filter_refer.set');
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\T4_A\S2_filter_re\');
    EEG = eeg_checkset( EEG );      
end
fprintf('done!');

%% 手动删除IO 
%eeglab
clear,clc;
alldata2=dir(['E:\EXP4\ana222\T4_A\S2_filter_re\','*.set']);
for i=25%1:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\EXP4\ana222\T4_A\S2_filter_re\');
    EEG = pop_select (EEG,'rmchannel',{'IO'});
    %保存
    setname2=strcat(strtok(thisname(1:5),'.'),'_filter_refer_deIO.set');
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\T4_A\S3_deIO\');
    EEG = eeg_checkset( EEG );      
end
fprintf('done!');



%% 插值坏道
eeglab
%还是保存再第二部的文件里面



%% T1 
%% 分段 基线校正 step6
clear,clc; %eeglab
alldata2=dir(['E:\EXP4\ana222\S3_deIO\','*.set']); %alldata2(1:2)=[];
for i=25%2:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\EXP4\ana222\S3_deIO\');   %将set转化为mat文件
    %创建mark
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist',...
        ['E:\EXP4\ana222\eventlist.txt'] ); 
    EEG = eeg_checkset( EEG );
    %创建bin
    EEG  = pop_binlister( EEG , 'BDF', 'E:\EXP4\ana222\bin.txt', 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' ); 
    EEG = eeg_checkset( EEG );
    %分段和基线校正
    EEG = pop_epochbin( EEG , [-600 800],  [-600 -400]);
    EEG = eeg_checkset( EEG );
    %保存
    setname2=strcat(strtok(thisname,'.'),'_epocbin.set'); 
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\S4_bin_baseline\');
    EEG = eeg_checkset( EEG );
end
fprintf('done!');
%% run ica 使用eeglab进行 step4
clear,clc;
alldata2=dir(['E:\EXP4\ana222\S4_bin_baseline\','*.set']);
for i=25%19:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\EXP4\ana222\S4_bin_baseline\');
    % 执行ica
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'pca',30,'interrupt','on');
    EEG = eeg_checkset( EEG );
    % 自动识别ica成分
    EEG = pop_iclabel(EEG, 'default');
    EEG = eeg_checkset( EEG );
    % eye 和 muscle 占90%以上的成分 标记为拒绝
    EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]); 
    EEG = eeg_checkset( EEG );
    % 保存
    setname2=strcat(strtok(thisname,'.'),'_ica.set');  %% setname3=EEG.filename;
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\S5_run icas\');
    EEG = eeg_checkset( EEG );
end
fprintf('done!');


%% 删除已标记的成分 %eeglab step5
clear,clc; 
alldata2=dir(['E:\EXP4\ana222\S5_run icas\','*.set']);
numRej=[];
for i=24%1:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\EXP4\ana222\S5_run icas\');
    EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);   %重新标记成分 只删除eye 20220114  %删除eye和muscle 报告删除成分平均值即可
    numComponent = 1:30;numComponent=numComponent';
    icaCompo = EEG.reject.gcompreject;           %此变量存放拒绝和接受的成分逻辑信息  拒绝成分标为1
    RejectCompo = numComponent(icaCompo==1)';
    anumRej=length(RejectCompo);
    numRej=[numRej;anumRej];                     %存储去除成分数量
    EEG = pop_subcomp( EEG,RejectCompo, 0);     %去除成分
    EEG = eeg_checkset( EEG );
    % 保存
    setname2=strcat(strtok(thisname,'.'),'_Rej.set'); 
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\S6_ica_reject\');
    EEG = eeg_checkset( EEG );
end
fprintf('done!');


%% 伪影检测 step7
clear,clc; %eeglab
alldata2=dir(['E:\EXP4\ana222\S6_ica_reject\','*.set']); %alldata2(1:2)=[];
for i=24%1:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\EXP4\ana222\S6_ica_reject\');
    %简单电压阈值函数 商业软件常用 -100-100
    EEG  = pop_artextval( EEG , 'Channel', 1:58, 'Flag',  1, 'Threshold', [-100 100], 'Twindow',[-600 800]);
    EEG = eeg_checkset( EEG );
    %保存伪影检测拒绝率
    ARfilepath=strcat('E:\EXP4\ana222\weiyingrefuse%\',thisname(1:5),'_AR.txt');
    pop_summary_AR_eeg_detection(EEG,ARfilepath);
    setname2=strcat(strtok(thisname,'.'),'_AR.set'); 
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\S7_refuse_artificREJ\');
    EEG = eeg_checkset( EEG );
end
fprintf('done!');





%% T2 T3 T4
%% 分段 基线校正 step6
clear,clc; %eeglab
alldata2=dir(['E:\EXP4\ana222\T2_A\S3_deIO\','*.set']); %alldata2(1:2)=[];
for i=25%2:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\EXP4\ana222\T2_A\S3_deIO\');   %将set转化为mat文件
    %创建mark
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist',...
        ['E:\EXP4\ana222\eventlist.txt'] ); 
    EEG = eeg_checkset( EEG );
    %创建bin
    EEG  = pop_binlister( EEG , 'BDF', 'E:\EXP4\ana222\bin.txt', 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' ); 
    EEG = eeg_checkset( EEG );
    %分段和基线校正
    EEG = pop_epochbin( EEG , [-600 800],  [-600 -400]);
    EEG = eeg_checkset( EEG );
    %保存
    setname2=strcat(strtok(thisname,'.'),'_epocbin.set'); 
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\T2_A\S4_bin_baseline\');
    EEG = eeg_checkset( EEG );
end
fprintf('done!');


%% 分段 基线校正 step6
clear,clc; %eeglab
alldata2=dir(['E:\EXP4\ana222\T3_A\S3_deIO\','*.set']); %alldata2(1:2)=[];
for i=25%2:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\EXP4\ana222\T3_A\S3_deIO\');   %将set转化为mat文件
    %创建mark
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist',...
        ['E:\EXP4\ana222\eventlist.txt'] ); 
    EEG = eeg_checkset( EEG );
    %创建bin
    EEG  = pop_binlister( EEG , 'BDF', 'E:\EXP4\ana222\bin.txt', 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' ); 
    EEG = eeg_checkset( EEG );
    %分段和基线校正
    EEG = pop_epochbin( EEG , [-600 800],  [-600 -400]);
    EEG = eeg_checkset( EEG );
    %保存
    setname2=strcat(strtok(thisname,'.'),'_epocbin.set'); 
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\T3_A\S4_bin_baseline\');
    EEG = eeg_checkset( EEG );
end
fprintf('done!');


%% 分段 基线校正 step6
clear,clc; %eeglab
alldata2=dir(['E:\EXP4\ana222\T4_A\S3_deIO\','*.set']); %alldata2(1:2)=[];
for i=25%2:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\EXP4\ana222\T4_A\S3_deIO\');   %将set转化为mat文件
    %创建mark
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist',...
        ['E:\EXP4\ana222\eventlist.txt'] ); 
    EEG = eeg_checkset( EEG );
    %创建bin
    EEG  = pop_binlister( EEG , 'BDF', 'E:\EXP4\ana222\bin.txt', 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' ); 
    EEG = eeg_checkset( EEG );
    %分段和基线校正
    EEG = pop_epochbin( EEG , [-600 800],  [-600 -400]);
    EEG = eeg_checkset( EEG );
    %保存
    setname2=strcat(strtok(thisname,'.'),'_epocbin.set'); 
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\T4_A\S4_bin_baseline\');
    EEG = eeg_checkset( EEG );
end
fprintf('done!');






%% T2
%% run ica 使用eeglab进行 step4
clear,clc;
alldata2=dir(['E:\EXP4\ana222\T2_A\S4_bin_baseline\','*.set']);
for i=24%1:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\EXP4\ana222\T2_A\S4_bin_baseline\');
    % 执行ica
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'pca',30,'interrupt','on');
    EEG = eeg_checkset( EEG );
    % 自动识别ica成分
    EEG = pop_iclabel(EEG, 'default');
    EEG = eeg_checkset( EEG );
    % eye 和 muscle 占90%以上的成分 标记为拒绝
    EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]); 
    EEG = eeg_checkset( EEG );
    % 保存
    setname2=strcat(strtok(thisname,'.'),'_ica.set');  %% setname3=EEG.filename;
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\T2_A\S5_run icas\');
    EEG = eeg_checkset( EEG );
end


%% 删除已标记的成分 %eeglab step5
clear,clc; 
alldata2=dir(['E:\EXP4\ana222\T2_A\S5_run icas\','*.set']);
numRej=[];
for i=24%1:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\EXP4\ana222\T2_A\S5_run icas\');
    EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);   %重新标记成分 只删除eye 20220114  %删除eye和muscle 报告删除成分平均值即可
    numComponent = 1:30;numComponent=numComponent';
    icaCompo = EEG.reject.gcompreject;           %此变量存放拒绝和接受的成分逻辑信息  拒绝成分标为1
    RejectCompo = numComponent(icaCompo==1)';
    anumRej=length(RejectCompo);
    numRej=[numRej;anumRej];                     %存储去除成分数量
    EEG = pop_subcomp( EEG,RejectCompo, 0);     %去除成分
    EEG = eeg_checkset( EEG );
    % 保存
    setname2=strcat(strtok(thisname,'.'),'_Rej.set'); 
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\T2_A\S6_ica_reject\');
    EEG = eeg_checkset( EEG );
end



%% 伪影检测 step7
clear,clc; %eeglab
alldata2=dir(['E:\EXP4\ana222\T2_A\S6_ica_reject\','*.set']); %alldata2(1:2)=[];
for i=24%1:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\EXP4\ana222\T2_A\S6_ica_reject\');
    %简单电压阈值函数 商业软件常用 -100-100
    EEG  = pop_artextval( EEG , 'Channel', 1:58, 'Flag',  1, 'Threshold', [-100 100], 'Twindow',[-600 800]);
    EEG = eeg_checkset( EEG );
    %保存伪影检测拒绝率
    ARfilepath=strcat('E:\EXP4\ana222\T2_A\weiyingrefuse%\',thisname(1:5),'_AR.txt');
    pop_summary_AR_eeg_detection(EEG,ARfilepath);
    setname2=strcat(strtok(thisname,'.'),'_AR.set'); 
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\T2_A\S7_refuse_artificREJ\');
    EEG = eeg_checkset( EEG );
end
fprintf('done!');


%% T3
%% run ica 使用eeglab进行 step4
clear,clc;
alldata2=dir(['E:\EXP4\ana222\T3_A\S4_bin_baseline\','*.set']);
for i=24%1:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\EXP4\ana222\T3_A\S4_bin_baseline\');
    % 执行ica
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'pca',30,'interrupt','on');
    EEG = eeg_checkset( EEG );
    % 自动识别ica成分
    EEG = pop_iclabel(EEG, 'default');
    EEG = eeg_checkset( EEG );
    % eye 和 muscle 占90%以上的成分 标记为拒绝
    EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]); 
    EEG = eeg_checkset( EEG );
    % 保存
    setname2=strcat(strtok(thisname,'.'),'_ica.set');  %% setname3=EEG.filename;
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\T3_A\S5_run icas\');
    EEG = eeg_checkset( EEG );
end
fprintf('done!');


%% 删除已标记的成分 %eeglab step5
clear,clc; 
alldata2=dir(['E:\EXP4\ana222\T3_A\S5_run icas\','*.set']);
numRej=[];
for i=24%1:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\EXP4\ana222\T3_A\S5_run icas\');
    EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);   %重新标记成分 只删除eye 20220114  %删除eye和muscle 报告删除成分平均值即可
    numComponent = 1:30;numComponent=numComponent';
    icaCompo = EEG.reject.gcompreject;           %此变量存放拒绝和接受的成分逻辑信息  拒绝成分标为1
    RejectCompo = numComponent(icaCompo==1)';
    anumRej=length(RejectCompo);
    numRej=[numRej;anumRej];                     %存储去除成分数量
    EEG = pop_subcomp( EEG,RejectCompo, 0);     %去除成分
    EEG = eeg_checkset( EEG );
    % 保存
    setname2=strcat(strtok(thisname,'.'),'_Rej.set'); 
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\T3_A\S6_ica_reject\');
    EEG = eeg_checkset( EEG );
end
fprintf('done!');


%% 伪影检测 step7
clear,clc; %eeglab
alldata2=dir(['E:\EXP4\ana222\T3_A\S6_ica_reject\','*.set']); %alldata2(1:2)=[];
for i=24%1:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\EXP4\ana222\T3_A\S6_ica_reject\');
    %简单电压阈值函数 商业软件常用 -100-100
    EEG  = pop_artextval( EEG , 'Channel', 1:58, 'Flag',  1, 'Threshold', [-100 100], 'Twindow',[-600 800]);
    EEG = eeg_checkset( EEG );
    %保存伪影检测拒绝率
    ARfilepath=strcat('E:\EXP4\ana222\T3_A\weiyingrefuse%\',thisname(1:5),'_AR.txt');
    pop_summary_AR_eeg_detection(EEG,ARfilepath);
    setname2=strcat(strtok(thisname,'.'),'_AR.set'); 
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\T3_A\S7_refuse_artificREJ\');
    EEG = eeg_checkset( EEG );
end
fprintf('done!');

%% T4
%% run ica 使用eeglab进行 step4
clear,clc;
alldata2=dir(['E:\EXP4\ana222\T4_A\S4_bin_baseline\','*.set']);
for i=24%1:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\EXP4\ana222\T4_A\S4_bin_baseline\');
    % 执行ica
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'pca',30,'interrupt','on');
    EEG = eeg_checkset( EEG );
    % 自动识别ica成分
    EEG = pop_iclabel(EEG, 'default');
    EEG = eeg_checkset( EEG );
    % eye 和 muscle 占90%以上的成分 标记为拒绝
    EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]); 
    EEG = eeg_checkset( EEG );
    % 保存
    setname2=strcat(strtok(thisname,'.'),'_ica.set');  %% setname3=EEG.filename;
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\T4_A\S5_run icas\');
    EEG = eeg_checkset( EEG );
end
fprintf('done!');


%% 删除已标记的成分 %eeglab step5
clear,clc; 
alldata2=dir(['E:\EXP4\ana222\T4_A\S5_run icas\','*.set']);
numRej=[];
for i=1:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\EXP4\ana222\T4_A\S5_run icas\');
    EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);   %重新标记成分 只删除eye 20220114  %删除eye和muscle 报告删除成分平均值即可
    numComponent = 1:30;numComponent=numComponent';
    icaCompo = EEG.reject.gcompreject;           %此变量存放拒绝和接受的成分逻辑信息  拒绝成分标为1
    RejectCompo = numComponent(icaCompo==1)';
    anumRej=length(RejectCompo);
    numRej=[numRej;anumRej];                     %存储去除成分数量
    EEG = pop_subcomp( EEG,RejectCompo, 0);     %去除成分
    EEG = eeg_checkset( EEG );
    % 保存
    setname2=strcat(strtok(thisname,'.'),'_Rej.set'); 
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\T4_A\S6_ica_reject\');
    EEG = eeg_checkset( EEG );
end
fprintf('done!');


%% 伪影检测 step7
clear,clc; %eeglab
alldata2=dir(['E:\EXP4\ana222\T4_A\S6_ica_reject\','*.set']); %alldata2(1:2)=[];
for i=24%1:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\EXP4\ana222\T4_A\S6_ica_reject\');
    %简单电压阈值函数 商业软件常用 -100-100
    EEG  = pop_artextval( EEG , 'Channel', 1:61, 'Flag',  1, 'Threshold', [-100 100], 'Twindow',[-600 800]);
    EEG = eeg_checkset( EEG );
    %保存伪影检测拒绝率
    ARfilepath=strcat('E:\EXP4\ana222\T4_A\weiyingrefuse%\',thisname(1:5),'_AR.txt');
    pop_summary_AR_eeg_detection(EEG,ARfilepath);
    setname2=strcat(strtok(thisname,'.'),'_AR.set'); 
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\EXP4\ana222\T4_A\S7_refuse_artificREJ\');
    EEG = eeg_checkset( EEG );
end
fprintf('done!');

%% 
eeglab


