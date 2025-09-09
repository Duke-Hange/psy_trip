% IRASA������ʹ��ʾ��
clear; clc;
 
% 1. ���ɲ����ź�
srate = 1000;           % ������
t = 0:1/srate:10;       % 10��ʱ��
fractal_component = pinknoise(length(t));  % ���γɷ�
osc_component = 0.5 * sin(2*pi*10*t) + 0.3 * sin(2*pi*20*t); % �񵴳ɷ�
signal = fractal_component + osc_component; % ����ź�

% 2. ����IRASA
[freq, mixd, frac, osci] = yh_irasa(signal, srate, 'frange', [1 45]);

% 3. ���ӻ����
plot_irasa(freq, mixd, frac, osci);

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