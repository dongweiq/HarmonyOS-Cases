# 柱状图方案

### 介绍

本示例主要介绍如何使用三方库mpchart实现柱状图UI效果。如堆叠数据类型显示，Y轴是否显示，左Y轴位置，右Y轴位置，是否显示X轴，是否绘制背景色，是否设置MarkerView等。

### 效果图预览

<img src="../../screenshots/device/BarChart.gif">

**使用说明**

1. 点击页面上控制项即可查看效果。需要注意的是选项”是否设置MarkerView“勾选后，点击柱状图中柱子会有弹窗效果。

### 实现思路

1. 通过this.model = new BarChartModel()初始化图表配置构建类。
2. 配置图表指定样式，为图表添加数据选择的监听器。
3. 通过this.model.setData(this.data)将数据与图表配置类绑定。
4. 通过BarChart({ model: this.model })为组件设置配置构建类。

### 高性能知识点

**不涉及**

### 工程结构&模块类型

   ```
   barchart                                        // har类型
   |---src\main\ets\view
   |   |---BarChart.ets                            // 视图层-柱状图页面 
   ```

### 模块依赖

1. 本模块依赖[mpchart三方库](https://gitee.com/openharmony-sig/ohos-MPChart)。

### 参考资料

[图表三方库mpchart](https://gitee.com/openharmony-sig/ohos-MPChart)