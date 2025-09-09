function [rest1_peak,rest2_peak,stim_peak]= yh_fnirs_psd_rof(subfile,fnirs_type,aim_fre)
% fnirs_type: 1=O 2=R 3=T
% Written by yh based on Homer3
load(subfile);
%功率谱参数
rest_onset1=[];
stim_onset=[];
rest_onset2=[];
noverlap=0;
nfft1=4096;
nfft2=16384;
Fs=11;

for sub=1:size(processdata_2.rest1,3)
    for Order=1:43
        chanel=1+fnirs_type*(Order-1);  %%  1=O 2=R 3=T
        [pxx_rest1,f_rest1] = pwelch(processdata_2.rest1(:,chanel,sub),hamming(size(processdata_2.rest1,1)),noverlap,nfft1,Fs);
        [pxx_rest2,f_rest2]=pwelch(processdata_2.rest2(:,chanel,sub),hamming(size(processdata_2.rest2,1)),noverlap,nfft1,Fs);
        [pxx_stim,f_stim] = pwelch(processdata_2.stim(:,chanel,sub),hamming(size(processdata_2.stim,1)),noverlap,nfft2,Fs);
        
        %%保存频段内峰值
        f1_range = f_rest1>=aim_fre-0.005 & f_rest1<=aim_fre+0.005;
        f2_range = f_rest2>=aim_fre-0.005 & f_rest2<=aim_fre+0.005;
        f3_range = f_stim>=aim_fre-0.005 & f_stim<=aim_fre-0.005;
        %rest1
        [peak_power1,peak_idx1] = max(pxx_rest1(f1_range));
        peak_power1=10*log10(peak_power1);
        rest1_peak(sub,Order) =peak_power1;
        f1_1 = f_rest1(f1_range);
        peak_freq1 = f1_1(peak_idx1);
        rest1_peak_fre(sub,Order) =peak_freq1;
        
        %rest2
        f2_range = f_rest2>=0.045 & f_rest2<=0.055;
        [peak_power2,peak_idx2] = max(pxx_rest2(f2_range));
        peak_power2=10*log10(peak_power2);
        rest2_peak(sub,Order) =peak_power2;
        f2_1 = f_rest2(f2_range);
        peak_freq2 = f2_1(peak_idx2);
        rest2_peak_fre(sub,Order) =peak_freq2;
        
        %stim
        f3_range = f_stim>=0.045 & f_stim<=0.055;
        [peak_power3,peak_idx3] = max(pxx_stim(f3_range));
        peak_power3=10*log10(peak_power3);
        stim_peak(sub,Order) =peak_power3;
        f3_1 = f_stim(f3_range);
        peak_freq3 = f3_1(peak_idx3);
        stim_peak_fre(sub,Order) =peak_freq3;
    end
end