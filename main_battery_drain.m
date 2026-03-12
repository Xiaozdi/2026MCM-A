%% 2026 MCM Problem A - 智能手机电池耗电模型
% 主程序：实现电池耗电的连续时间模型
% 基于Moto G60手机参数

clear; clc; close all;

%% 设置中文字体
set(0,'DefaultAxesFontName','Microsoft YaHei');
set(0,'DefaultTextFontName','Microsoft YaHei');

fprintf('========================================\n');
fprintf('智能手机电池耗电模型 - Moto G60\n');
fprintf('========================================\n\n');

%% 1. 加载参数
fprintf('步骤1: 加载模型参数...\n');
params = load_battery_parameters();

%% 2. 单因素可视化分析
fprintf('\n步骤2: 进行单因素耗电分析...\n');
single_factor_visualization(params);

%% 3. 各因素耗电量饼状图
fprintf('\n步骤3: 绘制各因素一小时耗电量饼状图...\n');
plot_power_consumption_pie(params);

%% 4. 综合场景模拟
fprintf('\n步骤4: 进行综合使用场景模拟...\n');
simulate_comprehensive_scenario(params);

%% 5. 实际数据验证
fprintf('\n步骤5: 使用实际数据验证模型...\n');
validate_with_real_data(params);

fprintf('\n========================================\n');
fprintf('所有分析完成！\n');
fprintf('========================================\n');
