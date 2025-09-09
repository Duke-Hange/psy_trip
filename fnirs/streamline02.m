clear
%% 1.FNIRS预处理
subpath='C:\Users\luping\Desktop\数据_0.02\snirf';
matpath='C:\Users\luping\Desktop\数据_0.02\homerOutput';
output_path='C:\Users\luping\Desktop\数据_0.02\result';
mkdir(output_path)
cd(output_path)
sampleFreq=11;
cyclicality_2=50;
Nrestmark_2=6;
Pretime=300;
[dcAvg_2,processdata_2]= yh_fnirs_process(subpath,matpath,sampleFreq,cyclicality_2,Nrestmark_2,Pretime);
save('dcAvg_2','dcAvg_2')
save('processdata_2','processdata_2')

%1.1数据分离
alldata=load('C:\Users\luping\Desktop\数据_0.02\result\dcAvg_2.mat');
output_path='C:\Users\luping\Desktop\数据_0.02\result\';
cd(output_path)

%1.1.1 stim
stim_data=alldata.dcAvg_2.stim;
for sub=1:size(stim_data,3)
    for j=1:43
        % 1=O 2=R 3=T
        stim.O(:,j,sub)=stim_data(:,1+3*(j-1),sub);
        stim.R(:,j,sub)=stim_data(:,2+3*(j-1),sub);
        stim.T(:,j,sub)=stim_data(:,3+3*(j-1),sub);
    end
end
 save('dcAvg_2_stim','stim')

%1.1.2 rest1
rest1_data=alldata.dcAvg_2.rest1;
for sub=1:size(rest1_data,3)
    for j=1:43
        % 1=O 2=R 3=T
        rest1.O(:,j,sub)=rest1_data(:,1+3*(j-1),sub);
        rest1.R(:,j,sub)=rest1_data(:,2+3*(j-1),sub);
        rest1.T(:,j,sub)=rest1_data(:,3+3*(j-1),sub);
    end
end
 save('dcAvg_2_rest1','rest1')

%1.1.3 rest2
rest2_data=alldata.dcAvg_2.rest2;
for sub=1:size(rest2_data,3)
    for j=1:43
        % 1=O 2=R 3=T
        rest2.O(:,j,sub)=rest2_data(:,1+3*(j-1),sub);
        rest2.R(:,j,sub)=rest2_data(:,2+3*(j-1),sub);
        rest2.T(:,j,sub)=rest2_data(:,3+3*(j-1),sub);
    end
end
 save('dcAvg_2_rest2','rest2')

%% 2.特征提取
% 2.1滤波后计算指标
% output_path='C:\Users\luping\Desktop\数据_0.05\result\filter'
% mkdir(output_path)
% cd(output_path)
% 
% nBands=2;
% Bands.infraslow_range=[0.01,0.1];
% Bands.delta_range=[0.5,4];
% Bands.theta_range=[4,8];  %考虑到采样率
% Bands.alpha_range=[8,11];  
% Bands_name=fieldnames(Bands);
% 
% for kBand=1:nBands
%     cd(output_path)
%     fname=Bands_name{kBand};
%     output_path_fre=fullfile(output_path,Bands_name{kBand});
%     mkdir(output_path_fre)
%     cd(output_path_fre)
%     [B,A]=butter(3,Bands.(Bands_name{kBand})*2/sampleFreq,'bandpass');
%     for sub=1:size(dcAvg_5.stim,3)
%         data_filtered(:,:,sub)=filter(B,A,dcAvg_5.stim(:,:,sub));
%     end
%     save(fname,'data_filtered')
% end

%2.1.1低频相位-Cross_frequency coupling (CFC)
low_fre=load('C:\Users\luping\Desktop\数据_0.02\result\dcAvg_2.mat');
output_path='C:\Users\luping\Desktop\数据_0.02\result';
cd(output_path)

for sub=1:size(dcAvg_2.stim,3)
    for j=1:43
        Angle_O=hilbert(dcAvg_2.stim(:,1+3*(j-1),sub));
        Angle_R=hilbert(dcAvg_2.stim(:,2+3*(j-1),sub));
        Angle_T=hilbert(dcAvg_2.stim(:,3+3*(j-1),sub));
        % x_angle((end-9:end),:)=[];
        % x_angle(1:10,:)=[];
        Angle.O(:,j,sub)=angle(Angle_O)*180/pi;
        Angle.R(:,j,sub)=angle(Angle_R)*180/pi;
        Angle.T(:,j,sub)=angle(Angle_T)*180/pi;
    end
end
save('Angle_stim','Angle')


%2.1.2 统计：低频相位与动态功能连接相关性
alpha=0.01;
n_test=43*43;
adjusted_alpha=alpha/n_test;
%for stim
load('Angle_stim.mat')
Angle_stim_mean=mean(Angle.O,3);
for a=1:43
    for i=1:43
        for j=1:43
            [coefficient,p]=corr(squeeze(FC(i,j,:)),Angle_stim_mean(:,a));
            if p>adjusted_alpha
                COR_stim(i,j,a)=[NaN];
                COR_stim_p(i,j,a)=p;
            else
                COR_stim(i,j,a)=coefficient;
                COR_stim_p(i,j,a)=p;
            end
        end
    end
end

for sub=1:size(dcAvg_5.rest1,3)
    for j=1:43
        Angle_O=hilbert(dcAvg_5.rest1(:,1+3*(j-1),sub));
        Angle_R=hilbert(dcAvg_5.rest1(:,2+3*(j-1),sub));
        Angle_T=hilbert(dcAvg_5.rest1(:,3+3*(j-1),sub));
        % x_angle((end-9:end),:)=[];
        % x_angle(1:10,:)=[];
        Angle.O(:,j,sub)=angle(Angle_O)*180/pi;
        Angle.R(:,j,sub)=angle(Angle_R)*180/pi;
        Angle.T(:,j,sub)=angle(Angle_T)*180/pi;
    end
end
save('Angle_rest1','Angle')

%for rest1
load('Angle_rest1.mat')
Angle_rest1_mean=mean(Angle.O,3);
for a=1:43
    for i=1:43
        for j=1:43
            [coefficient,p]=corr(squeeze(FC(i,j,:)),Angle_rest1_mean(:,a));
            if p>adjusted_alpha
                COR_rest1(i,j,a)=[NaN];
                COR_rest1_p(i,j,a)=p;
            else
                COR_rest1(i,j,a)=coefficient;
                COR_rest1_p(i,j,a)=p;
            end
        end
    end
end

COR_rest1(:,:,11);

for sub=1:size(dcAvg_5.rest2,3)
    for j=1:43
        Angle_O=hilbert(dcAvg_5.rest2(:,1+3*(j-1),sub));
        Angle_R=hilbert(dcAvg_5.rest2(:,2+3*(j-1),sub));
        Angle_T=hilbert(dcAvg_5.rest2(:,3+3*(j-1),sub));
        % x_angle((end-9:end),:)=[];
        % x_angle(1:10,:)=[];
        Angle.O(:,j,sub)=angle(Angle_O)*180/pi;
        Angle.R(:,j,sub)=angle(Angle_R)*180/pi;
        Angle.T(:,j,sub)=angle(Angle_T)*180/pi;
    end
end
save('Angle_rest2','Angle')

%2.2叠加平均后计算指标
%2.2.1 叠加后振幅
subfile='C:\Users\luping\Desktop\数据_0.02\result\dcAvg_2.mat';
path='C:\Users\luping\Desktop\数据_0.02\result';
fnirs_type=1;
[rest1_amp_ch,stim_amp_ch,rest2_amp_ch]= yh_fnirs_amp(subfile,fnirs_type);
cd(path)
save('amp_rest1_ch','rest1_amp_ch')
save('amp_stim_ch','stim_amp_ch')
save('amp_rest2_ch','rest2_amp_ch')

%2.2.3 PSD:频率点活动强度
%功率谱
subfile='C:\Users\luping\Desktop\数据_0.02\result\processdata_2.mat';
output_path='C:\Users\luping\Desktop\数据_0.02\result';
cd(output_path)
fnirs_type=1;
aim_fre=0.02;
[rest1_peak,rest2_peak,stim_peak]= yh_fnirs_psd_rof(subfile,fnirs_type,aim_fre);
save('rest1_peak','rest1_peak')
save('rest2_peak','rest2_peak')
save('stim_peak','stim_peak')

% plot(rest1_peak(:,11),'r')
% hold on
% plot(rest2_peak(:,11),'g')
% hold on
% plot(stim_peak(:,11),'b')
% legend('rest1','rest2','stim')
%% 3图论方法
%3.1 第一步：确认路径
output_path='C:\Users\luping\Desktop\数据_0.02\result\';
cd(output_path)

%3.2 功能连接随时间程变化的矩阵
load('dcAvg_2_stim.mat')
stim_O=permute(stim.O,[3,2,1]);
for time=1:size(stim_O,3)
    FC(:,:,time)=corr(stim_O(:,:,time));
end
save('FC_stim','FC')

%3.2 第二部：矩阵建立
%3.2.1:stim
output_path='C:\Users\luping\Desktop\数据_0.02\result\';
cd(output_path)
load('dcAvg_2_stim')
output_path='C:\Users\luping\Desktop\数据_0.02\result\GT\data\stim';
mkdir(output_path)
cd(output_path)
for sub=1:size(stim.O,3)
    Corr=corr(stim.O(:,:,sub));
    filename=strcat('stim_Osub',num2str(sub));
    save(filename,'Corr')
end

for sub=1:size(stim.R,3)
    Corr=corr(stim.R(:,:,sub));
    filename=strcat('stim_Rsub',num2str(sub));
    save(filename,'Corr')
end


for sub=1:size(stim.T,3)
    Corr=corr(stim.T(:,:,sub));
    filename=strcat('stim_Tsub',num2str(sub));
    save(filename,'Corr')
end


%3.2.2:rest1
output_path='C:\Users\luping\Desktop\数据_0.02\result\';
cd(output_path)
load('dcAvg_2_rest1')
output_path='C:\Users\luping\Desktop\数据_0.02\result\GT\data\rest1';
mkdir(output_path)
cd(output_path)
for sub=1:size(rest1.O,3)
    Corr=corr(rest1.O(:,:,sub));
    filename=strcat('rest1_Osub',num2str(sub));
    save(filename,'Corr')
end

for sub=1:size(rest1.R,3)
    Corr=corr(rest1.R(:,:,sub));
    filename=strcat('rest1_Rsub',num2str(sub));
    save(filename,'Corr')
end

for sub=1:size(rest1.T,3)
    Corr=corr(rest1.T(:,:,sub));
    filename=strcat('rest1_Tsub',num2str(sub));
    save(filename,'Corr')
end
%3.2.3:rest2
output_path='C:\Users\luping\Desktop\数据_0.02\result\';
cd(output_path)
load('dcAvg_2_rest2')
output_path='C:\Users\luping\Desktop\数据_0.02\result\GT\data\rest2';
mkdir(output_path)
cd(output_path)
for sub=1:size(rest2.O,3)
    Corr=corr(rest2.O(:,:,sub));
    filename=strcat('rest2_Osub',num2str(sub));
    save(filename,'Corr')
end


for sub=1:size(rest2.R,3)
    Corr=corr(rest2.R(:,:,sub));
    filename=strcat('rest2_Rsub',num2str(sub));
    save(filename,'Corr')
end

for sub=1:size(rest2.T,3)
    Corr=corr(rest2.T(:,:,sub));
    filename=strcat('rest2_Tsub',num2str(sub));
    save(filename,'Corr')
end

%3.2.4 待完成（现阶段先点点点）

%% 画图 只画最后的平均的图即可
%叠加平均marker后的图
  %建立输出目录
  output_path='C:\Users\luping\Desktop\数据_0.02\result\';
  cd(output_path)
  load('dcAvg_2.mat')
  dcAvg_2_rest1=mean(dcAvg_2.rest1,3);
  dcAvg_2_stim=mean(dcAvg_2.stim,3);
  dcAvg_2_rest2=mean(dcAvg_2.rest2,3);
  
  output_path='C:\Users\luping\Desktop\数据_0.02\result\图';
  mkdir(output_path)
  cd(output_path)
  for h=1:43
      x=1+3*(h-1);  %%  1=O 2=R 3=T
      plot(dcAvg_2_rest1(:,h),'r')
      hold on
      plot(dcAvg_2_stim(:,h),'g')
      plot(dcAvg_2_rest2(:,h),'b')
      title('叠加平均后血氧浓度变化')
      xlabel('时间窗')
      ylabel('血氧浓度')
      legend('rest1','stim','rest2')
      hold off
      fname=strcat('T',num2str(h),'.jpg');
      saveas(gcf,fname)
  end

%功率谱
output_path='C:\Users\luping\Desktop\数据_0.02\result\';
cd(output_path)
load('processdata_2.mat')
output_path='C:\Users\luping\Desktop\数据_0.02\result\图\PSD';
mkdir(output_path)
cd(output_path)
psd_stim = mean(processdata_2.stim,3);
psd_rest1 = mean(processdata_2.rest1,3);
psd_rest2 = mean(processdata_2.rest2,3);
noverlap=0;
nfft1=4096;
nfft2=16384;
Fs=11;

for h=1:43
    x=1+3*(h-1);  %%  1=O 2=R 3=T
    [pxx_stim,f_stim] = pwelch(psd_stim(:,x),hamming(12651),noverlap,nfft2,Fs);
    [pxx_rest1,f_rest1] = pwelch(psd_rest1(:,x),hamming(3301),noverlap,nfft1,Fs);
    [pxx_rest2,f_rest2] = pwelch(psd_rest2(:,x),hamming(3301),noverlap,nfft1,Fs);
    plot(f_rest1,10*log10(pxx_rest1),'r',f_rest2,10*log10(pxx_rest2),'b',f_stim,10*log10(pxx_stim),'g')
    title('Welch Power Spectral Density Estimate')
    xlabel('Normalized Frequency(×Π rad/sample)')
    ylabel('Power/frequency(dB/(rad/sample))')
    set(gca,'XLim',[0 0.1])
    line([0.05,0.05],[-120,-40],'linestyle','--')
    legend('rest1','rest2','stim')
    fname=strcat('T',num2str(h),'.jpg');
    saveas(gcf,fname)
end
