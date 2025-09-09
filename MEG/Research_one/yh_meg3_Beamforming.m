
function  [source,grad_c,headmodel,leadfield] =yh_meg3_Beamforming(brain_mesh,data_clean)
%% 3.1
% semi-realistic singleshell head model based on the implementation from Guido Nolte
cfg        = [];
cfg.method = 'singleshell';
headmodel = ft_prepare_headmodel(cfg, brain_mesh);   

grad  = data_clean.grad;
grad.coordsys = 'ctf';
grad_c = ft_convert_coordsys(grad, 'mni');  % this rotates it such that the X-axis points to the right
grad_c = ft_convert_units(grad_c, headmodel.unit);

%% 3.2 construction of source model 
cfg = [];
cfg.resolution = 3; % for clinical purpose should be 5mm or less
cfg.tight = 'yes';
cfg.unit = 'mm';
cfg.headmodel = headmodel;
cfg.grad = grad_c;
cfg.tight = 'yes';
cfg.inwardshift  = -1.5;
sourcemodel = ft_prepare_sourcemodel(cfg);

%% 3.3 Forward model  
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

source_forward      = [];
source_forward.vol  = headmodel; 
% source_forward.mri  = brain_mesh;
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


end