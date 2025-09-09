%%% audio
%% ERP����
%% ɾ����Ϣ��
clear;clc;
alldata=dir(['E:\Ԥ��ʵ������audio\�Ե�\rawdata\','*.vhdr']);
for i = 28:length(alldata)
    thisname=alldata(i).name;
    %setname1=strcat('a00',num2str(i),'.vhdr');
    EEG = pop_loadbv('E:\Ԥ��ʵ������audio\�Ե�\rawdata\', thisname, [], [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64]);
    EEG.setname=strcat(num2str(i));
    EEG = eeg_checkset( EEG );  %%
    % transfer boundary mark
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString',{ 'boundary' } );
    %Remove segments of EEG during the break periods in between trial blocks (defined as 2 seconds or longer in between successive stimulus event codes)
    EEG  = pop_erplabDeleteTimeSegments( EEG , 'displayEEG', 0, 'endEventcodeBufferMS', 3000, 'ignoreUseEventcodes',[1 2 3 4 8 9 5 21 22 41 42], 'ignoreUseType', 'Use', 'startEventcodeBufferMS',  3000, 'timeThresholdMS', 3000);
    EEG = eeg_checkset( EEG ); 
    %�Զ�������
    if i<10
        setname2=strcat('sub00',num2str(i),'_Derest');  %%�Զ���������
    else
        setname2=strcat('sub0',num2str(i),'_Derest');  %%�Զ���������
    end
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\Ԥ��ʵ������audio\�Ե�\DeRest');
    EEG = eeg_checkset( EEG );
end
fprintf('done!');
%% �˲� �زο� ʹ��erplab����
clear,clc; %eeglab
alldata2=dir(['E:\Ԥ��ʵ������audio\�Ե�\DeRest\','*.set']);
for i=28:length(alldata2)
     thisname=alldata2(i).name;
      EEG = pop_loadset(thisname,'E:\Ԥ��ʵ������audio\�Ե�\DeRest\');
      %�˲� �زο�
      EEG= pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );% Script: 13-Dec-2021 09:58:53
      EEG = eeg_checkset( EEG );
      EEG  = pop_basicfilter( EEG,  1:64 , 'Boundary', 'boundary', 'Cutoff', [0.1 45], 'Design', 'butter', 'Filter', 'bandpass', 'Order',  4 ); % GUI: 13-Dec-2021 10:15:09
      EEG.setname=strcat(num2str(i),'_filter'); 
      EEG = eeg_checkset( EEG );
%       EEG = pop_eegchanoperator( EEG, {  'nch1 = ch1 - ( avgchan( 1:64) ) Label Fp1',  'nch2 = ch2 - ( avgchan( 1:64) ) Label Fp2',  'nch3 = ch3 - ( avgchan( 1:64) ) Label F3',  'nch4 = ch4 - ( avgchan( 1:64) ) Label F4',  'nch5 = ch5 - ( avgchan( 1:64) ) Label C3',  'nch6 = ch6 - ( avgchan( 1:64) ) Label C4',  'nch7 = ch7 - ( avgchan( 1:64) ) Label P3',  'nch8 = ch8 - ( avgchan( 1:64) ) Label P4',  'nch9 = ch9 - ( avgchan( 1:64) ) Label O1',  'nch10 = ch10 - ( avgchan( 1:64) ) Label O2',  'nch11 = ch11 - ( avgchan( 1:64) ) Label F7',  'nch12 = ch12 - ( avgchan( 1:64) ) Label F8',  'nch13 = ch13 - ( avgchan( 1:64) ) Label T7',  'nch14 = ch14 - ( avgchan( 1:64) ) Label T8',  'nch15 = ch15 - ( avgchan( 1:64) ) Label P7',  'nch16 = ch16 - ( avgchan( 1:64) ) Label P8',  'nch17 = ch17 - ( avgchan( 1:64) ) Label Fz',  'nch18 = ch18 - ( avgchan( 1:64) ) Label Cz',  'nch19 = ch19 - ( avgchan( 1:64) ) Label Pz',  'nch20 = ch20 Label IO',  'nch21 = ch21 - ( avgchan( 1:64) ) Label FC1',  'nch22 = ch22 - ( avgchan( 1:64) ) Label FC2',  'nch23 = ch23 - ( avgchan( 1:64) ) Label CP1',  'nch24 = ch24 - ( avgchan( 1:64) ) Label CP2',  'nch25 = ch25 - ( avgchan( 1:64) ) Label FC5',  'nch26 = ch26 - ( avgchan( 1:64) ) Label FC6',  'nch27 = ch27 - ( avgchan( 1:64) ) Label CP5',  'nch28 = ch28 - ( avgchan( 1:64) ) Label CP6',  'nch29 = ch29 - ( avgchan( 1:64) ) Label FT9',  'nch30 = ch30 - ( avgchan( 1:64) ) Label FT10',  'nch31 = ch31 - ( avgchan( 1:64) ) Label TP9',  'nch32 = ch32 - ( avgchan( 1:64) ) Label TP10',  'nch33 = ch33 - ( avgchan( 1:64) ) Label F1',  'nch34 = ch34 - ( avgchan( 1:64) ) Label F2',  'nch35 = ch35 - ( avgchan( 1:64) ) Label C1',  'nch36 = ch36 - ( avgchan( 1:64) ) Label C2',  'nch37 = ch37 - ( avgchan( 1:64) ) Label P1',  'nch38 = ch38 - ( avgchan( 1:64) ) Label P2',  'nch39 = ch39 - ( avgchan( 1:64) ) Label AF3',  'nch40 = ch40 - ( avgchan( 1:64) ) Label AF4',  'nch41 = ch41 - ( avgchan( 1:64) ) Label FC3',  'nch42 = ch42 - ( avgchan( 1:64) ) Label FC4',  'nch43 = ch43 - ( avgchan( 1:64) ) Label CP3',  'nch44 = ch44 - ( avgchan( 1:64) ) Label CP4',  'nch45 = ch45 - ( avgchan( 1:64) ) Label PO3',  'nch46 = ch46 - ( avgchan( 1:64) ) Label PO4',  'nch47 = ch47 - ( avgchan( 1:64) ) Label F5',  'nch48 = ch48 - ( avgchan( 1:64) ) Label F6',  'nch49 = ch49 - ( avgchan( 1:64) ) Label C5',  'nch50 = ch50 - ( avgchan( 1:64) ) Label C6',  'nch51 = ch51 - ( avgchan( 1:64) ) Label P5',  'nch52 = ch52 - ( avgchan( 1:64) ) Label P6',  'nch53 = ch53 - ( avgchan( 1:64) ) Label AF7',  'nch54 = ch54 - ( avgchan( 1:64) ) Label AF8',  'nch55 = ch55 - ( avgchan( 1:64) ) Label FT7',  'nch56 = ch56 - ( avgchan( 1:64) ) Label FT8',  'nch57 = ch57 - ( avgchan( 1:64) ) Label TP7',  'nch58 = ch58 - ( avgchan( 1:64) ) Label TP8',  'nch59 = ch59 - ( avgchan( 1:64) ) Label PO7',  'nch60 = ch60 - ( avgchan( 1:64) ) Label PO8',  'nch61 = ch61 - ( avgchan( 1:64) ) Label Fpz',  'nch62 = ch62 - ( avgchan( 1:64) ) Label CPz',  'nch63 = ch63 - ( avgchan( 1:64) ) Label POz',  'nch64 = ch64 - ( avgchan( 1:64) ) Label Oz'} , 'ErrorMsg', 'popup', 'Warning', 'on' ); % GUI: 13-Dec-2021 10:16:39
      EEG = pop_reref( EEG, []);  %ȫ��ƽ���ο�
      EEG.setname=strcat(num2str(i),'_filter_refer');
      EEG = eeg_checkset( EEG );
      setname2=strcat(strtok(thisname(1:7),'.'),'_filter_refer.set');
      EEG = eeg_checkset( EEG );
      EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\Ԥ��ʵ������audio\�Ե�\prestep1');
      EEG = eeg_checkset( EEG );
end
fprintf('done!');
%% run ica ʹ��eeglab����
clear,clc; %eeglab
alldata2=dir(['E:\Ԥ��ʵ������audio\�Ե�\prestep1\','*.set']);
for i=28:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\Ԥ��ʵ������audio\�Ե�\prestep1\');
    %channel location ǰ����erplab��location��� ���¶�λһ��
%     EEG=pop_chanedit(EEG, 'load',{'E:\\Ԥ��ʵ�����ݴ���\\�Ե�\\anabrain1\\channellocation.ced','filetype','autodetect'});
%     EEG = eeg_checkset( EEG );
    % ִ��ica
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'pca',30,'interrupt','on');
    EEG = eeg_checkset( EEG );
    % �Զ�ʶ��ica�ɷ�
    EEG = pop_iclabel(EEG, 'default');
    EEG = eeg_checkset( EEG );
    % eye �� muscle ռ90%���ϵĳɷ� ���Ϊ�ܾ�
    EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]); 
    EEG = eeg_checkset( EEG );
    % ����
    setname2=strcat(strtok(thisname,'.'),'_ica.set');  %% setname3=EEG.filename;
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\Ԥ��ʵ������audio\�Ե�\prestep2');
    EEG = eeg_checkset( EEG );
end
%ɾ���ѱ�ǵĳɷ�
clear,clc; %eeglab
% alldata2=dir(['E:\Ԥ��ʵ�����ݴ���\�Ե�\anabrain1\pre_step2\','*.set']);
alldata2=dir(['E:\Ԥ��ʵ������audio\�Ե�\prestep2\','*.set']);
numRej=[];
for i=1:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\Ԥ��ʵ������audio\�Ե�\prestep2\');
    EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);   %���±�ǳɷ� ֻɾ��eye 20220114  %ɾ��eye��muscle ����ɾ���ɷ�ƽ��ֵ����
    numComponent = 1:30;numComponent=numComponent';
    icaCompo = EEG.reject.gcompreject;           %�˱�����žܾ��ͽ��ܵĳɷ��߼���Ϣ  �ܾ��ɷֱ�Ϊ1
    RejectCompo = numComponent(icaCompo==1)';
    anumRej=length(RejectCompo);
    numRej=[numRej;anumRej];                     %�洢ȥ���ɷ�����
    EEG = pop_subcomp( EEG,RejectCompo, 0);     %ȥ���ɷ�
    EEG = eeg_checkset( EEG );
    % ����
    setname2=strcat(strtok(thisname,'.'),'Rej.set'); 
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\Ԥ��ʵ������audio\�Ե�\prestep3');
    EEG = eeg_checkset( EEG );
end
%% �̼����� -200 800
%% �ֶ� ����У��
clear,clc; %eeglab
alldata2=dir(['E:\Ԥ��ʵ������audio\�Ե�\prestep3\','*.set']); 
for i=1:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\Ԥ��ʵ������audio\�Ե�\prestep3\');
    %����mark
    EEG  = pop_editeventlist( EEG , 'AlphanumericCleaning', 'on', 'List', 'E:\Ԥ��ʵ������audio\�Ե�\anabrainuse\Elist.txt', 'SendEL2', 'EEG', 'UpdateEEG', 'askUser', 'Warning', 'on' ); 
    EEG = eeg_checkset( EEG );
    %����bin
    EEG  = pop_binlister( EEG , 'BDF', 'E:\Ԥ��ʵ������audio\�Ե�\anabrainuse\BinlistStimu.txt', 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' ); 
    EEG = eeg_checkset( EEG );
    %�ֶκͻ���У��
%     EEG = pop_epochbin( EEG , [-1000.0  100.0],  'post');
     EEG = pop_epochbin( EEG , [-200 800],  'pre');
    EEG = eeg_checkset( EEG );
    %����
    setname2=strcat(strtok(thisname,'.'),'_epocbin.set'); 
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\stimulock-200_800\Pre1Epoch');
    EEG = eeg_checkset( EEG );
end
%% αӰ���
clear,clc; %eeglab
alldata2=dir(['E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\stimulock-200_800\Pre1Epoch\','*.set']); 
for i=28:39%1:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\stimulock-200_800\Pre1Epoch\');
    %�򵥵�ѹ��ֵ���� ��ҵ������� -100-100
    EEG  = pop_artextval( EEG , 'Channel', [1:19 21:64], 'Flag',  1, 'Threshold', [ -100 100], 'Twindow', [-200 800] );
    EEG = eeg_checkset( EEG );
    %����αӰ���ܾ���
%     ARfilepath=strcat('E:\Ԥ��ʵ�����ݴ���\�Ե�\anabrain1\Summary_AR\',thisname(1:6),'_AR.txt');
%     pop_summary_AR_eeg_detection(EEG,ARfilepath);
%     setname2=strcat(strtok(thisname,'.'),'_AR.set'); 
%     EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\Ԥ��ʵ�����ݴ���\�Ե�\anabrain1\pre_step5');
%     EEG = eeg_checkset( EEG );
    ARfilepath=strcat('E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\stimulock-200_800\αӰ�ܾ���\',thisname(1:6),'_AR.txt');
    pop_summary_AR_eeg_detection(EEG,ARfilepath);
    setname2=strcat(strtok(thisname,'.'),'_AR.set'); 
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\stimulock-200_800\Pre2ArticficRej');
    EEG = eeg_checkset( EEG );
end
%% ƽ�� ѡ����һ������
clear,clc; %eeglab
alldata2=dir(['E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\stimulock-200_800\Pre2ArticficRej\','*.set']); 
for i=1:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\stimulock-200_800\Pre2ArticficRej\');
    ERP = pop_averager( EEG , 'Criterion', 'good', 'DQ_flag', 1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
    aerpname=strcat(thisname(1:6),'_erp');
    afilename=strcat(thisname(1:6),'_erp.erp'); 
    ERP = pop_savemyerp(ERP, 'erpname',aerpname, 'filename',afilename, 'filepath', 'E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\stimulock-200_800\AverageERP\Allerp', 'Warning', 'on');
end
% ��ʵ������trial����ƽ����� ÿ��������ͨ����*ʱ���
    alldata2=dir(['E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\stimulock-200_800\AverageERP\Allerp\','*.erp']);
  for i=1:length(alldata2)
    S1=[];S2=[];S3=[];S4=[];adata=[];
    thisname=alldata2(i).name;
    ERP = pop_loaderp( 'filename', thisname, 'filepath', 'E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\stimulock-200_800\AverageERP\Allerp\' );
    adata = ERP.bindata;
    %����1
    S1 = adata(:,:,1);
    savename=[thisname(1:6),'_AVG_','S1'];
    eval([savename,'=S1;']);
    save(['E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\stimulock-200_800\AverageERP\S1\',savename,'.mat'],savename);
     %����2
    S2 = adata(:,:,2);
    savename=[thisname(1:6),'_AVG_','S2'];
    eval([savename,'=S2;']);
    save(['E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\stimulock-200_800\AverageERP\S2\',savename,'.mat'],savename);
     %����3
    S3 = adata(:,:,3);
    savename=[thisname(1:6),'_AVG_','S3'];
    eval([savename,'=S3;']);
    save(['E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\stimulock-200_800\AverageERP\S3\',savename,'.mat'],savename);
     %����4
    S4 = adata(:,:,4);
    savename=[thisname(1:6),'_AVG_','S4'];
    eval([savename,'=S4;']);
    save(['E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\stimulock-200_800\AverageERP\S4\',savename,'.mat'],savename);
  end
%% ��Ӧ���� -1000-200
%% �ֶ� ����У�� 
clear,clc; %eeglab
alldata2=dir(['E:\Ԥ��ʵ������audio\�Ե�\prestep3\','*.set']); 
for i=1:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\Ԥ��ʵ������audio\�Ե�\prestep3\');
    %����mark
  EEG  = pop_editeventlist( EEG , 'AlphanumericCleaning', 'on', 'List', 'E:\Ԥ��ʵ������audio\�Ե�\anabrainuse\Elist.txt', 'SendEL2', 'EEG', 'UpdateEEG', 'askUser', 'Warning', 'on' ); 
    EEG = eeg_checkset( EEG );
    %����bin
    EEG  = pop_binlister( EEG , 'BDF', 'E:\Ԥ��ʵ������audio\�Ե�\anabrainuse\BinlistResp.txt', 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' ); 
    EEG = eeg_checkset( EEG );
    %�ֶκͻ���У��
    EEG = pop_epochbin( EEG , [-1000.0  200.0],  [-1000 -800]); 
    EEG = eeg_checkset( EEG );
    %����
    setname2=strcat(strtok(thisname,'.'),'_epocbin.set'); 
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\resplock-1000_200\Pre1Epoch');
    EEG = eeg_checkset( EEG );
end
%% αӰ���
clear,clc; %eeglab
alldata2=dir(['E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\resplock-1000_200\Pre1Epoch\','*.set']); 
for i=1:length(alldata2)
    thisname=alldata2(i).name;
    EEG = pop_loadset(thisname,'E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\resplock-1000_200\Pre1Epoch\');
    %�ƶ����ڷ��ֵ��� �����)  100uv
%     EEG  = pop_artmwppth( EEG , 'Channel', [ 1:19 21:64], 'Flag',  1, 'Threshold',  100, 'Twindow', [ -200 598], 'Windowsize',  200, 'Windowstep',  100 ); % GUI: 14-Dec-2021 20:33:48
%     EEG = eeg_checkset( EEG );
    %�򵥵�ѹ��ֵ���� ��ҵ������� -100-100
    EEG  = pop_artextval( EEG , 'Channel', [ 1:19 21:64], 'Flag',  1, 'Threshold', [ -100 100], 'Twindow', [ -1000 198] );
    EEG = eeg_checkset( EEG );
    %����αӰ���ܾ���
%     ARfilepath=strcat('E:\Ԥ��ʵ�����ݴ���\�Ե�\anabrain1\Summary_AR\',thisname(1:6),'_AR.txt');
%     pop_summary_AR_eeg_detection(EEG,ARfilepath);
%     setname2=strcat(strtok(thisname,'.'),'_AR.set'); 
%     EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\Ԥ��ʵ�����ݴ���\�Ե�\anabrain1\pre_step5');
%     EEG = eeg_checkset( EEG );
    ARfilepath=strcat('E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\resplock-1000_200\αӰ�ܾ���\',thisname(1:6),'_AR.txt');
    pop_summary_AR_eeg_detection(EEG,ARfilepath);
    setname2=strcat(strtok(thisname,'.'),'_AR.set'); 
    EEG = pop_saveset( EEG, 'filename',setname2,'filepath','E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\resplock-1000_200\Pre2ArticficRej');
    EEG = eeg_checkset( EEG );
end

%���αӰ�ܾ�������ɾ���ܶ����� ���ǵڶ��� �򵥼��� �����Խ����ʾ���90%����
%% LRP ��Ӧ����
clear,clc; 
alldata2=dir(['E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\resplock-1000_200\Pre2ArticficRej\','*.set']); 
for c=1:4
    EEG_avg=[];
    for i=1:length(alldata2)
        thisname=alldata2(i).name;
        EEG = pop_loadset(thisname,'E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\resplock-1000_200\Pre2ArticficRej\');
        EEG = pop_rejepoch( EEG, find(EEG.reject.rejmanual==1), 0);   %ȥ��α����
        %��mark�������ֺ�����  ��4������ ÿ������trialƽ����ŵ������洢 ��8������
        condi=['B',num2str(c),'(Resp_CorrectR)'];
%         EEG = pop_epoch( EEG, {  'B1(Resp_CorrectL)'}, [-1 0.2], 'epochinfo', 'yes'); %SR-L
%         EEG = pop_epoch( EEG, {  'B1(Resp_CorrectR)'}, [-1 0.2],'epochinfo', 'yes');  %SR-R
        EEG = pop_epoch( EEG, { condi}, [-1 0.2], 'epochinfo', 'yes'); 
        EEG = eeg_checkset( EEG );
        EEG = pop_select( EEG, 'channel',{'C3','C4'});
        EEG = eeg_checkset( EEG );
        EEG_avg(i,:,:)=squeeze(mean(EEG.data,3));
    end
    savename=['AVG_','S',num2str(c),'_R'];
    eval([savename,'=EEG_avg;']);
    save(['E:\Ԥ��ʵ������audio\�Ե�\ERPanaly\resplock-1000_200\LRP\',savename,'.mat'],savename);
end  
avg_S1C3=AVG_S1_L(:,1,:)+AVG_S1_R(:,1,:);
reshape(avg_S1C3/2,37,600);