%% load a HOMER3 processed file (recorded by NIRSport) and plot signals
%% Author: Chia-Feng Lu, 2022.05.05
clear, close all

%% parameter initialization
plotCh=6;  % selected channel to display
plotCond=1;  % selected condition to display, ex: 1 for stim1, 2 for stim2, 3 for stim3

interval1=[5 30]; % in second, for the calculation of mean and peak value

sclConc = 1e6; % convert Conc from Molar to uMolar

%% load file
[filename filepath]=uigetfile('*.mat','Please select a HOMER3 processed file');
load([filepath filename],'-mat')

% samplerate = 7.81; % in Hz
samplerate = 1/(output.dod.time(2)-output.dod.time(1)); % in Hz

%% plot Hb concentration signals for a channel 
channelnum=size(output.dc.dataTimeSeries,2)/3;

t=output.dc.time;
Sig_HbO=output.dc.dataTimeSeries(:,(plotCh-1)*3+1)*sclConc;
Sig_HbR=output.dc.dataTimeSeries(:,(plotCh-1)*3+2)*sclConc;
Sig_HbT=output.dc.dataTimeSeries(:,(plotCh-1)*3+3)*sclConc;

figure('color','w')
plot(t,Sig_HbO,'b'), hold on           % plot HbO signal
plot(t,Sig_HbR,'r')                    % plot HbR signal
plot(t,Sig_HbT,'g')                    % plot HbT signal
legend('HbO','HbR','HbT')
title('Hb concentration signals')
xlabel('time (s)'),ylabel('micro-mole')
grid on

%% plot block averages for a channel
setlength=channelnum*3;
t=output.dcAvg.time;
nTrials=output.nTrials{1}(plotCond);
SigHbO=output.dcAvg.dataTimeSeries(:,(plotCond-1)*setlength+(plotCh-1)*3+1)*sclConc;
SigHbR=output.dcAvg.dataTimeSeries(:,(plotCond-1)*setlength+(plotCh-1)*3+2)*sclConc;
SigHbT=output.dcAvg.dataTimeSeries(:,(plotCond-1)*setlength+(plotCh-1)*3+3)*sclConc;
SigHbOstd=output.dcAvgStd.dataTimeSeries(:,(plotCond-1)*setlength+(plotCh-1)*3+1)*sclConc;
SigHbRstd=output.dcAvgStd.dataTimeSeries(:,(plotCond-1)*setlength+(plotCh-1)*3+2)*sclConc;
SigHbTstd=output.dcAvgStd.dataTimeSeries(:,(plotCond-1)*setlength+(plotCh-1)*3+3)*sclConc;

figure('color','w')
plot(t,SigHbO,'r','linewidth',2), hold on     % plot HbO
plot(t,SigHbR,'b','linewidth',2)              % plot HbR
plot(t,SigHbT,'g','linewidth',2)              % plot HbT
errorbar(t(1:10:end),SigHbO(1:10:end),SigHbOstd(1:10:end)/sqrt(nTrials),'r','linewidth',1),             % plot standard error of mean of HbO
errorbar(t(1:10:end),SigHbR(1:10:end),SigHbRstd(1:10:end)/sqrt(nTrials),'b','linewidth',1)              % plot standard error of mean of HbR
errorbar(t(1:10:end),SigHbT(1:10:end),SigHbTstd(1:10:end)/sqrt(nTrials),'g','linewidth',1)              % plot standard error of mean of HbT
legend('HbO','HbR','HbT')
title('Block-average Signals')
xlabel('time (s)'),ylabel('Hb changes (micro-mole)')
grid on

%% Calculate signal mean and maximal value within the period of interval (5 to 30s)
intind=[find(t>=interval1(1),1,'first') find(t<=interval1(end),1,'last')];

HbOmean = mean(SigHbO(intind(1):intind(end)));
HbRmean = mean(SigHbR(intind(1):intind(end)));
HbTmean = mean(SigHbT(intind(1):intind(end)));

HbOpeak = max(SigHbO(intind(1):intind(end)));
HbRpeak = min(SigHbR(intind(1):intind(end)));  
HbTpeak = max(SigHbT(intind(1):intind(end)));


