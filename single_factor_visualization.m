function single_factor_visualization(params)
% 单因素耗电分析可视化
% 分别展示每个因素单独作用时的一小时耗电量

fprintf('开始单因素分析...\n');

% 创建基础场景（所有因素都关闭）
base_scenario.screen_on = 0;
base_scenario.brightness = 0;
base_scenario.cpu_usage = 0.05;  % 最小CPU使用率
base_scenario.network_type = 'none';
base_scenario.network_activity = 0;
base_scenario.gps_freq = 0;
base_scenario.background_activity = 0;

% 时间设置：1小时
time_duration = 1;  % 小时
initial_SOC = 100;  % 初始电量100%

%% 1. WiFi单独作用
fprintf('  - 分析WiFi耗电...\n');
scenario_wifi = base_scenario;
scenario_wifi.network_type = 'wifi';
scenario_wifi.network_activity = 0.5;
[SOC_wifi, power_wifi, ~] = simulate_battery_drain(params, scenario_wifi, time_duration, initial_SOC);

%% 2. 4G单独作用
fprintf('  - 分析4G耗电...\n');
scenario_4g = base_scenario;
scenario_4g.network_type = '4g';
scenario_4g.network_activity = 0.5;
[SOC_4g, power_4g, ~] = simulate_battery_drain(params, scenario_4g, time_duration, initial_SOC);

%% 3. 5G单独作用
fprintf('  - 分析5G耗电...\n');
scenario_5g = base_scenario;
scenario_5g.network_type = '5g';
scenario_5g.network_activity = 0.5;
[SOC_5g, power_5g, ~] = simulate_battery_drain(params, scenario_5g, time_duration, initial_SOC);

%% 4. 屏幕单独作用（中等亮度）
fprintf('  - 分析屏幕耗电...\n');
scenario_screen = base_scenario;
scenario_screen.screen_on = 1;
scenario_screen.brightness = 128;
[SOC_screen, power_screen, ~] = simulate_battery_drain(params, scenario_screen, time_duration, initial_SOC);

%% 5. CPU单独作用（高负载）
fprintf('  - 分析CPU耗电...\n');
scenario_cpu = base_scenario;
scenario_cpu.cpu_usage = 0.8;
[SOC_cpu, power_cpu, ~] = simulate_battery_drain(params, scenario_cpu, time_duration, initial_SOC);

%% 6. GPS单独作用
fprintf('  - 分析GPS耗电...\n');
scenario_gps = base_scenario;
scenario_gps.gps_freq = 60;  % 每分钟60次
[SOC_gps, power_gps, ~] = simulate_battery_drain(params, scenario_gps, time_duration, initial_SOC);

%% 7. 后台任务单独作用
fprintf('  - 分析后台任务耗电...\n');
scenario_background = base_scenario;
scenario_background.background_activity = 1.0;
[SOC_background, power_background, ~] = simulate_battery_drain(params, scenario_background, time_duration, initial_SOC);

%% 绘制单因素对比图
figure('Name', '单因素耗电分析', 'Position', [100, 100, 1200, 800]);

% 计算每个因素的耗电量（百分比）
drain_wifi = initial_SOC - SOC_wifi(end);
drain_4g = initial_SOC - SOC_4g(end);
drain_5g = initial_SOC - SOC_5g(end);
drain_screen = initial_SOC - SOC_screen(end);
drain_cpu = initial_SOC - SOC_cpu(end);
drain_gps = initial_SOC - SOC_gps(end);
drain_background = initial_SOC - SOC_background(end);

% 子图1: 柱状图对比
subplot(2, 2, 1);
factors = {'WiFi', '4G', '5G', '屏幕', 'CPU', 'GPS', '后台任务'};
drains = [drain_wifi, drain_4g, drain_5g, drain_screen, drain_cpu, drain_gps, drain_background];
bar(drains, 'FaceColor', [0.2 0.6 0.8]);
set(gca, 'XTickLabel', factors);
ylabel('一小时耗电量 (%)');
title('各因素单独作用一小时耗电量对比');
grid on;
xtickangle(45);

% 子图2: WiFi vs 4G vs 5G
subplot(2, 2, 2);
time_vec = linspace(0, time_duration, length(SOC_wifi));
plot(time_vec, SOC_wifi, 'b-', 'LineWidth', 2); hold on;
plot(time_vec, SOC_4g, 'r-', 'LineWidth', 2);
plot(time_vec, SOC_5g, 'g-', 'LineWidth', 2);
xlabel('时间 (小时)');
ylabel('电量 (%)');
title('网络类型对比');
legend('WiFi', '4G', '5G', 'Location', 'best');
grid on;

% 子图3: 屏幕、CPU、GPS对比
subplot(2, 2, 3);
plot(time_vec, SOC_screen, 'm-', 'LineWidth', 2); hold on;
plot(time_vec, SOC_cpu, 'c-', 'LineWidth', 2);
plot(time_vec, SOC_gps, 'k-', 'LineWidth', 2);
xlabel('时间 (小时)');
ylabel('电量 (%)');
title('主要硬件组件对比');
legend('屏幕', 'CPU', 'GPS', 'Location', 'best');
grid on;

% 子图4: 平均功率对比
subplot(2, 2, 4);
avg_powers = [mean(power_wifi), mean(power_4g), mean(power_5g), ...
              mean(power_screen), mean(power_cpu), mean(power_gps), mean(power_background)];
bar(avg_powers, 'FaceColor', [0.8 0.4 0.2]);
set(gca, 'XTickLabel', factors);
ylabel('平均功率 (W)');
title('各因素平均功率消耗');
grid on;
xtickangle(45);

% 保存图片
saveas(gcf, '单因素耗电分析.png');
fprintf('单因素分析完成！图片已保存。\n');

end
