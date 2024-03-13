/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import {
  BarChart, // 柱状图图表类
  BarChartModel, // 柱状图配置构建类
  BarData, // 柱状图数据包
  BarDataSet, // 柱状图数据集合
  BarEntry, // 柱状图数据结构
  Description, // 图表Description(描述)部件
  IAxisValueFormatter, // 图表高亮数据
  IBarDataSet, // 柱状图数据集合的操作类
  JArrayList, // 工具类：数据集合
  Legend, // 图表Legend(图例)部件
  LimitLabelPosition, // 图表的LimitLine标签位置枚举类
  LimitLine, // 图表LimitLine
  MarkerView, // 图表的Marker(标志气泡)部件
  XAxis, // 图表X轴部件
  XAxisPosition, // 图表X轴标签位置枚举类
  YAxis, // 图表Y轴部件
  ChartColor as Colors
} from '@ohos/mpchart';

const GRID_BG_COLOR: string = '#FFFBF9EC';
const STEP_TARGET: string = '目标 250';
const STEP_TARGET_NUMBER: number = 250;
const CALORIE: string = '卡路里';
const VISIBLE_VALUE_COUNT: number = 7;
const LINE_WIDTH: number = 2;
const DASHED_LINE_LENGTH: number = 20;
const DASHED_SPACE_LENGTH: number = 3;
const TEXT_SIZE: number = 16;
const ZERO: number = 0;
const LABEL_COUNT: number = 7;
const BAR_WIDTH: number = 0.3;

/**
 * 场景描述：当前组件为柱状图组件 BarChartModel。
 * 构造新的对象模型后通过模型的方法设置属性。
 * 具体实现见aboutToAppear内注释。
 */
@Component
export struct BarCharts {
  @Prop calorieData: Array<number | null> = [233, 285, 458, 268, 237, 278, 407]; // 卡路里数据
  model: BarChartModel | null = null; // 柱状图模型
  private leftAxis: YAxis | null = null; // 左侧Y轴数据
  private rightAxis: YAxis | null = null; // 右侧Y轴数据
  private xAxis: XAxis | null = null; // X轴数据
  data: BarData | null = null; // 柱状图数据
  limitLine: LimitLine | null = null; // 限制线类型

  // 图表数据初始化
  aboutToAppear() {
    // TODO 知识点：必须初始化图表配置构建类
    this.model = new BarChartModel();
    this.model.setPinchZoom(false);
    // TODO 知识点：配置图表指定样式，各部件间没有先后之分
    // 获取图表描述部件，设置图表描述部件不可用，即图表不进行绘制描述部件
    let description: Description | null = this.model.getDescription();
    if (description) {
      description.setEnabled(false);
    }
    // 获取图表图例部件，设置图表图例部件不可用
    let legend: Legend | null = this.model.getLegend();
    if (legend) {
      legend.setEnabled(false);
    }
    // 设置图表数据最大的绘制数，如果超过该数值，则不进行绘制图表的数值标签
    this.model.setMaxVisibleValueCount(VISIBLE_VALUE_COUNT);
    // 是否绘制图表的背景色，绘制范围为图表柱状图的绘制范围，不包含轴线之外的部分
    this.model.setDrawGridBackground(true);
    // 设置图表的背景色，颜色的规格需要满足CanvasRenderingContext2D.fillstyle/strokestyle规格
    this.model.setGridBackgroundColor(GRID_BG_COLOR);
    // 设置不绘制柱状图的柱体阴影背景
    this.model.setDrawBarShadow(false);
    // 设置柱状图的数值在柱体上方
    this.model.setDrawValueAboveBar(true);
    // 设置柱状图的高亮范围是否为整个柱体，只在堆叠柱状图中有区别
    this.model.setHighlightFullBarEnabled(true);
    // 为左Y轴设置LimitLine,可设置限制线的宽度，线段样式，限制标签的位置，标签字体大小等
    this.limitLine = new LimitLine(STEP_TARGET_NUMBER, STEP_TARGET);
    // 设置限制线的宽度
    this.limitLine.setLineWidth(LINE_WIDTH);
    // 设置限制线虚线类型的长度
    this.limitLine.enableDashedLine(DASHED_LINE_LENGTH, DASHED_SPACE_LENGTH, ZERO);
    // 设置限制线的颜色
    this.limitLine.setLineColor(Color.Gray);
    // 设置限制线的位置
    this.limitLine.setLabelPosition(LimitLabelPosition.RIGHT_TOP);
    // 设置限制线上文本的大小
    this.limitLine.setTextSize(vp2px(TEXT_SIZE));
    // 设置图表左Y轴信息
    this.leftAxis = this.model.getAxisLeft();
    if (this.leftAxis) {
      // 设置图表左Y轴最小值
      this.leftAxis.setAxisMinimum(ZERO);
      // 设置图表左Y轴是否在数据后绘制限制线
      this.leftAxis.setDrawLimitLinesBehindData(false);
      // 设置图表左Y轴数据的格式转换器
      this.leftAxis.setValueFormatter(new YValueFormatter());
      // 添加LimitLines
      this.leftAxis.addLimitLine(this.limitLine);
    }
    // 设置图表右Y轴信息
    this.rightAxis = this.model.getAxisRight();
    if (this.rightAxis) {
      // 设置图表右Y轴是否显示
      this.rightAxis.setEnabled(false);
      // 设置图表右Y轴最小值
      this.rightAxis.setAxisMinimum(ZERO);
    }
    // 设置X轴信息
    this.xAxis = this.model.getXAxis();
    if (this.xAxis) {
      // 设置X轴是否绘制网格线
      this.xAxis.setDrawGridLines(false);
      // 设置绘制标签个数
      this.xAxis.setLabelCount(LABEL_COUNT, false);
      //设置标签位置
      this.xAxis.setPosition(XAxisPosition.BOTTOM);
      // 设置数据的格式转换器
      this.xAxis.setValueFormatter(new XValueFormatter());
    }
    // //设置是否支持双击放大
    this.model.setDoubleTapToZoomEnabled(false);
    // 生成单一颜色数据
    this.data = this.getNormalData();
    // TODO 知识点：将数据与图表配置类绑定
    this.model.setData(this.data);
  }

  // 生成柱状图数据
  private getNormalData(): BarData {
    let start: number = 0;
    let values: JArrayList<BarEntry> = new JArrayList<BarEntry>();
    for (let i = start; i < this.calorieData.length; i++) {
      values.add(new BarEntry(i, this.calorieData[i]));
    }
    let dataSet: BarDataSet = new BarDataSet(values, CALORIE);
    dataSet.setHighLightColor(Color.Gray);
    dataSet.setDrawIcons(false);
    dataSet.setDrawValues(true);
    dataSet.setHighlightEnabled(false);
    // 为柱体添加颜色信息
    dataSet.setColorByColor(Colors.rgb(34, 177, 48));
    let dataSetList: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
    dataSetList.add(dataSet);
    let barData: BarData = new BarData(dataSetList);
    //设置柱状图宽度
    barData.setBarWidth(BAR_WIDTH);
    return barData;
  }

  build() {
    BarChart({ model: this.model })
      .width($r('app.string.layout_100'))
      .height($r('app.string.layout_40'))
      .margin({ bottom: $r('app.integer.margin_20') })
  }
}

// 设置X轴数据的格式转换器
class XValueFormatter implements IAxisValueFormatter {
  getFormattedValue(value: number): string {
    return `1/${(value + 1).toFixed(0)}`;
  }
}

// 设置Y轴数据的格式转换器
class YValueFormatter implements IAxisValueFormatter {
  getFormattedValue(value: number): string {
    return value.toFixed(0);
  }
}
