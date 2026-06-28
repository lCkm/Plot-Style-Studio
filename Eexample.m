%% Figure Best V2 - 示例脚本
% 演示所有功能的完整示例

close all; clc; clear all;

% 添加路径
addpath(fileparts(mfilename('fullpath')));

fprintf('======= Figure Best V2 示例 =======\n\n');

%% 示例1: fb_line - 增强折线图
fprintf('[1/7] fb_line - 增强折线图\n');
figure('Name', 'fb_line 示例');
x = linspace(0, 2*pi, 100);
fb_line(x, sin(x), 'DisplayName', 'sin(x)');
fb_line(x, cos(x), 'DisplayName', 'cos(x)');
fb_line(x, sin(2*x), '--', 'DisplayName', 'sin(2x)');
legend('Location', 'best');
title('增强折线图 - fb\_line');
xlabel('x'); ylabel('y');

%% 示例2: fb_bar - 增强柱状图
fprintf('[2/7] fb_bar - 增强柱状图\n');
figure('Name', 'fb_bar 示例');
fb_bar([6 3 4; 2 4 2; 3 1 1]);
title('增强柱状图 - fb\_bar');
xlabel('组'); ylabel('值');
legend({'A组', 'B组', 'C组'}, 'Location', 'best');
set(gca, 'XTickLabel', {'类别1', '类别2', '类别3'});

%% 示例3: fb_scatter + fb_stem
fprintf('[3/7] fb_scatter + fb_stem\n');
figure('Name', 'fb_scatter + fb_stem 示例');
subplot(1,2,1);
fb_scatter(randn(80,1), randn(80,1));
title('增强散点图 - fb\_scatter');
xlabel('X'); ylabel('Y');

subplot(1,2,2);
X = linspace(0, 2*pi, 30);
fb_stem(X, cos(X));
title('增强茎叶图 - fb\_stem');
xlabel('X'); ylabel('cos(X)');

%% 示例4: fb_boxplot + fb_hist
fprintf('[4/7] fb_boxplot + fb_hist\n');
figure('Name', 'fb_boxplot + fb_hist 示例');
subplot(1,2,1);
x1 = randn(30,1)*0.5;
x2 = randn(30,1)*0.8 + 1;
x3 = randn(30,1)*0.3 - 0.5;
x = [x1; x2; x3];
g = [ones(30,1); 2*ones(30,1); 3*ones(30,1)];
fb_boxplot(x, g);
title('增强箱线图 - fb\_boxplot');
set(gca, 'XTickLabel', {'A组', 'B组', 'C组'});

subplot(1,2,2);
fb_hist(randn(2000,1), 30);
title('增强直方图 - fb\_hist');

%% 示例5: fb_errorbar + fb_surface
fprintf('[5/7] fb_errorbar + fb_surface\n');
figure('Name', 'fb_errorbar 示例');
x = 0:pi/8:pi;
y = sin(x);
e = 0.1*ones(size(x));
fb_errorbar(x, y, e, '-o', 'DisplayName', 'sin(x) \pm 0.1');
title('增强误差棒图 - fb\_errorbar');
xlabel('x'); ylabel('sin(x)');
legend;

figure('Name', 'fb_surface 示例');
[X, Y] = meshgrid(-3:0.1:3, -3:0.1:3);
Z = peaks(X, Y);
fb_surface(X, Y, Z);
title('增强曲面图 - fb\_surface');

%% 示例6: 快速美化 (figure_best_v2('apply'))
fprintf('[6/7] 快速美化已有图表\n');
figure('Name', '快速美化示例');
plot(1:20, rand(1,20), '-o', 1:20, rand(1,20), '-s');
title('美化前的图表');
xlabel('X轴'); ylabel('Y轴');
legend('数据A', '数据B');

% 一键美化
figure_best_v2('preset', 'academic');
fprintf('  -> 已应用 "academic" 预设\n');

%% 示例7: 配色方案展示
fprintf('[7/7] 局部放大功能\n');
figure('Name', '局部放大示例');
x = linspace(0, 4*pi, 500);
y = sin(x) + 0.1*randn(size(x));
plot(x, y, 'LineWidth', 1.2);
title('包含细节的曲线 - 可使用 fb\_inset 添加局部放大');
xlabel('x'); ylabel('y');
grid on;

% 自动添加局部放大
fb_inset('auto');

fprintf('\n======= 示例完成 =======\n');
fprintf('\n提示:\n');
fprintf('  - 运行 figure_best_v2 打开 GUI 界面\n');
fprintf('  - 运行 figure_best_v2(''apply'') 一键美化当前图窗\n');
fprintf('  - 运行 figure_best_v2(''preset'', ''ieee'') 应用特定预设\n');
fprintf('  - 运行 fb_color(''show'') 查看所有配色方案\n');
fprintf('  - 运行 fb_export(''dpi'', 600, ''format'', ''tiff'') 导出高清图\n');
