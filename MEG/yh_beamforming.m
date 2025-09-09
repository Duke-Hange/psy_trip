clear
Meg_dir = 'E:\22级\Yu_Hang\新建文件夹\demo数据\ds000247_R1.0.0\sub-0002\ses-0001\meg';
Mri_dir = 'E:\22级\Yu_Hang\新建文件夹\demo数据\ds000247_R1.0.0\sub-0002\ses-0001\anat';

Meg_file=dir(fullfile(Meg_dir,'*meg.ds'));
Meg_file=fullfile(Meg_file.folder,Meg_file.name);

Mri_file=dir(fullfile(Mri_dir,'*.nii'));
Mri_file=fullfile(Mri_file.folder,Mri_file.name);

%% specify and read mri file from patient folder
mri_file = Mri_file; 
mri_orig = ft_read_mri(mri_file);

%% detect and specify MEG file 
% specify and read MEG file 
meg_file = Meg_file; 

% headshape file 
headshape = dir(fullfile(Meg_dir,'*.pos'));
headshape=fullfile(headshape.folder,headshape.name);
headshape = ft_read_headshape(headshape);

% convert dimensions of headshape for further analysis
headshape = ft_convert_units(headshape, 'mm');

% check axis of coordinate system
ft_determine_coordsys(mri_orig, 'interactive', 'no') % x-axis should be right
ft_plot_headshape(headshape);

%% Re-align 
cfg = [];
cfg.method = 'headshape';
cfg.headshape.interactive = 'yes';
cfg.headshape.icp = 'yes';
cfg.headshape.headshape = headshape;
cfg.coordsys = 'neuromag';
cfg.spmversion = 'spm12';
mri_realigned = ft_volumerealign(cfg, mri_orig);
mri_realigned.coordsys = 'neuromag';

% Do you want to change the anatomical labels for the axes [Y, n]? y
% What is the anatomical label for the positive X-axis [r, l, a, p, s, i]? r  
% What is the anatomical label for the positive Y-axis [r, l, a, p, s, i]? a
% What is the anatomical label for the positive Z-axis [r, l, a, p, s, i]? s
% Is the origin of the coordinate system at the a(nterior commissure), i(nterauricular), n(ot a landmark)? i

ft_determine_coordsys(mri_realigned, 'interactive', 'no')
ft_plot_headshape(headshape);

output_dir='E:\22级\Yu_Hang\新建文件夹\demo数据\ds000247_R1.0.0\sub-0002\result';
mkdir(output_dir)
cd (output_dir)
save ('headshape');

%% %% pre-process MEG
cfg = [];
cfg.dataset = meg_file;
cfg = ft_definetrial(cfg);
cfg= ft_artifact_jump(cfg);
cfg = ft_rejectartifact(cfg);

cfg.hpfilter = 'yes';
cfg.hpfreq = 2; % can be changed to 10
cfg.lpfilter = 'yes';
cfg.lpfreq = 150;
cfg.channel= {'MEG', 'ECG'};
cfg.coilaccuracy = 0;
cfg.continuous = 'yes';
data = ft_preprocessing(cfg);

% Resample data file to save memory space

cfg = [];
cfg.resamplefs = 300;
data_resampled = ft_resampledata(cfg, data);


%% compute data covariance window 
cfg = [];
cfg.channel = 'MEG';
cfg.covariance = 'yes';
cov_matrix = ft_timelockanalysis(cfg, data_resampled);
cd (output_dir);
save ('cov_matrix', '-v7.3');

%% create headmodel 
cfg = [];
cfg.tissue = 'brain';
cfg.spmversion = 'spm12';
seg = ft_volumesegment(cfg, mri_realigned);

save ('seg', '-v7.3'); 

cfg = [];
cfg.tissue = 'brain';
cfg.spmversion = 'spm12';
brain_mesh = ft_prepare_mesh(cfg, seg);

cfg = [];
cfg.method = 'singleshell'; % previously was singleshell 
cfg.grad = data_resampled.grad; 
headmodel = ft_prepare_headmodel(cfg, brain_mesh);

cd (output_dir);
save ('headmodel', '-v7.3')
clear seg.mat

%% construction of source model 
cfg = [];
cfg.resolution = 5; % for clinical purpose should be 5mm or less
cfg.unit = 'mm';
cfg.headmodel = headmodel;
cfg.grad = data_resampled.grad;
sourcemodel = ft_prepare_sourcemodel(cfg);

cd (output_dir);
save ('sourcemodel', '-v7.3') 


%% compute leadfield 
cfg = [];
cfg.channel = 'MEG';
cfg.headmodel = headmodel;
cfg.sourcemodel = sourcemodel;
cfg.normalize = 'yes'; % normalisation avoids power bias towards centre of head
cfg.reducerank = 2;
cfg.resolution = 2; 
cfg.unit      = 'cm';
leadfield = ft_prepare_leadfield(cfg, cov_matrix);

cd (output_dir);
save ('leadfield', '-v7.3'); 

% %% plot all geometrical data to check their alignment
figure
ft_plot_axes([], 'unit', 'mm', 'coordsys', 'neuromag');
ft_plot_headmodel(headmodel, 'unit', 'mm'); % this is the brain shaped head model volume
ft_plot_sens(data_clean.grad, 'unit', 'mm', 'coilsize', 10); % the sensor locations
ft_plot_mesh(sourcemodel.pos, 'unit', 'mm'); % the source model is a cubic grid of points
ft_plot_ortho(mri_realigned.anatomy, 'transform', mri_realigned.transform, 'style', 'intersect');
alpha 0.5 % make the anatomical MRI slices a bit transparent

%% compute the LCMV beamformer 

cfg = [];
cfg.method = 'lcmv';
cfg.sourcemodel = leadfield;
cfg.headmodel = headmodel;
cfg.lcmv.keepfilter = 'yes';
cfg.lcmv.fixedori = 'yes'; % project on axis of max variance using SVD
cfg.lcmv.lambda = '5%';
cfg.lcmv.kappa = 69;
cfg.lcmv.projectmom = 'yes'; % project dipole time series in direction of maximal power 
cfg.lcmv.kurtosis = 'yes';
cfg.lcmv.keepmom = 'yes';
source = ft_sourceanalysis(cfg, cov_matrix);

save ('source', '-v7.3'); 

%% interpolate kurtosis into the mri 
cfg = [];
cfg.parameter = 'kurtosis';
source_interp = ft_sourceinterpolate(cfg, source, mri_realigned);

%% load brainnetome atlas
atlas_brainnetome = ft_read_atlas ('D:\toolbox_matlab\fieldtrip-master\template\atlas\brainnetome\BNA_MPM_thr25_1.25mm.nii');


%% plot kurtosis output in 'ortho'
cfg = [];
cfg.funparameter = 'kurtosis';
cfg.method = 'ortho'; % orthogonal slices with crosshairs at peak (default anyway if not specified)
cfg.atlas = atlas_brainnetome; 
ft_sourceplot(cfg, source_interp);

%% plot kurtosis output in 'slices'
cfg = [];
cfg.funparameter = 'kurtosis';
cfg.method = 'slice'; % plot slices
ft_sourceplot(cfg, source_interp);

%% find regions of max kurtosis

array = reshape(source.avg.kurtosis, source.dim);
array(isnan(array)) = 0;
ispeak = imregionalmax(array); % findpeaksn is an alternative that does not require the image toolbox
peakindex = find(ispeak(:));
[peakval, i] = sort(source.avg.kurtosis(peakindex), 'descend'); % sort on the basis of kurtosis value
peakindex = peakindex(i);

npeaks = 5;
disp(source.pos(peakindex(1:npeaks),:));% output positions
poi = (source.pos(peakindex(1:npeaks),:));

%% visualize the kurtosis in MRIcro 

cfg = [];
cfg.filename = mri_file;
cfg.parameter = 'anatomy';
cfg.format = 'nifti';
ft_volumewrite(cfg, source_interp);

cfg = [];
cfg.filename = strcat('sub002', '_kurtosis.nii');
cfg.parameter = 'kurtosis';
cfg.format = 'nifti';
cfg.datatype = 'float'; % integer datatypes will be scaled to the maximum, floating point datatypes not
ft_volumewrite(cfg, source_interp);

%% write vm timeseries

for i = 1: length (source.avg.mom); 
    if isempty (source.avg.mom{i,1}) == 0
        ve_series = source.avg.mom {i,1};
        ve_matrix = [source.time; ve_series];
        fname = [output_dir, 'sub002', num2str(i) , '.dat'];
        % patient_id already specified for the beamformer_ft_kk function
        % Specifies the subject for which the script is being run
        save (fname, 've_matrix', '-ascii')
    end 
end 

%% load virtual electrode time_series 
ve_files = dir ('*.dat');


%% run the hurst_mod script and save the output to a text file

tic
 for i = 1: length (ve_files)
     ve = load (ve_files(i).name);
     [~,~,H,~] = hurst_mod(ve(2,:),50); % use hurst_mod function to calculate H 
     H_idx = extractBetween(ve_files(i).name, "_", ".dat"); % extract the index of the time series 
     % create a file name including the index of the ve time series for
     % which the Hurst Exponent was derived
     fname = ['/Users/neelbazro/Desktop/he_db/output/' patient_id, '/H/', 'H_', H_idx{1,1} , '.txt']; 
     % save H of every time series as a separate .txt file with appended ve number
     save (fname, 'H', '-ascii') 
     close all
     clear ve % clean variable data to save computer memory
 end 
 toc