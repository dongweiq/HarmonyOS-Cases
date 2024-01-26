# 柱状图方案

### 介绍

本示例主要介绍如何使用三方库mpchart实现柱状图UI效果。

### 效果图预览

![](../../screenshots/device/BarChart.gif)

**场景**

使用三方库mpchart可以实现柱状图UI效果。如堆叠数据类型显示，Y轴是否显示，左Y轴位置，右Y轴位置，是否显示X轴，是否绘制背景色，是否设置MarkerView等。具体代码可参考[BarChart.ets](./src/main/ets/view/BarChart.ets)。

柱状图实现的关键步骤如下：

1. 通过this.model = new BarChartModel()初始化图表配置构建类。

2. 配置图表指定样式，为图表添加数据选择的监听器。

3. 通过this.model.setData(this.data)将数据与图表配置类绑定。

4. 通过BarChart({ model: this.model })为组件设置配置构建类。

**使用说明**：

1. 点击页面上控制项即可查看效果。需要注意的是选项”是否设置MarkerView“勾选后，点击柱状图中柱子会有弹窗效果。

2. 如何需要在别的工程中使用，推荐使用在工程的oh-package.json5中设置mpchart三方包依赖，配置"dependencies": { "@ohos/mpchart": "3.0.0-rc.1"}。依赖设置完成后，需要在Terminal窗口中执行ohpm install命令安装依赖包，依赖包会存储在工程的oh_modules目录下。

3. 更多类型图表UI请查看三方库[mpchart](https://gitee.com/openharmony-sig/ohos-MPChart)。