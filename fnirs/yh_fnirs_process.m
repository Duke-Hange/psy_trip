function [dcAvg,processdata]= yh_fnirs_process(subpath,matpath,sampleFreq,cyclicality,Nrestmark,Pretime)
% 适用于稳定时间间隔的fnirs设计
% Written by yh based on Homer3 and Dpabi.
%% 读取homor文件路径
%snirf文件
subfile=dir(subpath);
subfile(1:2)=[];

matfile=dir(matpath);
matfile(1:2)=[];
%% 参数设置
% 头动参数
tMotion=0.5;
tMask=1.0;
STDEVthresh=50.0;
AMPthresh=5.0;
p=0.99;
turnon=1;

%血氧转换参数
ppf=[1.0, 1.0];

%叠加平均参数
trange=[-2.0, cyclicality];

for sub=1:length(subfile)
    tic
    file=fullfile(subpath,subfile(sub).name);
    
    %读取近红外文件
    snirf=SnirfClass(file);
    probe=snirf.probe;
    time=snirf.data.time;
    
    %储存起始点信息
    rest1_onset(:,sub)=snirf.stim(1, 1).data(1,1);
    stim_onset(:,sub)=snirf.stim(1, 2).data(:,1);
    rest2_onset(:,sub)=snirf.stim(1, 3).data(1,1);
    
    %补入mark
    mark_rest1=snirf.stim(1,1).states;
    mark_rest2=snirf.stim(1,3).states;
    
    for i=1:Nrestmark
        %补入rest1的mark
        [row1,~,~] = find(time==mark_rest1(1,1));
        row1=row1+(i-1)*sampleFreq*cyclicality;
        mark_rest1(i,1)= time(row1,1);
        mark_rest1(i,2)=1;
        
        %补入rest2的mark
        [row2,~,~] = find(time==mark_rest2(1,1)) ;
        row2=row2+(i-1)*sampleFreq*cyclicality;
        mark_rest2(i,1)= time(row2,1);
        mark_rest2(i,2)=1;
    end
    
    snirf.stim(1,1).states=mark_rest1;
    snirf.stim(1,3).states=mark_rest2;
    
    %光强转光密
    dod=hmrR_Intensity2OD(snirf.data);
    
    %头动检测
    [tInc,tIncCh] = hmrR_MotionArtifactByChannel(dod, probe, [], [], [], tMotion, tMask, STDEVthresh, AMPthresh);
    
    %头动矫正
    dod_m = hmrR_MotionCorrectSpline(dod, [], tIncCh, p, turnon);
    
    %滤波
    %dod_mf=hmrR_BandpassFilt(dod_m,0.045,0.055);
    dod_mf=hmrR_BandpassFilt(dod_m,0.01,0.1);
    
    %光密度到血氧浓度
    dc = hmrR_OD2Conc( dod_mf, probe, ppf );
    
    %基于marker叠加平均
    [dcAvg_rest1, ~, ~, ~] = hmrR_BlockAvg(dc, snirf.stim(1,1), trange);
    [dcAvg_stim, ~, ~, ~] = hmrR_BlockAvg(dc, snirf.stim(1,2), trange);
    [dcAvg_rest2, ~, ~, ~] = hmrR_BlockAvg( dc, snirf.stim(1,3), trange);
  

    dcAvg.rest1(:,:,sub)=dcAvg_rest1.dataTimeSeries;
    dcAvg.stim(:,:,sub)=dcAvg_stim.dataTimeSeries;
    dcAvg.rest2(:,:,sub)=dcAvg_rest2.dataTimeSeries;
    
    
    %% 截取片段
    matfile1=fullfile(matpath,matfile(sub).name);
    fnirsfile=load(matfile1);
    
    [row1,~,~] = find(time==rest1_onset(1,sub)) ;   %%寻找mark点
    [row2,~,~] = find(time==stim_onset(3,sub)) ;    %%去掉开始两个刺激周期
    [row3,~,~] = find(time==rest2_onset(1,sub)) ;
    
    data_rest1=fnirsfile.output.dc.dataTimeSeries(row1:row1+Pretime*sampleFreq,:);     %%选取片段  165  Pretime
    data_rest2=fnirsfile.output.dc.dataTimeSeries(row3:row3+Pretime*sampleFreq,:);          %%选取片段  165
    data_stim1=fnirsfile.output.dc.dataTimeSeries(row2:row2+cyclicality*sampleFreq*(1200/cyclicality-1),:);   %%考虑往后1个周期误差   649
      
    %周期计算解释：
    %  50（50秒一个周期）*24（24个周期）*11（秒内采样率）=13200
    %  50（50秒一个周期）*11（秒内采样率）=550
    
    %存一个原始数据（未按trigger叠加）
    processdata.rest1(:,:,sub)=data_rest1
    processdata.rest2(:,:,sub)=data_rest2
    processdata.stim(:,:,sub)=data_stim1

   toc
end

