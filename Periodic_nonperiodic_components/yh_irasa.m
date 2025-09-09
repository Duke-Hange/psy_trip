function [freq, mixd, frac, osci] = yh_irasa(x, srate, varargin)
% IRASA - ����ʱ�����е����ںͷ����ڳɷ�
% ���룺
%   x     : ʱ������ (1��N)
%   srate : ������ (Hz)
% ��ѡ������
%   'frange', [fmin fmax] : Ƶ�ʷ�Χ (Ĭ��=[0 srate/4])
%   'hset'  : �ز������� (Ĭ��=1.1:0.05:1.9)
% �����
%   freq : Ƶ������
%   mixd : ��Ϲ�����
%   frac : ����(������)�ɷֹ�����
%   osci : ��(����)�ɷֹ�����

% ������ѡ����
p = inputParser;
addParameter(p, 'frange', [0 srate/4], @isnumeric);
addParameter(p, 'hset', 1.1:0.05:1.9, @isnumeric);
parse(p, varargin{:});

fmin = max(p.Results.frange(1), 0);
fmax = min(p.Results.frange(2), srate/2);
hset = p.Results.hset;

% Ԥ����
x = detrend(x(:), 'linear');  % ȥ��������
Ntotal = length(x);

% �������
Ndata = 2^floor(log2(Ntotal*0.9));  % �ֶγ���
Nsubset = 15;                       % �ֶ���
L = floor((Ntotal-Ndata)/(Nsubset-1));
nfft = 2^nextpow2(ceil(max(hset))*Ndata);
Nfrac = nfft/2 + 1;
freq = linspace(0, srate/2, Nfrac)';

% �����Ϲ�����
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

% ������γɷ�
frac_set = zeros(Nfrac, length(hset));
for ih = 1:length(hset)
    h = hset(ih);
    [n, d] = rat(h);
    
    % �����ز���
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
    
    % �����ز���
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
    
    % ����ƽ��
    frac_set(:, ih) = sqrt(Sh .* S1h);
end

% ��λ������
frac = median(frac_set, 2);

% �����񵴳ɷ�
osci = mixd - frac;

% ����Ƶ�ʷ�Χ
valid_freq = (freq >= fmin) & (freq <= fmax);
freq = freq(valid_freq);
mixd = mixd(valid_freq);
frac = frac(valid_freq);
osci = osci(valid_freq);
end