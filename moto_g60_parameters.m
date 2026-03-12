function params = moto_g60_parameters()
% MOTO_G60_PARAMETERS - Moto G60 手机电池和硬件参数
% 基于 Moto G60 实际规格设置参数
%
% Moto G60 规格:
% - 电池容量: 6000 mAh (6 Ah)
% - 屏幕: 6.8英寸 FHD+ (2460x1080), IPS LCD, 120Hz
% - 处理器: Qualcomm Snapdragon 732G (8核)
% - 内存: 6GB RAM
% - 网络: 4G LTE, WiFi 5, Bluetooth 5.0, GPS

    %% 基本电池参数
    params.Q_max = 6.0;              % 最大电池容量 (Ah)
    params.V_nominal = 3.85;         % 标称电压 (V)
    params.R = 0.05;                 % 内阻 (Ω)
    
    %% 基础功耗 (待机)
    params.P_base_25 = 0.08;         % 25°C时基础功耗 (W) - 待机约80mW
    params.alpha_base = 0.015;       % 基础功耗温度系数
    
    %% 屏幕参数
    params.screen_diagonal = 6.8;    % 屏幕对角线尺寸 (英寸)
    params.screen_width = 2460;      % 屏幕宽度 (像素)
    params.screen_height = 1080;     % 屏幕高度 (像素)
    params.screen_area = params.screen_diagonal^2 * 0.5; % 屏幕面积估算
    params.refresh_rate = 120;       % 刷新率 (Hz)
    params.P_circuit = 0.15;         % 屏幕电路功耗 (W)
    
    % 像素功耗系数 (IPS LCD屏幕)
    params.pixel_power_coef = 0.5;   % 像素功耗系数
    
    %% CPU参数 (Snapdragon 732G - 8核处理器)
    params.N_cores = 8;              % CPU核心数
    params.P_static = 0.25;          % CPU静态功耗 (W)
    params.f_max = 2.3;              % 最大频率 (GHz)
    params.alpha_CPU = 0.02;         % CPU温度系数
    
    % 各核心功耗 (W) - Snapdragon 732G: 2x2.3GHz + 6x1.8GHz
    params.P_core = [
        0.45, 0.45,                  % 2个性能核心 (Kryo 470 Gold)
        0.25, 0.25, 0.25, 0.25, 0.25, 0.25  % 6个效率核心 (Kryo 470 Silver)
    ];
    
    %% 网络参数
    % WiFi (WiFi 5, 802.11ac)
    params.P_wifi_base = 0.05;       % WiFi基础功耗 (W)
    params.P_wifi_coef = 0.15;       % WiFi活动系数
    
    % 4G LTE
    params.P_4G_base = 0.12;         % 4G基础功耗 (W)
    params.P_4G_coef = 0.35;         % 4G活动系数
    
    % 5G (Moto G60不支持5G，但保留参数)
    params.P_5G_base = 0.18;         % 5G基础功耗 (W)
    params.P_5G_coef = 0.45;         % 5G活动系数
    
    %% GPS参数
    params.lambda_GPS = 1.0;         % GPS每分钟启动次数
    params.T_session = 60;           % GPS会话时长 (秒)
    params.P_GPS_on = 0.35;          % GPS开启功耗 (W)
    
    %% 后台任务参数
    params.P_background_base = 0.15; % 后台任务基础功耗 (W)
    
    %% 温度参数
    params.T_ambient = 25;           % 环境温度 (°C)
    params.T_initial = 25;           % 初始温度 (°C)
    
    %% 使用场景参数
    % 待机场景
    params.scenario.standby.screen_on = 0;
    params.scenario.standby.brightness = 0;
    params.scenario.standby.cpu_load = 0.05;
    params.scenario.standby.network_activity = 0.1;
    params.scenario.standby.network_type = 'wifi';
    params.scenario.standby.gps_active = 0;
    params.scenario.standby.background_load = 2;
    
    % 网页浏览场景
    params.scenario.browsing.screen_on = 1;
    params.scenario.browsing.brightness = 0.5;
    params.scenario.browsing.cpu_load = 0.3;
    params.scenario.browsing.network_activity = 0.6;
    params.scenario.browsing.network_type = 'wifi';
    params.scenario.browsing.gps_active = 0;
    params.scenario.browsing.background_load = 3;
    
    % 视频播放场景
    params.scenario.video.screen_on = 1;
    params.scenario.video.brightness = 0.7;
    params.scenario.video.cpu_load = 0.5;
    params.scenario.video.network_activity = 0.8;
    params.scenario.video.network_type = 'wifi';
    params.scenario.video.gps_active = 0;
    params.scenario.video.background_load = 2;
    
    % 游戏场景
    params.scenario.gaming.screen_on = 1;
    params.scenario.gaming.brightness = 0.8;
    params.scenario.gaming.cpu_load = 0.9;
    params.scenario.gaming.network_activity = 0.5;
    params.scenario.gaming.network_type = '4G';
    params.scenario.gaming.gps_active = 0;
    params.scenario.gaming.background_load = 4;
    
    % 导航场景
    params.scenario.navigation.screen_on = 1;
    params.scenario.navigation.brightness = 0.9;
    params.scenario.navigation.cpu_load = 0.4;
    params.scenario.navigation.network_activity = 0.7;
    params.scenario.navigation.network_type = '4G';
    params.scenario.navigation.gps_active = 1;
    params.scenario.navigation.background_load = 3;
    
    fprintf('Moto G60 参数加载完成\n');
    fprintf('电池容量: %.1f Ah\n', params.Q_max);
    fprintf('屏幕尺寸: %.1f 英寸\n', params.screen_diagonal);
    fprintf('处理器: Snapdragon 732G (%d核)\n', params.N_cores);
end
