clear all
% sub_foldername={'group1';'group2';'group3'};

slice_number = 42;
TR = 2;
TA = TR-TR/slice_number;
slice_order = [1:1:slice_number];
refslice1 = 21;
% voxel_size= [3.75 3.75 4];
% smoothing_kernel = [6 6 6];

sub_foldername={'group1'};
subpath_0 = 'F:\教学数据\批处理代码\spm';

for isite=1:length(sub_foldername)
    
    subpath_1=fullfile(subpath_0,sub_foldername{isite});
    
    % 获取目标文件夹下的文件和文件夹列表
    dirInfo = dir(subpath_1)
    dirInfo(1:2)=[];
    
    T1_fold=fullfile(subpath_1,dirInfo(2).name);
    T1_subFolder = dir(T1_fold);
    T1_subFolder(1:2)=[];
    
    T2_fold=fullfile(subpath_1,dirInfo(1).name);
    T2_subFolder = dir(T2_fold);
    T2_subFolder(1:2)=[];
    
    for sub=1:length(T1_subFolder)
        clear T1_niifile T2_niifile
        sub_file_T1=fullfile(T1_subFolder(sub).folder,T1_subFolder(sub).name);
        outpath_T1={fullfile(T1_subFolder(sub).folder,T1_subFolder(sub).name)};
        
        matchingFiles = dir(fullfile(sub_file_T1, '*Image*'));
        
        for i=1:length(matchingFiles)
            T1_niifile{i,:}=fullfile(matchingFiles(i).folder,matchingFiles(i).name);
        end
        
        sub_file_T2=fullfile(T2_subFolder(sub).folder,T2_subFolder(sub).name);
        outpath_T2={fullfile(T2_subFolder(sub).folder,T2_subFolder(sub).name)};
        
        matchingFiles = dir(fullfile(sub_file_T2, '*Image*'));
        
        for i=1:length(matchingFiles)
            T2_niifile{i,:}=fullfile(matchingFiles(i).folder,matchingFiles(i).name);
        end
        
        %% spm处理开始
        % T2
        matlabbatch{1}.spm.util.import.dicom.data = T2_niifile;
        %%
        matlabbatch{1}.spm.util.import.dicom.root = 'flat';
        matlabbatch{1}.spm.util.import.dicom.outdir =outpath_T2;
        matlabbatch{1}.spm.util.import.dicom.protfilter = '.*';
        matlabbatch{1}.spm.util.import.dicom.convopts.format = 'nii';
        matlabbatch{1}.spm.util.import.dicom.convopts.meta = 0;
        matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;
        
        %% T1
        matlabbatch{2}.spm.util.import.dicom.data = T1_niifile;
        matlabbatch{2}.spm.util.import.dicom.root = 'flat';
        matlabbatch{2}.spm.util.import.dicom.outdir = outpath_T1;
        matlabbatch{2}.spm.util.import.dicom.protfilter = '.*';
        matlabbatch{2}.spm.util.import.dicom.convopts.format = 'nii';
        matlabbatch{2}.spm.util.import.dicom.convopts.meta = 0;
        matlabbatch{2}.spm.util.import.dicom.convopts.icedims = 0;
        
        spm_jobman('run',matlabbatch);
        
    end

    for sub=1:length(T1_subFolder)
        clear matlabbatch T2_niifile T1_niifile

        sub_file_T1=fullfile(T1_subFolder(sub).folder,T1_subFolder(sub).name);
        sub_file_T2=fullfile(T2_subFolder(sub).folder,T2_subFolder(sub).name);

        %% slice timing +a
        converted_T1 = dir(fullfile(sub_file_T1, '*sg*'));
        converted_T2 = dir(fullfile(sub_file_T2, '*sg*'));

        for i=1:length(converted_T1)
            T1_niifile{i,:}=fullfile(converted_T1(i).folder,converted_T1(i).name);
        end

        for i=1:length(converted_T2)
            T2_niifile{i,:}=fullfile(converted_T2(i).folder,converted_T2(i).name);
        end

        matlabbatch{1}.spm.temporal.st.scans= {T2_niifile};
        matlabbatch{1}.spm.temporal.st.nslices = slice_number;
        matlabbatch{1}.spm.temporal.st.tr = TR;
        matlabbatch{1}.spm.temporal.st.ta = TA;
        matlabbatch{1}.spm.temporal.st.so = slice_order;
        matlabbatch{1}.spm.temporal.st.refslice = refslice1;
        matlabbatch{1}.spm.temporal.st.prefix = 'a';
        
        %%  头动矫正 Realign T2+r
        matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.sep = 4;
        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.interp = 2;
        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.weight = '';
        matlabbatch{2}.spm.spatial.realign.estwrite.roptions.which = [2 1];
        matlabbatch{2}.spm.spatial.realign.estwrite.roptions.interp = 4;
        matlabbatch{2}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
        matlabbatch{2}.spm.spatial.realign.estwrite.roptions.mask = 1;
        matlabbatch{2}.spm.spatial.realign.estwrite.roptions.prefix = 'r';  
     
        %% 配准 Coregister T1+r
        matlabbatch{3}.spm.spatial.coreg.estwrite.ref(1) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
        matlabbatch{3}.spm.spatial.coreg.estwrite.source = T1_niifile;
        matlabbatch{3}.spm.spatial.coreg.estwrite.other = {''};
        matlabbatch{3}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
        matlabbatch{3}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
        matlabbatch{3}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{3}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
        matlabbatch{3}.spm.spatial.coreg.estwrite.roptions.interp = 4;
        matlabbatch{3}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
        matlabbatch{3}.spm.spatial.coreg.estwrite.roptions.mask = 0;
        matlabbatch{3}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
        
        %% segement 
        matlabbatch{4}.spm.spatial.preproc.channel.vols(1) = cfg_dep('Coregister: Estimate & Reslice: Coregistered Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
        matlabbatch{4}.spm.spatial.preproc.channel.biasreg = 0.001;
        matlabbatch{4}.spm.spatial.preproc.channel.biasfwhm = 60;
        matlabbatch{4}.spm.spatial.preproc.channel.write = [0 1];
        matlabbatch{4}.spm.spatial.preproc.tissue(1).tpm = {'D:\toolbox_matlab\spm12\tpm\TPM.nii,1'};
        matlabbatch{4}.spm.spatial.preproc.tissue(1).ngaus = 1;
        matlabbatch{4}.spm.spatial.preproc.tissue(1).native = [1 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(1).warped = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(2).tpm = {'D:\toolbox_matlab\spm12\tpm\TPM.nii,2'};
        matlabbatch{4}.spm.spatial.preproc.tissue(2).ngaus = 1;
        matlabbatch{4}.spm.spatial.preproc.tissue(2).native = [1 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(2).warped = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(3).tpm = {'D:\toolbox_matlab\spm12\tpm\TPM.nii,3'};
        matlabbatch{4}.spm.spatial.preproc.tissue(3).ngaus = 2;
        matlabbatch{4}.spm.spatial.preproc.tissue(3).native = [1 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(3).warped = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(4).tpm = {'D:\toolbox_matlab\spm12\tpm\TPM.nii,4'};
        matlabbatch{4}.spm.spatial.preproc.tissue(4).ngaus = 3;
        matlabbatch{4}.spm.spatial.preproc.tissue(4).native = [1 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(4).warped = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(5).tpm = {'D:\toolbox_matlab\spm12\tpm\TPM.nii,5'};
        matlabbatch{4}.spm.spatial.preproc.tissue(5).ngaus = 4;
        matlabbatch{4}.spm.spatial.preproc.tissue(5).native = [1 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(5).warped = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(6).tpm = {'D:\toolbox_matlab\spm12\tpm\TPM.nii,6'};
        matlabbatch{4}.spm.spatial.preproc.tissue(6).ngaus = 2;
        matlabbatch{4}.spm.spatial.preproc.tissue(6).native = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(6).warped = [0 0];
        matlabbatch{4}.spm.spatial.preproc.warp.mrf = 1;
        matlabbatch{4}.spm.spatial.preproc.warp.cleanup = 1;
        matlabbatch{4}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
        matlabbatch{4}.spm.spatial.preproc.warp.affreg = 'mni';
        matlabbatch{4}.spm.spatial.preproc.warp.fwhm = 0;
        matlabbatch{4}.spm.spatial.preproc.warp.samp = 3;
        matlabbatch{4}.spm.spatial.preproc.warp.write = [0 1];
        matlabbatch{4}.spm.spatial.preproc.warp.vox = NaN;
        matlabbatch{4}.spm.spatial.preproc.warp.bb = [NaN NaN NaN NaN NaN NaN];

        %     end
        %
        %     for sub=1:length(T1_subFolder)
        %         converted_T2 = dir(fullfile(sub_file_T2, '*ra*'));
        %         converted_T1 = dir(fullfile(sub_file_T1, '*y_s*'));
        % for i=1:length(converted_T2)
        %             T2_niifile{i,:}=fullfile(converted_T2(i).folder,converted_T2(i).name);
        %         end
        %
        %         for i=1:length(converted_T1)
        %             T1_niifile{i,:}=fullfile(converted_T1(i).folder,converted_T1(i).name);
        %         end
        %

        %% 标准化
        matlabbatch{5}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
        matlabbatch{5}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rfiles'));
%         matlabbatch{5}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Realign: Estimate & Reslice: Realigned Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','cfiles'));
        matlabbatch{5}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70 78 76 85];
        matlabbatch{5}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
        matlabbatch{5}.spm.spatial.normalise.write.woptions.interp = 4;
        matlabbatch{5}.spm.spatial.normalise.write.woptions.prefix = 'w';
        
        %% 平滑
%         matlabbatch{6}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
        matlabbatch{6}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
        matlabbatch{6}.spm.spatial.smooth.fwhm = [6 6 6];
        matlabbatch{6}.spm.spatial.smooth.dtype = 0;
        matlabbatch{6}.spm.spatial.smooth.im = 0;
        matlabbatch{6}.spm.spatial.smooth.prefix = 's';
        
        spm_jobman('run',matlabbatch);
        
    end

    end


