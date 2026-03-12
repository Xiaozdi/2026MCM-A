function params = load_battery_parameters()
% 加载Moto G60手机的电池模型参数
% 基于Thevenin/Shepherd电化学模型

%% 基本电池参数
params.Q_max = 6000;  % 电池容量 (mAh) = 6Ah
params.voltage_nominal = 4.26;  % 标称电压 (V)

%% 电化学模型参数
params.R = 0.05;  % 内阻 (Ω)
params.V_pol_init = 0;  % 极化电压初始值 (V)

%% 温度参数（恒定25°C）
params.T_ambient = 25;  % 环境温度 (°C)
params.alpha_base = 0.001;  % 基础功耗温度系数
params.alpha_CPU = 0.002;  % CPU功耗温度系数

%% 1. 基础功耗参数
params.P_base_25 = 0.5;  % 25°C时的基础功耗 (W)

%% 2. 屏幕功耗参数 (OLED)
params.P_circuit = 0.3;  % 电路功耗 (W)
params.L = 255;  % 亮度级别 (0-255)
params.A_white = 1.0;  % 白色像素面积比例
params.f_refresh = 90;  % 刷新率 (Hz)

%% 3. CPU功耗参数
params.P_static = 0.3;  % 静态功耗 (W)
params.N_cores = 8;  % CPU核心数
params.P_core_i = [0.1, 0.1, 0.1, 0.1, 0.15, 0.15, 0.2, 0.2];  % 每个核心功耗系数
params.f_max = 2.3e9;  % 最大频率 (Hz)

%% 4. 无线通信功耗参数
% WiFi
params.P_wifi_base = 0.05;  % WiFi基础功耗 (W)
params.P_wifi_coef = 0.15;  % WiFi活动系数

% 4G
params.P_4g_base = 0.12;  % 4G基础功耗 (W)
params.P_4g_coef = 0.35;  % 4G活动系数

% 5G
params.P_5g_base = 0.18;  % 5G基础功耗 (W)
params.P_5g_coef = 0.45;  % 5G活动系数

%% 5. GPS功耗参数
params.P_on = 0.5;  % GPS单次启动功耗 (W)
params.T_session = 1/60;  % GPS使用时长 (小时)，默认1分钟

%% 6. 后台任务功耗参数
params.P_background_base = 0.2;  % 后台任务基础功耗 (W)

%% 使用场景参数定义
% 待机场景
params.scenario_idle.screen_on = 0;
params.scenario_idle.brightness = 0;
params.scenario_idle.cpu_usage = 0.05;
params.scenario_idle.cpu_freq_ratio = 0.3;  % 频率比例
params.scenario_idle.network_type = 'wifi';
params.scenario_idle.network_activity = 0.1;
params.scenario_idle.gps_freq = 0;
params.scenario_idle.background_activity = 1.0;  % R_background

% 浏览网页场景
params.scenario_browsing.screen_on = 1;
params.scenario_browsing.brightness = 128;
params.scenario_browsing.cpu_usage = 0.3;
params.scenario_browsing.cpu_freq_ratio = 0.5;
params.scenario_browsing.network_type = 'wifi';
params.scenario_browsing.network_activity = 0.5;
params.scenario_browsing.gps_freq = 0;
params.scenario_browsing.background_activity = 2.0;

% 看视频场景
params.scenario_video.screen_on = 1;
params.scenario_video.brightness = 180;
params.scenario_video.cpu_usage = 0.5;
params.scenario_video.cpu_freq_ratio = 0.6;
params.scenario_video.network_type = 'wifi';
params.scenario_video.network_activity = 0.8;
params.scenario_video.gps_freq = 0;
params.scenario_video.background_activity = 2.5;

% 玩游戏场景
params.scenario_gaming.screen_on = 1;
params.scenario_gaming.brightness = 255;
params.scenario_gaming.cpu_usage = 0.9;
params.scenario_gaming.cpu_freq_ratio = 0.95;
params.scenario_gaming.network_type = '4g';
params.scenario_gaming.network_activity = 0.6;
params.scenario_gaming.gps_freq = 0;
params.scenario_gaming.background_activity = 3.0;

% 导航场景
params.scenario_navigation.screen_on = 1;
params.scenario_navigation.brightness = 255;
params.scenario_navigation.cpu_usage = 0.4;
params.scenario_navigation.cpu_freq_ratio = 0.6;
params.scenario_navigation.network_type = '4g';
params.scenario_navigation.network_activity = 0.7;
params.scenario_navigation.gps_freq = 60;  % 每分钟60次
params.scenario_navigation.background_activity = 2.5;

fprintf('参数加载完成！\n');
fprintf('电池容量: %d mAh\n', params.Q_max);
fprintf('标称电压: %.2f V\n', params.voltage_nominal);
fprintf('环境温度: %.1f°C (恒定)\n', params.T_ambient);

end
