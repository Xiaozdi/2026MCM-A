function simulate_comprehensive_scenario(params)
% 综合场景模拟：模拟一天中不同活动的电池消耗
% 场景分配：
%   - 20% 时间待机
%   - 20% 时间浏览网页
%   - 20% 时间看视频
%   - 20% 时间玩游戏
%   - 20% 时间导航

fprintf('开始综合场景模拟...\n');

% 总时间设置（改为2.5小时，每个场景0.5小时）
total_time = 2.5;  % 总共2.5小时
segment_time = total_time / 5;  % 每个场景0.5小时

% 初始电量
initial_SOC = 100;

% 时间步长
dt = 0.001;  % 小时
time_steps_per_segment = round(segment_time / dt);
total_steps = time_steps_per_segment * 5;

% 初始化数组
time_vec = zeros(1, total_steps);
SOC_vec = zeros(1, total_steps);
power_vec = zeros(1, total_steps);
temp_vec = zeros(1, total_steps);
scenario_labels = cell(1, total_steps);

% 当前索引
idx = 1;
current_SOC = initial_SOC;

%% 场景1: 待机 (0-0.5小时)
fprintf('  场景1: 待机 (0-0.5小时)...\n');
[SOC_idle, power_idle, temp_idle] = simulate_battery_drain(params, params.scenario_idle, segment_time, current_SOC);
time_segment = linspace(0, segment_time, length(SOC_idle));
time_vec(idx:idx+length(SOC_idle)-1) = time_segment;
SOC_vec(idx:idx+length(SOC_idle)-1) = SOC_idle;
power_vec(idx:idx+length(SOC_idle)-1) = power_idle;
temp_vec(idx:idx+length(SOC_idle)-1) = temp_idle;
scenario_labels(idx:idx+length(SOC_idle)-1) = {'待机'};
idx = idx + length(SOC_idle);
current_SOC = SOC_idle(end);

%% 场景2: 浏览网页 (0.5-1小时)
fprintf('  场景2: 浏览网页 (0.5-1小时)...\n');
[SOC_browsing, power_browsing, temp_browsing] = simulate_battery_drain(params, params.scenario_browsing, segment_time, current_SOC);
time_segment = linspace(segment_time, 2*segment_time, length(SOC_browsing));
time_vec(idx:idx+length(SOC_browsing)-1) = time_segment;
SOC_vec(idx:idx+length(SOC_browsing)-1) = SOC_browsing;
power_vec(idx:idx+length(SOC_browsing)-1) = power_browsing;
temp_vec(idx:idx+length(SOC_browsing)-1) = temp_browsing;
scenario_labels(idx:idx+length(SOC_browsing)-1) = {'浏览网页'};
idx = idx + length(SOC_browsing);
current_SOC = SOC_browsing(end);

%% 场景3: 看视频 (1-1.5小时)
fprintf('  场景3: 看视频 (1-1.5小时)...\n');
[SOC_video, power_video, temp_video] = simulate_battery_drain(params, params.scenario_video, segment_time, current_SOC);
time_segment = linspace(2*segment_time, 3*segment_time, length(SOC_video));
time_vec(idx:idx+length(SOC_video)-1) = time_segment;
SOC_vec(idx:idx+length(SOC_video)-1) = SOC_video;
power_vec(idx:idx+length(SOC_video)-1) = power_video;
temp_vec(idx:idx+length(SOC_video)-1) = temp_video;
scenario_labels(idx:idx+length(SOC_video)-1) = {'看视频'};
idx = idx + length(SOC_video);
current_SOC = SOC_video(end);

%% 场景4: 玩游戏 (1.5-2小时)
fprintf('  场景4: 玩游戏 (1.5-2小时)...\n');
[SOC_gaming, power_gaming, temp_gaming] = simulate_battery_drain(params, params.scenario_gaming, segment_time, current_SOC);
time_segment = linspace(3*segment_time, 4*segment_time, length(SOC_gaming));
time_vec(idx:idx+length(SOC_gaming)-1) = time_segment;
SOC_vec(idx:idx+length(SOC_gaming)-1) = SOC_gaming;
power_vec(idx:idx+length(SOC_gaming)-1) = power_gaming;
temp_vec(idx:idx+length(SOC_gaming)-1) = temp_gaming;
scenario_labels(idx:idx+length(SOC_gaming)-1) = {'玩游戏'};
idx = idx + length(SOC_gaming);
current_SOC = SOC_gaming(end);

%% 场景5: 导航 (2-2.5小时)
fprintf('  场景5: 导航 (2-2.5小时)...\n');
[SOC_navigation, power_navigation, temp_navigation] = simulate_battery_drain(params, params.scenario_navigation, segment_time, current_SOC);
time_segment = linspace(4*segment_time, 5*segment_time, length(SOC_navigation));
time_vec(idx:idx+length(SOC_navigation)-1) = time_segment;
SOC_vec(idx:idx+length(SOC_navigation)-1) = SOC_navigation;
power_vec(idx:idx+length(SOC_navigation)-1) = power_navigation;
temp_vec(idx:idx+length(SOC_navigation)-1) = temp_navigation;
scenario_labels(idx:idx+length(SOC_navigation)-1) = {'导航'};
current_SOC = SOC_navigation(end);

%% 绘制综合场景图
figure('Name', '综合使用场景模拟', 'Position', [100, 100, 1400, 1000]);

% 子图1: SOC随时间变化
subplot(4, 1, 1);
plot(time_vec, SOC_vec, 'b-', 'LineWidth', 2);
hold on;
% 添加场景分界线
for i = 1:4
    xline(i*segment_time, '--k', 'LineWidth', 1.5);
end
xlabel('时间 (小时)');
ylabel('电量 SOC (%)');
title('综合场景下电池电量变化');
grid on;
ylim([0 100]);

% 添加场景标注
text(segment_time/2, 95, '待机', 'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
text(segment_time*1.5, 95, '浏览网页', 'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
text(segment_time*2.5, 95, '看视频', 'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
text(segment_time*3.5, 95, '玩游戏', 'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
text(segment_time*4.5, 95, '导航', 'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');

% 子图2: 功率消耗
subplot(4, 1, 2);
plot(time_vec, power_vec, 'r-', 'LineWidth', 2);
hold on;
for i = 1:4
    xline(i*segment_time, '--k', 'LineWidth', 1.5);
end
xlabel('时间 (小时)');
ylabel('功率 (W)');
title('各场景功率消耗（含温度修正）');
grid on;

% 子图3: 温度变化
subplot(4, 1, 3);
plot(time_vec, temp_vec - 273.15, 'g-', 'LineWidth', 2);  % 转换为摄氏度
hold on;
for i = 1:4
    xline(i*segment_time, '--k', 'LineWidth', 1.5);
end
yline(25, '--b', '环境温度', 'LineWidth', 1.5);
xlabel('时间 (小时)');
ylabel('温度 (°C)');
title('手机温度变化');
grid on;

% 子图4: 各场景耗电量对比
subplot(4, 1, 4);
drain_idle = initial_SOC - SOC_idle(end);
drain_browsing = SOC_idle(end) - SOC_browsing(end);
drain_video = SOC_browsing(end) - SOC_video(end);
drain_gaming = SOC_video(end) - SOC_gaming(end);
drain_navigation = SOC_gaming(end) - SOC_navigation(end);

scenarios = {'待机', '浏览网页', '看视频', '玩游戏', '导航'};
drains = [drain_idle, drain_browsing, drain_video, drain_gaming, drain_navigation];
colors_bar = [0.7 0.7 0.7; 0.2 0.6 0.8; 0.8 0.4 0.2; 0.8 0.2 0.2; 0.4 0.8 0.4];

bar(drains, 'FaceColor', 'flat', 'CData', colors_bar);
set(gca, 'XTickLabel', scenarios);
ylabel('耗电量 (%)');
title('各场景30分钟耗电量对比');
grid on;
xtickangle(45);

% 在柱状图上标注数值
for i = 1:length(drains)
    text(i, drains(i)+0.5, sprintf('%.1f%%', drains(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
end

% 保存图片
saveas(gcf, '综合场景模拟.png');

%% 打印统计信息
fprintf('\n综合场景模拟结果:\n');
fprintf('  初始电量: %.1f%%\n', initial_SOC);
fprintf('  最终电量: %.1f%%\n', current_SOC);
fprintf('  总耗电量: %.1f%%\n', initial_SOC - current_SOC);
fprintf('  最高温度: %.1f°C\n', max(temp_vec) - 273.15);
fprintf('\n各场景耗电量 (30分钟):\n');
fprintf('  待机: %.1f%%\n', drain_idle);
fprintf('  浏览网页: %.1f%%\n', drain_browsing);
fprintf('  看视频: %.1f%%\n', drain_video);
fprintf('  玩游戏: %.1f%%\n', drain_gaming);
fprintf('  导航: %.1f%%\n', drain_navigation);

fprintf('\n综合场景模拟完成！\n');

end
