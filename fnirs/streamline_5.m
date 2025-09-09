%% ��ȡĿ¼
clear
subpath='C:\Users\luping\Desktop\����_0.05\snirf';
subfile=dir(subpath); 
subfile(1:2)=[];

matpath='C:\Users\luping\Desktop\����_0.05\homerOutput';
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
trange=[-2.0, 20.0];

%�����ײ���
rest_onset1=[];
stim_onset=[];
rest_onset2=[];
noverlap=0;
nfft1=4096;
nfft2=16384;
Fs=11;

%% ������ʽ��ʼ
% test:  sub=1
for sub=1:length(subfile)
    %% ����Ԥ�����ײ�
    file=fullfile(subpath,subfile(sub).name);
    %��ȡ�������ļ�
    snirf=SnirfClass(file);
    probe=snirf.probe;
    time=snirf.data.time;
    
    %������ʼ����Ϣ
    rest_onset1(:,sub)=snirf.stim(1, 1).data(1,1);
    stim_onset(:,sub)=snirf.stim(1, 2).data(:,1);
    rest_onset2(:,sub)=snirf.stim(1, 3).data(1,1);
    
    %����mark
    mark_rest1=snirf.stim(1,1).states;
    mark_rest2=snirf.stim(1,3).states;
    
    for i=1:15
        %����rest1��mark
        [row1,~,~] = find(time==mark_rest1(1,1));
        row1=row1+(i-1)*220;
        mark_rest1(i,1)= time(row1,1);
        mark_rest1(i,2)=1;
        
        %����rest2��mark
        [row2,~,~] = find(time==mark_rest2(1,1)) ;
        row2=row2+(i-1)*220;
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
    dod_mf=hmrR_BandpassFilt(dod_m,0.01,0.1);

    %���ܶȵ�Ѫ��Ũ��
    dc = hmrR_OD2Conc( dod_mf, probe, ppf );
    

    %����marker����ƽ��
    [dcAvg_rest1, ~, ~, ~] = hmrR_BlockAvg(dc, snirf.stim(1,1), trange);
    [dcAvg_stim, ~, ~, ~] = hmrR_BlockAvg(dc, snirf.stim(1,2), trange);
    [dcAvg_rest2, ~, ~, ~] = hmrR_BlockAvg( dc, snirf.stim(1,3), trange);
    %[dcAvg_rest1, dcAvgStd, nTrials, dcSum2] = hmrR_BlockAvg( dc, snirf.stim(1,1), trange);
    
    %% ��ͼ
    %�������Ŀ¼
    [~,name,~]=fileparts(file); %���� fileparts ���������᷵���ļ�·�����������֣�Ŀ¼���ļ�������չ�����������ֻ��Ҫ���е�ĳ�����֣�����ʹ��ռλ�����������ǲ���Ҫ�Ĳ��֡�
    path=fileparts(fileparts(file));  %�����ϼ�Ŀ¼
    folderpath=fullfile(path,name);   %����¼�Ŀ¼
    mkdir(folderpath)   %�ڸ�·�������ļ���
    path=fullfile(folderpath,'��չ�Ա�');%����¼�Ŀ¼
    mkdir(path)       
    cd(path)
    
    %��ͨ����ͼ������
    %O
    for j=1:43
        x=1+3*(j-1);  %%  1=O 2=R 3=T
        plot(dcAvg_rest1.dataTimeSeries(:,x),'r')
        hold on
        plot(dcAvg_stim.dataTimeSeries(:,x),'g')
        plot(dcAvg_rest2.dataTimeSeries(:,x),'b')
        title('����ƽ����Ѫ��Ũ�ȱ仯')
        xlabel('ʱ�䴰')
        ylabel('Ѫ��Ũ��')
        legend('rest1','stim','rest2')
        hold off
        fname=strcat('O',num2str(j),'.jpg');
        saveas(gcf,fname)
        
        rest1_amp_ch = max(dcAvg_rest1.dataTimeSeries(:,x))-min(dcAvg_rest1.dataTimeSeries(:,x));
        stim_amp_ch = max(dcAvg_stim.dataTimeSeries(:,x))-min(dcAvg_stim.dataTimeSeries(:,x));
        rest2_amp_ch = max(dcAvg_rest2.dataTimeSeries(:,x))-min(dcAvg_rest2.dataTimeSeries(:,x));
        
        rest1_amp(sub,j) =rest1_amp_ch;
        stim_amp(sub,j) =stim_amp_ch;
        rest2_ampe(sub,j) =rest2_amp_ch;
        
    end
    
    %R
    for j=1:43
        x=2+3*(j-1);  %%  1=O 2=R 3=T
        plot(dcAvg_rest1.dataTimeSeries(:,x),'r')
        hold on
        plot(dcAvg_stim.dataTimeSeries(:,x),'g')
        plot(dcAvg_rest2.dataTimeSeries(:,x),'b')
        title('����ƽ����Ѫ��Ũ�ȱ仯')
        xlabel('ʱ�䴰')
        ylabel('Ѫ��Ũ��')
        legend('rest1','stim','rest2')
        hold off
        fname=strcat('R',num2str(j),'.jpg');
        saveas(gcf,fname)
    end
  
    %T
    for j=1:43
        x=3+3*(j-1);  %%  1=O 2=R 3=T
        plot(dcAvg_rest1.dataTimeSeries(:,x),'r')
        hold on
        plot(dcAvg_stim.dataTimeSeries(:,x),'g')
        plot(dcAvg_rest2.dataTimeSeries(:,x),'b')
        title('����ƽ����Ѫ��Ũ�ȱ仯')
        xlabel('ʱ�䴰')
        ylabel('Ѫ��Ũ��')
        legend('rest1','stim','rest2')
        hold off
        fname=strcat('T',num2str(j),'.jpg');
        saveas(gcf,fname)
    end
    
    %��������-��ȡƬ��
    matfile1=fullfile(matpath,matfile(sub).name);
    fnirsfile=load(matfile1);
    [row1,~,~] = find(time==rest_onset1(1,sub)) ;   %%Ѱ��mark��
    [row2,~,~] = find(time==stim_onset(3,sub)) ;    %%ȥ����ʼ�����̼�����
    [row3,col,v] = find(time==rest_onset2(1,sub)) ;
    
    data_rest1=fnirsfile.output.dc.dataTimeSeries(row1:row1+3300,:);     %%ѡȡƬ��  165
    data_rest2=fnirsfile.output.dc.dataTimeSeries(row3:row3+3300,:);     %%ѡȡƬ��  165
    data_stim1=fnirsfile.output.dc.dataTimeSeries(row2:row2+12980,:);   %%��������1���������   649
    
    %���ڼ�����ͣ�
    %  20���̼�ʱ��/���ӣ�*60��һ����60�룩*11�����ڲ����ʣ�=13200
    %  20��20��һ�����ڣ�*11�����ڲ����ʣ�=220
    
    %��һ��ԭʼ���ݣ�δ��trigger���ӣ�
    data_rest1_all(:,:,sub)=data_rest1
    data_rest2_all(:,:,sub)=data_rest2
    data_stim1_all(:,:,sub)=data_stim1
    
    %% ��������-����·��
    psd_path=fullfile(folderpath,'������');
    mkdir(psd_path)
    cd(psd_path)
    
    %�������ף�����ͨ����
    for h=1:43
        x=1+3*(h-1);  %%  1=O 2=R 3=T
        [pxx1,f1] = pwelch(data_rest1(:,x),hamming(3301),noverlap,nfft1,Fs);
        [pxx2,f2]=pwelch(data_rest2(:,x),hamming(3301),noverlap,nfft1,Fs);
        [pxx3,f3] = pwelch(data_stim1(:,x),hamming(12981),noverlap,nfft2,Fs);
        plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
        title('Welch Power Spectral Density Estimate')
        xlabel('Normalized Frequency(���� rad/sample)')
        ylabel('Power/frequency(dB/(rad/sample))')
        set(gca,'XLim',[0 0.2])
        line([0.05,0.05],[-150,50],'linestyle','--')
        legend('rest1','rest2','stim')
        fname=strcat('O',num2str(h),'.jpg');
        saveas(gcf,fname)
        
        %%����Ƶ���ڷ�ֵ
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
        [pxx1,f1] = pwelch(data_rest1(:,x),hamming(3301),noverlap,nfft1,Fs);
        [pxx2,f2]=pwelch(data_rest2(:,x),hamming(3301),noverlap,nfft1,Fs);
        [pxx3,f3] = pwelch(data_stim1(:,x),hamming(12981),noverlap,nfft2,Fs);
        plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
        title('Welch Power Spectral Density Estimate')
        xlabel('Normalized Frequency(���� rad/sample)')
        ylabel('Power/frequency(dB/(rad/sample))')
        set(gca,'XLim',[0 0.2])
        line([0.05,0.05],[-150,50],'linestyle','--')
        legend('rest1','rest2','stim')
        fname=strcat('R',num2str(h),'.jpg');
        saveas(gcf,fname)
    end
    
    for h=1:43
        x=3+3*(h-1);  %%  1=O 2=R 3=T
        [pxx1,f1] = pwelch(data_rest1(:,x),hamming(3301),noverlap,nfft1,Fs);
        [pxx2,f2]=pwelch(data_rest2(:,x),hamming(3301),noverlap,nfft1,Fs);
        [pxx3,f3] = pwelch(data_stim1(:,x),hamming(12981),noverlap,nfft2,Fs);
        plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
        title('Welch Power Spectral Density Estimate')
        xlabel('Normalized Frequency(���� rad/sample)')
        ylabel('Power/frequency(dB/(rad/sample))')
        set(gca,'XLim',[0 0.2])
        line([0.05,0.05],[-150,50],'linestyle','--')
        legend('rest1','rest2','stim')
        fname=strcat('T',num2str(h),'.jpg');
        saveas(gcf,fname)
    end
   %���ð����Ե��Ӿ���
    rest1_aver = rest1_aver+data_rest1;
    rest2_aver=  rest2_aver+data_rest2;
    stim_aver=   stim_aver+data_stim1;
end

cd('C:\Users\luping\Desktop\����_0.05\aver')
save('peak_power.mat', 'rest1_peak', 'rest2_peak', 'stim_peak');
save('peak_power_fre.mat', 'rest1_peak_fre', 'rest2_peak_fre', 'stim_peak_fre');
save('amp.mat', 'rest1_amp', 'stim_amp', 'rest2_amp');

 
%% ƽ��ͼ

rest1_aver = rest1_aver/length(subfile);  %%ƽ��
rest2_aver=  rest2_aver/length(subfile);
stim_aver=   stim_aver/length(subfile);

for i=1:43                             %%��ʼ��ͨ������
    x=1+3*(i-1);  %%  1=O 2=R 3=T
    rest1_aver_O(:,1) = rest1_aver_O(:,1)+rest1_aver(:,x);
    rest2_aver_O(:,1) = rest2_aver_O(:,1)+rest2_aver(:,x);
    stim_aver_O(:,1)=  stim_aver_O(:,1)+stim_aver(:,x);
end
rest1_aver_O=rest1_aver_O/i;  %%ƽ��
rest2_aver_O=rest2_aver_O/i;
stim_aver_O=stim_aver_O/i;

rest1_aver_R=zeros(3301,1);
rest2_aver_R=zeros(3301,1);
stim_aver_R=zeros(12981,1);

for i=1:43                             %%��ʼ��ͨ������
    x=2+3*(i-1);  %%  1=O 2=R 3=T
    rest1_aver_R(:,1) = rest1_aver_R(:,1)+rest1_aver(:,x);
    rest2_aver_R(:,1) = rest2_aver_R(:,1)+rest2_aver(:,x);
    stim_aver_R(:,1)=  stim_aver_R(:,1)+stim_aver(:,x);
end
rest1_aver_R=rest1_aver_R/i;  %%ƽ��
rest2_aver_R=rest2_aver_O/i;
stim_aver_R=stim_aver_R/i;

rest1_aver_T=zeros(3301,1);
rest2_aver_T=zeros(3301,1);
stim_aver_T=zeros(12981,1);

for i=1:43                             %%��ʼ��ͨ������
    x=3+3*(i-1);  %%  1=O 2=R 3=T
    rest1_aver_T(:,1) = rest1_aver_T(:,1)+rest1_aver(:,x);
    rest2_aver_T(:,1) = rest2_aver_T(:,1)+rest2_aver(:,x);
    stim_aver_T(:,1)=  stim_aver_T(:,1)+stim_aver(:,x);
end
rest1_aver_T=rest1_aver_R/i;  %%ƽ��
rest2_aver_T=rest2_aver_O/i;
stim_aver_T=stim_aver_R/i;

path='C:\Users\luping\Desktop\����_0.05\aver\������\';
mkdir(path)
cd(path)

[pxx1,f1] = pwelch(rest1_aver_O(:,1),hamming(3301),noverlap,nfft1,Fs);
[pxx2,f2] = pwelch(rest2_aver_O(:,1),hamming(3301),noverlap,nfft1,Fs);
[pxx3,f3] = pwelch(stim_aver_O(:,1),hamming(12981),noverlap,nfft2,Fs);
plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
title('Welch Power Spectral Density Estimate')
xlabel('Normalized Frequency(���� rad/sample)')
ylabel('Power/frequency(dB/(rad/sample))')
set(gca,'XLim',[0 0.2])
    line([0.05,0.05],[-150,50],'linestyle','--')
legend('rest1','rest2','stim')
fname=strcat(path,'O_','aver','.jpg');
saveas(gcf,fname)

[pxx1,f1] = pwelch(rest1_aver_R(:,1),hamming(3301),noverlap,nfft1,Fs);
[pxx2,f2] = pwelch(rest2_aver_R(:,1),hamming(3301),noverlap,nfft1,Fs);
[pxx3,f3] = pwelch(stim_aver_R(:,1),hamming(12981),noverlap,nfft2,Fs);
plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
title('Welch Power Spectral Density Estimate')
xlabel('Normalized Frequency(���� rad/sample)')
ylabel('Power/frequency(dB/(rad/sample))')
set(gca,'XLim',[0 0.2])
    line([0.05,0.05],[-150,50],'linestyle','--')
legend('rest1','rest2','stim')
fname=strcat(path,'R_','aver','.jpg');
saveas(gcf,fname)

[pxx1,f1] = pwelch(rest1_aver_T(:,1),hamming(3301),noverlap,nfft1,Fs);
[pxx2,f2] = pwelch(rest2_aver_T(:,1),hamming(3301),noverlap,nfft1,Fs);
[pxx3,f3] = pwelch(stim_aver_T(:,1),hamming(12981),noverlap,nfft2,Fs);
plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
title('Welch Power Spectral Density Estimate')
xlabel('Normalized Frequency(���� rad/sample)')
ylabel('Power/frequency(dB/(rad/sample))')
set(gca,'XLim',[0 0.2])
    line([0.05,0.05],[-150,50],'linestyle','--')
legend('rest1','rest2','stim')
fname=strcat(path,'T_','aver','.jpg');
saveas(gcf,fname)

%% ��ͨ��SD

for i=1:43
    x=1+3*(i-1);  %%  1=O 2=R 3=T
    [pxx1,f1] = pwelch(rest1_aver(:,x),hamming(3301),noverlap,nfft1,Fs);
    [pxx2,f2]=pwelch(rest2_aver(:,x),hamming(3301),noverlap,nfft1,Fs);
    [pxx3,f3] = pwelch(stim_aver(:,x),hamming(12981),noverlap,nfft2,Fs);
    plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
    title('Welch Power Spectral Density Estimate')
    xlabel('Normalized Frequency(���� rad/sample)')
    ylabel('Power/frequency(dB/(rad/sample))')
    set(gca,'XLim',[0 0.2])
    line([0.05,0.05],[-150,50],'linestyle','--')
    legend('rest1','rest2','stim')
    fname=strcat(path,'O',num2str(i),'.jpg');
    saveas(gcf,fname)
end


for i=1:43
    x=2+3*(i-1);  %%  1=O 2=R 3=T
    [pxx1,f1] = pwelch(rest1_aver(:,x),hamming(3301),noverlap,nfft1,Fs);
    [pxx2,f2]=pwelch(rest2_aver(:,x),hamming(3301),noverlap,nfft1,Fs);
    [pxx3,f3] = pwelch(stim_aver(:,x),hamming(12981),noverlap,nfft2,Fs);
    plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
    title('Welch Power Spectral Density Estimate')
    xlabel('Normalized Frequency(���� rad/sample)')
    ylabel('Power/frequency(dB/(rad/sample))')
    set(gca,'XLim',[0 0.2])
    line([0.05,0.05],[-150,50],'linestyle','--')
    legend('rest1','rest2','stim')
    fname=strcat(path,'R',num2str(i),'.jpg');
    saveas(gcf,fname)
end


for i=1:43
    x=3+3*(i-1);  %%  1=O 2=R 3=T
    [pxx1,f1] = pwelch(rest1_aver(:,x),hamming(3301),noverlap,nfft1,Fs);
    [pxx2,f2]=pwelch(rest2_aver(:,x),hamming(3301),noverlap,nfft1,Fs);
    [pxx3,f3] = pwelch(stim_aver(:,x),hamming(12981),noverlap,nfft2,Fs);
    plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
    title('Welch Power Spectral Density Estimate')
    xlabel('Normalized Frequency(���� rad/sample)')
    ylabel('Power/frequency(dB/(rad/sample))')
    set(gca,'XLim',[0 0.2])
    line([0.05,0.05],[-150,50],'linestyle','--')
    legend('rest1','rest2','stim')
    fname=strcat(path,'T',num2str(i),'.jpg');
    saveas(gcf,fname)
end


