function visualize_power_pie_charts(params)
% VISUALIZE_POWER_PIE_CHARTS - 绘制各场景下功耗组成的饼状图
%
% 输入:
%   params - 参数结构体
%
% 输出:
%   生成5个饼状图，展示各场景下各组件功耗占比

    % 创建图形窗口
    figure('Position', [100, 100, 1400, 800]);
    set(gcf, 'Color', 'w');
    
    % 场景列表
    scenarios = {'standby', 'browsing', 'video', 'gaming', 'navigation'};
    scenario_names = {'待机模式', '网页浏览', '视频播放', '游戏模式', '导航模式'};
    
    % 颜色方案
    colors = [
        0.2, 0.4, 0.8;  % 基础功耗 - 蓝色
        0.8, 0.4, 0.2;  % 屏幕功耗 - 橙色
        0.2, 0.8, 0.4;  % CPU功耗 - 绿色
        0.8, 0.2, 0.4;  % 网络功耗 - 红色
        0.6, 0.2, 0.8;  % GPS功耗 - 紫色
        0.8, 0.8, 0.2;  % 后台功耗 - 黄色
    ];
    
    for i = 1:5
        subplot(2, 3, i);
        
        % 获取场景参数
        scenario = params.scenario.(scenarios{i});
        
        % 计算各组件功耗
        [~, P_components] = calculate_power_consumption(0, params, scenario);
        
        % 功耗数据
        power_data = [
            P_components.P_base;
            P_components.P_OLED;
            P_components.P_CPU;
            P_components.P_network;
            P_components.P_GPS;
            P_components.P_background
        ];
        
        % 标签
        labels = {
            sprintf('基础功耗\n%.3f W (%.1f%%)', P_components.P_base, ...
                P_components.P_base/sum(power_data)*100);
            sprintf('屏幕功耗\n%.3f W (%.1f%%)', P_components.P_OLED, ...
                P_components.P_OLED/sum(power_data)*100);
            sprintf('CPU功耗\n%.3f W (%.1f%%)', P_components.P_CPU, ...
                P_components.P_CPU/sum(power_data)*100);
            sprintf('网络功耗\n%.3f W (%.1f%%)', P_components.P_network, ...
                P_components.P_network/sum(power_data)*100);
            sprintf('GPS功耗\n%.3f W (%.1f%%)', P_components.P_GPS, ...
                P_components.P_GPS/sum(power_data)*100);
            sprintf('后台功耗\n%.3f W (%.1f%%)', P_components.P_background, ...
                P_components.P_background/sum(power_data)*100)
        };
        
        % 绘制饼图
        pie(power_data);
        colormap(colors);
        title(sprintf('%s\n总功耗: %.3f W', scenario_names{i}, sum(power_data)), ...
            'FontSize', 12, 'FontWeight', 'bold');
        
        % 添加图例（只在第一个子图添加）
        if i == 1
            legend({'基础功耗', '屏幕功耗', 'CPU功耗', '网络功耗', 'GPS功耗', '后台功耗'}, ...
                'Location', 'southoutside', 'Orientation', 'horizontal', 'FontSize', 9);
        end
    end
    
    % 第6个子图：功耗对比柱状图
    subplot(2, 3, 6);
    
    % 收集所有场景的功耗数据
    all_power_data = zeros(6, 5);
    total_powers = zeros(1, 5);
    
    for i = 1:5
        scenario = params.scenario.(scenarios{i});
        [~, P_components] = calculate_power_consumption(0, params, scenario);
        
        all_power_data(:, i) = [
            P_components.P_base;
            P_components.P_OLED;
            P_components.P_CPU;
            P_components.P_network;
            P_components.P_GPS;
            P_components.P_background
        ];
        
        total_powers(i) = sum(all_power_data(:, i));
    end
    
    % 绘制堆叠柱状图
    bar(all_power_data', 'stacked');
    colormap(colors);
    set(gca, 'XTickLabel', scenario_names);
    ylabel('功耗 (W)', 'FontSize', 11);
    title('各场景功耗组成对比', 'FontSize', 12, 'FontWeight', 'bold');
    legend({'基础', '屏幕', 'CPU', '网络', 'GPS', '后台'}, ...
        'Location', 'northwest', 'FontSize', 9);
    grid on;
    
    % 在柱状图上标注总功耗
    hold on;
    for i = 1:5
        text(i, total_powers(i) + 0.1, sprintf('%.2f W', total_powers(i)), ...
            'HorizontalAlignment', 'center', 'FontSize', 9, 'FontWeight', 'bold');
    end
    hold off;
    
    % 总标题
    sgtitle('Moto G60 各场景功耗组成分析', 'FontSize', 14, 'FontWeight', 'bold');
    
    % 保存图片
    saveas(gcf, 'MATLAB/MCM_MotoG60_Battery/功耗组成饼状图.png');
    fprintf('功耗组成饼状图已保存\n');
end
