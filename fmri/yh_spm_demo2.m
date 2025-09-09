%此程序模仿北师DPARSF和REST的文件结构进行数据安排（可节省空间，方便手动删除中间数据）、参考从SPM网站和其他相关网站上关于用SPM批处理脑成像数据的资料，以及结合本人感悟体会精心编制而成。字字浸透汗水，点点凝结心血。
%数据无价，程序是宝，牢记于心，获益非小。
% 文件夹名字的最后几个大写字母含义：F(功能像), A(slice timng), R(realignment), W(normalization), S(smoothing)
%为了让生成的各步骤的结果分别输出到不同的文件夹，我采取了复制粘贴的笨方法--空里流霜，2013.5
%%%%%%%%%%%%%%%首先创建文件夹来放置中间文件%%%%%%%%%%%%%%%%%
clear;
cwd='F:\教学数据\批处理代码\demo'; %设置进行文件操作和数据处理的目录
cd (cwd)
mkdir('FunImgF');mkdir('FunImgAF');mkdir('FunImgRAF');mkdir('FunImgWRAF');mkdir('FunImgSWRAF'); %生成用到的文件夹
                        
foldernames={'FunImgF' 'FunImgAF' 'FunImgRAF' 'FunImgWRAF' 'FunImgSWRAF'};
     for folder=1:5
           folderdir=[ cwd sprintf(foldernames{folder})]
   
              for wnumfolder=1:20
                      if wnumfolder==3||wnumfolder==7||wnumfolder==17;   %如果你的哪些被试有问题，可以通过这种方式跳过
                         continue;                  
                      end  
                    cd(folderdir)
                    if wnumfolder<10;
                        sw=strcat('mkdir',12,'subject0',num2str(wnumfolder));  %生成每个被试的文件夹  
                    else
                        sw=strcat('mkdir',12,'subject',num2str(wnumfolder));    %生成每个被试的文件夹   
                    end;
                   system(sw);
                   cd ([folderdir sprintf('/subject%02d',wnumfolder)])
                   mkdir('RUN1');mkdir('RUN2');mkdir('RUN3');mkdir('RUN4');mkdir('RUN5'); %生成每个run的文件夹
              end
     end
cd (cwd)
mkdir('T1Img');
folderdir2=[cwd sprintf('T1Img')]
     for wnumfolder=1:20
                   if sub==3||sub==7||sub==17;   %跳过删除的被试
                      continue;
                   end  
                  cd(folderdir2)
                   if wnumfolder<10;
                      sw=strcat('mkdir',12,'subject0',num2str(wnumfolder));  
                   else
                      sw=strcat('mkdir',12,'subject',num2str(wnumfolder));   
                   end;
                   system(sw);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
spm_get_defaults             % 设置SPM默认值
global defaults
spm_jobman('initcfg');

nsub=20;
nses=4;                   % session或run的个数   
runnames={'RUN1' 'RUN2' 'RUN3' 'RUN4'};      % session或是run的名字
cwd='I:/kongliliushuang/2012Exp_SPM_MRIresults_Preprocessing/'; %设置根目录

for sub=1:nsub   
      if sub==3||sub==7||sub==17;   %跳过删除的被试
         continue;
      end
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%以下转换DICOM为NIFTI%%%%%%%%%%%%%%%%%%%%%%  

%%%%%%%%%%%%%%%%%%%%以下转换结构像%%%%%%%%%%%%%%%%%%%%%%%
        dirStruc=[ cwd sprintf('T1Raw/subject%02d/',sub)]; %DICOM格式的原始文件所在的地方               
        cd([ cwd sprintf('T1Img/subject%02d/',sub)]);  %转换为Analyze格式的文件之后输出的地方
        ds=spm_get('Files',dirStruc,'201*.IMA'); %列出所有DICOM文件的名字以备转换，spm8中没有spm_get函数，可安装marsbar，或是下载本帖的附件spm_get.zip,解压后放在spm的文件夹中任意位置.也可使用spm_select函数，具体更改方式请参考http://www.alivelearn.net/spm_get-spm_select-and-char/
        hdrs=spm_dicom_headers(ds);     %读取DICOM文件的头文件   
        spm_dicom_convert(hdrs,'all','flat','img');     %开始转换，转换为img格式
        display(sprintf('Anatomical run has been finished.'));     %显示某部分转换完成的信息
%%%%%%%%%%%%%%%%%%%%以下转换功能像%%%%%%%%%%%%%%%%%%%%%%
    for ses=1:nses
        dirFunc{ses}=[ cwd sprintf('FunRaw/subject%02d/%s/',sub,runnames{ses})]; %DICOM格式的原始文件所在的地方
        cd([ cwd sprintf('FunImgF/subject%02d/%s/',sub,runnames{ses})]); %转换为Analyze格式的文件之后输出的地方
        df=spm_get('Files',dirFunc{ses},'201*.IMA')  %列出所有DICOM文件的名字以备转换
        hdr=spm_dicom_headers(df); %读取DICOM文件的头文件
        spm_dicom_convert(hdr,'all','flat','img');  %开始转换
        display(sprintf('Functional run %s has been finished.',runnames{ses})); %显示某部分转换完成的信息，共有nses个run
    end
   
  %%%%%%%%%%%%%%%%%%%以下进行slice timing%%%%%%%%%%%%%%%%%%%%%%%%%%
  for ses=1:nses
        dirst=[ cwd sprintf('FunImgF/subject%02d/%s/',sub,runnames{ses})]; %要时间矫正的文件所在的地方(即上一步转化来的文件)（这一部分是功能像）
        st=spm_get('Files',dirst,'fR*.img') %列出所有fR打头的文件名
        jobs{1}.temporal{1}.st.scans{ses}=cellstr(st);   %将所有RUN结合在一起，而不是分别slice timing，虽然如此，不同run其实是分别选进去的，注意其中{ses}的用法
   end  
  
    jobs{1}.temporal{1}.st.nslices = 33;
    jobs{1}.temporal{1}.st.tr = 2;
    jobs{1}.temporal{1}.st.ta = 1.93939393939394;
    jobs{1}.temporal{1}.st.so = [1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32];  %33层，从下到上，隔层扫描
    jobs{1}.temporal{1}.st.refslice = 33;     %时间点或解剖上的中间层，对于我的西门子机器采集的数据，时间上的中间层是33，空间上的中间层是17，此处和1st level中的microtime resolution(有时被称为t)
    jobs{1}.temporal{1}.st.prefix = 'a';      %以及microtime onset（有时被称为t0）要对应，后面t=33（层数），t0=17（slice timing参考层选择33时，第33层是第17个扫描的）。如果参考层是17，则t0=9
    spm_jobman('run',jobs);    %开始跑
    clear jobs;               %清除之前设置的job
   
                                      for run=1:nses
                                          diroffile=[cwd,sprintf('FunImgF/subject%02d/%s/',sub,runnames{run})]   %最后一定要加斜杠
                                          files=fullfile(diroffile,'afR*')
                                          diroffile2=[cwd,sprintf('FunImgAF/subject%02d/%s/',sub,runnames{run})]
                                          copyfile(files,diroffile2)    %复制文件到做时间矫正的文件夹
                                          cd(diroffile)
                                          delete 'af*'
                                      end
   
%%%%%%%%%%%%%%%%%%%%%%以下进行realignment%%%%%%%%%%%%%%%%%%%%%%%%
    cd([cwd,sprintf('FunImgSWRAF/subject%02d/',sub)]); %为了让输出的头动矫正曲线到最后一步的文件夹中
    for ses=1:nses
        dir=[ cwd sprintf('FunImgAF/subject%02d/%s/',sub,runnames{ses})]; %要对准的文件所在的地方(即上一步转化来的文件)（这一部分是功能像）
        p=spm_get('Files',dir,'afR*.img') %列出所有fR打头的文件名
        jobs{1}.spatial{1}.realign{1}.estwrite.data{ses} = cellstr(p);      %将所有RUN结合在一起，而不是分别realign，注意其中{ses}的用法
    end
   
        jobs{1}.spatial{1}.realign{1}.estwrite.eoptions.rtm = 0;         %对准第一个volume/image
    spm_jobman('run',jobs);    %开始跑这部分的job，生成的头动参数图像默认输入在最后一个run中，而生成的平均图像mean文件则放在第一个run中（头动参数图为ps格式，可用GhostView等打开，也可转换为PDF格式）
    clear jobs;               %清除之前设置的job
                                      for run=1:nses
                                        diroffile=[cwd,sprintf('FunImgAF/subject%02d/%s/',sub,runnames{run})]   %最后一定要加斜杠
                                        files=fullfile(diroffile,'r*')
                                        files2=fullfile(diroffile,'mean*')
                                        diroffile2=[cwd,sprintf('FunImgRAF/subject%02d/%s/',sub,runnames{run})]
                                        copyfile(files,diroffile2)     %复制文件到做头动矫正的文件夹
                                                  if run==1;
                                                  copyfile(files2,diroffile2)     %复制文件到做头动矫正的文件夹
                                                  end
                                   
                                        cd(diroffile)
                                        delete 'r*'
                                        delete 'mean*'
                                      end
   
%%%%%%%%%%%%%%%%%%%%%%%%以下进行coregistration%%%%%%%%%%%%%%%%%%%%
      s=spm_get('Files',[ cwd sprintf('T1Img/subject%02d/',sub)],'sR*.img'); %DICOM格式转换生成的结构像
      m=spm_get('Files',[ cwd sprintf('FunImgRAF/subject%02d/RUN1',sub)],'mean*.img'); %之前生成的mean文件
        jobs{1}.spatial{1}.coreg{1}.estimate.ref = cellstr(m);       %功能像的mean文件作为对准的参照
        jobs{1}.spatial{1}.coreg{1}.estimate.source = cellstr(s);     %将结构像去和功能像去对（即realignment生成的平均文件不动，不停摆放结构像使其与平均文件契合）
        spm_jobman('run',jobs);
        clear jobs;   
   
%%%%%%%%%%%%%%%%%%%%%%%%以下进行segmentation%%%%%%%%%%%%%%%%%
     jobs{1}.spatial{1}.preproc.data=cellstr(s);  %对上一步摆放好的结构像进行白质灰质的切割
     spm_jobman('run',jobs);
     clear jobs;
     
%%%%%%%%%%%%%%%%%%%%%以下进行normalize%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%以下对功能像进行标准化%%%%%%%%%%%%%%%%%%%%%%
       sp=spm_get('Files',[ cwd sprintf('T1Img/subject%02d/',sub)],'*seg_sn.mat') %结构像的参数
       sm=spm_get('Files',[ cwd sprintf('T1Img/subject%02d/',sub)],'m*.img') %结构像的完全路径
      
       jobs{1}.spatial{1}.normalise{1}.write.subj.matname  = cellstr(sp);  %写入参数
       ff = spm_get('Files',[ cwd sprintf('FunImgRAF/subject%02d/RUN1',sub)],'mean*.img') %之前生成的mean文件
      
        conCat_fs=[];  %定义一个空矩阵用来装所有的功能像
           for ses=1:nses
              dir=[ cwd sprintf('FunImgRAF/subject%02d/%s/',sub,runnames{ses})]; %之前生成的经过头动校正的文件所在的地方
              f=spm_get('Files',dir,'rafR*.img'); %之前生成的经过头动校正的文件，即功能像
              fs=cellstr(f);
              conCat_fs=[conCat_fs;fs]; %将所有功能像粘成一列
              f = []; fs = [];  %清除此两个变量的值，为下一循环准备，其实也可不用清除，下一循环会更新
           end
       conCat_fs=[conCat_fs;cellstr(ff)]; %顺便把平均图像也标准化
       jobs{1}.spatial{1}.normalise{1}.write.subj.resample = conCat_fs;   %开始标准化
       jobs{1}.spatial{1}.normalise{1}.write.roptions.bb = [-90 -126 -72
                                                            90 90 108];    % 有人认为默认的太小[-78 -112 -50,78 76 85]，小脑没有包括全，建议改为[-90 -126 -72,90 90 108],或[-78 -112 -70,78 76 85]
       jobs{1}.spatial{1}.normalise{1}.write.roptions.vox  = [3 3 3];  %标准化所用的体素大小，改为最接近图像采集分辨率的参数（可用MRIcro等查看原始图像）

%%%%%%%%%%%%%%%%%%%以下对结构像进行标准化%%%%%%%%%%%%%%%%%%%%%%
         jobs{1}.spatial{1}.normalise{2}.write.subj.matname  = cellstr(sp)
         jobs{1}.spatial{1}.normalise{2}.write.subj.resample = cellstr(sm)
         jobs{1}.spatial{1}.normalise{2}.write.roptions.vox  = [1 1 1];     %改为最接近图像采集分辨率的参数（可用MRIcro查看原始图像）
         spm_jobman('run',jobs);
         clear jobs;
         
                                      for run=1:nses
                                          diroffile=[cwd,sprintf('FunImgRAF/subject%02d/%s/',sub,runnames{run})]   %最后一定要加斜杠
                                          files=fullfile(diroffile,'wraf*')
                                          diroffile2=[cwd,sprintf('FunImgWRAF/subject%02d/%s/',sub,runnames{run})]
                                          copyfile(files,diroffile2)    %复制文件到做标准化的文件夹
                                          cd(diroffile)
                                          delete 'wraf*'
                                      end
%%%%%%%%%%%%%%%%%%%%以下进行smoothing%%%%%%%%%%%%%%%%%%%%%%%%%
     
     for ses=1:nses
        dirn=[ cwd sprintf('FunImgWRAF/subject%02d/%s/',sub,runnames{ses})]; %之前生成的经过头动校正(以及标准化)的文件所在的地方
        fn=spm_get('Files',dirn,'wrafR*.img') %之前生成的经过头动校正（以及标准化）的文件
        jobs{1}.spatial{ses}.smooth.data = cellstr(fn);    %进行空间平滑（注意ses的位置）
        jobs{1}.spatial{ses}.smooth.fwhm =[8 8 8];              %默认是8，可以自己更改                                                                       end
   
   spm_jobman('run',jobs);
   clear jobs;  
   
                                      for run=1:nses
                                          diroffile=[cwd,sprintf('FunImgWRAF/subject%02d/%s/',sub,runnames{run})]   %最后一定要加斜杠
                                          files=fullfile(diroffile,'swraf*')
                                          diroffile2=[cwd,sprintf('FunImgSWRAF/subject%02d/%s/',sub,runnames{run})]
                                          copyfile(files,diroffile2)     %复制文件到做平滑的文件夹
                                          cd(diroffile)
                                          delete 'swraf*'
                                      end
%%%%%%%%%%%%%将头动矫正生成的矫正参数文件复制到预处理最后一阶段%%%%%%%%%%%%%%%%
                                      for run=1:nses
                                          diroffile=[cwd,sprintf('FunImgRAF/subject%02d/%s/',sub,runnames{run})]   %最后一定要加斜杠
                                          files=fullfile(diroffile,'rp*.txt')
                                          diroffile2=[cwd,sprintf('FunImgSWRAF/subject%02d/%s/',sub,runnames{run})]
                                          copyfile(files,diroffile2)     %复制文件到做最后一步文件夹
                                                                     
                                       end
                                    
end


############以上是预处理的程序###################






###############统计分析的示例程序###############
由于我的实验的设计比较复杂，有4个run，为了方便大家理解，这里先把在后面SPM生成的某个被试的设计矩阵展现如下

%%%%%%%%%%%%%%%在结果文件夹下先生成统计结果输出到的文件夹%%%%%%%%%%%%%%%%%
clear;
cwd='I:/kongliliushuang/2012Exp_SPM_MRIresults_Analysis/StruNorm_ST_tTest_other-self/'; %设置根目录
cd(cwd)
                                 
                                mkdir('groupResults')        %生成来放组分析结果的文件夹
                                for wnumfolder=1:20
                                                  if wnumfolder==3||wnumfolder==7||wnumfolder==17;   %跳过删除的被试
                                                     continue;
                                                  end  
                                                  cd(cwd)
                                                  if wnumfolder<10;
                                                    sw=strcat('mkdir',12,'subject0',num2str(wnumfolder));  
                                                    else
                                                    sw=strcat('mkdir',12,'subject',num2str(wnumfolder));   
                                                    end;
                                                  system(sw);
                                                   cd ([cwd sprintf('/subject%02d',wnumfolder)])
                                                   mkdir('subResults');
                                end
%%%%%%%%%%%%%%%在结果文件夹下先生成统计结果输出到的文件夹%%%%%%%%%%%%%%%%%
%
clear
spm_get_defaults             % 设置SPM默认值
nsub=20;
nses=4;                   % session或run的个数   
runnames={'RUN1' 'RUN2' 'RUN3' 'RUN4'};      % session或是run的名字
cwd='I:/kongliliushuang/2012Exp_SPM_MRIresults_Analysis/StruNorm_ST_tTest_other-self/'; %设置根目录
datadir='I:/kongliliushuang/2012Exp_SPM_MRIresults_Preprocessing/FunImgSWRAF/';  %经过预处理的文件所在之处
spm_jobman('initcfg');
for sub=1:nsub
     if sub==3||sub==7||sub==17;   %跳过有问题的被试
        continue;
     end  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%四个run数据的处理%model specification和estimation%%%%%%%%%%%%
   
    jobs{1}.stats{1}.fmri_spec.dir=cellstr([cwd sprintf('subject%02d/subResults',sub)]);    %进行模型设置输出结果的文件夹（已经在上面事先建好）
    jobs{1}.stats{1}.fmri_spec.timing.units='secs';    %模型设定的单位是秒还是“点”。秒的话用‘secs’是TR的话用‘scans'
    jobs{1}.stats{1}.fmri_spec.timing.RT=2;   %这儿虽然是TR时长，但一定要写成RT，即repetition time。
    jobs{1}.stats{1}.fmri_spec.timing.fmri_t = 33;
    jobs{1}.stats{1}.fmri_spec.timing.fmri_t0 = 17;    %此处是33层中第17个扫描的，而不是第17层
   
    for ses=1:4
   
     muldirFiles=[ datadir sprintf('subject%02d/%s',sub,runnames{ses})];     %之前经过所有预处理之后生成的图像文件所在的文件夹           
     mulfiles=spm_get('Files',muldirFiles,'swraf*.img') ;        %标准化过的就用swrf,未标准化的就用srf
     mulmotionfiles=spm_get('Files',muldirFiles,'rp*.txt') ;   %上面头动矫正生成的文本文件，每一个run都有一个
     
     
     
     mulcondition_file_name=['sub',num2str(sub),'_other-self',num2str(ses),'.mat']; %用matlab处理行为实验结果而生成的.mat文件
       mulcondpath='I:/kongliliushuang/2012Exp_SPM_MRIresults_Analysis/BehavioralData/';
     mulconditions=load(fullfile(mulcondpath,mulcondition_file_name));            %将之前行为实验的结果生成的.mat文件载入进来，每个被试的每个run都有一个（如何制作行为结果的.mat文件的帖子在此http://home.52brain.com/forum.ph ... =1&extra=#pid163180）
   
   
          jobs{1}.stats{1}.fmri_spec.sess(ses).scans=cellstr(mulfiles);            %如处理多个run则须加上ses，但要写在圆括弧之内（ses）
   
        for j=1:5                   % 有几个条件就写成1到几
          jobs{1}.stats{1}.fmri_spec.sess(ses).cond(j).name=mulconditions.names{j}                     % .mat文件中的names,onsets和durations
          jobs{1}.stats{1}.fmri_spec.sess(ses).cond(j).onset=mulconditions.onsets{j}
          jobs{1}.stats{1}.fmri_spec.sess(ses).cond(j).duration=mulconditions.durations{j}
        end
   
          jobs{1}.stats{1}.fmri_spec.sess(ses).multi_reg=cellstr(mulmotionfiles); %加上头动参数在模型中
   
    end
     resultpath=[cwd sprintf('subject%02d/',sub)];
     jobs{1}.stats{2}.fmri_est.spmmat=cellstr(fullfile(resultpath,'subResults','SPM.mat')); %保存模型设定和估计结果在SPM.mat中
    save(fullfile(resultpath,'subResults','modelspecification.mat'),'jobs'); %保存这一步的job
   
    spm_jobman('run',jobs);
   
    clear jobs;     
   
%%%%%%%%以下设置四个run 的contrasts并输出激活脑图%%%%%%%%%%%%%%%%%%%%%
    resultpath=[cwd sprintf('subject%02d/',sub)];
    jobs{1}.stats{1}.con.spmmat=cellstr(fullfile(resultpath,'subResults','SPM.mat'));  %打开模型设定生成的SPM.mat以便写入对照信息

     jobs{1}.stats{1}.con.consess{1}.tcon=struct('name','self-other','convec',[0 0.25 -0.25 0 0 0 0 0 0 0 0 0 0.25 -0.25 0 0 0 0 0 0 0 0 0 0.25 -0.25 0 0 0 0 0 0 0 0 0 0.25 -0.25 0 0 0 0 0 0 0 0 ],'sessrep','none');    %设置对比
     jobs{1}.stats{1}.con.consess{2}.tcon=struct('name','other-self','convec',[0 -0.25 0.25 0 0 0 0 0 0 0 0 0 -0.25 0.25 0 0 0 0 0 0 0 0 0 -0.25 0.25 0 0 0 0 0 0 0 0 0 -0.25 0.25 0 0 0 0 0 0 0 0 ],'sessrep','none');
                                                                                          
                                                                                                
    jobs{1}.stats{2}.results.spmmat=cellstr(fullfile(resultpath,'subResults','SPM.mat'));
    jobs{1}.stats{2}.results.conspec.contrasts=Inf;       %激活图分别输出
    jobs{1}.stats{2}.results.conspec.threshdesc='none';   %不使用多重矫正用“none”，也可使用“FWE”或是“FDR”
    jobs{1}.stats{2}.results.conspec.thresh=0.001;        %显著性水平
    jobs{1}.stats{2}.results.conspec.extent=10;            %只显示大于多少个体素的激活团
    spm_jobman('run',jobs);                         %SPM把激活图像逐个输出为.ps文件，此文件可用GhostView等查看，也可转换为PDF格式
    clear jobs;  
   
   
     end
%%%%%%%%%%%%%%%%%%%%%%以上为个体被试处理的过程%%%%%%%%%%%%%%%%%%%
%￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥      
%%%%%%%%%%%%%%%%%以下进行第二层的分析%%%%%%%%%%%%%%%%%%%%%
  ncontra=2;    %有几个contrast文件就写几，之前生成多少对比条件就写几
     
   cd([cwd,'groupResults']);  %cd到用来放组分析结果的文件夹
  
  condition_contrast={'self-other','other-self'};
   kong=12; %空格的ASKII码
   
  for numfolder=1:ncontra
       s=strcat('mkdir',kong,num2str(numfolder),condition_contrast{numfolder});  
       system(s);
  end
  
  contrastname={'con_0001.img','con_0002.img'}; %有多少个contrast可以事先定好
       for count=1:ncontra            
                groupFour=[cwd,'groupResults/',num2str(count),condition_contrast{count}];         
                cd(groupFour); %输出第二层结果的地方
                    fileCat=[];  %设置一个空矩阵来装所有被试的对比     
                 for sub=1:nsub
                        if sub==3|| sub==7 || sub==17;
                            continue
                       end
                     dirCon=[ cwd sprintf('subject%02d/subResults',sub)]; %一层分析输出的contrast文件所在的地方               
                     secondlev=spm_get('Files',dirCon,contrastname{count}) %第一层结果文件夹中的对比结果文件
                     sl=cellstr(secondlev);
                     fileCat=[fileCat;sl]
                    end
                 jobs{1}.stats{1}.factorial_design.des.t1.scans = fileCat;     
                 jobs{1}.stats{1}.factorial_design.dir = {[groupFour]};
                 jobs{1}.stats{2}.fmri_est.spmmat=cellstr(fullfile(groupFour,'SPM.mat'));   %生成模型设定的SPM.mat文件，其中会保存模型设定的全部参数以及之后的条件对照设置
               spm_jobman('run',jobs);
               clear jobs;
%%%%%%%%%%%%%%%%%%%%%%%以下设置对比并输出激活脑图%%%%%%%%%%%%%%     

                jobs{1}.stats{1}.con.spmmat=cellstr(fullfile(groupFour,'SPM.mat'));                  %打开模型设定生成的SPM.mat以便写入对照信息
                jobs{1}.stats{1}.con.consess{1}.tcon=struct('name',condition_contrast{count},'convec',[1],'sessrep','none');  %设置条件对照，要写成数组的形式

                jobs{1}.stats{2}.results.spmmat=cellstr(fullfile(groupFour,'SPM.mat'));  %打开模型设定及条件对照生成的SPM.mat文件
                jobs{1}.stats{2}.results.conspec.contrasts=inf;        %各个对照分别输出
                jobs{1}.stats{2}.results.conspec.threshdesc='none';    %设置threshold
                jobs{1}.stats{2}.results.conspec.thresh=0.001;         %设置显著水平
                jobs{1}.stats{2}.results.conspec.extent=10;             %只显示大于多少个体素的的激活团
                spm_jobman('run',jobs);    %SPM把激活图像逐个输出为.ps文件，此文件可用GhostView等查看，也可转换为PDF格式
                clear jobs;  
       end