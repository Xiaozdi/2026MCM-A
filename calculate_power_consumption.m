function [P_total, P_components] = calculate_power_consumption(t, params, scenario)
% CALCULATE_POWER_CONSUMPTION - 计算总功耗及各组件功耗
% 
% 输入:
%   t - 时间 (秒)
%   params - 参数结构体
%   scenario - 场景参数结构体
%
% 输出:
%   P_total - 总功耗 (W)
%   P_components - 各组件功耗结构体

    % 当前温度 (简化模型，假设温度随使用强度变化)
    T = params.T_ambient + 10 * (scenario.cpu_load + scenario.brightness * scenario.screen_on) / 2;
    
    %% (1) 基础功耗 P_base
    P_base = params.P_base_25 * (1 + params.alpha_base * (T - 25));
    
    %% (2) 屏幕功耗 P_OLED
    if scenario.screen_on == 1
        % 像素功耗
        L = scenario.brightness;  % 亮度 [0,1]
        A_white = params.screen_area;  % 屏幕面积
        f_refresh = params.refresh_rate;  % 刷新率
        
        P_pixel = params.pixel_power_coef * L^2.2 * A_white * ...
                  (1 + 0.0083 * (f_refresh - 60));
        
        P_OLED = P_pixel + params.P_circuit;
    else
        P_OLED = 0;
    end
    
    %% (3) CPU功耗 P_CPU
    % 静态功耗
    P_CPU_static = params.P_static;
    
    % 动态功耗
    P_CPU_dynamic = 0;
    f_i = scenario.cpu_load;  % CPU负载 [0,1]
    U_i = 1.0;  % 电压利用率
    
    for i = 1:params.N_cores
        P_CPU_dynamic = P_CPU_dynamic + params.P_core(i) * U_i^1.7 * (f_i / params.f_max);
    end
    
    % 总CPU功耗（含温度修正）
    P_CPU = (P_CPU_static + P_CPU_dynamic) * (1 + params.alpha_CPU * (T - 25));
    
    %% (4) 网络功耗 P_network
    A_network = scenario.network_activity;  % 网络活动强度 [0,1]
    
    switch scenario.network_type
        case 'wifi'
            P_tech = params.P_wifi_base + params.P_wifi_coef * A_network;
        case '4G'
            P_tech = params.P_4G_base + params.P_4G_coef * A_network;
        case '5G'
            P_tech = params.P_5G_base + params.P_5G_coef * A_network;
        otherwise
            P_tech = params.P_wifi_base + params.P_wifi_coef * A_network;
    end
    
    P_network = P_tech;
    
    %% (5) GPS功耗 P_GPS
    if scenario.gps_active == 1
        P_GPS = params.lambda_GPS * params.T_session * params.P_GPS_on / 60;
    else
        P_GPS = 0;
    end
    
    %% (6) 后台任务功耗 P_background
    R_background = scenario.background_load;  % 后台任务活跃度 [1,10]
    P_background = params.P_background_base * R_background;
    
    %% 总功耗
    P_total = P_base + P_OLED + P_CPU + P_network + P_GPS + P_background;
    
    %% 输出各组件功耗
    P_components.P_base = P_base;
    P_components.P_OLED = P_OLED;
    P_components.P_CPU = P_CPU;
    P_components.P_network = P_network;
    P_components.P_GPS = P_GPS;
    P_components.P_background = P_background;
    P_components.temperature = T;
end
