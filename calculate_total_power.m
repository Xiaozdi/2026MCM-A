function P_total = calculate_total_power(params, scenario)
% 根据新模型计算总功耗
% 输入:
%   params - 参数结构体
%   scenario - 场景结构体
% 输出:
%   P_total - 总功耗 (W)

T = params.T_ambient;  % 温度恒定为25°C

%% 1. 基础功耗 P_base(t)
P_base = params.P_base_25 * (1 + params.alpha_base * (T - 25));

%% 2. 屏幕功耗 P_OLED(t)
if scenario.screen_on == 1
    % 屏幕点亮
    L = scenario.brightness;  % 亮度级别
    % 像素级功耗
    P_pixel = 0.5 * L^2.2 * params.A_white * (1 + 0.0083 * (params.f_refresh - 60));
    P_OLED = P_pixel + params.P_circuit;
else
    % 屏幕关闭
    P_OLED = 0;
end

%% 3. CPU功耗 P_CPU(t)
% 动态功耗
P_dynamic = 0;
f_ratio = scenario.cpu_freq_ratio;  % 频率比例
for i = 1:params.N_cores
    U_i = scenario.cpu_usage;  % 简化：所有核心使用率相同
    P_dynamic = P_dynamic + params.P_core_i(i) * U_i^1.7 * f_ratio;
end
% 总CPU功耗
P_CPU = (params.P_static + P_dynamic) * (1 + params.alpha_CPU * (T - 25));

%% 4. 无线通信功耗 P_network(t)
A_network = scenario.network_activity;  % 网络活动强度
switch scenario.network_type
    case 'wifi'
        P_network = params.P_wifi_base + params.P_wifi_coef * A_network;
    case '4g'
        P_network = params.P_4g_base + params.P_4g_coef * A_network;
    case '5g'
        P_network = params.P_5g_base + params.P_5g_coef * A_network;
    otherwise
        P_network = 0;
end

%% 5. GPS功耗 P_GPS(t)
if scenario.gps_freq > 0
    lambda = scenario.gps_freq / 60;  % 转换为每秒次数
    P_GPS = lambda * params.T_session * params.P_on * 3600;  % 转换为W
else
    P_GPS = 0;
end

%% 6. 后台任务功耗 P_background(t)
R_background = scenario.background_activity;  % 后台活跃度 [1,10]
P_background = params.P_background_base * R_background;

%% 总功耗
P_total = P_base + P_OLED + P_CPU + P_network + P_GPS + P_background;

end
