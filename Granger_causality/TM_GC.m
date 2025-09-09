clear
sub_path='D:\TMConn\conn_project01\results\新建文件夹';
sub_file=dir(sub_path);
sub_file(1:2)=[];

for i=1:length(sub_file)
    data=load(fullfile(sub_file(i).folder,sub_file(i).name));
    fc(i,1)=data.Z(31,11);
    fc(i,2)=data.Z(31,10);
    fc(i,3)=data.Z(31,9);

    fc(i,4)=data.Z(15,13);
    fc(i,5)=data.Z(4,32);

    fc(i,6)=data.Z(31,3);
    fc(i,7)=data.Z(31,24);
    fc(i,8)=data.Z(31,26);

    fc(i,9)=data.Z(1,23);
    fc(i,10)=data.Z(1,25);
end

%% 循环被试格兰杰
addpath 'E:\22级\Yu_Hang\toolbox\CopulaGrangerCausality_ContinuousData-master'
clear all
% subpath='D:\TMConn\conn_project01\results\xx\ROI';
subpath='D:\TMConn\conn_project01\results\xx\ROI_HC';
sub_file=dir(subpath);
sub_file(1:2)=[];

GC_data=[];

m_mir=4;
mw=2;

%         mw=1;
%         m_mir=3;
h1=9;  % 9  171

bt=true;
nbt=5000; %5000  171
alpha_value=0.05;

% i=4;

filter=xlsread('D:\TMConn\SBC\fc_zero.xlsx');
[row, col] = find(filter == 1);

for i=1:length(sub_file)
    i
    clear data
    file_name=fullfile(sub_file(i).folder,sub_file(i).name);
    file=load(file_name);

    file_Data_V_L_r(:,i)=cell2mat(file.data(14));
    file_Data_V_L_l(:,i)=cell2mat(file.data(13));
    file_Data_V_O(:,i)=cell2mat(file.data(12));
    file_Data_C_A(:,i)=cell2mat(file.data(34));
    file_Data_C_P(:,i)=cell2mat(file.data(35));
    file_Data_S_RPFC_l(:,i)=cell2mat(file.data(18));
    file_Data_S_Alnsula_l(:,i)=cell2mat(file.data(16));
    file_Data_DM_MPFC(:,i)=cell2mat(file.data(4));
    file_Data_DM_PPC(:,i)=cell2mat(file.data(7));
    file_Data_DM_LP_r(:,i)=cell2mat(file.data(6));
    file_Data_FP_PPC_r(:,i)=cell2mat(file.data(29));
    file_Data_FP_PPC_l(:,i)=cell2mat(file.data(27));
    file_Data_FP_LPFC_l(:,i)=cell2mat(file.data(26));
    file_Data_FP_LPFC_r(:,i)=cell2mat(file.data(28));

    data(1,:)=file_Data_V_L_r(:,i);
    data(2,:)=file_Data_V_L_l(:,i);
    data(3,:)= file_Data_V_O(:,i);
    data(4,:)=file_Data_C_A(:,i);
    data(5,:)= file_Data_C_P(:,i);
    data(6,:)=file_Data_S_RPFC_l(:,i);
    data(7,:)=file_Data_S_Alnsula_l(:,i);
    data(8,:)=file_Data_DM_MPFC(:,i);
    data(9,:)=file_Data_DM_PPC(:,i);
    data(10,:)= file_Data_DM_LP_r(:,i);
    data(11,:)= file_Data_FP_PPC_r(:,i);
    data(12,:)=file_Data_FP_PPC_l(:,i);
    data(13,:)=file_Data_FP_LPFC_l(:,i);
    data(14,:)= file_Data_FP_LPFC_r(:,i);



    for x=1:length(row)
            XY=zeros(14,14);
        x

        % 通过互相关寻找最优延迟
        GC_data(1,:)=data(row(x),:);
        GC_data(2,:)=data(col(x),:);

        clear crossCorr lags maxCorr maxIndex delay nlag_s nlag_r

        [crossCorr, lags] = xcorr(GC_data(1,:), GC_data(2,:));
        [maxCorr, maxIndex] = max(crossCorr(232:248));
        maxIndex2=232+maxIndex-1;
        delay = lags(maxIndex2);

        if delay < 0
            nlag_s = abs(delay);
            nlag_r = 1;
        elseif delay > 0
            nlag_s = 1;
            nlag_r = abs(delay);
        else % 当 delay 等于 0 时
            nlag_s = 1;
            nlag_r = 1;
        end

        % 计算格兰杰因果
        clear GCxy GCyx GCxy_bt GCyx_bt

        [GCxy GCyx GCxy_bt GCyx_bt]=copu_gc_callfunc(GC_data,mw,m_mir,h1,nlag_s,nlag_r,bt,nbt);
        GCxy_bt=sort(squeeze(GCxy_bt));
        GCyx_bt=sort(squeeze(GCyx_bt));

        if  abs(delay) == 1 || abs(delay) == 0
            if GCxy > GCxy_bt(fix(nbt*(1-alpha_value)))
                fprintf('True positive \n');   % correctly identify GC
                XY(row(x),col(x))=1;
            end

            if GCyx > GCyx_bt(fix(nbt*(1-alpha_value)))
                fprintf('False positive \n');  % falsely identify GC
                XY(col(x),row(x))=1;
            end

        else
            GCxy=GCxy(abs(delay));
            GCyx=GCyx(abs(delay));

            if GCxy >= GCxy_bt(abs(delay),nbt*(1-alpha_value))
                fprintf('True positive \n');   % correctly identify GC
                XY(row(x),col(x))=1;
            end

            if GCyx >= GCyx_bt(abs(delay),fix(nbt*(1-alpha_value)))
                fprintf('False positive \n');  % falsely identify GC
                XY(col(x),row(x))=1;
            end
        end
        Summary_sub_GCxy_summary.(sprintf('m_mir_mw_x_y_%d_%d_%d_%d',m_mir,mw,row(x),col(x)))(i,:)=GCxy;
        Summary_sub_GCyx_summary.(sprintf('m_mir_mw_x_y_%d_%d_%d_%d',m_mir,mw,row(x),col(x)))(i,:)=GCyx;
        %             Summary_GCyx_summary.(sprintf('m_mir_mw_%d_%d',m_mir,mw))(i,x,y)=GCyx;
        Summary_sub_XY.(sprintf('m_mir_mw_%d_%d',m_mir,mw))(i,:,:)=XY;

        clear XY 

    end

save('Summary_sub_XY','Summary_sub_XY')
save('Summary_sub_GCxy_summary','Summary_sub_GCxy_summary')
save('Summary_sub_GCyx_summary','Summary_sub_GCyx_summary')

end

max_len = max(length(Summary_sub_GCxy_summary.m_mir_mw_x_y_4_2_7_6), length(Summary_sub_GCxy_summary.m_mir_mw_x_y_4_2_7_6));
data = NaN(max_len, 2);
data(1:length( Summary_sub_GCxy_summary.m_mir_mw_x_y_4_2_7_6), 1) = Summary_sub_GCxy_summary.m_mir_mw_x_y_4_2_7_6;
data(1:length( Summary_sub_GCxy_summary.m_mir_mw_x_y_4_2_7_6), 2) = Summary_sub_GCyx_summary.m_mir_mw_x_y_4_2_7_6;
group = [ones(size(data(:,1))); 2*ones(size(data(:,2)))];
boxplot(data, group);

[h,p,ci,stats]=ttest2(Summary_sub_GCxy_summary.m_mir_mw_x_y_4_2_7_6, Summary_sub_GCyx_summary.m_mir_mw_x_y_4_2_7_6);


%% 写入数据
clear
subpath='D:\TMConn\conn_project01\results\xx\ROI';
sub_file=dir(subpath);
sub_file(1:2)=[];
for i=1:length(sub_file)
    file_name=fullfile(sub_file(i).folder,sub_file(i).name);
    file=load(file_name);

    file_Data_V_L_r(:,i)=cell2mat(file.data(14));
    file_Data_V_L_l(:,i)=cell2mat(file.data(13));
    file_Data_V_O(:,i)=cell2mat(file.data(12));
    file_Data_C_A(:,i)=cell2mat(file.data(34));
    file_Data_C_P(:,i)=cell2mat(file.data(35));
    file_Data_S_RPFC_l(:,i)=cell2mat(file.data(18));
    file_Data_S_Alnsula_l(:,i)=cell2mat(file.data(16));
    file_Data_DM_MPFC(:,i)=cell2mat(file.data(4));
    file_Data_DM_PPC(:,i)=cell2mat(file.data(7));
    file_Data_DM_LP_r(:,i)=cell2mat(file.data(6));
    file_Data_FP_PPC_r(:,i)=cell2mat(file.data(29));
    file_Data_FP_PPC_l(:,i)=cell2mat(file.data(27));
    file_Data_FP_LPFC_l(:,i)=cell2mat(file.data(26));
    file_Data_FP_LPFC_r(:,i)=cell2mat(file.data(28));

    data(1,:)=file_Data_V_L_r(:,i);
    data(2,:)=file_Data_V_L_l(:,i);
    data(3,:)= file_Data_V_O(:,i);
    data(4,:)=file_Data_C_A(:,i);
    data(5,:)= file_Data_C_P(:,i);
    data(6,:)=file_Data_S_RPFC_l(:,i);
    data(7,:)=file_Data_S_Alnsula_l(:,i);
    data(8,:)=file_Data_DM_MPFC(:,i);
    data(9,:)=file_Data_DM_PPC(:,i);
    data(10,:)= file_Data_DM_LP_r(:,i);
    data(11,:)= file_Data_FP_PPC_r(:,i);
    data(12,:)=file_Data_FP_PPC_l(:,i);
    data(13,:)=file_Data_FP_LPFC_l(:,i);
    data(14,:)= file_Data_FP_LPFC_r(:,i);
end
all_data(1,:)=mean(file_Data_V_L_r,2);
all_data(2,:)=mean(file_Data_V_L_l,2);
all_data(3,:)=mean(file_Data_V_O,2);
all_data(4,:)=mean(file_Data_C_A,2);
all_data(5,:)=mean(file_Data_C_P,2);
all_data(6,:)=mean(file_Data_S_RPFC_l,2);
all_data(7,:)=mean(file_Data_S_Alnsula_l,2);
all_data(8,:)=mean(file_Data_DM_MPFC,2);
all_data(9,:)=mean(file_Data_DM_PPC,2);
all_data(10,:)=mean(file_Data_DM_LP_r,2);
all_data(11,:)=mean(file_Data_FP_PPC_r,2);
all_data(12,:)=mean(file_Data_FP_PPC_l,2);
all_data(13,:)=mean(file_Data_FP_LPFC_l,2);
all_data(14,:)=mean(file_Data_FP_LPFC_r,2);

clearvars -except all_data

%%

filter=xlsread('D:\TMConn\SBC\fc_zero.xlsx');
[row, col] = find(filter == 1);


for m_mir=2:4
    m_mir
    for mw=1:m_mir
        mw
        XY=zeros(14,14);

        h1=9;  % 9  171
        bt=true;
        nbt=5000; %5000  171
        alpha_value=0.05;


        for x=1:length(row)
            x

            % 通过互相关寻找最优延迟
            GC_data(1,:)=all_data(row(x),:);
            GC_data(2,:)=all_data(col(x),:);

            clear crossCorr lags maxCorr maxIndex delay nlag_s nlag_r

            [crossCorr, lags] = xcorr(GC_data(1,:), GC_data(2,:));
            [maxCorr, maxIndex] = max(crossCorr(232:248));
            maxIndex2=232+maxIndex-1;
            delay = lags(maxIndex2);

            if delay < 0
                nlag_s = abs(delay);
                nlag_r = 1;
            elseif delay > 0
                nlag_s = 1;
                nlag_r = abs(delay);
            else % 当 delay 等于 0 时
                nlag_s = 1;
                nlag_r = 1;
            end

            % 计算格兰杰因果
            clear GCxy GCyx GCxy_bt GCyx_bt

            [GCxy GCyx GCxy_bt GCyx_bt]=copu_gc_callfunc(GC_data,mw,m_mir,h1,nlag_s,nlag_r,bt,nbt);
            GCxy_bt=sort(squeeze(GCxy_bt));
            GCyx_bt=sort(squeeze(GCyx_bt));

            if  abs(delay) == 1 || abs(delay) == 0
                if GCxy > GCxy_bt(fix(nbt*(1-alpha_value)))
                    fprintf('True positive \n');   % correctly identify GC
                    XY(row(x),col(x))=1;
                end

                if GCyx > GCyx_bt(fix(nbt*(1-alpha_value)))
                    fprintf('False positive \n');  % falsely identify GC
                    XY(col(x),row(x))=1;
                end

            else
                GCxy=GCxy(abs(delay));
                GCyx=GCyx(abs(delay));

                if GCxy >= GCxy_bt(abs(delay),nbt*(1-alpha_value))
                    fprintf('True positive \n');   % correctly identify GC
                    XY(row(x),col(x))=1;
                end

                if GCyx >= GCyx_bt(abs(delay),fix(nbt*(1-alpha_value)))
                    fprintf('False positive \n');  % falsely identify GC
                    XY(col(x),row(x))=1;
                end
            end
            % Summary_GCxy_summary.(sprintf('m_mir_mw_%d_%d',m_mir,mw))(i,x,y)=GCxy;
            % Summary_GCyx_summary.(sprintf('m_mir_mw_%d_%d',m_mir,mw))(i,x,y)=GCyx;

        end
        Summary_XY2.(sprintf('m_mir_mw_%d_%d',m_mir,mw))(:,:)=XY;
        clear XY

        save('Summary_XY2','Summary_XY2')
    end

end

system('shutdown /s /t 0');  

%% 画图
figure;  
imagesc(Summary_XY.m_mir_mw_4_2); 


% 设置坐标轴标签  
set(gca, 'XTick', 1:14, 'YTick', 1:14, ...
    'XTickLabel', {'V_L_l', 'V_L_r','V_O','C_A','C_P','S_RPFC_l','S_Alnsula_l','DM_MPFC','DM_PCC','DM_LP_r','FP_PPC_r','FP_PPC_l','FP_LPFC_l','FP_LPFC_r'}, ...
    'YTickLabel', {'V_L_l', 'V_L_r','V_O','C_A','C_P','S_RPFC_l','S_Alnsula_l','DM_MPFC','DM_PCC','DM_LP_r','FP_PPC_r','FP_PPC_l','FP_LPFC_l','FP_LPFC_r'});  
xlabel('Source');  
ylabel('Target');  

% 调整坐标轴范围  
axis xy; % 使 Y 轴方向向上  

% 设置颜色映射  
colormap(gray); % 使用灰色色图  


% 显示图形  
axis square;  


%%
font_name = 'Times New Roman';
figure;  
imagesc(Summary_XY2.m_mir_mw_4_2);   

% Set axis labels  
set(gca, 'XTick', 1:14, 'YTick', 1:14, ...  
    'XTickLabel', {'V.L l', 'V.L r','V.O','C.A','C.P','S.RPFC l','S.AI l','DMN.MPFC','DMN.PCC','DMN.LP r','FP.PPC r','FP.PPC l','FP.LPFC l','FP.LPFC r'}, ...  
    'YTickLabel', {'V.L l', 'V.L r','V.O','C.A','C.P','S.RPFC l','S.AI l','DMN.MPFC','DMN.PCC','DMN.LP r','FP.PPC r','FP.PPC l','FP.LPFC l','FP.LPFC r'}, ...  
    'FontName', font_name, 'FontSize', 10);  
xlabel('Source', 'FontName', font_name,'FontSize', 12, 'FontWeight', 'bold');  
ylabel('Target','FontName', font_name, 'FontSize', 12, 'FontWeight', 'bold');  

% Adjust axis range  
axis xy; % Make Y-axis direction up  

% Set color mapping  
colormap(parula); % Use a different color map  
% colorbar; % Add a color bar  


title('Functional Connectivity Based on Granger Causation', 'FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Times New Roman');  
% Enhance the grid  
grid on; % Show grid lines  
set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.5); % Customize grid appearance  

% Display the figure  
axis square;   

exportgraphics(gca, 'output2.tiff',...
    'Resolution', 600,...  % 组合图要求 ≥500dpi
    'BackgroundColor', 'white',...
    'ContentType', 'auto'); % 自动识别图像类型

%%
figure;  
imagesc(Summary_XY2.m_mir_mw_4_2);   

% Set axis labels  
set(gca, 'XTick', 1:14, 'YTick', 1:14, ...  
    'XTickLabel', {'V.L l', 'V.L r','V.O','C.A','C.P','S.RPFC l','S.AI l','DMN.MPFC','DMN.PCC','DMN.LP r','FP.PPC r','FP.PPC l','FP.LPFC l','FP.LPFC r'}, ...  
    'YTickLabel', {'V.L l', 'V.L r','V.O','C.A','C.P','S.RPFC l','S.AI l','DMN.MPFC','DMN.PCC','DMN.LP r','FP.PPC r','FP.PPC l','FP.LPFC l','FP.LPFC r'}, ...  
    'FontName', font_name,'FontSize', 10);  
xlabel('Source', 'FontName', font_name,'FontSize', 12, 'FontWeight', 'bold');  
ylabel('Target', 'FontName', font_name,'FontSize', 12, 'FontWeight', 'bold');  

% Adjust axis range  
axis xy; % Make Y-axis direction up  

% Set color mapping  
colormap(parula); % Use a different color map  
% colorbar; % Uncomment if you want to add a color bar  

title('Functional Connectivity Based on Granger Causation', 'FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Times New Roman');  

% Enhance the grid  
grid on; % Show grid lines  
set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.5); % Customize grid appearance  

% Display the figure  
axis square;  

% Add a diagonal line from the top-left to the bottom-right  
hold on; % Keep the current plot  
% plot([1 14], [1 14], 'r--', 'LineWidth', 1.5); % Draw a black diagonal line  
plot(1:14, 1:14, '--', 'Color', [1 0 0 0.7], 'LineWidth', 1.5);
hold off; % Release the plot hold  

exportgraphics(gca, 'output2.tiff',...
    'Resolution', 600,...  % 组合图要求 ≥500dpi
    'BackgroundColor', 'white',...
    'ContentType', 'auto'); % 自动识别图像类型

%% 
figure;  
imagesc(Summary_XY2.m_mir_mw_4_2);   

% 设置坐标轴标签  
set(gca, 'XTick', 1:14, 'YTick', 1:14, ...  
    'XTickLabel', {'V L l', 'V L r', 'V O', 'C A', 'C P', ...  
                   'S RPFC l', 'S Alnsula l', 'DM MPFC', ...  
                   'DM PCC', 'DM LP r', 'FP PPC r', ...  
                   'FP PPC l', 'FP LPFC l', 'FP LPFC r'}, ...  
    'YTickLabel', {'V L l', 'V L r', 'V O', 'C A', 'C P', ...  
                   'S RPFC l', 'S Alnsula l', 'DM MPFC', ...  
                   'DM PCC', 'DM LP r', 'FP PPC r', ...  
                   'FP PPC l', 'FP LPFC l', 'FP LPFC r'}, ...  
    'FontSize', 10, 'FontWeight', 'bold', 'FontName', 'Arial'); % 增加字体设置  

xlabel('Source', 'FontSize', 10, 'FontWeight', 'bold', 'FontName', 'Arial');  
ylabel('Target', 'FontSize', 10, 'FontWeight', 'bold', 'FontName', 'Arial');  

% 调整坐标轴范围  
axis xy; % 使 Y 轴方向向上  

% 设置颜色映射  
colormap("gray"); % 使用灰色色图  

box on; % 添加边框  

% grid on; % 启用网格线  
% set(gca, 'GridColor', 'k');
% set(gca, 'GridLineStyle', '-', 'XGrid', 'on', 'YGrid', 'on', 'LineWidth', 1.5);

% 添加标题  
title('Causality Connectivity among Different Rigion', 'FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Arial');  

% 显示图形  
axis square;  
% colorbar; % 如果需要显示颜色条


%% 通过互相关寻找最优延迟

[crossCorr, lags] = xcorr(GC_data(1,:), GC_data(2,:));  

% 找到一个bold周期内 互相关的最大值及其对应的延迟  
[maxCorr, maxIndex] = max(crossCorr(232:248));  

maxIndex2=232+maxIndex-1;
delay = lags(maxIndex2);

if delay<0
    nlag_s=abs(delay);
    nlag_r=1;
else
    nlag_s=1;
    nlag_r=abs(delay);
end
%% 计算格兰杰因果
[GCxy GCyx GCxy_bt GCyx_bt]=copu_gc_callfunc(GC_data,mw,m_mir,h1,nlag_s,nlag_r,bt,nbt);
GCxy_bt=sort(squeeze(GCxy_bt));
GCyx_bt=sort(squeeze(GCyx_bt));

if GCxy(abs(delay)) > GCxy_bt(abs(delay),nbt*(1-alpha_value))
    fprintf('True positive \n');   % correctly identify GC
end

if GCyx(abs(delay)) > GCyx_bt(abs(delay),fix(nbt*(1-alpha_value)))
    fprintf('False positive \n');  % falsely identify GC
end

%%


%%


