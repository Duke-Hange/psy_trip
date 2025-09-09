% ���ɲ����ź�
fs = 1000;
t = 0:1/fs:10;
x = pinknoise(length(t)) + 2*sin(2*pi*10*t) + 1.5*sin(2*pi*25*t);

% ����IRASA
[freq, mixd, frac, osci] = yh_irasa(x, fs, 'frange', [1 45]);

% רҵ���ӻ�
plot_irasa2(freq, mixd, frac, osci, ...
    'title', '�����ź�IRASA����', ...
    'showfit', true, ...
    'logplot', true);

% �������������ɷۺ�����
function y = pinknoise(n)
    % ���ɷۺ����� (1/f����)
    x = randn(1, n);
    x_fft = fft(x);
    n_over2 = floor(n/2);
    magnitudes = [0, 1./(1:n_over2), 1./(n_over2:-1:1)];
    y = real(ifft(x_fft .* magnitudes));
    y = y - mean(y);
end