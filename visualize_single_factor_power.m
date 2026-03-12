function visualize_single_factor_power(params)
% VISUALIZE_SINGLE_FACTOR_POWER - 可视化单个因素作用下的一小时耗电量
%
% 输入:
%   params - 参数结构体
%
% 输出:
%   生成6个子图，展示各因素单独作用下的功耗变化

    % 时间向量 (1小时)
    t = linspace(0, 3600, 3600);  % 0-3600秒，每秒一个点
    
    % 创建图形窗口
    figure('Position', [100, 100, 1400, 900]);
    set(gcf, 'Color', 'w');
    
    %% 子图1: 基础功耗 (待机)
    subplot(2, 3, 1);
    scenario = params.scenario.standby;
    P_standby = zeros(size(t));
    for i = 1:length(t)
        [P_total, ~] = calculate_power_consumption(t(i), params, scenario);
        P_standby(i) = P_total;
    end
    plot(t/60, P_standby, 'LineWidth', 2, 'Color', [0.2, 0.4, 0.8]);
    grid on;
    xlabel('时间 (分钟)', 'FontSize', 11);
    ylabel('功耗 (W)', 'FontSize', 11);
    title('(1) 待机模式功耗', 'FontSize', 12, 'FontWeight', 'bold');
    avg_power = mean(P_standby);
    energy_consumed = avg_power * 1;  % Wh
    text(30, max(P_standby)*0.9, sprintf('平均功耗: %.3f W\n一小时耗电: %.3f Wh', ...
        avg_power, energy_consumed), 'FontSize', 10);
    
    %% 子图2: 屏幕功耗 (网页浏览)
    subplot(2, 3, 2);
    scenario = params.scenario.browsing;
    P_browsing = zeros(size(t));
    for i = 1:length(t)
        [P_total, ~] = calculate_power_consumption(t(i), params, scenario);
        P_browsing(i) = P_total;
    end
    plot(t/60, P_browsing, 'LineWidth', 2, 'Color', [0.8, 0.4, 0.2]);
    grid on;
    xlabel('时间 (分钟)', 'FontSize', 11);
    ylabel('功耗 (W)', 'FontSize', 11);
    title('(2) 网页浏览功耗', 'FontSize', 12, 'FontWeight', 'bold');
    avg_power = mean(P_browsing);
    energy_consumed = avg_power * 1;
    text(30, max(P_browsing)*0.9, sprintf('平均功耗: %.3f W\n一小时耗电: %.3f Wh', ...
        avg_power, energy_consumed), 'FontSize', 10);
    
    %% 子图3: CPU功耗 (视频播放)
    subplot(2, 3, 3);
    scenario = params.scenario.video;
    P_video = zeros(size(t));
    for i = 1:length(t)
        [P_total, ~] = calculate_power_consumption(t(i), params, scenario);
        P_video(i) = P_total;
    end
    plot(t/60, P_video, 'LineWidth', 2, 'Color', [0.2, 0.8, 0.4]);
    grid on;
    xlabel('时间 (分钟)', 'FontSize', 11);
    ylabel('功耗 (W)', 'FontSize', 11);
    title('(3) 视频播放功耗', 'FontSize', 12, 'FontWeight', 'bold');
    avg_power = mean(P_video);
    energy_consumed = avg_power * 1;
    text(30, max(P_video)*0.9, sprintf('平均功耗: %.3f W\n一小时耗电: %.3f Wh', ...
        avg_power, energy_consumed), 'FontSize', 10);
    
    %% 子图4: 网络功耗 (游戏)
    subplot(2, 3, 4);
    scenario = params.scenario.gaming;
    P_gaming = zeros(size(t));
    for i = 1:length(t)
        [P_total, ~] = calculate_power_consumption(t(i), params, scenario);
        P_gaming(i) = P_total;
    end
    plot(t/60, P_gaming, 'LineWidth', 2, 'Color', [0.8, 0.2, 0.4]);
    grid on;
    xlabel('时间 (分钟)', 'FontSize', 11);
    ylabel('功耗 (W)', 'FontSize', 11);
    title('(4) 游戏模式功耗', 'FontSize', 12, 'FontWeight', 'bold');
    avg_power = mean(P_gaming);
    energy_consumed = avg_power * 1;
    text(30, max(P_gaming)*0.9, sprintf('平均功耗: %.3f W\n一小时耗电: %.3f Wh', ...
        avg_power, energy_consumed), 'FontSize', 10);
    
    %% 子图5: GPS功耗 (导航)
    subplot(2, 3, 5);
    scenario = params.scenario.navigation;
    P_navigation = zeros(size(t));
    for i = 1:length(t)
        [P_total, ~] = calculate_power_consumption(t(i), params, scenario);
        P_navigation(i) = P_total;
    end
    plot(t/60, P_navigation, 'LineWidth', 2, 'Color', [0.6, 0.2, 0.8]);
    grid on;
    xlabel('时间 (分钟)', 'FontSize', 11);
    ylabel('功耗 (W)', 'FontSize', 11);
    title('(5) 导航模式功耗', 'FontSize', 12, 'FontWeight', 'bold');
    avg_power = mean(P_navigation);
    energy_consumed = avg_power * 1;
    text(30, max(P_navigation)*0.9, sprintf('平均功耗: %.3f W\n一小时耗电: %.3f Wh', ...
        avg_power, energy_consumed), 'FontSize', 10);
    
    %% 子图6: 所有场景对比
    subplot(2, 3, 6);
    hold on;
    plot(t/60, P_standby, 'LineWidth', 2, 'DisplayName', '待机');
    plot(t/60, P_browsing, 'LineWidth', 2, 'DisplayName', '网页浏览');
    plot(t/60, P_video, 'LineWidth', 2, 'DisplayName', '视频播放');
    plot(t/60, P_gaming, 'LineWidth', 2, 'DisplayName', '游戏');
    plot(t/60, P_navigation, 'LineWidth', 2, 'DisplayName', '导航');
    hold off;
    grid on;
    xlabel('时间 (分钟)', 'FontSize', 11);
    ylabel('功耗 (W)', 'FontSize', 11);
    title('(6) 各场景功耗对比', 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'best', 'FontSize', 9);
    
    % 总标题
    sgtitle('Moto G60 各使用场景一小时功耗分析', 'FontSize', 14, 'FontWeight', 'bold');
    
    % 保存图片
    saveas(gcf, 'MATLAB/MCM_MotoG60_Battery/单因素功耗分析.png');
    fprintf('单因素功耗分析图已保存\n');
end
