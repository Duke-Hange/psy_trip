%% analysis -- The GC between 17 ROIs
%%% step 1 - calculate the ROIS (7 regions, and 8 thalumus subregion )
clear;clc;close all
info_path='F:\Projects\20230814_ThalamusGC_MDD\result\sup_all.xls';   % biological data
[~,~,parti_info]=xlsread(info_path);
parti_info(1,:)=[];
SUB_NAME=parti_info(:,1);
SUB_SITE=parti_info(:,2);

load('F:\Projects\20230814_ThalamusGC_MDD\result\label_exclude.mat')  % load label of the exclude
mask_path='F:\Mask\BN_Atlas_246_3mm.nii';
mask_data=y_Read(mask_path);   % read brain mask
label_0=find(mask_data==0);    % find the voxel that don't need to be calculated
mask_data(label_0)=[];
parent_sub_path='F:\DataBase\mdd';
save_path='F:\Projects\20230814_ThalamusGC_MDD\result\GCA';
mkdir(save_path)

sub_foldername=unique(string(SUB_SITE));
TR=[2.5,2,2,2.7,2.5,2.5];
Band=[0.001,0.027; 0.0271,0.073; 0.0731,0.185;0.001,0.08];

region_label={1:68;69:124;125:162;163:174;175:188;189:210;211:214;215:218;219:230};
region_name=["Frontal","Temporal","Parietal","Insular","Limbic","Occipital","Amyg","Hipp","BG"];
subtha_label={231:232;233:234;235:236;237:238;239:240;241:242;243:244;245:246};
subtha_name=["mPFtha","mPMtha","Stha","rTtha","PPtha","Otha","cTtha","lPFtha"];
labels=[region_label;subtha_label];
names=[region_name,subtha_name];

numsub=0;
subnum=1;
batch=[];
for isite=1:length(sub_foldername)
    sub_path=fullfile(parent_sub_path,sub_foldername{isite},'Raw4DARWSC');
    sub_dir=dir(sub_path);
    sub_dir(1:2)=[];
    
    kk=1;
    label=[];
    for isub=1:length(sub_dir)
        a=string(label_exclude_all(:,1));
        if sum(ismember(a,sub_dir(isub).name))
            label(kk)=isub;
            kk=kk+1;
        end
    end
    sub_dir(label)=[];     % Set the subjects to be excluded as empty
    clear label
    
    kk=1;
    label=[];
    for isub=1:length(sub_dir)
        kkk=find(string(parti_info(:,1))==sub_dir(isub).name);
        if strcmp(parti_info(kkk,6),'NA')
            label(kk)=isub;
            kk=kk+1;
        end
    end
    sub_dir(label)=[];
    clear label
    
    numsub=[numsub,length(sub_dir)];
    batch=[batch,isite*ones(1,length(sub_dir))];
    for isub=1:length(sub_dir)
        tic
        a=strcat('sub_num = ',num2str(subnum));
        disp(a);
        
        sub_name=sub_dir(isub).name;
        sub_label=find(strcmp(sub_name,SUB_NAME)==1);
        
        if isempty(sub_label)
            error('error:the sub name dismatch!');
        end
        
        DemographicMat.site(subnum,1)=parti_info(sub_label,2);
        DemographicMat.diag(subnum,1)=cell2mat(parti_info(sub_label,3));
        DemographicMat.age(subnum,1)=cell2mat(parti_info(sub_label,4));
        DemographicMat.gender(subnum,1)=cell2mat(parti_info(sub_label,5));
        DemographicMat.hand(subnum,1)=cell2mat(parti_info(sub_label,6));
        score(subnum,1)=cell2mat(parti_info(sub_label,7));
        
        %%% step 1 - calculate rois
        % load nii data
        brain_path=fullfile(sub_dir(isub).folder,sub_dir(isub).name);
        cd(brain_path);
        brain=dir('*.nii');
        [brain_data,~]=y_Read(brain.name);
        
        dim=size(brain_data);
        brain_data=reshape(brain_data,[],dim(4));
        brain_data(isnan(brain_data))=0;
        brain_data(label_0,:)=[];
        
        tp_num=dim(4);
        rois = zeros(17,tp_num);  % 9 region + 8 thalumus subregion
        for iroi = 1:17
            roi_pos=[];
            label_now=cell2mat(labels(iroi));
            for ilabel=1:length(label_now)
                roi_pos=[roi_pos,find(mask_data == label_now(ilabel))];
            end
            roi_voxel = brain_data(roi_pos,:);
            rois(iroi,:) = mean(roi_voxel,1);
        end
        
        %%% step2 -Calculate gc
        fs=1./TR(isite);
        fres      = 200;
        freqs = sfreqs(fres,fs);  % Get frequency vector according to the sampling rate.
        %%% step 2  - calculate gc
        for iroi=1:17
            for jroi=1:17
                if iroi~=jroi
                    % Estimate SS model order and model paramaters using CCA SS-SS algorithm
                    try
                        f=y_specGC(rois([iroi,jroi],:));
                        SpecGC(iroi,jroi,:)=squeeze(f(1,2,:));   % GC{i,j} indicata from roi-j to roi-i
                        %                         SpecGC(jroi,iroi,:,subnum)=f(2,1,:);
                    catch
                        SpecGC(iroi,jroi,:)=0;   % GC{i,j} indicata from roi-j to roi-i
                        %                         SpecGC(jroi,iroi,:,subnum)=0;
                    end
                end
            end
        end
        
        % diff band   
        for iband=1:4
            freLow=Band(iband,1);  freHigh=Band(iband,2);
            [~,freLowLabel]=min(abs(freqs-freLow));
            [~,freHighLabel]=min(abs(freqs-freHigh));
            SpecGC_band(:,:,iband)=mean(SpecGC(:,:,freLowLabel:freHighLabel),3);
        end

        subnum=subnum+1;
        toc
    end
end
cd(save_path)
save SpecGC_17.mat SpecGC_band  DemographicMat score