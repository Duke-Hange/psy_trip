clear all
parent_sub_path='F:\广西医科大\TM_new\GS';        
parent_result_path='F:\广西医科大\TM_new\GS\result';     
 mkdir(parent_result_path)
mask_path='E:\22级\Yu_Hang\BN_Atlas_246_3mm.nii';
sub_foldername={'CONTROL';'TM'};
%% GS
for isite=1:length(sub_foldername)
    sub_path=fullfile(parent_sub_path,sub_foldername{isite});
    result_path=fullfile(parent_result_path,'gs',sub_foldername{isite});
    mkdir(result_path)
    y_gs(sub_path,mask_path,result_path)
end

%% ROIS
 for isite=1:length(sub_foldername)
   sub_path=fullfile(parent_sub_path,sub_foldername{isite});
   result_path=fullfile(parent_result_path,'roi',sub_foldername{isite});
   mkdir(result_path)
   y_roisignals(sub_path,mask_path,result_path)
 end
  %% topo_COHERE  
 clear result_path sub_path  isite
 for isite=1:length(sub_foldername)
     sub_path_gs=fullfile(parent_result_path,'gs',sub_foldername{isite});
     sub_path_rois=fullfile(parent_result_path,'roi',sub_foldername{isite});
     result_path=fullfile(parent_result_path,'topo','cohere',sub_foldername{isite});
     mkdir(result_path)
     window=15;
     overlap=7;
     nfft=512;
%        window=30;
%      overlap=15;
%      nfft=256;
     TR=2;
     y_gstopo_cohere(sub_path_gs,sub_path_rois,result_path,window,overlap,nfft,TR)
 end
 
 %% PowerSpectrum
 clear result_path sub_path  isite
 for isite=1:length(sub_foldername)
     sub_path=fullfile(parent_result_path,'gs',sub_foldername{isite});
     result_path=fullfile(parent_result_path,'topo','powerspectrum',sub_foldername{isite});
     mkdir(result_path)
         window=15;
     overlap=7;
     nfft=512;
     TR=2;
     fs=1/TR;
     y_PowerSpectrum(sub_path,result_path,window,overlap,nfft,fs)
 end
 
 
 %% 先比较GS
 clear all
 parent_sub_path = 'F:\广西医科大\TM_new\GS\result\gs';
 parent_result_path='F:\广西医科大\TM_new\GS\result\';
 mkdir(parent_result_path);
 sub_foldername={'CONTROL';'TM'};
 
 for isite=1:length(sub_foldername)
     sub_path=fullfile(parent_sub_path,sub_foldername{isite});
     result_path=fullfile(parent_result_path,sub_foldername{isite});
     sub_file=dir(sub_path);
     sub_file(1:2)=[];
     gs=[];
     gs_mean=[];
     gs_sd=[];
     
     for i=1:length(sub_file);
         a=load(fullfile(sub_path,sub_file(i).name));
         gs(:,i)=a.gs(1,:);
         gs_mean(:,i)=mean(gs(:,i));
         gs_sd(:,i)=std(gs(:,i));
     end
  
     if isite==1
         gs_SLE=gs;
         gs_SLE_mean=gs_mean;
         gs_SLE_sd=gs_sd;
     elseif isite==2
         gs_HC=gs;
         gs_HC_mean=gs_mean;
         gs_HC_sd=gs_sd;
     end
 end
 
 %mean
max_len = max(length(gs_HC_mean), length(gs_SLE_mean));
data = NaN(max_len, 2);
data(1:length(gs_HC_mean), 1) = gs_HC_mean;
data(1:length(gs_SLE_mean), 2) = gs_SLE_mean;
group = [ones(size(data(:,1))); 2*ones(size(data(:,2)))];
boxplot(data, group);

[h,p,ci,stats]=ttest2(gs_HC_mean,gs_SLE_mean);

 [P_result_fdr,T_result_fdr]=y_FDR(p,stats.tstat);

 %sd
max_len = max(length(gs_HC_sd), length(gs_SLE_sd));
data = NaN(max_len, 2);
data(1:length(gs_HC_sd), 1) = gs_HC_sd;
data(1:length(gs_SLE_sd), 2) = gs_SLE_sd;
group = [ones(size(data(:,1))); 2*ones(size(data(:,2)))];
boxplot(data, group);

[h,p,ci,stats]=ttest2(gs_HC_sd,gs_SLE_sd);

[P_result_fdr,T_result_fdr]=y_FDR(p,stats.tstat);

gs_SLE_mean=gs_SLE_mean';
gs_HC_mean=gs_HC_mean';
gs_SLE_sd=gs_SLE_sd';
gs_HC_sd=gs_HC_sd';

 %% PSD
clear all
parent_sub_path = 'F:\广西医科大\TM_new\GS\result\topo\powerspectrum';
parent_result_path='F:\广西医科大\TM_new\GS\result\topo\averPSD';
mkdir(parent_result_path);
sub_foldername={'CONTROL';'TM'};
% sub_foldername={'B';'A'};

for isite=1:length(sub_foldername)
    sub_path=fullfile(parent_sub_path,sub_foldername{isite});
    result_path=fullfile(parent_result_path,sub_foldername{isite});
    sub_file=dir(sub_path);
    sub_file(1:2)=[];
f=[];
psd=[];
psd_mean=[];

for i=1:length(sub_file);
    a=load(fullfile(sub_path,sub_file(i).name));
    f=a.f;
    psd(:,i)=a.Pxx_dB;
    psd_mean=mean(psd,2);
end

if isite==1
    PSD_SLE=psd;
    T_B_PSD_mean=psd_mean;
elseif isite==2
    PSD_HC=psd;
    T_A_PSD_mean=psd_mean;
end
end

for fre=1:257
    [h,p,ci,stats]=ttest2(PSD_SLE(fre,:),PSD_HC(fre,:));
    P_result(:,fre)=p;
    T_result(:,fre)=stats.tstat;
end

% [P_result_fdr,T_result_fdr]=y_FDR(P_result,T_result);
significant_freq = f(P_result <= 0.05);

hold on
plot(f,T_B_PSD_mean,'Color', [0.85,0.33,0.10],'LineWidth',1.5,'LineJoin','round');
plot(f,T_A_PSD_mean,'Color', [0.93,0.69,0.13],'LineWidth',1.5,'LineJoin','round');

% % Highlighting Regions
% for level = significant_freq
%     line([level, level], [0, 1],'LineStyle', '--', 'Color', 'k', 'LineWidth', 0.5);
% end

xlim([0 0.2]);  
hold off
legend('SLE','HC')
xlabel('Frequency (Hz)')
ylabel('Power/frequency (dB/Hz)')

%% GStopo
clear all
parent_sub_path='F:\广西医科大\TM_new\GS\result\topo\cohere';
parent_result_path='F:\广西医科大\TM_new\GS\result\topo\GStopo';
mkdir(parent_result_path)
cd(parent_result_path)
sub_path_A=fullfile(parent_sub_path,'CONTROL');
sub_path_B=fullfile(parent_sub_path,'TM');
mkdir(parent_result_path);
sub_file_A=dir(sub_path_A);sub_file_A(1:2)=[];
sub_file_B=dir(sub_path_B);sub_file_B(1:2)=[];

for i=1:length(sub_file_A)
    a_a=load(fullfile(sub_file_A(i).folder,sub_file_A(i).name));
    topo_HC(i,:,:)=a_a.gs_topo.C; %C
end

for i=1:length(sub_file_B)
    a_b=load(fullfile(sub_file_B(i).folder,sub_file_B(i).name));
    topo_SLE(i,:,:)=a_b.gs_topo.C; %C
end

for roi=1:246
    roi
    for fre=1:257
        [h,p,ci,stats]=ttest2(topo_HC(:,roi,fre),topo_SLE(:,roi,fre),0.05);
        P_result(roi,fre)=p;
        T_result(roi,fre)=stats.tstat;
%         T_result(roi,fre)=stats.tstat.*(p<0.05/49);
    end
end

[P_result_fdr,T_result_fdr]=y_FDR(P_result,T_result);

% Plotting the results
figure;
imagesc(T_result_fdr);
colorbar;
caxis([-5, 5]); % Customize the color bar range as per your data

% Adding Title and Labels
title('Significant Differences between HC and TM Groups');
xlabel('Frequency (Hz)');
ylabel('Brain Regions');

% yticks={[69:124;125:162;163:174;175:188;189:210;211:214;215:218;219:230,231:232;233:234;235:236;237:238;239:240;241:242;243:244;245:246]};
% region_name=["Frontal","Temporal","Parietal","Insular","Limbic","Occipital","Amyg","Hipp","BG","mPFtha","mPMtha","Stha","rTtha","PPtha","Otha","cTtha","lPFtha"];

yticks([25, 89, 140, 170, 180, 200, 220]);
yticklabels({'Frontal lobe', 'Temporal lobe', 'Parietal lobe', 'Insular lobe', 'Limbic lobe', 'Occipital lobe', 'Subcortial nuclei'});
% % xticks([50, 102.8, 152.5, 205, 257]);
xticks([52, 103, 155, 206,257]);
xticklabels({'0.05', '0.1', '0.15', '0.2','0.25'});

% Highlighting Regions
hold on;
region = [68, 125, 163, 175, 189, 211];
for level = region
    line([0, 257], [level, level], 'LineStyle', '--', 'Color', 'k', 'LineWidth', 1.5);
end

% xlim([0 205]);  
hold off;

% Customize the figure properties for better readability
set(gca, 'FontSize', 10);
set(gcf, 'Color', 'w');
% set(gca,'XLim',[0 0.02])


%非画图
T_result2 = T_result ~= 0; 
topo_valve=mean(topo_SLE,1);
% topo_valve2 = reshape(topo_valve, 246, 129);  
topo_valve2 = squeeze(topo_valve); 
topo_valve3=topo_valve2.*T_result2;

[row, col, val] = find(T_result);  
row=unique(row);
col=unique(col);

%%

figure;  
imagesc(T_result);  
colorbar;  
caxis([-5, 5]); % Set color bar range  

% Customize colormap for better visibility  
colormap(parula); % Or use 'parula', 'hot', 'cool', etc.  'jet'

% Adding Title and Labels  
title('Significant Differences between HC and TM Groups', 'FontSize', 14, 'FontWeight', 'bold');  
xlabel('Frequency (Hz)', 'FontSize', 12);  
ylabel('Brain Regions', 'FontSize', 12);  
yticks([25, 89, 140, 170, 180, 200, 220]);  
yticklabels({'Frontal lobe', 'Temporal lobe', 'Parietal lobe', 'Insular lobe', 'Limbic lobe', 'Occipital lobe', 'Subcortical nuclei'});  

% Adjust x-ticks  
xticks([50, 102.8, 152.5]);  
xticklabels({'0.05', '0.1', '0.15'});  

% Highlighting Regions with thicker lines and color  
hold on;  
region = [68, 125, 163, 175, 189, 211];  
for level = region  
    line([0, size(T_result, 2)], [level, level], 'LineStyle', '--', 'Color', 'k', 'LineWidth', 2);  
end  

% Set xlim to focus on relevant data  
% xlim([0 257]);  

% Customize the axes appearance  
set(gca, 'FontSize', 10, 'FontWeight', 'bold', 'Box', 'on', 'GridLineStyle', ':', 'GridColor', [0.5, 0.5, 0.5], 'GridAlpha', 0.3);  
set(gca, 'YColor', [0.2, 0.2, 0.2]);  
% set(gca, 'XColor', [0.2, 0.2, 0.2]);  

% Apply background color and grid  
set(gcf, 'Color', 'w');  
grid on;  

% Improve color bar appearance  
cb = colorbar;  
cb.Label.String = 'Magnitude';  
cb.Label.FontSize = 12;  
cb.FontSize = 10;  

% Aesthetic adjustments  
set(gca, 'TickLength', [0.02, 0.02]);  
set(gca, 'LineWidth', 1.5);  
hold off;

