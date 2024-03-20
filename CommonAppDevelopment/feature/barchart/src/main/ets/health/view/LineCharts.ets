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
  JArrayList,
  XAxis,
  XAxisPosition,
  YAxis,
  Description,
  Legend,
  EntryOhos,
  YAxisLabelPosition,
  LineDataSet,
  ILineDataSet,
  LineData,
  Mode,
  LineChart,
  LineChartModel,
  ChartColorStop,
  LegendForm,
  IAxisValueFormatter,
  AxisBase,
  LegendOrientation,
  LegendVerticalAlignment,
  LegendHorizontalAlignment,
} from '@ohos/mpchart';
import { EventType } from '@ohos/mpchart/src/main/ets/components/listener/EventControl';
import { CustomUiInfo } from '../model/BasicDataSource';

const HEART_RATE: string = 'heartRate';
const REFERENCE: string = '参考';
const HEART_FILL_COLOR1: string = '#FFFDFCF5';
const STEP_FILL_COLOR1: string = '#0C0099CC';
const HEART_FILL_COLOR2: string = '#FFFBF4DE';
const STEP_FILL_COLOR2: string = '#7F0099CC';
const HEART_FILL_COLOR3: string = '#FFFAE8C2';
const STEP_FILL_COLOR3: string = '#0099CC';
const TEXT_SIZE: number = 14;
const CUSTOM_WIDTH: number = 90;
const CUSTOM_HEIGHT: number = 50;
const HEART_RATES: string = '心率';
const STEP_NUMBER: string = '步数';

/**
 * 场景描述：当前组件为线形图组件 LineChartModel。
 * 构造新的对象模型后通过模型的方法设置属性。
 * 具体实现见aboutToAppear内注释。
 */
@Component
export struct LineCharts {
  @Prop type: string = HEART_RATE; // 设置线形图类型（心率或步数）
  @Prop referenceData: Array<number | null>; // 参考数据
  @Prop todayData: Array<number | null>; // 当日数据
  model: LineChartModel | null = null; // 线形图模型
  private leftAxis: YAxis | null = null; // 左侧Y轴数据
  private rightAxis: YAxis | null = null; // 右侧Y轴数据
  private xAxis: XAxis | null = null; // X轴数据
  @State lineData: LineData = new LineData(); // 线形图数据
  @State customUiInfo: CustomUiInfo = new CustomUiInfo(HEART_RATE, CUSTOM_WIDTH, CUSTOM_HEIGHT); // 图表的Marker(标志气泡)组件

  // 图表Marker(标志气泡)组件
  @Builder
  customUi() {
    // 是否在图表content内
    if (this.customUiInfo.isInbounds && this.customUiInfo.data) {
      Column() {
        Text(this.customUiInfo.getFormattedValue())
          .fontColor(Color.White)
          .fontSize($r('app.integer.font_size_12'))
          .fontWeight(FontWeight.Bold)
        Text(`${this.customUiInfo.type === HEART_RATE ? HEART_RATES : STEP_NUMBER}： ${JSON.stringify(this.customUiInfo.data.getY())}`)
          .fontColor(Color.White)
          .fontSize($r('app.integer.font_size_12'))
      }
      .padding($r('app.integer.padding_4'))
      .borderRadius($r('app.integer.radius_6'))
      .border({
        width: $r('app.integer.border_width_1'),
        color: this.customUiInfo.type === HEART_RATE ? Color.Orange : Color.Blue
      })
      .backgroundColor($r('app.color.bg_color'))
      .width(this.customUiInfo.width)
      .height(this.customUiInfo.height)
      .margin({ left: this.customUiInfo.x, top: this.customUiInfo.y })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.customUiInfo.showUi = false;
      })
    }
  }

  // 图表数据初始化
  aboutToAppear(): void {
    // 构建Marker组件
    this.customUiInfo = new CustomUiInfo(this.type, CUSTOM_WIDTH, CUSTOM_HEIGHT);
    // TODO 知识点：必须初始化图表配置构建类
    this.model = new LineChartModel();
    this.model.setPinchZoom(false);
    this.model.setDrawGridBackground(false);
    // TODO 知识点：配置图表指定样式，各部件间没有先后之分
    // 获取图表描述部件，设置图表描述部件不可用，即图表不进行绘制描述部件
    let description: Description | null = this.model.getDescription();
    if (description) {
      description.setEnabled(false);
    }
    // 设置X轴信息
    this.xAxis = this.model.getXAxis();
    if (this.xAxis) {
      //设置标签位置
      this.xAxis.setPosition(XAxisPosition.BOTTOM);
      // 设置X轴是否绘制网格线
      this.xAxis.setDrawGridLines(true);
      this.xAxis.setGranularity(1);
      // 设置数据的格式转换器
      this.xAxis.setValueFormatter(new XValueFormatter());
      // 设置绘制标签个数
      this.xAxis.setLabelCount(10);
      this.xAxis.enableGridDashedLine(2, 2, 0);
    }
    // 设置图表左Y轴信息
    this.leftAxis = this.model.getAxisLeft();
    if (this.leftAxis) {
      this.leftAxis.setLabelCount(4, true);
      this.leftAxis.setDrawGridLines(true);
      // 设置图表左Y轴是否在数据后绘制限制线
      this.leftAxis.setDrawGridLinesBehindData(true);
      this.leftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
      this.leftAxis.setAxisMinimum(0);
      // 设置图表左Y轴数据的格式转换器
      this.leftAxis.setValueFormatter(new YValueFormatter());
      this.leftAxis.setEnabled(true);
      this.leftAxis.enableGridDashedLine(2, 2, 0);
    }
    // 设置图表右Y轴信息
    this.rightAxis = this.model.getAxisRight();
    if (this.rightAxis) {
      // 设置图表右Y轴是否显示
      this.rightAxis.setEnabled(false);
    }
    // 获取图表图例部件，设置图表图例部件不可用
    let legend: Legend | null = this.model.getLegend();
    if (legend) {
      legend.setEnabled(true);
      // 设置图例类型
      legend.setForm(LegendForm.LINE);
      // 设置图例文本大小
      legend.setTextSize(TEXT_SIZE);
      // 设置图例方向为水平
      legend.setOrientation(LegendOrientation.HORIZONTAL);
      // 设置图例垂直对齐方式为顶部
      legend.setVerticalAlignment(LegendVerticalAlignment.TOP);
      // 设置图例水平对齐方式为左对齐
      legend.setHorizontalAlignment(LegendHorizontalAlignment.LEFT);
    }
    // TODO 知识点：将数据与图表配置类绑定
    this.model.setData(this.lineData);
    // 设置模型是否可缩放
    this.model.setScaleEnabled(false);

    this.lineData = this.getLineData();
    if (this.model) {
      this.model.setData(this.lineData);
      this.model.invalidate();
    }
  }

  // 生成线形图数据
  private getLineData(): LineData {
    let start: number = 0;
    let values: JArrayList<EntryOhos> = new JArrayList<EntryOhos>();
    let values2: JArrayList<EntryOhos> = new JArrayList<EntryOhos>();
    for (let i = start; i < this.todayData.length; i++) {
      values.add(new EntryOhos(i, this.todayData[i]));
    }
    for (let i = start; i < this.referenceData.length; i++) {
      values2.add(new EntryOhos(i, this.referenceData[i]));
    }
    let dataSetList: JArrayList<ILineDataSet> = new JArrayList<ILineDataSet>();
    let dataSet = new LineDataSet(values, '今日');
    // 设置数据高亮颜色
    dataSet.setHighLightColor(Color.Red);
    // 设置数据高亮线的宽度
    dataSet.setHighlightLineWidth(0.1);
    // 不绘制数据值
    dataSet.setDrawValues(false);
    dataSet.setLineWidth(1.5);
    dataSet.setDrawIcons(false);
    // 设置曲线为贝塞尔曲线模式
    dataSet.setMode(Mode.CUBIC_BEZIER);
    // 折线点不画圆圈
    dataSet.setDrawCircles(false);
    // 设置曲线颜色
    dataSet.setColorByColor(this.customUiInfo.type === HEART_RATE ? Color.Orange : Color.Blue);
    let gradientFillColor = new JArrayList<ChartColorStop>();
    gradientFillColor.add([this.customUiInfo.type === HEART_RATE ? HEART_FILL_COLOR3 : STEP_FILL_COLOR3, 0.2]);
    gradientFillColor.add([this.customUiInfo.type === HEART_RATE ? HEART_FILL_COLOR2 : STEP_FILL_COLOR2, 0.6]);
    gradientFillColor.add([this.customUiInfo.type === HEART_RATE ? HEART_FILL_COLOR1 : STEP_FILL_COLOR1, 1.0]);
    // 设置渐变色填充
    dataSet.setGradientFillColor(gradientFillColor);
    dataSet.setDrawFilled(true);
    dataSetList.add(dataSet);
    let dataSet2 = new LineDataSet(values2, REFERENCE);
    dataSet2.setHighLightColor(Color.Black);
    dataSet2.setHighlightLineWidth(0.1);
    dataSet2.setDrawValues(false);
    dataSet2.setLineWidth(1.5);
    dataSet2.setDrawIcons(false);
    dataSet2.setMode(Mode.CUBIC_BEZIER);
    dataSet2.setDrawCircles(false);
    dataSet2.setColorByColor(Color.Green);
    dataSetList.add(dataSet2);
    return new LineData(dataSetList);
  }

  build() {
    LineChart({
      model: this.model,
      // 自定义 ui: 传入 builder
      customUiBuilder: this.customUi,
      // 通过什么事件触发
      customUiTriggerEvent: EventType.SingleTap,
      // 自定义ui的位置信息
      customUiInfo: this.customUiInfo,
    })
      .width($r('app.string.layout_100'))
      .height($r('app.string.layout_40'))
      .margin({ top: $r('app.integer.margin_5'), bottom: $r('app.integer.margin_20') })
  }
}

// 设置X轴数据的格式转换器
class XValueFormatter implements IAxisValueFormatter {
  getFormattedValue(value: number, axis: AxisBase): string {
    switch (value) {
      case 0:
        return '0:00';
      case 3:
        return '3:00';
      case 6:
        return '6:00';
      case 9:
        return '9:00';
      case 12:
        return '12:00';
      case 15:
        return '15:00';
      case 18:
        return '18:00';
      case 21:
        return '21:00';
      case 24:
        return '+1';
      case 27:
        return '3:00';
    }
    return value + '';
  }
}

// 设置Y轴数据的格式转换器
class YValueFormatter implements IAxisValueFormatter {
  getFormattedValue(value: number, axis: AxisBase): string {
    return value.toFixed(0);
  }
}