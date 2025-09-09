function [dcAvg,processdata]= yh_fnirs_process(subpath,matpath,sampleFreq,cyclicality,Nrestmark,Pretime)
% �������ȶ�ʱ������fnirs���
% Written by yh based on Homer3 and Dpabi.
%% ��ȡhomor�ļ�·��
%snirf�ļ�
subfile=dir(subpath);
subfile(1:2)=[];

matfile=dir(matpath);
matfile(1:2)=[];
%% ��������
% ͷ������
tMotion=0.5;
tMask=1.0;
STDEVthresh=50.0;
AMPthresh=5.0;
p=0.99;
turnon=1;

%Ѫ��ת������
ppf=[1.0, 1.0];

%����ƽ������
trange=[-2.0, cyclicality];

for sub=1:length(subfile)
    tic
    file=fullfile(subpath,subfile(sub).name);
    
    %��ȡ�������ļ�
    snirf=SnirfClass(file);
    probe=snirf.probe;
    time=snirf.data.time;
    
    %������ʼ����Ϣ
    rest1_onset(:,sub)=snirf.stim(1, 1).data(1,1);
    stim_onset(:,sub)=snirf.stim(1, 2).data(:,1);
    rest2_onset(:,sub)=snirf.stim(1, 3).data(1,1);
    
    %����mark
    mark_rest1=snirf.stim(1,1).states;
    mark_rest2=snirf.stim(1,3).states;
    
    for i=1:Nrestmark
        %����rest1��mark
        [row1,~,~] = find(time==mark_rest1(1,1));
        row1=row1+(i-1)*sampleFreq*cyclicality;
        mark_rest1(i,1)= time(row1,1);
        mark_rest1(i,2)=1;
        
        %����rest2��mark
        [row2,~,~] = find(time==mark_rest2(1,1)) ;
        row2=row2+(i-1)*sampleFreq*cyclicality;
        mark_rest2(i,1)= time(row2,1);
        mark_rest2(i,2)=1;
    end
    
    snirf.stim(1,1).states=mark_rest1;
    snirf.stim(1,3).states=mark_rest2;
    
    %��ǿת����
    dod=hmrR_Intensity2OD(snirf.data);
    
    %ͷ�����
    [tInc,tIncCh] = hmrR_MotionArtifactByChannel(dod, probe, [], [], [], tMotion, tMask, STDEVthresh, AMPthresh);
    
    %ͷ������
    dod_m = hmrR_MotionCorrectSpline(dod, [], tIncCh, p, turnon);
    
    %�˲�
    %dod_mf=hmrR_BandpassFilt(dod_m,0.045,0.055);
    dod_mf=hmrR_BandpassFilt(dod_m,0.01,0.1);
    
    %���ܶȵ�Ѫ��Ũ��
    dc = hmrR_OD2Conc( dod_mf, probe, ppf );
    
    %����marker����ƽ��
    [dcAvg_rest1, ~, ~, ~] = hmrR_BlockAvg(dc, snirf.stim(1,1), trange);
    [dcAvg_stim, ~, ~, ~] = hmrR_BlockAvg(dc, snirf.stim(1,2), trange);
    [dcAvg_rest2, ~, ~, ~] = hmrR_BlockAvg( dc, snirf.stim(1,3), trange);
  

    dcAvg.rest1(:,:,sub)=dcAvg_rest1.dataTimeSeries;
    dcAvg.stim(:,:,sub)=dcAvg_stim.dataTimeSeries;
    dcAvg.rest2(:,:,sub)=dcAvg_rest2.dataTimeSeries;
    
    
    %% ��ȡƬ��
    matfile1=fullfile(matpath,matfile(sub).name);
    fnirsfile=load(matfile1);
    
    [row1,~,~] = find(time==rest1_onset(1,sub)) ;   %%Ѱ��mark��
    [row2,~,~] = find(time==stim_onset(3,sub)) ;    %%ȥ����ʼ�����̼�����
    [row3,~,~] = find(time==rest2_onset(1,sub)) ;
    
    data_rest1=fnirsfile.output.dc.dataTimeSeries(row1:row1+Pretime*sampleFreq,:);     %%ѡȡƬ��  165  Pretime
    data_rest2=fnirsfile.output.dc.dataTimeSeries(row3:row3+Pretime*sampleFreq,:);          %%ѡȡƬ��  165
    data_stim1=fnirsfile.output.dc.dataTimeSeries(row2:row2+cyclicality*sampleFreq*(1200/cyclicality-1),:);   %%��������1���������   649
      
    %���ڼ�����ͣ�
    %  50��50��һ�����ڣ�*24��24�����ڣ�*11�����ڲ����ʣ�=13200
    %  50��50��һ�����ڣ�*11�����ڲ����ʣ�=550
    
    %��һ��ԭʼ���ݣ�δ��trigger���ӣ�
    processdata.rest1(:,:,sub)=data_rest1
    processdata.rest2(:,:,sub)=data_rest2
    processdata.stim(:,:,sub)=data_stim1

   toc
end

