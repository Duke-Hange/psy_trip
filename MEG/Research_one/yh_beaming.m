clear
rawpath='D:\MEG数据\Omega';

sub='0001';
ses='01';
% sub: subect code, e.g., '0001'
% ses: session, e.g., '01'
% rawpath: folder with raw data
% dpath: folder to store processed data

cd([rawpath '/sub-' sub '/ses-' ses '/meg/'])

%% 1.1. Reading data

meg_file = findfile('01_meg.ds');
% cd(dataresting)                                  

% datafile    = findfile('.meg4');
% headerfile  = findfile('.res4');

cfg            = [];
cfg.dataset = meg_file;

cfg = ft_definetrial(cfg);
cfg = ft_artifact_jump(cfg);        % 跳变伪迹检测
cfg = ft_rejectartifact(cfg);       % 去除含伪迹的 trial

cfg.channel= {'MEG', 'ECG'};
cfg.detrend = 'yes';
cfg.continuous = 'yes';
% cfg.channel= {'MEG'};
data  = ft_preprocessing(cfg);

cfg              = [];
cfg.channel      = {'MEG'};
data        = ft_selectdata(cfg, data);

%% 1.2. Preprocessing 

cfg            = [];
cfg.refchannel = 'MEGREF';
data           = ft_denoise_pca(cfg,data);

% data.trial{1}  = ft_preproc_dftfilter(data.trial{1},data.fsample,[60 120 180],'dftreplace','neighbour');    % Mewett et al., 2004

cfg            = [];
cfg.resamplefs = 300;
cfg.demean     = 'yes';
data           = ft_resampledata(cfg,data);

%% 1.3. Artifact correction with ICA 
cfg              = [];
cfg.numcomponent = 20;                                  
cfg.method       = 'fastica';
comp             = ft_componentanalysis(cfg ,data);         

% 手动
cfg = [];
cfg.preproc.demean = 'yes';
cfg.preproc.lpfilter = 'yes';
cfg.preproc.lpfreq = 50;
cfg.preproc.hpfilter = 'yes';
cfg.preproc.hpfreq = 1;

cfg.viewmode = 'component';
cfg.layout = 'CTF275.lay';
ft_databrowser(cfg, comp);


% the original data can now be reconstructed, excluding specified components
% This asks the user to specify the components to be removed
%     disp('Enter components in the form [1 2 3]')
comp2remove = input('Which components would you like to remove?\n');
cfg           = [];
cfg.component = [comp2remove]; %these are the components to be removed
data_clean    = ft_rejectcomponent(cfg, comp,data);

%% 1.3 滤波
% 先高通+低通
cfg            = [];
cfg.hpfilter   = 'yes';
cfg.hpfreq     = 1; % can be changed to 10
cfg.hpfiltord  = 3;
cfg.lpfilter = 'yes';
cfg.lpfreq = 149;
cfg.lpfiltord  = 3;             % 更陡峭的滚降
data_f1 = ft_preprocessing(cfg, data_clean);

% 再单独处理带阻
cfg            = [];
cfg.bsfilter = 'yes';
cfg.bsfreq = [59 61; 119 121];
cfg.bsfiltdir = 'twopass';
cfg.bsinstabilityfix = 'split';
data_f2 = ft_preprocessing(cfg, data_f1);

%% 将分段数据合并为连续数据
cfg         = [];
cfg.trials='all';
cfg.continuous = 'yes'; 
data_clean= ft_redefinetrial(cfg,data_f2);

 grad  = data_clean.grad;

grad.coordsys = 'ctf';
grad_c = ft_convert_coordsys(grad, 'mni');  % this rotates it such that the X-axis points to the right



% % 获取MRI到头部坐标系的变换矩阵
% transform = mri_csr2n.transform;
% 
% % 将传感器位置转换到MRI空间
% sensor_pos_mri = ft_warp_apply(transform, grad.chanpos);
% 
% normtrans      = mri_csr2n.transform;

% grad2 = ft_warp_apply(normtrans, grad.)

%% 2.1. Coregistration of MEG-MRI spaces
% mri.transform is the transformation matrix to go from mri space to sensor space

Mri_dir = 'D:\MEG数据\Omega\sub-0001\ses-03\anat';
Mri_file=dir(fullfile(Mri_dir,'*.nii'));
Mri_file=fullfile(Mri_file.folder,Mri_file.name);

mri = ft_read_mri(Mri_file);

mri_c=ft_determine_coordsys(mri, 'interactive', 'yes');
% do you want to change the anatomical labels for the axes [Y, n]? Y (r,a,s,i)

% 重新切片会导致体素轴与头部坐标轴对齐
cfg = [];
cfg.method = 'flip';
cfg.resolution = 1;
mri_c.coordsys = 'mni';
mri_c.unit = 'mm';
mri_cs = ft_volumereslice(cfg, mri_c);

cd([rawpath '/sub-' sub '/ses-' ses '/meg/'])

hsfile    = findfile('.pos');
headshape = ft_read_headshape(hsfile);   

% convert dimensions of headshape for further analysis
 headshape = ft_convert_units(headshape, 'mm');


%% 3.1. MRI normalization

% first align to headshape 
[mri_csr,scp] = omega_coreg([], mri_cs, headshape);    
% mark fiducials: lpa (l), rpa (r) and nasion (n), then quit (q) 

% second call
% mri.transformorig = mri.transform; 
cfg = [];
cfg.method = 'headshape';
cfg.headshape.headshape = headshape;
cfg.headshape.icp = 'yes';
cfg.headshape.interactive = 'yes';  
%  cfg.coordsys = 'ctf'; 
%'ctf', '4d', 'bti','eeglab', 'neuromag', 'itab', 'yokogawa', 'asa', 'acpc'
% cfg.spmversion = 'spm12';
mri_csr2 = ft_volumerealign(cfg, mri_csr);

cfg            = [];
cfg.nonlinear  = 'no';
cfg.spmversion = 'spm12';
mri_csr2n       = ft_volumenormalise(cfg, mri_csr2);  

% cfg=[];
% ft_sourceplot(cfg, mri_csr2n);  
normtrans      = mri_csr2n.transform;

cfg = [];
cfg.output = 'brain';
cfg.spmversion = 'spm12';
segment         = ft_volumesegment(cfg,mri_csr2n);        % extract brain surface

segment.anatomy = mri_csr2n.anatomy;

cfg = [];
cfg.shift  = 0.3;
cfg.method = 'hexahedral';
brain_mesh = ft_prepare_mesh(cfg, segment);



%% 3.2. Head model

% % % Check that the segmentation is coregistered with mri
% figure
% cfg = [];
% cfg.interactive = 'yes';
% ft_sourceplot(cfg,mri_csr2n);      % only mri
% cfg.funparameter = 'gray';
% hold on
% ft_sourceplot(cfg,segment);  % segmented gray matter on top

% semi-realistic singleshell head model based on the implementation from Guido Nolte
cfg        = [];
cfg.method = 'singleshell';
% cfg.grad = data_clean.grad;
headmodel = ft_prepare_headmodel(cfg, brain_mesh);    % construct semi-realistic singleshell head model

% headmodel = ft_convert_units(headmodel, 'mm');

grad_c = ft_convert_units(grad_c, headmodel.unit);
%% 3.3 construction of source model 
cfg = [];
cfg.resolution = 3; % for clinical purpose should be 5mm or less
cfg.tight = 'yes';
cfg.unit = 'mm';
cfg.headmodel = headmodel;
cfg.grad = grad_c;
cfg.tight = 'yes';
cfg.inwardshift  = -1.5;
sourcemodel = ft_prepare_sourcemodel(cfg);

%% 3.4. Forward model  



% Compute leadfields for each grid's voxel
cfg             = [];
cfg.channel     = 'MEG';
cfg.grid = sourcemodel;
cfg.grad        = grad_c;
cfg.headmodel   = headmodel;
cfg.normalize = 'yes';
cfg.reducerank = 2; % default for MEG is 2, for EEG is 3
cfg.resolution = 1;   % use a 3-D grid with a 1 cm resolution
% cfg.unit      = 'mm';
cfg.tight    = 'yes';
leadfield    = ft_prepare_leadfield(cfg);

% Check that grad, vol and grid are correct (only for the first subject)
if strcmp(sub,'0001')
    figure
     % the sensor locations
%     plot3 (grad.chanpos(:,1), grad.chanpos(:,2), grad.chanpos(:,3), '.','MarkerEdgeColor',[0.8 0 0],'MarkerSize',25), 
    hold on
    ft_plot_sens(grad_c, 'unit', 'mm', 'coilsize', 10);
    hold on
    plot3 (headmodel.bnd.pos(:,1), headmodel.bnd.pos(:,2), headmodel.bnd.pos(:,3), '.','MarkerEdgeColor',[0 0 0.8]);
    hold on
    plot3 (leadfield.pos(leadfield.inside,1), leadfield.pos(leadfield.inside,2), leadfield.pos(leadfield.inside,3), '+k')
end

% Save grad, vol, grid and mri in source_forward structure to be used later
source_forward      = [];
source_forward.vol  = headmodel; 
source_forward.mri  = mri_csr2n;
source_forward.grad = grad_c;
source_forward.grid = leadfield;

%% 3.4. Computation of beamforming weights
% output: source_inverse_10mm (contains beamforming weights in source.avg.filter) 
cfg            = [];
cfg.covariance = 'yes';
cov_matrix        = ft_timelockanalysis(cfg, data_clean);  

% Compute spatial filters (in source.avg.filter)
cfg                   = [];
cfg.method            = 'lcmv';
cfg.grad              = source_forward.grad;
cfg.headmodel         = source_forward.vol;
cfg.sourcemodel       = source_forward.grid;
cfg.lcmv.keepfilter   = 'yes';          % important: save filters to use them later
cfg.lcmv.fixedori     = 'yes';
cfg.lcmv.lambda       = '5%';          % the higher the smoother
cfg.lcmv.kappa = 69;
cfg.lcmv.projectnoise = 'yes';
cfg.lcmv.kurtosis = 'yes';
cfg.lcmv.keepmom = 'yes';
% cfg.lcmv.normalize    = 'yes';
% cfg.lcmv.reducerank   = 2;
source                = ft_sourceanalysis(cfg, cov_matrix);

source = ft_convert_units(source,'mm');

%% 加载 AAL 模板（需与 MRI 空间对齐）
% % atlas_brainnetome = ft_read_atlas ('D:\toolbox_matlab\fieldtrip-master\template\atlas\brainnetome\BNA_MPM_thr25_1.25mm.nii');
 
atlas_brainnetome = ft_read_atlas ('D:\toolbox_matlab\fieldtrip-master\template\atlas\aal\ROI_MNI_V4.nii');

% atlas_brainnetome = ft_convert_units(atlas_brainnetome,'mm');

% cfg = [];
% cfg.atlas      = atlas_brainnetome;
% cfg.roi        = atlas_brainnetome.tissuelabel;  % here you can also specify a single label, i.e. single ROI
% mask           = ft_volumelookup(cfg, source);
% mri_csr2n
cfg = [];
% cfg.voxelcoord   = 'no';
cfg.interpmethod = 'nearest';
cfg.parameter = 'tissue';
% cfg.parameter    = 'avg.pow';
sourcemodel_aal = ft_sourceinterpolate(cfg, atlas_brainnetome, source);

cfg = [];
cfg.funparameter = 'tissue';
cfg.funcolormap = 'jet';
ft_sourceplot(cfg, sourcemodel_aal);  % 显示模板

% 初始化data_roi结构
data_roi = [];
data_roi.label = atlas_brainnetome.tissuelabel; % 直接使用模板标签
data_roi.fsample = data_clean.fsample;
data_roi.time = data_clean.time;
data_roi.trial = cell(1, length(data_clean.trial));

% 预处理：提取所有体点对应的滤波器
all_filters = cat(1, source.avg.filter{source.inside});

% 对每个ROI进行处理
num_rois = length(sourcemodel_aal.tissuelabel);
roi_signals = zeros(num_rois, size(data_clean.trial{1},2)); % 预分配

for roi_id = 1:num_rois
    mask = (sourcemodel_aal.tissue == roi_id);
    if ~any(mask)
        roi_signals(roi_id, :) = 0;
        continue;
    end
    % 提取该ROI内的滤波器
    roi_filters = all_filters(mask(source.inside), :);
    if isempty(roi_filters)
        roi_signals(roi_id, :) = 0;
        continue;
    end
    % 计算PCA主成分  %% 需要优化
    projected = roi_filters * data_clean.trial{1};
    [coeff, score, latent]  = pca(projected');
    explained(roi_id,1) = max(latent / sum(latent) * 100); 
    roi_signals(roi_id, :) = score(:,1)';
end

data_roi.trial{1} = roi_signals;

% data reshape
data_AAL = cell2mat(data_roi.trial);



%%
