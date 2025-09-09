
function  [mri_csr2n,brain_mesh] =yh_meg2_Coregistration(sub_path)
%% 2.1 
files = dir(fullfile(sub_path, '**')); % '**' 表示包括所有子目录
mri_dir = files(contains({files.name}, '.nii.gz'));
mri_file=fullfile(mri_dir(end).folder,mri_dir(end).name);

hs_dir = files(contains({files.name}, 'headshape.pos'));
hs_file = fullfile(hs_dir(end).folder,hs_dir(end).name);
headshape = ft_read_headshape(hs_file);   
headshape = ft_convert_units(headshape, 'mm');

%% 2.2
mri = ft_read_mri(mri_file);
mri_c=ft_determine_coordsys(mri, 'interactive', 'yes');
% do you want to change the anatomical labels for the axes [Y, n]? Y (r,a,s,i)

cfg = [];
cfg.method = 'flip';
cfg.resolution = 1;
mri_c.coordsys = 'mni';
mri_c.unit = 'mm';
mri_cs = ft_volumereslice(cfg, mri_c);

%% 2.3
% first align to headshape 
[mri_csr,scp] = omega_coreg([], mri_cs, headshape);    

% second call
% mri.transformorig = mri.transform; 
cfg = [];
cfg.method = 'headshape';
cfg.headshape.headshape = headshape;
cfg.headshape.icp = 'yes';
cfg.headshape.interactive = 'yes';  
mri_csr2 = ft_volumerealign(cfg, mri_csr);

%% 2.4
cfg            = [];
cfg.nonlinear  = 'no';
cfg.spmversion = 'spm12';
mri_csr2n       = ft_volumenormalise(cfg, mri_csr2);  
% normtrans      = mri_csr2n.transform;

%% 2.5 
cfg = [];
cfg.output = 'brain';
cfg.spmversion = 'spm12';
segment         = ft_volumesegment(cfg,mri_csr2n);        % extract brain surface

segment.anatomy = mri_csr2n.anatomy;

cfg = [];
cfg.shift  = 0.3;
cfg.method = 'hexahedral';
brain_mesh = ft_prepare_mesh(cfg, segment);
end



% %% 设置目标ROI
% target_roi = 'Hippocampus_L'; % 例如：左侧海马
% roi_index = find(strcmp(sourcemodel_aal.tissuelabel, target_roi));
% 
% %% 1. ROI定位可视化
% figure
% cfg = [];
% cfg.funparameter = 'tissue';       % 使用模板的tissue字段
% cfg.funcolormap = 'jet';           % 颜色映射
% cfg.maskparameter = 'tissue';      % 高亮显示模板区域
% cfg.opacitymap = 'rampup';         % 透明度映射
% cfg.title = ['ROI定位 - ' target_roi]; 
% ft_sourceplot(cfg, sourcemodel_aal);
% hold on;
% % ft_plot_ortho(mri_sr2n.anatomy, 'transform', mri_sr2n.transform, 'style', 'intersect');
% title('ROI定位');
% 
% %% 2. 时域信号可视化
% figure
% time = data_roi.time{1}; % 时间轴
% signal = data_roi.trial{1}(roi_index, :); % 提取目标ROI的时域信号
% 
% % 绘制时域信号
% plot(time, signal, 'LineWidth', 1.5);
% xlabel('时间 (s)');
% ylabel('信号强度 (a.u.)');
% title(['时域信号 - ' target_roi]);
% grid on;
% 
% %% 3. 频域分析可视化
% figure
% cfg = [];
% cfg.method = 'mtmfft';       % 多锥形傅里叶变换
% cfg.taper = 'hanning';       % 窗函数类型
% cfg.foilim = [1 145];         % 频率范围1-45Hz
% cfg.keeptrials = 'no';       % 不保留单试次数据
% cfg.channel = target_roi;    % 指定ROI
% 
% % 执行频域分析
% freq_data = ft_freqanalysis(cfg, data_roi);
% 
% % 绘制频谱图
% ft_singleplotER([], freq_data);
% xlabel('频率 (Hz)');
% ylabel('功率 (dB)');
% title(['频域特征 - ' target_roi]);
