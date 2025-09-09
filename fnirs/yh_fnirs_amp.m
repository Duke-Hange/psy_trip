function [rest1_amp_ch,stim_amp_ch,rest2_amp_ch]= yh_fnirs_amp(subfile,fnirs_type)
% 适用于稳定时间间隔的fnirs设计
% fnirs_type: 1=O 2=R 3=T
% Written by yh based on Homer3 and Dpabi.
x=load(subfile);
for sub=1:size(x.dcAvg_2.stim,3)
    for Order=1:43
        chanel=1+fnirs_type*(Order-1);     
        rest1_amp_ch(sub,Order)= max(x.dcAvg_2.rest1(:,chanel,sub))-min(x.dcAvg_2.rest1(:,chanel,sub));
        stim_amp_ch(sub,Order)= max(x.dcAvg_2.stim(:,chanel,sub))-min(x.dcAvg_2.stim(:,chanel,sub));
        rest2_amp_ch(sub,Order)= max(x.dcAvg_2.rest2(:,chanel,sub))-min(x.dcAvg_2.rest2(:,chanel,sub));
    end
end