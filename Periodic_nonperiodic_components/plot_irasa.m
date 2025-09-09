function plot_irasa(freq, mixd, frac, osci)
% ����IRASAƵ�׷������
% ������
%   freq : Ƶ������
%   mixd : ��Ϲ�����
%   frac : ���γɷ�
%   osci : �񵴳ɷ�

% ����ͼ�δ���
figure('Position', [100, 100, 900, 700], 'Color', 'w', 'Name', 'IRASAƵ�׷���');
set(gcf, 'DefaultAxesFontSize', 12, 'DefaultTextFontSize', 14);

% ========================= ��������ͼ =========================
ax1 = subplot(2,1,1);
hold on;

% ����Ƶ������
h1 = plot(freq, mixd, 'b-', 'LineWidth', 2, 'DisplayName', '��Ϲ�����');
h2 = plot(freq, frac, 'r-', 'LineWidth', 2, 'DisplayName', '���γɷ�');
h3 = plot(freq, osci, 'g-', 'LineWidth', 2, 'DisplayName', '�񵴳ɷ�');

% ����������ͱ�ǩ
set(ax1, 'XScale', 'log', 'YScale', 'log');
xlabel('Ƶ�� (Hz)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('�������ܶ�', 'FontSize', 12, 'FontWeight', 'bold');
title('IRASAƵ�׷��� (��������)', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
box on;

% ���������᷶Χ
xlim([min(freq) max(freq)]);
ylim_vals = [mixd; frac; osci];
ylim([max(1e-10, min(ylim_vals))*0.8, max(ylim_vals)*1.2]);

% ���ͼ�� (�����汾)
leg1 = legend([h1, h2, h3], 'Location', 'southwest');
set(leg1, 'FontSize', 10, 'Box', 'off');

% ========================= ��������ͼ =========================
ax2 = subplot(2,1,2);
hold on;

% ����Ƶ������
plot(freq, mixd, 'b-', 'LineWidth', 2);
plot(freq, frac, 'r-', 'LineWidth', 2);
h_osci = plot(freq, osci, 'g-', 'LineWidth', 2);

% ����������ͱ�ǩ
xlabel('Ƶ�� (Hz)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('�������ܶ�', 'FontSize', 12, 'FontWeight', 'bold');
title('IRASAƵ�׷��� (��������)', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
box on;

% ���������᷶Χ
xlim([min(freq) max(freq)]);
ylim([0 max([mixd; frac; osci])*1.1]);

% ����񵴳ɷ����
yyaxis right;
pos_osci = max(osci, 0);  % ȷ���Ǹ�ֵ
fill([freq; flipud(freq)], [pos_osci; zeros(size(pos_osci))], ...
     [0.2 0.8 0.2], 'FaceAlpha', 0.15, 'EdgeColor', 'none');
ylabel('�񵴳ɷֹ���', 'FontSize', 10);
set(gca, 'YColor', [0.2 0.6 0.2]);

% ���ͼ�� (�����汾)
leg2 = legend('��Ϲ�����', '���γɷ�', '�񵴳ɷ�', 'Location', 'northeast');
set(leg2, 'FontSize', 10, 'Box', 'off');

% ͳһ��������ʽ
set([ax1, ax2], 'LineWidth', 1.5, 'TickDir', 'out', ...
    'XMinorTick', 'on', 'YMinorTick', 'on');

% �Ż�����
linkaxes([ax1, ax2], 'x');
set(gcf, 'Color', 'w');
end