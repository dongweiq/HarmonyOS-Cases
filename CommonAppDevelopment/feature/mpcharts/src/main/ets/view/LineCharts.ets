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
const HEART_FILL_COLOR1: string = '#0C9B0909';
const STEP_FILL_COLOR1: string = '#0C0099CC';
const HEART_FILL_COLOR2: string = '#8fc60919';
const STEP_FILL_COLOR2: string = '#7F0099CC';
const HEART_FILL_COLOR3: string = '#f3c60919';
const STEP_FILL_COLOR3: string = '#0099CC';
const CUSTOM_WIDTH: number = 90;
const CUSTOM_HEIGHT: number = 50;
const HEART_RATES:string = '心率';
const STEP_NUMBER:string = '步数';

@Component
export struct LineCharts {
  @Prop type: string = HEART_RATE;
  @Prop referenceData: Array<number | null>;
  @Prop todayData: Array<number | null>;
  model: LineChartModel | null = null;
  private leftAxis: YAxis | null = null;
  private rightAxis: YAxis | null = null;
  private xAxis: XAxis | null = null;
  @State lineData: LineData = new LineData();
  @State customUiInfo: CustomUiInfo = new CustomUiInfo(HEART_RATE, CUSTOM_WIDTH, CUSTOM_HEIGHT);

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
      .border({ width: $r('app.integer.border_width_1'), color: this.customUiInfo.type === HEART_RATE ? Color.Orange : Color.Blue })
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

  aboutToAppear(): void {
    this.customUiInfo = new CustomUiInfo(this.type, CUSTOM_WIDTH, CUSTOM_HEIGHT);
    this.model = new LineChartModel();
    this.model.setPinchZoom(false);
    this.model.setDrawGridBackground(false);
    let description: Description | null = this.model.getDescription();
    if (description) {
      description.setEnabled(false);
    }
    this.xAxis = this.model.getXAxis();
    if (this.xAxis) {
      this.xAxis.setPosition(XAxisPosition.BOTTOM);
      this.xAxis.setDrawGridLines(true);
      this.xAxis.setGranularity(1);
      this.xAxis.setValueFormatter(new XValueFormatter());
      this.xAxis.setLabelCount(10);
      this.xAxis.enableGridDashedLine(2, 2, 0);
    }

    this.leftAxis = this.model.getAxisLeft();
    if (this.leftAxis) {
      this.leftAxis.setLabelCount(4, true);
      this.leftAxis.setDrawGridLines(true);
      this.leftAxis.setDrawGridLinesBehindData(true);
      this.leftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
      this.leftAxis.setAxisMinimum(0);
      this.leftAxis.setValueFormatter(new YValueFormatter());
      this.leftAxis.setEnabled(true);
      this.leftAxis.enableGridDashedLine(2, 2, 0);
    }
    this.rightAxis = this.model.getAxisRight();
    if (this.rightAxis) {
      this.rightAxis.setEnabled(false);
    }
    let legend: Legend | null = this.model.getLegend();
    if (legend) {
      legend.setEnabled(true);
      legend.setForm(LegendForm.LINE);
      legend.setTextSize(vp2px(14));
      legend.setOrientation(LegendOrientation.HORIZONTAL);
      legend.setVerticalAlignment(LegendVerticalAlignment.TOP);
      legend.setHorizontalAlignment(LegendHorizontalAlignment.LEFT);
    }
    this.model.setData(this.lineData);
    this.model.setScaleEnabled(false);

    this.lineData = this.getLineData();
    if (this.model) {
      this.model.setData(this.lineData);
      this.model.invalidate();
    }
  }

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
    dataSet.setHighLightColor(Color.Red);
    dataSet.setHighlightLineWidth(0.1);
    dataSet.setDrawValues(false);
    dataSet.setLineWidth(1.5);
    dataSet.setDrawIcons(false);
    dataSet.setMode(Mode.CUBIC_BEZIER);
    dataSet.setDrawCircles(false);
    dataSet.setColorByColor(this.customUiInfo.type === HEART_RATE ? Color.Orange : Color.Blue);
    let gradientFillColor = new JArrayList<ChartColorStop>();
    gradientFillColor.add([this.customUiInfo.type === HEART_RATE ? HEART_FILL_COLOR3 : STEP_FILL_COLOR3, 0.2]);
    gradientFillColor.add([this.customUiInfo.type === HEART_RATE ? HEART_FILL_COLOR2 : STEP_FILL_COLOR2, 0.6]);
    gradientFillColor.add([this.customUiInfo.type === HEART_RATE ? HEART_FILL_COLOR1 : STEP_FILL_COLOR1, 1.0]);
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

class YValueFormatter implements IAxisValueFormatter {
  getFormattedValue(value: number, axis: AxisBase): string {
    return value.toFixed(0);
  }
}