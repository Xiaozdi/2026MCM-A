# 智能手机电池耗电模型 - Moto G60

## 声明

本仓库用于整理并保存 **2026 MCM Problem A** 相关建模工作的部分程序与说明材料。需特别说明的是，由于原始项目文件在后期存储与迁移过程中发生缺失，完整工程中原有的 **80 余份代码文件** 目前仅保留下图示及仓库中所列出的部分脚本。因此，当前仓库所包含内容仅为原项目实现的**部分留存版本**，并不构成完整的论文配套代码，也不能视为对最终参赛成果的完全复现。

从研究内容上看，原论文工作建立的是一个面向智能手机电池耗电过程的**连续时间微分方程模型**，内容涵盖电池状态演化、电化学等效建模、硬件级功耗分解、温度与老化因素耦合、典型场景仿真、敏感性分析以及与真实测试数据的对比验证。当前仓库保留下来的代码主要对应其中的部分建模、仿真与可视化过程，能够反映原项目的方法框架与实现思路，但在模块完整性、参数覆盖范围、实验复现程度以及结果对应关系方面均存在明显限制。

因此，本仓库更适合作为 **2026 年 MCM A 题** 的阶段性建模记录与有限参考材料，用于展示原项目的部分数学建模思想、MATLAB 实现框架及结果可视化方法；若用于复现、比较、引用或进一步扩展，均应充分注意其**不完整性、阶段性与参考性**。

## 项目简介

本项目实现了2026 MCM Problem A的智能手机电池耗电连续时间数学模型，基于Moto G60手机参数进行建模和仿真。

## 模型描述

### 核心方程

电池状态（SOC）的微分方程：

```
dSOC/dt = -P_total(t) / C
```

其中：
- `SOC`: 电池剩余电量百分比 (%)
- `P_total(t)`: 总功率消耗 (W)
- `C`: 电池总能量容量 (Wh)

### 总功率模型

```
P_total = P_base + P_screen + P_cpu + P_network + P_gps + P_background
```

#### 1. 基础功耗 (P_base)
```
P_base = 0.5 W
```

#### 2. 屏幕功耗 (P_screen)
```
P_screen = δ_screen * (P_screen_base + α * B)
```
- `δ_screen`: 屏幕开关状态 (0或1)
- `P_screen_base`: 屏幕基础功耗 = 1.5 W
- `α`: 像素级功耗系数 = 0.02
- `B`: 亮度值 (0-255)

#### 3. CPU功耗 (P_cpu)
```
P_cpu = P_cpu_static + k * V² * f
```
- `P_cpu_static`: 静态功耗 = 0.3 W
- `k`: 动态功耗系数 = 1e-9
- `V`: 工作电压 = 1.2 V
- `f`: CPU频率 (Hz)

#### 4. 无线通信功耗 (P_network)
支持WiFi、4G、5G三种网络类型：
- WiFi: 空闲0.05W, 传输1.2W, 接收0.8W
- 4G: 空闲0.1W, 传输2.0W, 接收1.5W
- 5G: 空闲0.2W, 传输3.5W, 接收2.5W

#### 5. GPS功耗 (P_gps)
```
P_gps = P_gps_per_use * (n_gps / 60)
```
- `P_gps_per_use`: 每次使用功耗 = 0.5 W
- `n_gps`: 每分钟启动次数

#### 6. 后台任务功耗 (P_background)
```
P_background = P_background_base * (1 + β * A_background)
```
- `P_background_base`: 基础功耗 = 0.2 W
- `β`: 活跃度系数 = 0.5
- `A_background`: 后台活跃度 (0-1)

## 文件结构

```
MCM_Battery_Drain_Model/
├── main_battery_drain.m                    # 主程序
├── load_battery_parameters.m               # 参数加载
├── calculate_total_power.m                 # 功率计算
├── simulate_battery_drain.m                # 电池耗电模拟
├── single_factor_visualization.m           # 单因素可视化
├── plot_power_consumption_pie.m            # 饼状图绘制
├── simulate_comprehensive_scenario.m       # 综合场景模拟
└── README.md                               # 本文档
```

## 使用方法

### 1. 运行主程序

在MATLAB中运行：

```matlab
cd MATLAB/MCM_Battery_Drain_Model
main_battery_drain
```

### 2. 输出结果

程序将生成以下可视化结果：

1. **单因素耗电分析图** (`单因素耗电分析.png`)
   - 各因素单独作用一小时的耗电量对比
   - 网络类型对比（WiFi vs 4G vs 5G）
   - 主要硬件组件对比（屏幕、CPU、GPS）
   - 平均功率消耗对比

2. **耗电量饼状图** (`耗电量饼状图.png`)
   - 各组件功率消耗分布
   - 一小时耗电量分布

3. **综合场景模拟图** (`综合场景模拟.png`)
   - SOC随时间变化曲线
   - 各场景功率消耗
   - 各场景耗电量对比

## 使用场景定义

### 1. 待机场景
- 屏幕关闭
- CPU最低负载 (5%)
- WiFi连接，低活动 (10%)
- 无GPS
- 后台活动 (20%)

### 2. 浏览网页场景
- 屏幕开启，中等亮度 (128/255)
- CPU中等负载 (30%)
- WiFi连接，中等活动 (50%)
- 无GPS
- 后台活动 (30%)

### 3. 看视频场景
- 屏幕开启，较高亮度 (180/255)
- CPU较高负载 (50%)
- WiFi连接，高活动 (80%)
- 无GPS
- 后台活动 (20%)

### 4. 玩游戏场景
- 屏幕开启，最高亮度 (255/255)
- CPU高负载 (90%)
- 4G连接，中高活动 (60%)
- 无GPS
- 后台活动 (40%)

### 5. 导航场景
- 屏幕开启，最高亮度 (255/255)
- CPU中等负载 (40%)
- 4G连接，高活动 (70%)
- GPS高频使用 (60次/分钟)
- 后台活动 (30%)

## 模型参数

### Moto G60 手机参数
- 电池容量: 6000 mAh
- 标称电压: 4.26 V
- 总能量: 25.56 Wh
- 最大CPU频率: 2.3 GHz

## 主要发现

1. **耗电量排序**（单因素，1小时）：
   - 5G网络 > 屏幕 > 4G网络 > GPS > CPU > WiFi > 后台任务

2. **综合场景耗电**（2小时）：
   - 玩游戏耗电最多
   - 导航场景因GPS持续使用耗电较大
   - 待机耗电最少

3. **优化建议**：
   - 降低屏幕亮度可显著延长续航
   - 使用WiFi代替移动数据可节省电量
   - 关闭不必要的后台应用
   - 避免长时间使用GPS导航

## 扩展功能

可以通过修改参数或添加新场景来扩展模型：

```matlab
% 自定义场景
custom_scenario.screen_on = 1;
custom_scenario.brightness = 200;
custom_scenario.cpu_usage = 0.6;
custom_scenario.network_type = '5g';
custom_scenario.network_activity = 0.8;
custom_scenario.gps_freq = 30;
custom_scenario.background_activity = 0.5;

% 模拟
[SOC, power] = simulate_battery_drain(params, custom_scenario, 1, 100);
```

## 参考文献

1. 2026 MCM Problem A: Modeling Smartphone Battery Drain
2. Moto G60 技术规格
3. 锂离子电池特性研究

## 作者

MCM团队 - 2026

## 许可证

本项目仅用于学术研究和教育目的。
