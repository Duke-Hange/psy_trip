function plot_irasa(freq, mixd, frac, osci, varargin)
% ��ǿ��IRASA���ӻ� - רҵ���м�ͼ��
% ���룺
%   freq : Ƶ������
%   mixd : ��Ϲ�����
%   frac : ���γɷ�
%   osci : �񵴳ɷ�
% ��ѡ������
%   'logplot' : �Ƿ�ʹ�ö������� (Ĭ��=true)
%   'title'   : ͼ�����
%   'showfit' : �Ƿ���ʾ������� (Ĭ��=true)

% ������ѡ����
p = inputParser;
addParameter(p, 'logplot', true, @islogical);
addParameter(p, 'title', 'IRASAƵ�׷ֽ�', @ischar);
addParameter(p, 'showfit', true, @islogical);
parse(p, varargin{:});

% ����רҵ����ͼ��
figure('Position', [100, 100, 900, 700], 'Color', 'w');
set(gcf, 'DefaultAxesFontSize', 12, 'DefaultAxesFontName', 'Arial');

% ��Ƶ��ͼ
subplot(3,1,[1,2]);
hold on;

% ����Ƶ������
h_mixd = plot(freq, mixd, 'Color', [0, 0.45, 0.74], 'LineWidth', 2.5, 'DisplayName', '���Ƶ��');
h_frac = plot(freq, frac, 'Color', [0.85, 0.33, 0.1], 'LineWidth', 2.5, 'DisplayName', '���γɷ�');
h_osci = plot(freq, osci, 'Color', [0.49, 0.18, 0.56], 'LineWidth', 2.5, 'DisplayName', '�񵴳ɷ�');

% ����������
fill_x = [freq; flipud(freq)];
fill_y = [frac; mixd];
fill(fill_x, fill_y, [0.93, 0.69, 0.13], 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'DisplayName', '������');

% ���������ϣ�������ã�
if p.Results.showfit
    % ������ϣ�log(P) = ��*log(f) + c
    logf = log10(freq(freq > 1)); % ����log(0)
    logP = log10(frac(freq > 1));
    coeffs = polyfit(logf, logP, 1);
    beta = -coeffs(1); % ��б��
    fit_line = 10.^(coeffs(2) * freq.^(coeffs(1)));
    
    % ���������
    plot(freq, fit_line, '--', 'Color', [0.64, 0.08, 0.18], 'LineWidth', 2, ...
        'DisplayName', sprintf('������� (��=%.2f)', beta));
end

% ����������
if p.Results.logplot
    set(gca, 'XScale', 'log', 'YScale', 'log');
end

% רҵ��ʽ����
grid on;
box on;
set(gca, 'Layer', 'top', 'GridLineStyle', ':', 'LineWidth', 1.2);
xlabel('Ƶ�� (Hz)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('����', 'FontSize', 14, 'FontWeight', 'bold');
title(p.Results.title, 'FontSize', 16, 'FontWeight', 'bold');

% ���רҵͼ��
% legend('Location', 'southwest', 'Box', 'off', 'FontSize', 12);

% ��ӿ�ѧ��ע
text(0.02, 0.95, sprintf('����񵴹���: %.2f Hz', freq(osci == max(osci))), ...
    'Units', 'normalized', 'FontSize', 12, 'BackgroundColor', [1, 1, 1, 0.7]);

% �񵴳ɷ�Ƶ�׷���
subplot(3,1,3);
hold on;

% �����ͨ�˲�����񵴳ɷ�
[b, a] = butter(4, [2, 45]/(srate/2), 'bandpass');
osci_filt = filtfilt(b, a, osci);

% ������Ƶ��
plot(freq, osci_filt, 'Color', [0.49, 0.18, 0.56], 'LineWidth', 2);

% ��ע��ֵ
[peaks, locs] = findpeaks(osci_filt, 'MinPeakProminence', max(osci_filt)/10);
for i = 1:min(3, length(peaks)) % ����ע3����Ҫ��ֵ
    plot(freq(locs(i)), peaks(i), 'v', 'MarkerSize', 10, ...
        'MarkerFaceColor', [0.93, 0.69, 0.13], 'MarkerEdgeColor', 'k');
    text(freq(locs(i)), peaks(i)*1.15, sprintf('%.1f Hz', freq(locs(i))), ...
        'FontSize', 11, 'HorizontalAlignment', 'center');
end

% ����������
xlim([1, 50]);
grid on;
box on;
set(gca, 'Layer', 'top', 'GridLineStyle', ':', 'LineWidth', 1.2);
xlabel('Ƶ�� (Hz)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('�񵴹���', 'FontSize', 14, 'FontWeight', 'bold');
title('�񵴳ɷ�Ƶ�׷���', 'FontSize', 14, 'FontWeight', 'bold');

% ���ͳһע��
annotation('textbox', [0.01, 0.01, 0.4, 0.03], 'String', ...
    sprintf('IRASA���� | ������: %d Hz | Ƶ�ʷ�Χ: %.1f-%.1f Hz', srate, min(freq), max(freq)), ...
    'FitBoxToText', 'on', 'EdgeColor', 'none', 'FontSize', 10);
end