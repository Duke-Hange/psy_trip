function [freq, mixd, frac, osci] = yh_irasa(x, srate, varargin)
% IRASA - 分离时间序列的周期和非周期成分
% 输入：
%   x     : 时间序列 (1×N)
%   srate : 采样率 (Hz)
% 可选参数：
%   'frange', [fmin fmax] : 频率范围 (默认=[0 srate/4])
%   'hset'  : 重采样因子 (默认=1.1:0.05:1.9)
% 输出：
%   freq : 频率向量
%   mixd : 混合功率谱
%   frac : 分形(非周期)成分功率谱
%   osci : 振荡(周期)成分功率谱

% 解析可选参数
p = inputParser;
addParameter(p, 'frange', [0 srate/4], @isnumeric);
addParameter(p, 'hset', 1.1:0.05:1.9, @isnumeric);
parse(p, varargin{:});

fmin = max(p.Results.frange(1), 0);
fmax = min(p.Results.frange(2), srate/2);
hset = p.Results.hset;

% 预处理
x = detrend(x(:), 'linear');  % 去线性趋势
Ntotal = length(x);

% 计算参数
Ndata = 2^floor(log2(Ntotal*0.9));  % 分段长度
Nsubset = 15;                       % 分段数
L = floor((Ntotal-Ndata)/(Nsubset-1));
nfft = 2^nextpow2(ceil(max(hset))*Ndata);
Nfrac = nfft/2 + 1;
freq = linspace(0, srate/2, Nfrac)';

% 计算混合功率谱
mixd = zeros(Nfrac, 1);
taper = hann(Ndata);
for k = 0:Nsubset-1
    i0 = L*k + 1;
    seg = x(i0:i0+Ndata-1);
    seg = seg .* taper;
    pxx = abs(fft(seg, nfft)).^2 / Ndata;
    mixd = mixd + pxx(1:Nfrac);
end
mixd = mixd / Nsubset;

% 计算分形成分
frac_set = zeros(Nfrac, length(hset));
for ih = 1:length(hset)
    h = hset(ih);
    [n, d] = rat(h);
    
    % 正向重采样
    Sh = zeros(Nfrac, 1);
    for k = 0:Nsubset-1
        i0 = L*k + 1;
        seg = x(i0:i0+Ndata-1);
        seg_res = resample(seg, n, d);
        taper_h = hann(length(seg_res));
        seg_res = seg_res .* taper_h;
        pxx = abs(fft(seg_res, nfft)).^2 / length(seg_res);
        Sh = Sh + pxx(1:Nfrac);
    end
    Sh = Sh / Nsubset;
    
    % 反向重采样
    S1h = zeros(Nfrac, 1);
    for k = 0:Nsubset-1
        i0 = L*k + 1;
        seg = x(i0:i0+Ndata-1);
        seg_res = resample(seg, d, n);
        taper_h = hann(length(seg_res));
        seg_res = seg_res .* taper_h;
        pxx = abs(fft(seg_res, nfft)).^2 / length(seg_res);
        S1h = S1h + pxx(1:Nfrac);
    end
    S1h = S1h / Nsubset;
    
    % 几何平均
    frac_set(:, ih) = sqrt(Sh .* S1h);
end

% 中位数整合
frac = median(frac_set, 2);

% 计算振荡成分
osci = mixd - frac;

% 限制频率范围
valid_freq = (freq >= fmin) & (freq <= fmax);
freq = freq(valid_freq);
mixd = mixd(valid_freq);
frac = frac(valid_freq);
osci = osci(valid_freq);
end