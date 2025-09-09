clear all
clc
%% load homer3 precessed data
load AG_42_hy_F; %载入处理后的数据
%% 整理block average 数据及std
%load Data_AG

% cond4
a1=199;%HbO_SSD 3*22*3+1=199
a2=200;%HbR_SSD 3*22*3+2=200
for ich=1:22
    Data.AG.HbO(25).dc.Avg.Con{1,1}(:,ich)=output.dcAvg.dataTimeSeries(:,a1)  ; %homer数据结构 HR（3）*Chn（30）*Con(41)=360
    Data.AG.HbO(25).dc.AvgStd.Con{1,1}(:,ich)=output.dcAvgStd.dataTimeSeries(:,a1)  ; 
    Data.AG.HbR(25).dc.Avg.Con{1,1}(:,ich)=output.dcAvg.dataTimeSeries(:,a2)  ; 
    Data.AG.HbR(25).dc.AvgStd.Con{1,1}(:,ich)=output.dcAvgStd.dataTimeSeries(:,a2)  
    a1=a1+3;
    a2=a2+3;
end
%cond5
b1=265;%HbO_SSD mark5 4*22*3+1=265
b2=266;%HbO_SSD mark5 4*22*3+2=266
for ich=1:22
    Data.AG.HbO(25).dc.Avg.Con{1,2}(:,ich)=output.dcAvg.dataTimeSeries(:,b1)  ; %homer数据结构 HR（3）*Chn（30）*Con(41)=360
    Data.AG.HbO(25).dc.AvgStd.Con{1,2}(:,ich)=output.dcAvgStd.dataTimeSeries(:,b1)  ; 
    Data.AG.HbR(25).dc.Avg.Con{1,2}(:,ich)=output.dcAvg.dataTimeSeries(:,b2)  ; 
    Data.AG.HbR(25).dc.AvgStd.Con{1,2}(:,ich)=output.dcAvgStd.dataTimeSeries(:,b2)  
    b1=b1+3;
    b2=b2+3;
end
%cond6
c1=331;
c2=332;
for ich=1:22
    Data.AG.HbO(25).dc.Avg.Con{1,3}(:,ich)=output.dcAvg.dataTimeSeries(:,c1)  ; %homer数据结构 HR（3）*Chn（30）*Con(41)=360
    Data.AG.HbO(25).dc.AvgStd.Con{1,3}(:,ich)=output.dcAvgStd.dataTimeSeries(:,c1)  ; 
    Data.AG.HbR(25).dc.Avg.Con{1,3}(:,ich)=output.dcAvg.dataTimeSeries(:,c2)  ; 
    Data.AG.HbR(25).dc.AvgStd.Con{1,3}(:,ich)=output.dcAvgStd.dataTimeSeries(:,c2)  
    c1=c1+3;
    c2=c2+3;
end
%cond7
d1=397;
d2=398;
for ich=1:22
    Data.AG.HbO(25).dc.Avg.Con{1,4}(:,ich)=output.dcAvg.dataTimeSeries(:,d1)  ; %homer数据结构 HR（3）*Chn（30）*Con(41)=360
    Data.AG.HbO(25).dc.AvgStd.Con{1,4}(:,ich)=output.dcAvgStd.dataTimeSeries(:,d1)  ; 
    Data.AG.HbR(25).dc.Avg.Con{1,4}(:,ich)=output.dcAvg.dataTimeSeries(:,d2)  ; 
    Data.AG.HbR(25).dc.AvgStd.Con{1,4}(:,ich)=output.dcAvgStd.dataTimeSeries(:,d2)  
    d1=d1+3;
    d2=d2+3;
end

%% 整理 被试内t value, p value 和FDR校正p
Data.AG.HbO(25).tpbeta.tval(:,:)=output.misc.hmrstats.tval(4:7,:,1)';%改成tval(4:7,:,1)'
Data.AG.HbO(25).tpbeta.pval(:,:)=output.misc.hmrstats.pval(4:7,:,1)';
Data.AG.HbR(25).tpbeta.tval(:,:)=output.misc.hmrstats.tval(4:7,:,2)';
Data.AG.HbR(25).tpbeta.pval(:,:)=output.misc.hmrstats.pval(4:7,:,2)';%改成tval(4:7,:,2)'
% FDR 校正 目前是30通道
for icon=1:4
   FDR=mafdr(Data.AG.HbO(25).tpbeta.pval(:,icon),'BHFDR',true);
   Data.AG.HbO(25).tpbeta.pvalFDR(:,icon)=FDR;
end
%% 整理 被试内 beta
% ich 通道数量 icon 条件数量
for ich=1:22 %改成1：22
    for icon=1:4
        Data.AG.HbO(25).tpbeta.beta(ich,icon)=output.misc.beta{1,1}(:,1,ich,icon+3)*1.0e5;%改成(:,1,ich,icon+3)*1.0e5
        Data.AG.HbR(25).tpbeta.beta(ich,icon)=output.misc.beta{1,1}(:,2,ich,icon+3)*1.0e5;%上面不运行，改成(:,1,ich,(icon+3))*1.0e5
    end
end

save('Data_AG','Data');
clear all
clc

