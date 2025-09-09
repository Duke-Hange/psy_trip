
cd('C:\Users\luping\Desktop\数据_0.02\result\GT\result_O\NetworkEfficiency\Group1')
x1=load('NetworkEfficiency.mat', 'aEloc');

cd('C:\Users\luping\Desktop\数据_0.02\result\GT\result_O\NetworkEfficiency\Group2')
x2=load('NetworkEfficiency.mat', 'aEloc');
data(:,1)=x1.aEloc;
data(:,2)=x2.aEloc;
bar(data,'DisplayName','data')
[h,p,ci,stats]=ttest2(data(:,1),data(:,2));


cd('C:\Users\luping\Desktop\数据_0.02\result\GT\result_O\NetworkEfficiency\Group1')
x1=load('NetworkEfficiency.mat', 'aEg');
cd('C:\Users\luping\Desktop\数据_0.02\result\GT\result_O\NetworkEfficiency\Group2')
x2=load('NetworkEfficiency.mat', 'aEg');
data(:,1)=x1.aEg;
data(:,2)=x2.aEg;
bar(data,'DisplayName','data')

clear
cd('F:\桌面文件夹\近红外论文\数据_0.05\result')
load('amp_rest1_ch.mat');
load('amp_stim_ch.mat');
load('amp_rest2_ch.mat');
x1=rest1_amp_ch(:,11);
x2=stim_amp_ch(:,11);
x3=rest2_amp_ch(:,11);
data(:,1)=x1;
data(:,2)=x2;
data(:,3)=x3;
boxplot(data)

clear
cd('F:\桌面文件夹\近红外论文\数据_0.05\result')
load('rest1_peak.mat');
load('stim_peak.mat');
load('rest2_peak.mat');
x1=rest1_peak(:,11);
x2=stim_peak(:,11);
x3=rest2_peak(:,11);
data(:,1)=x1;
data(:,2)=x2;
data(:,3)=x3;
boxplot(data)

Angle.O(:,11,1);

rows2vars