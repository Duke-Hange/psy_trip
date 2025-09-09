clear all
parent_sub_path='F:\广西医科大\TM_new\GS';        
parent_result_path='F:\广西医科大\TM_new\GS\result';     
 mkdir(parent_result_path)
mask_path='E:\22级\Yu_Hang\BN_Atlas_246_3mm.nii';
sub_foldername={'CONTROL';'TM'};
%% GS  全局
for isite=1:length(sub_foldername)
    sub_path=fullfile(parent_sub_path,sub_foldername{isite});
    result_path=fullfile(parent_result_path,'gs',sub_foldername{isite});
    mkdir(result_path)
    y_gs(sub_path,mask_path,result_path)
end

%% ROIS  局部（点）
 for isite=1:length(sub_foldername)
   sub_path=fullfile(parent_sub_path,sub_foldername{isite});
   result_path=fullfile(parent_result_path,'roi',sub_foldername{isite});
   mkdir(result_path)
   y_roisignals(sub_path,mask_path,result_path)
 end
 
 
 %% FC 局部到局部（线）!!
  for isite=1:length(sub_foldername)
   sub_path=fullfile(parent_sub_path,sub_foldername{isite});
   result_path=fullfile(parent_result_path,'roi',sub_foldername{isite});
   mkdir(result_path)
   y_gstopo_cohere(sub_path,mask_path,result_path)
 end
 
  %% gstopo  全局到局部（线）
 clear result_path sub_path  isite
 for isite=1:length(sub_foldername)
     sub_path_gs=fullfile(parent_result_path,'gs',sub_foldername{isite});
     sub_path_rois=fullfile(parent_result_path,'roi',sub_foldername{isite});
     result_path=fullfile(parent_result_path,'topo','cohere',sub_foldername{isite});
     mkdir(result_path)
     window=30;
     overlap=5;
     nfft=512;
     TR=2;
     y_gstopo_cohere(sub_path_gs,sub_path_rois,result_path,window,overlap,nfft,TR)
 end
 
 %% PowerSpectrum
 clear result_path sub_path  isite
 for isite=1:length(sub_foldername)
     sub_path=fullfile(parent_result_path,'gs',sub_foldername{isite});
     result_path=fullfile(parent_result_path,'topo','powerspectrum',sub_foldername{isite});
     mkdir(result_path)
     window=30;
     overlap=5;
     nfft=512;
     TR=2;
     fs=1/TR;
     y_PowerSpectrum(sub_path,result_path,window,overlap,nfft,fs)
 end
 
 
 %% 先比较GS  （全局）
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
     
     for i=1:length(sub_file);
         a=load(fullfile(sub_path,sub_file(i).name));
         gs(:,i)=a.gs(1,:);
         gs_sd(:,i)=std(gs(:,i));
     end
  
     if isite==1
         gs_CONTROL=gs;
         %回归年龄性别
         y=gs_sd';
         goal_list=xlsread('F:\广西医科大\TM_new\CONTROL.xlsx');
         age=goal_list(:,1);
         gender=goal_list(:,2);
         X=[age, gender];
         %开始分析
         [b,bint,r] = regress(y,X);
         gs_CONTROL_sd=gs_sd;
         gs_CONTROL_sd_R=r;
         
     elseif isite==2
         gs_TM=gs;
         %回归年龄性别
         y=gs_sd';
         goal_list=xlsread('F:\广西医科大\TM_new\TM.xlsx');
         age=goal_list(:,1);
         gender=goal_list(:,2);
         X=[age, gender];
         %开始分析
         [b,bint,r] = regress(y,X);
         gs_TM_sd=gs_sd;
         gs_TM_sd_R=r;
     end
 end
 
max_len = max(length(gs_CONTROL_sd_R), length(gs_TM_sd_R));
data = NaN(max_len, 2);
data(1:length(gs_CONTROL_sd_R), 1) = gs_CONTROL_sd_R;
data(1:length(gs_TM_sd_R), 2) = gs_TM_sd_R;
group = [ones(size(data(:,1))); 2*ones(size(data(:,2)))];
boxplot(data, group);

[h,p,ci,stats]=ttest2(gs_CONTROL_sd_R,gs_TM_sd_R);
 

 %% PSD   
clear all
parent_sub_path = 'F:\广西医科大\TM_new\GS\result\topo\powerspectrum';
parent_result_path='F:\广西医科大\TM_new\GS\result\topo\averPSD';
mkdir(parent_result_path);
sub_foldername={'CONTROL';'TM'};

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
    PSD_CONTROL=psd;
    PSD_CONTROL_mean=psd_mean;
elseif isite==2
    PSD_TM=psd;
    PSD_TM_mean=psd_mean;
end
end

for fre=1:257
    [h,p,ci,stats]=ttest2(PSD_CONTROL(fre,:),PSD_TM(fre,:));
    P_result(:,fre)=p;
    T_result(:,fre)=stats.tstat;
end

% significant_freq = f(P_result <= 0.05);

[P_result_fdr,T_result_fdr]=y_FDR(P_result,T_result);
significant_freq = f(P_result_fdr <= 0.05);

hold on
plot(f,PSD_CONTROL_mean,'Color', [0.85,0.33,0.10],'LineWidth',1.5,'LineJoin','round');
plot(f,PSD_TM_mean,'Color', [0.93,0.69,0.13],'LineWidth',1.5,'LineJoin','round');

% Highlighting Regions
for level = significant_freq
    line([level, level], [0, 1],'LineStyle', '--', 'Color', 'k', 'LineWidth', 0.5);
end

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

sub_file_A=dir(sub_path_A);
sub_file_A(1:2)=[];
sub_file_B=dir(sub_path_B);
sub_file_B(1:2)=[];

for i=1:length(sub_file_A)
    a_a=load(fullfile(sub_file_A(i).folder,sub_file_A(i).name));
    topo_CONTROL(i,:,:)=a_a.gs_topo.C;
end


for i=1:length(sub_file_B)
    a_b=load(fullfile(sub_file_B(i).folder,sub_file_B(i).name));
    topo_TM(i,:,:)=a_b.gs_topo.C;
end


for roi=1:246
    roi
    for fre=1:257
        [h,p,ci,stats]=ttest2(topo_CONTROL(:,roi,fre),topo_TM(:,roi,fre),0.01);
        P_result(roi,fre)=p;
        T_result(roi,fre)=stats.tstat;
%         T_result(roi,fre)=stats.tstat.*(p<0.001/2);
    end
end

   [P_result_fdr,T_result_fdr]=y_FDR(P_result,T_result);
% Plotting the results
figure;
% imagesc(T_result_fdr.*(P_result_fdr<=0.001));
imagesc(T_result_fdr);
colorbar;
caxis([-5, 5]); % Customize the color bar range as per your data

% Adding Title and Labels
title('Significant Differences between HC and TM Groups');
xlabel('Frequency (Hz)');
ylabel('Brain Regions');
yticks([25, 89, 140, 170, 180, 200, 220]);
yticklabels({'Frontal lobe', 'Temporal lobe', 'Parietal lobe', 'Insular lobe', 'Limbic lobe', 'Occipital lobe', 'Subcortial nuclei'});
% xticks([50, 102.8, 152.5, 205, 257]);
xticks([50, 102.8, 152.5, 205]);
xticklabels({'0.05', '0.1', '0.15', '0.2'});

% Highlighting Regions
hold on;
region = [68, 125, 163, 175, 189, 211];
for level = region
    line([0, 257], [level, level], 'LineStyle', '--', 'Color', 'k', 'LineWidth', 1.5);
end

% xlim([0 102]);  
hold off;

% Customize the figure properties for better readability
set(gca, 'FontSize', 10);
set(gcf, 'Color', 'w');
% set(gca,'XLim',[0 0.02])

%%
[row, col] = find(T_result_fdr.*(P_result_fdr<=0.001));  
[row, col] = find(T_result_fdr);  