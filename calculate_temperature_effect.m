function [T_new, P_corrected] = calculate_temperature_effect(params, P_total, T_current, dt)
% 计算温度变化及其对功耗的影响
% 输入:
%   params - 参数结构体
%   P_total - 当前总功率 (W)
%   T_current - 当前温度 (K)
%   dt - 时间步长 (小时)
% 输出:
%   T_new - 新温度 (K)
%   P_corrected - 温度修正后的功率 (W)

% 热动力学方程：dT/dt = (P_heat - P_dissipation) / (m * c)
% P_heat: 发热功率（来自CPU和基础功耗）
% P_dissipation: 散热功率

% 发热功率（假设CPU和基础功耗的80%转化为热量）
P_heat = P_total * 0.8;

% 散热功率（牛顿冷却定律）：P_dissipation = h * A * (T - T_ambient)
P_dissipation = params.h * params.A * (T_current - params.T_ambient);

% 温度变化率 (K/s)
dT_dt = (P_heat - P_dissipation) / (params.m * params.c);

% 转换为 K/h
dT_dt_hour = dT_dt * 3600;

% 更新温度
T_new = T_current + dT_dt_hour * dt;

% 限制温度范围（防止过热或过冷）
T_new = max(params.T_ambient, min(T_new, params.T_ambient + 40));  % 最高升温40K

% 温度对功耗的影响
% 温度每升高10K，功耗增加约5%（基于经验公式）
delta_T = T_new - params.T_ambient;
temp_factor = 1 + 0.005 * delta_T;  % 温度修正系数

% 修正后的功率
P_corrected = P_total * temp_factor;

end
