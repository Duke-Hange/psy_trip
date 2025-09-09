%读取目录
clear
subpath='C:\Users\luping\Desktop\数据_伪刺激\shem_snirf';
subfile=dir(subpath);
subfile(1:2)=[];

matpath='C:\Users\luping\Desktop\数据_伪刺激\homerOutput';
matfile=dir(matpath);
matfile(1:2)=[];

%头动参数
tMotion=0.5;
tMask=1.0;
STDEVthresh=50.0;
AMPthresh=5.0;
p=0.99;
turnon=1;

%血氧转换参数
ppf=[1.0, 1.0];

%叠加平均参数
trange=[-2.0, 20.0];

%功率谱参数
rest_onset1=[];
stim_onset=[];
rest_onset2=[];
noverlap=0;
nfft1=4096;
nfft2=16384;
Fs=11;

%被试叠加矩阵设置
rest1_aver=zeros(2861,129);
rest2_aver=zeros(2861,129);
stim_aver=zeros(12981,129);   %%0.05-12981  0.02-12651

for sub=1:length(subfile)
    file=fullfile(subpath,subfile(sub).name);
    
    %读取近红外文件
    snirf=SnirfClass(file);
    probe=snirf.probe;
    time=snirf.data.time;
    
    %储存起始点信息
    rest_onset1(:,sub)=snirf.stim(1, 1).data(1,1);
    stim_onset(:,sub)=snirf.stim(1, 2).data(:,1);
    rest_onset2(:,sub)=snirf.stim(1, 3).data(1,1);
    
    %补入mark
    mark_rest1=snirf.stim(1,1).states;
    mark_rest2=snirf.stim(1,3).states;
    mark_stim=snirf.stim(1,2).states;
    for i=1:14   %15  
        %补入rest1的mark
        [row1,~,~] = find(time==mark_rest1(1,1));
        row1=row1+(i-1)*220;
        mark_rest1(i,1)= time(row1,1);
        mark_rest1(i,2)=1;
        
        %补入rest2的mark
        [row2,~,~] = find(time==mark_rest2(1,1)) ;
        row2=row2+(i-1)*220;
        mark_rest2(i,1)= time(row2,1);
        mark_rest2(i,2)=1;
    end
    
    for i=1:60
        %补入stim的mark
        [row3,~,~] = find(time==mark_stim(1,1));
        row3=row3+(i-1)*220;   %%220  550
        mark_stim(i,1)= time(row3,1);
        mark_stim(i,2)=1;
    end
    
    snirf.stim(1,1).states=mark_rest1;
    snirf.stim(1,3).states=mark_rest2;
    snirf.stim(1,2).states=mark_stim;
    
    %光强转光密
    dod=hmrR_Intensity2OD(snirf.data);
    
    %头动检测
    [tInc,tIncCh] = hmrR_MotionArtifactByChannel(dod, probe, [], [], [], tMotion, tMask, STDEVthresh, AMPthresh);
    
    %头动矫正
    dod_m = hmrR_MotionCorrectSpline(dod, [], tIncCh, p, turnon);
    
    %滤波
    dod_mf=hmrR_BandpassFilt(dod_m,0.045,0.055);
    
    %光密度到血氧浓度
    dc = hmrR_OD2Conc( dod_mf, probe, ppf );
    %叠加平均
    [dcAvg_rest1, ~, ~, ~] = hmrR_BlockAvg( dc, snirf.stim(1,1), trange);
    [dcAvg_stim, ~, ~, ~] = hmrR_BlockAvg( dc, snirf.stim(1,2), trange);
    [dcAvg_rest2, dcAvgStd, nTrials, dcSum2] = hmrR_BlockAvg( dc, snirf.stim(1,3), trange);
    
    %建立输出目录
    [~,name,~]=fileparts(file); %对于 fileparts 函数，它会返回文件路径的三个部分：目录、文件名和扩展名。如果我们只需要其中的某个部分，可以使用占位符来代替我们不需要的部分。
    path=fileparts(fileparts(file));
    folderpath=fullfile(path,name);
    mkdir(folderpath)
    path=fullfile(folderpath,'发展对比');
    mkdir(path)
    cd(path)
    
    %按通道画图并保存
    for j=1:43
        x=1+3*(j-1);  %%  1=O 2=R 3=T
        plot(dcAvg_rest1.dataTimeSeries(:,x),'r')
        hold on
        plot(dcAvg_stim.dataTimeSeries(:,x),'g')
        plot(dcAvg_rest2.dataTimeSeries(:,x),'b')
        title('叠加平均后血氧浓度变化')
        xlabel('时间窗')
        ylabel('血氧浓度')
        legend('rest1','stim','rest2')
        hold off
        fname=strcat('O',num2str(j),'.jpg');
        saveas(gcf,fname)
        
        rest1_amp_ch = max(dcAvg_rest1.dataTimeSeries(:,x))-min(dcAvg_rest1.dataTimeSeries(:,x));
        stim_amp_ch = max(dcAvg_stim.dataTimeSeries(:,x))-min(dcAvg_stim.dataTimeSeries(:,x));
        rest2_amp_ch = max(dcAvg_rest2.dataTimeSeries(:,x))-min(dcAvg_rest2.dataTimeSeries(:,x));
        
        rest1_amp(sub,j) =rest1_amp_ch;
        stim_amp(sub,j) =stim_amp_ch;
        rest2_amp(sub,j) =rest2_amp_ch;
        
    end
    
    for j=1:43
        x=2+3*(j-1);  %%  1=O 2=R 3=T
        plot(dcAvg_rest1.dataTimeSeries(:,x),'r')
        hold on
        plot(dcAvg_stim.dataTimeSeries(:,x),'g')
        plot(dcAvg_rest2.dataTimeSeries(:,x),'b')
        title('叠加平均后血氧浓度变化')
        xlabel('时间窗')
        ylabel('血氧浓度')
        legend('rest1','stim','rest2')
        hold off
        fname=strcat('R',num2str(j),'.jpg');
        saveas(gcf,fname)
    end
    
    for j=1:43
        x=3+3*(j-1);  %%  1=O 2=R 3=T
        plot(dcAvg_rest1.dataTimeSeries(:,x),'r')
        hold on
        plot(dcAvg_stim.dataTimeSeries(:,x),'g')
        plot(dcAvg_rest2.dataTimeSeries(:,x),'b')
        title('叠加平均后血氧浓度变化')
        xlabel('时间窗')
        ylabel('血氧浓度')
        legend('rest1','stim','rest2')
        hold off
        fname=strcat('T',num2str(j),'.jpg');
        saveas(gcf,fname)
    end
    
    %画功率谱-截取片段
    matfile1=fullfile(matpath,matfile(sub).name);
    fnirsfile=load(matfile1);
    [row1,~,~] = find(time==rest_onset1(1,sub)) ;   %%寻找mark点
    [row2,~,~] = find(time==stim_onset(1,sub)) ;
    [row3,col,v] = find(time==rest_onset2(1,sub)) ;
    
    data_rest1=fnirsfile.output.dc.dataTimeSeries(row1:row1+2860,:);     %%选取片段
    data_rest2=fnirsfile.output.dc.dataTimeSeries(row3:row3+2860,:);
    data_stim1=fnirsfile.output.dc.dataTimeSeries(row2+440:row2+13420,:);   %%去掉开始两个刺激周期,考虑往后1个周期误差
    
    %设置按被试叠加矩阵          
    rest1_aver = rest1_aver+data_rest1;
    rest2_aver=  rest2_aver+data_rest2;
    stim_aver=   stim_aver+data_stim1;
    
    
    %画功率谱-设置路径
    psd_path=fullfile(folderpath,'功率谱');
    mkdir(psd_path)
    cd(psd_path)
    
   
    %画功率谱（单个通道）
    for h=1:43
        x=1+3*(h-1);  %%  1=O 2=R 3=T
        [pxx1,f1] = pwelch(data_rest1(:,x),hamming(2861),noverlap,nfft1,Fs);
        [pxx2,f2]=pwelch(data_rest2(:,x),hamming(2861),noverlap,nfft1,Fs);
        [pxx3,f3] = pwelch(data_stim1(:,x),hamming(12981),noverlap,nfft2,Fs);
        plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
        title('Welch Power Spectral Density Estimate')
        xlabel('Normalized Frequency(×Π rad/sample)')
        ylabel('Power/frequency(dB/(rad/sample))')
        set(gca,'XLim',[0 0.2])
        line([0.05,0.05],[-150,50],'linestyle','--')
        %可以加入两条线
        legend('rest1','rest2','stim')
        fname=strcat('O',num2str(h),'.jpg');
        saveas(gcf,fname)
        
        %%保存频段内峰值
%         f1_range = f1>=0.015 & f1<=0.025;
%         [peak_power1,peak_idx1] = max(pxx1(f1_range));
%         peak_power1=10*log10(peak_power1);
%         rest1_peak(sub,h) =peak_power1;
%         f1_1 = f1(f1_range);
%         peak_freq1 = f1_1(peak_idx1);
%         rest1_peak_fre(sub,h) =peak_freq1;
%         
%         f2_range = f2>=0.015 & f2<=0.025;
%         [peak_power2,peak_idx2] = max(pxx2(f2_range));
%         peak_power2=10*log10(peak_power2);
%         rest2_peak(sub,h) =peak_power2;
%         f2_1 = f2(f2_range);
%         peak_freq2 = f2_1(peak_idx2);
%         rest2_peak_fre(sub,h) =peak_freq2;
%         
%         f3_range = f3>=0.015 & f3<=0.025;
%         [peak_power3,peak_idx3] = max(pxx3(f3_range));
%         peak_power3=10*log10(peak_power3);
%         stim_peak(sub,h) =peak_power3;
%         f3_1 = f3(f3_range);
%         peak_freq3 = f3_1(peak_idx3);
%         stim_peak_fre(sub,h) =peak_freq3;
        
         f1_range = f1>=0.045 & f1<=0.055;
        [peak_power1,peak_idx1] = max(pxx1(f1_range));
        peak_power1=10*log10(peak_power1);
        rest1_peak(sub,h) =peak_power1;
        f1_1 = f1(f1_range);
        peak_freq1 = f1_1(peak_idx1);
        rest1_peak_fre(sub,h) =peak_freq1;
        
        f2_range = f2>=0.045 & f2<=0.055;
        [peak_power2,peak_idx2] = max(pxx2(f2_range));
        peak_power2=10*log10(peak_power2);
        rest2_peak(sub,h) =peak_power2;
        f2_1 = f2(f2_range);
        peak_freq2 = f2_1(peak_idx2);
        rest2_peak_fre(sub,h) =peak_freq2;
        
        f3_range = f3>=0.045 & f3<=0.055;
        [peak_power3,peak_idx3] = max(pxx3(f3_range));
        peak_power3=10*log10(peak_power3);
        stim_peak(sub,h) =peak_power3;
        f3_1 = f3(f3_range);
        peak_freq3 = f3_1(peak_idx3);
        stim_peak_fre(sub,h) =peak_freq3;
        
    end
    
    for h=1:43
        x=2+3*(h-1);  %%  1=O 2=R 3=T
        [pxx1,f1] = pwelch(data_rest1(:,x),hamming(2861),noverlap,nfft1,Fs);
        [pxx2,f2]=pwelch(data_rest2(:,x),hamming(2861),noverlap,nfft1,Fs);
        [pxx3,f3] = pwelch(data_stim1(:,x),hamming(12981),noverlap,nfft2,Fs);
        plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
        title('Welch Power Spectral Density Estimate')
        xlabel('Normalized Frequency(×Π rad/sample)')
        ylabel('Power/frequency(dB/(rad/sample))')
        set(gca,'XLim',[0 0.2])
        line([0.05,0.05],[-150,50],'linestyle','--')
        legend('rest1','rest2','stim')
        fname=strcat('R',num2str(h),'.jpg');
        saveas(gcf,fname)
    end
    
    for h=1:43
        x=3+3*(h-1);  %%  1=O 2=R 3=T
        [pxx1,f1] = pwelch(data_rest1(:,x),hamming(2861),noverlap,nfft1,Fs);
        [pxx2,f2]=pwelch(data_rest2(:,x),hamming(2861),noverlap,nfft1,Fs);
        [pxx3,f3] = pwelch(data_stim1(:,x),hamming(12981),noverlap,nfft2,Fs);
        plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
        title('Welch Power Spectral Density Estimate')
        xlabel('Normalized Frequency(×Π rad/sample)')
        ylabel('Power/frequency(dB/(rad/sample))')
        set(gca,'XLim',[0 0.2])
        line([0.05,0.05],[-150,50],'linestyle','--')
        legend('rest1','rest2','stim')
        fname=strcat('T',num2str(h),'.jpg');
        saveas(gcf,fname)
    end
end
cd('C:\Users\luping\Desktop\数据_伪刺激\aver')
% save('peak_power2.mat', 'rest1_peak', 'rest2_peak', 'stim_peak');
% save('peak_power_fre2.mat', 'rest1_peak_fre', 'rest2_peak_fre', 'stim_peak_fre');
save('peak_power5.mat', 'rest1_peak', 'rest2_peak', 'stim_peak');
save('peak_power_fre5.mat', 'rest1_peak_fre', 'rest2_peak_fre', 'stim_peak_fre');
save('amp.mat', 'rest1_amp', 'stim_amp', 'rest2_amp');

%% 平均图
rest1_aver = rest1_aver/length(subfile);  %%平均
rest2_aver=  rest2_aver/length(subfile);
stim_aver=   stim_aver/length(subfile);

rest1_aver_O=zeros(2861,1);
rest2_aver_O=zeros(2861,1);
stim_aver_O=zeros(12981,1);

for i=1:43                             %%开始按通道叠加
    x=1+3*(i-1);  %%  1=O 2=R 3=T
    rest1_aver_O(:,1) = rest1_aver_O(:,1)+rest1_aver(:,x);
    rest2_aver_O(:,1) = rest2_aver_O(:,1)+rest2_aver(:,x);
    stim_aver_O(:,1)=  stim_aver_O(:,1)+stim_aver(:,x);
end
rest1_aver_O=rest1_aver_O/i;  %%平均
rest2_aver_O=rest2_aver_O/i;
stim_aver_O=stim_aver_O/i;

rest1_aver_R=zeros(2861,1);
rest2_aver_R=zeros(2861,1);
stim_aver_R=zeros(12981,1);

for i=1:43                             %%开始按通道叠加
    x=2+3*(i-1);  %%  1=O 2=R 3=T
    rest1_aver_R(:,1) = rest1_aver_R(:,1)+rest1_aver(:,x);
    rest2_aver_R(:,1) = rest2_aver_R(:,1)+rest2_aver(:,x);
    stim_aver_R(:,1)=  stim_aver_R(:,1)+stim_aver(:,x);
end
rest1_aver_R=rest1_aver_R/i;  %%平均
rest2_aver_R=rest2_aver_O/i;
stim_aver_R=stim_aver_R/i;

rest1_aver_T=zeros(2861,1);
rest2_aver_T=zeros(2861,1);
stim_aver_T=zeros(12981,1);

for i=1:43                             %%开始按通道叠加
    x=3+3*(i-1);  %%  1=O 2=R 3=T
    rest1_aver_T(:,1) = rest1_aver_T(:,1)+rest1_aver(:,x);
    rest2_aver_T(:,1) = rest2_aver_T(:,1)+rest2_aver(:,x);
    stim_aver_T(:,1)=  stim_aver_T(:,1)+stim_aver(:,x);
end
rest1_aver_T=rest1_aver_R/i;  %%平均
rest2_aver_T=rest2_aver_O/i;
stim_aver_T=stim_aver_R/i;

path='C:\Users\luping\Desktop\数据_伪刺激\aver\功率谱\';
mkdir(path)
cd(path)


[pxx1,f1] = pwelch(rest1_aver_O(:,1),hamming(2861),noverlap,nfft1,Fs);
[pxx2,f2] = pwelch(rest2_aver_O(:,1),hamming(2861),noverlap,nfft1,Fs);
[pxx3,f3] = pwelch(stim_aver_O(:,1),hamming(12981),noverlap,nfft2,Fs);
plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
title('Welch Power Spectral Density Estimate')
xlabel('Normalized Frequency(×Π rad/sample)')
ylabel('Power/frequency(dB/(rad/sample))')
set(gca,'XLim',[0 0.2])
line([0.05,0.05],[-150,50],'linestyle','--')
legend('rest1','rest2','stim')
fname=strcat(path,'O_','aver','.jpg');
saveas(gcf,fname)

[pxx1,f1] = pwelch(rest1_aver_R(:,1),hamming(2861),noverlap,nfft1,Fs);
[pxx2,f2] = pwelch(rest2_aver_R(:,1),hamming(2861),noverlap,nfft1,Fs);
[pxx3,f3] = pwelch(stim_aver_R(:,1),hamming(12981),noverlap,nfft2,Fs);
plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
title('Welch Power Spectral Density Estimate')
xlabel('Normalized Frequency(×Π rad/sample)')
ylabel('Power/frequency(dB/(rad/sample))')
set(gca,'XLim',[0 0.2])
line([0.05,0.05],[-150,50],'linestyle','--')
legend('rest1','rest2','stim')
fname=strcat(path,'R_','aver','.jpg');
saveas(gcf,fname)

[pxx1,f1] = pwelch(rest1_aver_T(:,1),hamming(2861),noverlap,nfft1,Fs);
[pxx2,f2] = pwelch(rest2_aver_T(:,1),hamming(2861),noverlap,nfft1,Fs);
[pxx3,f3] = pwelch(stim_aver_T(:,1),hamming(12981),noverlap,nfft2,Fs);
plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
title('Welch Power Spectral Density Estimate')
xlabel('Normalized Frequency(×Π rad/sample)')
ylabel('Power/frequency(dB/(rad/sample))')
set(gca,'XLim',[0 0.2])
line([0.05,0.05],[-150,50],'linestyle','--')
legend('rest1','rest2','stim')
fname=strcat(path,'T_','aver','.jpg');
saveas(gcf,fname)

%% 单通道SD

for i=1:43
    x=1+3*(i-1);  %%  1=O 2=R 3=T
    [pxx1,f1] = pwelch(rest1_aver(:,x),hamming(2861),noverlap,nfft1,Fs);
    [pxx2,f2]=pwelch(rest2_aver(:,x),hamming(2861),noverlap,nfft1,Fs);
    [pxx3,f3] = pwelch(stim_aver(:,x),hamming(12981),noverlap,nfft2,Fs);
    plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
    title('Welch Power Spectral Density Estimate')
    xlabel('Normalized Frequency(×Π rad/sample)')
    ylabel('Power/frequency(dB/(rad/sample))')
    set(gca,'XLim',[0 0.2])
    line([0.05,0.05],[-150,50],'linestyle','--')
    legend('rest1','rest2','stim')
    fname=strcat(path,'O',num2str(i),'.jpg');
    saveas(gcf,fname)
end


for i=1:43
    x=2+3*(i-1);  %%  1=O 2=R 3=T
    [pxx1,f1] = pwelch(rest1_aver(:,x),hamming(2861),noverlap,nfft1,Fs);
    [pxx2,f2]=pwelch(rest2_aver(:,x),hamming(2861),noverlap,nfft1,Fs);
    [pxx3,f3] = pwelch(stim_aver(:,x),hamming(12981),noverlap,nfft2,Fs);
    plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
    title('Welch Power Spectral Density Estimate')
    xlabel('Normalized Frequency(×Π rad/sample)')
    ylabel('Power/frequency(dB/(rad/sample))')
    set(gca,'XLim',[0 0.2])
    line([0.05,0.05],[-150,50],'linestyle','--')
    legend('rest1','rest2','stim')
    fname=strcat(path,'R',num2str(i),'.jpg');
    saveas(gcf,fname)
end


for i=1:43
    x=3+3*(i-1);  %%  1=O 2=R 3=T
    [pxx1,f1] = pwelch(rest1_aver(:,x),hamming(2861),noverlap,nfft1,Fs);
    [pxx2,f2]=pwelch(rest2_aver(:,x),hamming(2861),noverlap,nfft1,Fs);
    [pxx3,f3] = pwelch(stim_aver(:,x),hamming(12981),noverlap,nfft2,Fs);
    plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
    title('Welch Power Spectral Density Estimate')
    xlabel('Normalized Frequency(×Π rad/sample)')
    ylabel('Power/frequency(dB/(rad/sample))')
    set(gca,'XLim',[0 0.2])
    line([0.05,0.05],[-150,50],'linestyle','--')
    legend('rest1','rest2','stim')
    fname=strcat(path,'T',num2str(i),'.jpg');
    saveas(gcf,fname)
end

