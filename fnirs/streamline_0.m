%��ȡĿ¼
clear
subpath='C:\Users\luping\Desktop\����_α�̼�\shem_snirf';
subfile=dir(subpath);
subfile(1:2)=[];

matpath='C:\Users\luping\Desktop\����_α�̼�\homerOutput';
matfile=dir(matpath);
matfile(1:2)=[];

%ͷ������
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

%���Ե��Ӿ�������
rest1_aver=zeros(2861,129);
rest2_aver=zeros(2861,129);
stim_aver=zeros(12981,129);   %%0.05-12981  0.02-12651

for sub=1:length(subfile)
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
    mark_stim=snirf.stim(1,2).states;
    for i=1:14   %15  
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
    
    for i=1:60
        %����stim��mark
        [row3,~,~] = find(time==mark_stim(1,1));
        row3=row3+(i-1)*220;   %%220  550
        mark_stim(i,1)= time(row3,1);
        mark_stim(i,2)=1;
    end
    
    snirf.stim(1,1).states=mark_rest1;
    snirf.stim(1,3).states=mark_rest2;
    snirf.stim(1,2).states=mark_stim;
    
    %��ǿת����
    dod=hmrR_Intensity2OD(snirf.data);
    
    %ͷ�����
    [tInc,tIncCh] = hmrR_MotionArtifactByChannel(dod, probe, [], [], [], tMotion, tMask, STDEVthresh, AMPthresh);
    
    %ͷ������
    dod_m = hmrR_MotionCorrectSpline(dod, [], tIncCh, p, turnon);
    
    %�˲�
    dod_mf=hmrR_BandpassFilt(dod_m,0.045,0.055);
    
    %���ܶȵ�Ѫ��Ũ��
    dc = hmrR_OD2Conc( dod_mf, probe, ppf );
    %����ƽ��
    [dcAvg_rest1, ~, ~, ~] = hmrR_BlockAvg( dc, snirf.stim(1,1), trange);
    [dcAvg_stim, ~, ~, ~] = hmrR_BlockAvg( dc, snirf.stim(1,2), trange);
    [dcAvg_rest2, dcAvgStd, nTrials, dcSum2] = hmrR_BlockAvg( dc, snirf.stim(1,3), trange);
    
    %�������Ŀ¼
    [~,name,~]=fileparts(file); %���� fileparts ���������᷵���ļ�·�����������֣�Ŀ¼���ļ�������չ�����������ֻ��Ҫ���е�ĳ�����֣�����ʹ��ռλ�����������ǲ���Ҫ�Ĳ��֡�
    path=fileparts(fileparts(file));
    folderpath=fullfile(path,name);
    mkdir(folderpath)
    path=fullfile(folderpath,'��չ�Ա�');
    mkdir(path)
    cd(path)
    
    %��ͨ����ͼ������
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
        rest2_amp(sub,j) =rest2_amp_ch;
        
    end
    
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
    [row2,~,~] = find(time==stim_onset(1,sub)) ;
    [row3,col,v] = find(time==rest_onset2(1,sub)) ;
    
    data_rest1=fnirsfile.output.dc.dataTimeSeries(row1:row1+2860,:);     %%ѡȡƬ��
    data_rest2=fnirsfile.output.dc.dataTimeSeries(row3:row3+2860,:);
    data_stim1=fnirsfile.output.dc.dataTimeSeries(row2+440:row2+13420,:);   %%ȥ����ʼ�����̼�����,��������1���������
    
    %���ð����Ե��Ӿ���          
    rest1_aver = rest1_aver+data_rest1;
    rest2_aver=  rest2_aver+data_rest2;
    stim_aver=   stim_aver+data_stim1;
    
    
    %��������-����·��
    psd_path=fullfile(folderpath,'������');
    mkdir(psd_path)
    cd(psd_path)
    
   
    %�������ף�����ͨ����
    for h=1:43
        x=1+3*(h-1);  %%  1=O 2=R 3=T
        [pxx1,f1] = pwelch(data_rest1(:,x),hamming(2861),noverlap,nfft1,Fs);
        [pxx2,f2]=pwelch(data_rest2(:,x),hamming(2861),noverlap,nfft1,Fs);
        [pxx3,f3] = pwelch(data_stim1(:,x),hamming(12981),noverlap,nfft2,Fs);
        plot(f1,10*log10(pxx1),'r',f2,10*log10(pxx2),'b',f3,10*log10(pxx3),'g')
        title('Welch Power Spectral Density Estimate')
        xlabel('Normalized Frequency(���� rad/sample)')
        ylabel('Power/frequency(dB/(rad/sample))')
        set(gca,'XLim',[0 0.2])
        line([0.05,0.05],[-150,50],'linestyle','--')
        %���Լ���������
        legend('rest1','rest2','stim')
        fname=strcat('O',num2str(h),'.jpg');
        saveas(gcf,fname)
        
        %%����Ƶ���ڷ�ֵ
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
        [pxx1,f1] = pwelch(data_rest1(:,x),hamming(2861),noverlap,nfft1,Fs);
        [pxx2,f2]=pwelch(data_rest2(:,x),hamming(2861),noverlap,nfft1,Fs);
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
end
cd('C:\Users\luping\Desktop\����_α�̼�\aver')
% save('peak_power2.mat', 'rest1_peak', 'rest2_peak', 'stim_peak');
% save('peak_power_fre2.mat', 'rest1_peak_fre', 'rest2_peak_fre', 'stim_peak_fre');
save('peak_power5.mat', 'rest1_peak', 'rest2_peak', 'stim_peak');
save('peak_power_fre5.mat', 'rest1_peak_fre', 'rest2_peak_fre', 'stim_peak_fre');
save('amp.mat', 'rest1_amp', 'stim_amp', 'rest2_amp');

%% ƽ��ͼ
rest1_aver = rest1_aver/length(subfile);  %%ƽ��
rest2_aver=  rest2_aver/length(subfile);
stim_aver=   stim_aver/length(subfile);

rest1_aver_O=zeros(2861,1);
rest2_aver_O=zeros(2861,1);
stim_aver_O=zeros(12981,1);

for i=1:43                             %%��ʼ��ͨ������
    x=1+3*(i-1);  %%  1=O 2=R 3=T
    rest1_aver_O(:,1) = rest1_aver_O(:,1)+rest1_aver(:,x);
    rest2_aver_O(:,1) = rest2_aver_O(:,1)+rest2_aver(:,x);
    stim_aver_O(:,1)=  stim_aver_O(:,1)+stim_aver(:,x);
end
rest1_aver_O=rest1_aver_O/i;  %%ƽ��
rest2_aver_O=rest2_aver_O/i;
stim_aver_O=stim_aver_O/i;

rest1_aver_R=zeros(2861,1);
rest2_aver_R=zeros(2861,1);
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

rest1_aver_T=zeros(2861,1);
rest2_aver_T=zeros(2861,1);
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

path='C:\Users\luping\Desktop\����_α�̼�\aver\������\';
mkdir(path)
cd(path)


[pxx1,f1] = pwelch(rest1_aver_O(:,1),hamming(2861),noverlap,nfft1,Fs);
[pxx2,f2] = pwelch(rest2_aver_O(:,1),hamming(2861),noverlap,nfft1,Fs);
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

[pxx1,f1] = pwelch(rest1_aver_R(:,1),hamming(2861),noverlap,nfft1,Fs);
[pxx2,f2] = pwelch(rest2_aver_R(:,1),hamming(2861),noverlap,nfft1,Fs);
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

[pxx1,f1] = pwelch(rest1_aver_T(:,1),hamming(2861),noverlap,nfft1,Fs);
[pxx2,f2] = pwelch(rest2_aver_T(:,1),hamming(2861),noverlap,nfft1,Fs);
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
    [pxx1,f1] = pwelch(rest1_aver(:,x),hamming(2861),noverlap,nfft1,Fs);
    [pxx2,f2]=pwelch(rest2_aver(:,x),hamming(2861),noverlap,nfft1,Fs);
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
    [pxx1,f1] = pwelch(rest1_aver(:,x),hamming(2861),noverlap,nfft1,Fs);
    [pxx2,f2]=pwelch(rest2_aver(:,x),hamming(2861),noverlap,nfft1,Fs);
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
    [pxx1,f1] = pwelch(rest1_aver(:,x),hamming(2861),noverlap,nfft1,Fs);
    [pxx2,f2]=pwelch(rest2_aver(:,x),hamming(2861),noverlap,nfft1,Fs);
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

