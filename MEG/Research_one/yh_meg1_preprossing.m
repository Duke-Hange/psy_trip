
function  [data_clean] =yh_meg1_preprossing(sub_path)

files = dir(fullfile(sub_path, '**')); % '**' 表示包括所有子目录
meg_dir = files(contains({files.name}, 'meg.ds'));
meg_file=fullfile(meg_dir(end).folder,meg_dir(end).name);
%% 1.1. Reading data

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
cfg.hpfreq     = 0.5; % can be changed to 10
cfg.hpfiltord  = 2;
cfg.lpfilter = 'yes';
cfg.lpfreq = 149;
cfg.lpfiltord  = 2;             % 更陡峭的滚降
data_f1 = ft_preprocessing(cfg, data_clean);

% 再单独处理带阻
cfg            = [];
cfg.bsfilter = 'yes';
cfg.bsfreq = [59.5 60.5; 119.5 120.5];
cfg.bsfiltdir = 'twopass';
% cfg.bsinstabilityfix = 'split';
cfg.bsfiltord  = 2;
data_f2 = ft_preprocessing(cfg, data_f1);

%% 1.4将分段数据合并为连续数据
cfg         = [];
cfg.trials='all';
cfg.continuous = 'yes'; 
data_clean= ft_redefinetrial(cfg,data_f2);
end