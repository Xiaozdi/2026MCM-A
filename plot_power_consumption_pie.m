function plot_power_consumption_pie(params)
% 绘制各因素一小时耗电量饼状图

fprintf('开始绘制耗电量饼状图...\n');

% 创建一个典型使用场景
typical_scenario.screen_on = 1;
typical_scenario.brightness = 150;
typical_scenario.cpu_usage = 0.4;
typical_scenario.cpu_freq_ratio = 0.5;
typical_scenario.network_type = 'wifi';
typical_scenario.network_activity = 0.5;
typical_scenario.gps_freq = 0;
typical_scenario.background_activity = 2.0;

%% 计算各组件功耗（使用新模型）
T = params.T_ambient;

% 1. 基础功耗
P_base = params.P_base_25 * (1 + params.alpha_base * (T - 25));

% 2. 屏幕功耗
L = typical_scenario.brightness;
P_pixel = 0.5 * L^2.2 * params.A_white * (1 + 0.0083 * (params.f_refresh - 60));
P_screen = P_pixel + params.P_circuit;

% 3. CPU功耗
P_dynamic = 0;
f_ratio = typical_scenario.cpu_freq_ratio;
for i = 1:params.N_cores
    U_i = typical_scenario.cpu_usage;
    P_dynamic = P_dynamic + params.P_core_i(i) * U_i^1.7 * f_ratio;
end
P_cpu = (params.P_static + P_dynamic) * (1 + params.alpha_CPU * (T - 25));

% 4. WiFi功耗
P_wifi = params.P_wifi_base + params.P_wifi_coef * typical_scenario.network_activity;

% 5. GPS功耗（此场景下为0）
P_gps = 0;

% 6. 后台任务功耗
P_background = params.P_background_base * typical_scenario.background_activity;

%% 计算一小时耗电量（mAh）
% 功率转换为电流：I = P / V
% 一小时耗电量 = I * 1h
drain_base = (P_base / params.voltage_nominal) * 1000;  % mAh
drain_screen = (P_screen / params.voltage_nominal) * 1000;
drain_cpu = (P_cpu / params.voltage_nominal) * 1000;
drain_wifi = (P_wifi / params.voltage_nominal) * 1000;
drain_gps = (P_gps / params.voltage_nominal) * 1000;
drain_background = (P_background / params.voltage_nominal) * 1000;

%% 绘制饼状图
figure('Name', '各因素一小时耗电量分布', 'Position', [100, 100, 1000, 600]);

% 子图1: 功率分布
subplot(1, 2, 1);
powers = [P_base, P_screen, P_cpu, P_wifi, P_background];
labels = {'基础功耗', '屏幕', 'CPU', 'WiFi', '后台任务'};
colors = [0.8 0.8 0.8; 0.2 0.6 0.8; 0.8 0.4 0.2; 0.4 0.8 0.4; 0.8 0.6 0.2];

pie(powers, labels);
colormap(colors);
title('各组件功率消耗分布 (W)');

% 添加图例显示具体数值
legend_str = cell(length(labels), 1);
for i = 1:length(labels)
    legend_str{i} = sprintf('%s: %.2f W (%.1f%%)', labels{i}, powers(i), powers(i)/sum(powers)*100);
end
legend(legend_str, 'Location', 'southoutside');

% 子图2: 一小时耗电量分布
subplot(1, 2, 2);
drains = [drain_base, drain_screen, drain_cpu, drain_wifi, drain_background];
pie(drains, labels);
colormap(colors);
title('一小时耗电量分布 (mAh)');

% 添加图例显示具体数值
legend_str2 = cell(length(labels), 1);
for i = 1:length(labels)
    legend_str2{i} = sprintf('%s: %.1f mAh (%.1f%%)', labels{i}, drains(i), drains(i)/sum(drains)*100);
end
legend(legend_str2, 'Location', 'southoutside');

% 保存图片
saveas(gcf, '耗电量饼状图.png');

%% 打印详细信息
fprintf('\n典型使用场景下各组件功耗:\n');
fprintf('  基础功耗: %.2f W (%.1f mAh/h)\n', P_base, drain_base);
fprintf('  屏幕功耗: %.2f W (%.1f mAh/h)\n', P_screen, drain_screen);
fprintf('  CPU功耗: %.2f W (%.1f mAh/h)\n', P_cpu, drain_cpu);
fprintf('  WiFi功耗: %.2f W (%.1f mAh/h)\n', P_wifi, drain_wifi);
fprintf('  后台任务: %.2f W (%.1f mAh/h)\n', P_background, drain_background);
fprintf('  总功耗: %.2f W (%.1f mAh/h)\n', sum(powers), sum(drains));
fprintf('  预计续航时间: %.2f 小时\n', params.Q_max / sum(drains));

fprintf('饼状图绘制完成！\n');

end
