%% 间接法先由序列x(n)估计出自相关函数R(n)，然后对R(n)进行傅立叶变换，便得到x(n)的功率谱估计。
clear;
Fs=1000; %采样频率
n=0:1/Fs:1;
 
%产生含有噪声的序列
xn=cos(2*pi*40*n)+3*cos(2*pi*100*n)+randn(size(n));
 
nfft=1024;
cxn=xcorr(xn,'unbiased'); %计算序列的自相关函数
CXk=fft(cxn,nfft);
Pxx=abs(CXk);
index=0:round(nfft/2-1);
k=index*Fs/nfft;
plot_Pxx=10*log10(Pxx(index+1));
plot(k,plot_Pxx)

%% 直接法又称周期图法，它是把随机序列x(n)的N个观测数据视为一能量有限的序列，直接计算x(n)的离散傅立叶变换，得X(k)，然后再取其幅值的平方，并除以N，作为序列x(n)真实功率谱的估计。
clear; 
Fs=1000; %采样频率 
n=0:1/Fs:1; 
 
%产生含有噪声的序列 
xn=cos(2*pi*40*n)+3*cos(2*pi*100*n)+randn(size(n)); 
 
window=boxcar(length(xn)); %矩形窗 
nfft=1024; 
[Pxx,f]=periodogram(xn,window,nfft,Fs); %直接法 
plot(f,10*log10(Pxx));

%% Bartlett法
clear;
Fs=1000;
n=0:1/Fs:1;
xn=cos(2*pi*40*n)+3*cos(2*pi*100*n)+randn(size(n));
nfft=1024;
window=boxcar(length(n)); %矩形窗
noverlap=0; %数据无重叠
p=0.9; %置信概率
 
[Pxx,Pxxc]=psd(xn,nfft,Fs,window,noverlap,p);
 
index=0:round(nfft/2-1);
k=index*Fs/nfft;
plot_Pxx=10*log10(Pxx(index+1));
plot_Pxxc=10*log10(Pxxc(index+1));
figure(1)
plot(k,plot_Pxx);
 
pause;
 
figure(2)
plot(k,[plot_Pxx plot_Pxx-plot_Pxxc plot_Pxx+plot_Pxxc]);

%% Welch法
clear;
Fs=1000;
n=0:1/Fs:1;
xn=cos(2*pi*40*n)+3*cos(2*pi*100*n)+randn(size(n));
nfft=1024;
window=boxcar(100); %矩形窗
window1=hamming(100); %海明窗
window2=blackman(100); %blackman窗
noverlap=20; %数据无重叠
range='half'; %频率间隔为[0 Fs/2]，只计算一半的频率
 
[Pxx,f]=pwelch(xn,window,noverlap,nfft,Fs,range);
[Pxx1,f]=pwelch(xn,window1,noverlap,nfft,Fs,range);
[Pxx2,f]=pwelch(xn,window2,noverlap,nfft,Fs,range);
 
plot_Pxx=10*log10(Pxx);
plot_Pxx1=10*log10(Pxx1);
plot_Pxx2=10*log10(Pxx2);
 
figure(1)
plot(f,plot_Pxx);
 
pause;
 
figure(2)
plot(f,plot_Pxx1);
 
pause;
 
figure(3)
plot(f,plot_Pxx2);
