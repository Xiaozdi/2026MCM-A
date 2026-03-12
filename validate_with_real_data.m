function validate_with_real_data(params)
% 使用实际数据验证模型
% 读取CSV文件，根据实际使用情况计算理论SOC，并与实际SOC对比

fprintf('开始读取实际数据并验证模型...\n');

% 读取CSV文件
csv_file = 'C:\Users\lenovo\Desktop\70a09b5174d07fff_20220512_dynamic_processed.csv';
data = readtable(csv_file);

fprintf('数据读取完成，共 %d 条记录\n', height(data));

% 提取关键列
timestamps = data.timestamp;
battery_level = data.battery_level;  % 实际SOC
screen_status = data.screen_status;
bright_level = data.bright_level;
cpu_usage = data.cpu_usage;
wifi_status = data.wifi_status;
gps_status = data.gps_status;
battery_temp = data.battery_temperature;

% 数据采样（每10秒一个数据点，采样间隔）
sample_interval = 10;  % 每10条数据取一条
indices = 1:sample_interval:height(data);
n_samples = length(indices);

% 初始化
time_hours = zeros(n_samples, 1);
SOC_actual = zeros(n_samples, 1);
SOC_theory = zeros(n_samples, 1);
temp_theory = zeros(n_samples, 1);

% 初始条件
SOC_theory(1) = battery_level(1);
T_current = params.T_ambient;
temp_theory(1) = T_current - 273.15;  % 转换为摄氏度

% 时间步长（秒转小时）
dt = sample_interval / 3600;  % 转换为小时

fprintf('开始模拟计算...\n');

for i = 1:n_samples
    idx = indices(i);
    
    % 记录实际SOC
    SOC_actual(i) = battery_level(idx);
    
    % 计算时间（小时）
    if i == 1
        time_hours(i) = 0;
    else
        time_hours(i) = time_hours(i-1) + dt;
    end
    
    % 如果不是第一个点，计算理论SOC
    if i > 1
        % 构建场景参数 - 根据实际状态判断
        
        % 1. 屏幕状态
        scenario.screen_on = screen_status(idx);
        if scenario.screen_on == 1
            scenario.brightness = bright_level(idx);
        else
            scenario.brightness = 0;
        end
        
        % 2. CPU使用率
        scenario.cpu_usage = cpu_usage(idx) / 100;  % 转换为0-1
        
        % 3. 网络状态 - 根据实际状态判断
        if wifi_status(idx) == 1
            % WiFi开启
            scenario.network_type = 'wifi';
            % 根据数据传输量判断活动强度
            if i > 1
                wifi_rx_rate = abs(data.wifi_rx(idx) - data.wifi_rx(indices(i-1)));
                wifi_tx_rate = abs(data.wifi_tx(idx) - data.wifi_tx(indices(i-1)));
                total_traffic = wifi_rx_rate + wifi_tx_rate;
                % 归一化网络活动强度（假设最大1MB/s）
                scenario.network_activity = min(1.0, total_traffic / 1000000);
            else
                scenario.network_activity = 0.1;
            end
        else
            % WiFi关闭，检查移动网络
            if data.mobile_status(idx) == 1
                % 移动网络开启
                if strcmp(data.network_mode(idx), '5G') || data.network_mode(idx) == 5
                    scenario.network_type = '5g';
                else
                    scenario.network_type = '4g';
                end
                % 根据移动数据传输量判断活动强度
                if i > 1
                    mobile_rx_rate = abs(data.mobile_rx(idx) - data.mobile_rx(indices(i-1)));
                    mobile_tx_rate = abs(data.mobile_tx(idx) - data.mobile_tx(indices(i-1)));
                    total_traffic = mobile_rx_rate + mobile_tx_rate;
                    scenario.network_activity = min(1.0, total_traffic / 1000000);
                else
                    scenario.network_activity = 0.1;
                end
            else
                % 无网络连接
                scenario.network_type = 'none';
                scenario.network_activity = 0;
            end
        end
        
        % 4. GPS状态
        if gps_status(idx) == 1
            % GPS开启，根据gps_activity判断使用频率
            gps_activity = data.gps_activity(idx);
            if gps_activity > 0
                scenario.gps_freq = 60;  % 高频使用
            else
                scenario.gps_freq = 10;  % 低频使用
            end
        else
            scenario.gps_freq = 0;
        end
        
        % 5. 后台活动 - 根据RAM和CPU使用情况估算
        ram_usage_ratio = data.ram_usage(idx) / (data.ram_usage(idx) + data.ram_free(idx));
        % 后台活动强度与RAM使用率和CPU使用率相关
        scenario.background_activity = (ram_usage_ratio + scenario.cpu_usage) / 2;
        
        % 计算功率
        P_base = calculate_total_power(params, scenario);
        
        % 考虑温度影响
        [T_new, P_corrected] = calculate_temperature_effect(params, P_base, T_current, dt);
        
        % 更新理论SOC
        dSOC_dt = -P_corrected / params.total_energy * 100;
        SOC_theory(i) = SOC_theory(i-1) + dSOC_dt * dt;
        
        % 限制范围
        SOC_theory(i) = max(0, min(100, SOC_theory(i)));
        
        % 更新温度
        T_current = T_new;
        temp_theory(i) = T_current - 273.15;
    end
    
    % 显示进度
    if mod(i, 100) == 0
        fprintf('  进度: %d/%d (%.1f%%)\n', i, n_samples, i/n_samples*100);
    end
end

fprintf('模拟计算完成！\n');

%% 绘制对比图
figure('Name', '理论与实际SOC对比', 'Position', [100, 100, 1400, 900]);

% 子图1: SOC对比
subplot(3, 1, 1);
plot(time_hours, SOC_actual, 'b-', 'LineWidth', 2, 'DisplayName', '实际SOC');
hold on;
plot(time_hours, SOC_theory, 'r--', 'LineWidth', 2, 'DisplayName', '理论SOC');
xlabel('时间 (小时)');
ylabel('电量 (%)');
title('实际SOC与理论SOC对比');
legend('Location', 'best');
grid on;

% 子图2: SOC误差
subplot(3, 1, 2);
error = SOC_theory - SOC_actual;
plot(time_hours, error, 'g-', 'LineWidth', 1.5);
hold on;
yline(0, '--k', 'LineWidth', 1);
xlabel('时间 (小时)');
ylabel('误差 (%)');
title('理论SOC与实际SOC的误差');
grid on;

% 子图3: 温度对比
subplot(3, 1, 3);
% 实际温度（如果有）
actual_temp = battery_temp(indices);
plot(time_hours, actual_temp, 'b-', 'LineWidth', 2, 'DisplayName', '实际温度');
hold on;
plot(time_hours, temp_theory, 'r--', 'LineWidth', 2, 'DisplayName', '理论温度');
xlabel('时间 (小时)');
ylabel('温度 (°C)');
title('实际温度与理论温度对比');
legend('Location', 'best');
grid on;

% 保存图片
saveas(gcf, '理论与实际对比.png');

%% 计算统计指标
mae = mean(abs(error));  % 平均绝对误差
rmse = sqrt(mean(error.^2));  % 均方根误差
max_error = max(abs(error));  % 最大误差

fprintf('\n模型验证结果:\n');
fprintf('  平均绝对误差 (MAE): %.2f%%\n', mae);
fprintf('  均方根误差 (RMSE): %.2f%%\n', rmse);
fprintf('  最大误差: %.2f%%\n', max_error);
fprintf('  初始SOC: %.1f%%\n', SOC_actual(1));
fprintf('  最终实际SOC: %.1f%%\n', SOC_actual(end));
fprintf('  最终理论SOC: %.1f%%\n', SOC_theory(end));

fprintf('\n验证完成！图片已保存为 理论与实际对比.png\n');

end
