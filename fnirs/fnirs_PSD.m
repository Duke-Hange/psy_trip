%% 设置工作路径
cd('C:\Users\luping\Desktop\剂量实验');

cd('C:\Users\luping\Desktop\数据_0.02');

cd('C:\Users\luping\Desktop\数据_0.02\剔除被试')
%% 截取片段
clear
fnirsfile=load('C:\Users\luping\Desktop\剂量实验\homerOutput\025_liuyingqiang.mat');
rest_onset1=[];
stim_onset=[];
rest_onset2=[];
markfile=SnirfClass('C:\Users\luping\Desktop\剂量实验\025_liuyingqiang.snirf');               %%读取近红外文件
rest_onset1(:,1)=markfile.stim(1, 1).data(1,1);
stim_onset(:,1)=markfile.stim(1, 2).data(:,1);
rest_onset2(:,1)=markfile.stim(1, 3).data(1,1);

rest1_aver=zeros(3301,129);
rest2_aver=zeros(3301,129);
stim_aver=zeros(12981,129);

time=fnirsfile.output.dc.time;
[row1,col,v] = find(time==rest_onset1(1,1)) ;   %%寻找mark点
[row2,col,v] = find(time==stim_onset(3,1)) ;    %%去掉开始两个刺激周期
[row3,col,v] = find(time==rest_onset2(1,1)) ;

data_rest1=fnirsfile.output.dc.dataTimeSeries(row1:row1+3300,:);     %%选取片段
data_rest2=fnirsfile.output.dc.dataTimeSeries(row3:row3+3300,:);   %%3300
data_stim1=fnirsfile.output.dc.dataTimeSeries(row2:row2+12980,:);   %%考虑往后1个周期误差


%% 通道叠加平均
rest1_aver_O=zeros(3301,129);
rest2_aver_O=zeros(3301,129);
stim_aver_O=zeros(12981,129);
for i=1:43                             %%开始按通道叠加
    x=1+3*(i-1);  %%  1=O 2=R 3=T
    rest1_aver_O(:,1) = rest1_aver_O(:,1)+data_rest1(:,x);
    rest2_aver_O(:,1) = rest2_aver_O(:,1)+data_rest2(:,x);
    stim_aver_O(:,1)=  stim_aver_O(:,1)+data_stim1(:,x);
end
rest1_aver_O=rest1_aver_O/i;  %%平均
rest2_aver_O=rest2_aver_O/i;
stim_aver_O=stim_aver_O/i;

rest1_aver_R=zeros(3301,1);
rest2_aver_R=zeros(3301,1);
stim_aver_R=zeros(12981,1);
for i=1:43                             %%开始按通道叠加
    x=2+3*(i-1);  %%  1=O 2=R 3=T
    rest1_aver_R(:,1) = rest1_aver_R(:,1)+data_rest1(:,x);
    rest2_aver_R(:,1) = rest2_aver_R(:,1)+data_rest2(:,x);
    stim_aver_R(:,1)=  stim_aver_R(:,1)+data_stim1(:,x);
end
rest1_aver_R=rest1_aver_R/i;  %%平均
rest2_aver_R=rest2_aver_R/i;
stim_aver_R=stim_aver_R/i;

rest1_aver_T=zeros(3301,1);
rest2_aver_T=zeros(3301,1);
stim_aver_T=zeros(12981,1);
for i=1:43                             %%开始按通道叠加
    x=3+3*(i-1);  %%  1=O 2=R 3=T
    rest1_aver_T(:,1) = rest1_aver_T(:,1)+data_rest1(:,x);
    rest2_aver_T(:,1) = rest2_aver_T(:,1)+data_rest2(:,x);
    stim_aver_T(:,1)=  stim_aver_T(:,1)+data_stim1(:,x);
end
rest1_aver_T=rest1_aver_T/i;  %%平均
rest2_aver_T=rest2_aver_T/i;
stim_aver_T=stim_aver_T/i;

%% 画功率谱-通道叠加平均图
% window=boxcar(length(n)); %矩形窗
% window1=hamming(length(n)); %海明窗
% window2=blackman(length(n)); %blackman窗
noverlap=0
nfft1=4096;
nfft2=16384;
Fs=11;

[Pxx1,f1]=pwelch(rest1_aver_O(:,1),hamming(3301),noverlap,nfft1,Fs); %计算功率谱
[pxx2,f2]=pwelch(rest2_aver_O(:,1),hamming(3301),noverlap,nfft1,Fs);
[Pxx3,f3]=pwelch(stim_aver_O(:,1),hamming(12981),noverlap,nfft2,Fs);
plot(f1,10*log10(Pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(Pxx3),'g')
title('Welch Power Spectral Density Estimate')
xlabel('Normalized Frequency(×Π rad/sample)')
ylabel('Power/frequency(dB/(rad/sample))')
set(gca,'XLim',[0.045 0.055])
line([0.05,0.05],[-200,-50],'linestyle','--')
legend('rest1','rest2','stim')

path='C:\Users\luping\Desktop\剂量实验\024_songyiwen\功率谱\'; %%保存路径
mkdir(path)
fname=strcat(path,'O_','aver','.jpg');
saveas(gcf,fname)

[Pxx1,f1]=pwelch(rest1_aver_R(:,1),hamming(3301),noverlap,nfft1,Fs);
[pxx2,f2]=pwelch(rest2_aver_R(:,1),hamming(3301),noverlap,nfft1,Fs);
[Pxx3,f3]=pwelch(stim_aver_R(:,1),hamming(12981),noverlap,nfft2,Fs);
plot(f1,10*log10(Pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(Pxx3),'g')
title('Welch Power Spectral Density Estimate')
xlabel('Normalized Frequency(×Π rad/sample)')
ylabel('Power/frequency(dB/(rad/sample))')
set(gca,'XLim',[0 0.2])
line([0.05,0.05],[0,140],'linestyle','--')
legend('rest1','rest2','stim')

path='C:\Users\luping\Desktop\剂量实验\024_songyiwen\功率谱\';  %%保存路径
fname=strcat(path,'R_','aver','.jpg');
saveas(gcf,fname)

[Pxx1,f1]=pwelch(rest1_aver_T(:,1),hamming(3301),noverlap,nfft1,Fs);
[pxx2,f2]=pwelch(rest2_aver_T(:,1),hamming(3301),noverlap,nfft1,Fs);
[Pxx3,f3]=pwelch(stim_aver_T(:,1),hamming(12981),noverlap,nfft2,Fs);
plot(f1,10*log10(Pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(Pxx3),'g')
legend('rest1','rest2','stim')
title('Welch Power Spectral Density Estimate')
xlabel('Normalized Frequency(×Π rad/sample)')
ylabel('Power/frequency(dB/(rad/sample))')
set(gca,'XLim',[0 0.2])
line([0.05,0.05],[0,140],'linestyle','--')
legend('rest1','rest2','stim')

path='C:\Users\luping\Desktop\剂量实验\024_songyiwen\功率谱\';  %%保存路径
fname=strcat(path,'T_','aver','.jpg');
saveas(gcf,fname)

%% 画功率谱-全通道观察
for i=1:43
    x=1+3*(i-1);  %%  1=O 2=R 3=T
    [pxx1,f1] = pwelch(data_rest1(:,x),hamming(3301),noverlap,nfft1,Fs);
    [pxx2,f2]=pwelch(data_rest2(:,x),hamming(3301),noverlap,nfft1,Fs);
    [pxx3,f3] = pwelch(data_stim1(:,x),hamming(12981),noverlap,nfft2,Fs);
    plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
    title('Welch Power Spectral Density Estimate')
    xlabel('Normalized Frequency(×Π rad/sample)')
    ylabel('Power/frequency(dB/(rad/sample))')
    set(gca,'XLim',[0.045 0.055])
    line([0.05,0.05],[-130,-50],'linestyle','--')
    legend('rest1','rest2','stim')
    
    path='C:\Users\luping\Desktop\剂量实验\025_liuyingqiang\功率谱\';
    fname=strcat(path,'O',num2str(i),'.jpg');
    saveas(gcf,fname)
end


for i=1:43
    x=2+3*(i-1);  %%  1=O 2=R 3=T
    [pxx1,f1] = pwelch(data_rest1(:,x),hamming(3301),noverlap,nfft1,Fs);
    [pxx2,f2]=pwelch(data_rest2(:,x),hamming(3301),noverlap,nfft1,Fs);
    [pxx3,f3] = pwelch(data_stim1(:,x),hamming(12981),noverlap,nfft2,Fs);
    plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
    title('Welch Power Spectral Density Estimate')
    xlabel('Normalized Frequency(×Π rad/sample)')
    ylabel('Power/frequency(dB/(rad/sample))')
    set(gca,'XLim',[0 0.2])
    line([0.05,0.05],[-150,50],'linestyle','--')
    legend('rest1','rest2','stim')
    
    path='C:\Users\luping\Desktop\剂量实验\025_liuyingqiang\功率谱\';
    fname=strcat(path,'R',num2str(i),'.jpg');
    saveas(gcf,fname)
end


for i=1:43
    x=3+3*(i-1);  %%  1=O 2=R 3=T
    [pxx1,f1] = pwelch(data_rest1(:,x),hamming(3301),noverlap,nfft1,Fs);
    [pxx2,f2]=pwelch(data_rest2(:,x),hamming(3301),noverlap,nfft1,Fs);
    [pxx3,f3] = pwelch(data_stim1(:,x),hamming(12981),noverlap,nfft2,Fs);
    plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
    title('Welch Power Spectral Density Estimate')
    xlabel('Normalized Frequency(×Π rad/sample)')
    ylabel('Power/frequency(dB/(rad/sample))')
    set(gca,'XLim',[0 0.2])
    line([0.05,0.05],[-150,50],'linestyle','--')
    legend('rest1','rest2','stim')
    
    path='C:\Users\luping\Desktop\剂量实验\025_liuyingqiang\功率谱\';
    fname=strcat(path,'T',num2str(i),'.jpg');
    saveas(gcf,fname)
end

    %% %% 按时间叠加后走势图
    time=fnirsfile.output.dc.time;
    stim_overlap_aver=zeros(550,129);
    rest1_overlap_aver=zeros(550,129);
    rest2_overlap_aver=zeros(550,129);
    
    for i=1:21   %%60-3    24-3
        [row_s,col,v] = find(time==stim_onset(i+2,1)) ;
        data_stim=fnirsfile.output.dc.dataTimeSeries(row_s:row_s+549,:);
        stim_overlap_aver=stim_overlap_aver+data_stim;
    end
    stim_overlap_aver=stim_overlap_aver/21;

    [row_r1,col,v] = find(time==rest_onset1(1,1)) ;
    for i=1:6    %%15   6
        data_rest1=fnirsfile.output.dc.dataTimeSeries(row_r1+(i-1)*550:row_r1+i*550-1,:);
        rest1_overlap_aver=rest1_overlap_aver+data_rest1;
    end
    rest1_overlap_aver=rest1_overlap_aver/6;
    
    [row_r2,col,v] = find(time==rest_onset2(1,1)) ;
    for i=1:6
        data_rest2=fnirsfile.output.dc.dataTimeSeries(row_r2+(i-1)*550:row_r2+i*550-1,:);
        rest2_overlap_aver=rest2_overlap_aver+data_rest2;
    end
    rest2_overlap_aver=rest2_overlap_aver/6;
    
    path='C:\Users\luping\Desktop\数据_0.02\014_husen\发展对比\';
    mkdir(path)
    
    for i=1:43
        x=1+3*(i-1);  %%  1=O 2=R 3=T
        plot(rest1_overlap_aver(:,x),'r')
        hold on
        plot(rest2_overlap_aver(:,x),'b')
        hold on
        plot(stim_overlap_aver(:,x),'g')
        legend('rest1','rest2','stim')
        hold off
        fname=strcat(path,'O',num2str(i),'.jpg');
        saveas(gcf,fname)
    end
    
    for i=1:43
        x=2+3*(i-1);  %%  1=O 2=R 3=T
        plot(rest1_overlap_aver(:,x),'r')
        hold on
        plot(rest2_overlap_aver(:,x),'b')
        hold on
        plot(stim_overlap_aver(:,x),'g')
        legend('rest1','rest2','stim')
        hold off
        fname=strcat(path,'R',num2str(i),'.jpg');
        saveas(gcf,fname)
    end
    
    for i=1:43
        x=3+3*(i-1);  %%  1=O 2=R 3=T
        plot(rest1_overlap_aver(:,x),'r')
        hold on
        plot(rest2_overlap_aver(:,x),'b')
        hold on
        plot(stim_overlap_aver(:,x),'g')
        legend('rest1','rest2','stim')
        hold off
        fname=strcat(path,'T',num2str(i),'.jpg');
        saveas(gcf,fname)
    end

%  %Xsmooth=smooth(X,30,'lowess'); %平滑滤波


   %%  变化(刺激-基线)_FC相关(版本2)
aver_diff=stim_overlap_aver-rest1_overlap_aver;

stim_O=[];stim_R=[];stim_T=[];

for k=1:43  %k=1
    x1=1+3*(k-1);  %%  1=O 2=R 3=T
    x2=2+3*(k-1); 
    x3=3+3*(k-1); 
    stim_O(:,k)=aver_diff(:,x1);
    stim_R(:,k)=aver_diff(:,x2);
    stim_T(:,k)=aver_diff(:,x3);
end
   
   stim_O=corr(stim_O);
   stim_R=corr(stim_R);
   stim_T=corr(stim_T);
   
   heatmap(stim_O);
   colormap default;
   path='C:\Users\luping\Desktop\数据_0.02\014_husen\';
   fname=strcat(path,'_O','.jpg');
   saveas(gcf,fname)
   
   heatmap(stim_R);
   colormap default;
   path='C:\Users\luping\Desktop\数据_0.02\014_husen\';
   fname=strcat(path,'_R','.jpg');
   saveas(gcf,fname)
   
   heatmap(stim_T);
   colormap default;
   path='C:\Users\luping\Desktop\数据_0.02\014_husen\';
   fname=strcat(path,'_T','.jpg');
   saveas(gcf,fname)
