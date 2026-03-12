function [SOC, V_pol_history, I_history] = simulate_battery_drain_new(params, scenario, time_duration, initial_SOC)
% 使用Thevenin/Shepherd电化学模型模拟电池耗电
% 输入:
%   params - 参数结构体
%   scenario - 使用场景
%   time_duration - 模拟时长 (小时)
%   initial_SOC - 初始电量 (%)
% 输出:
%   SOC - 电量随时间变化 (%)
%   V_pol_history - 极化电压历史 (V)
%   I_history - 电流历史 (A)

% 时间步长
dt = 0.001;  % 小时 (约3.6秒)
dt_sec = dt * 3600;  % 转换为秒
time_steps = round(time_duration / dt);

% 初始化
SOC = zeros(1, time_steps);
SOC(1) = initial_SOC / 100;  % 转换为0-1
V_pol = params.V_pol_init;
V_pol_history = zeros(1, time_steps);
I_history = zeros(1, time_steps);

% 计算功率
P_total = calculate_total_power(params, scenario);

% 模拟电池耗电
for i = 1:time_steps-1
    % 当前SOC
    soc = SOC(i);
    
    % 开路电压 V_oc(SOC)
    V_oc = 3.7 + 0.15*soc + 0.05*log(soc) - 0.1*log(1-soc);
    
    % 极化电压微分方程: dV_pol/dt = -0.02*V_pol + 0.02*I
    % 需要先计算电流I
    % 从 V(t) = V_oc(SOC) - V_pol(t) - I(t)*R 和 P(t) = V(t)*I(t)
    % 得到 I 的二次方程: R*I^2 + (V_oc - V_pol)*I - P = 0
    a = params.R;
    b = V_oc - V_pol;
    c = -P_total;
    
    % 求解二次方程
    discriminant = b^2 - 4*a*c;
    if discriminant >= 0
        I = (-b + sqrt(discriminant)) / (2*a);  % 取正根
    else
        I = 0;  % 异常情况
    end
    
    % 更新极化电压
    dV_pol_dt = -0.02 * V_pol + 0.02 * I;
    V_pol = V_pol + dV_pol_dt * dt_sec;
    
    % 记录
    V_pol_history(i) = V_pol;
    I_history(i) = I;
    
    % 更新SOC: dSOC/dt = -I(t) / Q_max
    dSOC_dt = -I / (params.Q_max / 1000);  % Q_max从mAh转换为Ah
    SOC(i+1) = SOC(i) + dSOC_dt * dt;
    
    % 限制SOC范围
    if SOC(i+1) < 0
        SOC(i+1) = 0;
        break;
    elseif SOC(i+1) > 1
        SOC(i+1) = 1;
    end
end

% 最后一个点
V_pol_history(end) = V_pol;
I_history(end) = I;

% 转换SOC为百分比
SOC = SOC * 100;

end
