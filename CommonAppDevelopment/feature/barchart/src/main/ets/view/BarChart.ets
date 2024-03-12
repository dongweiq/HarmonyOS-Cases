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
  ChartGesture, // 手势事件模式
  Description, // 图表Description(描述)部件
  EntryOhos, // 图表数据结构基础类
  Fill, // 图表填充类型构建类
  Highlight, // 图表高亮数据
  IBarDataSet, // 柱状图数据集合的操作类
  JArrayList, // 工具类：数据集合
  Legend, // 图表Legend(图例)部件
  LimitLabelPosition, // 图表的LimitLine标签位置枚举类
  LimitLine, // 图表LimitLine
  MarkerView, // 图表的Marker(标志气泡)部件
  OnChartGestureListener, // 手势事件监听
  OnChartValueSelectedListener, // 数据选择监听
  XAxis, // 图表X轴部件
  XAxisPosition, // 图表X轴标签位置枚举类
  YAxis, // 图表Y轴部件
  YAxisLabelPosition // 图表Y轴标签位置枚举类
} from '@ohos/mpchart';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter';

@Component
export struct BarChartPage {
  private model: BarChartModel | null = null; // 柱状图配置构建类
  private leftAxis: YAxis | null = null; // 图表左Y轴信息
  private rightAxis: YAxis | null = null; // 图表右Y轴信息
  private xAxis: XAxis | null = null; // 图表X轴位置
  private limitLine1: LimitLine | null = null; // 限制线
  private limitLine2: LimitLine | null = null; // 限制线
  private data: BarData | null = null; // 柱状图数据
  private mMaxVisibleXCount: number = 20; // 图表最大的X轴显示范围
  private normalMarker: MarkerView | null = null; // 图表markerView标记视图
  // 构造数据选择监听器
  private valueSelectedListener: OnChartValueSelectedListener = {
    onValueSelected: (e: EntryOhos, h: Highlight) => {
      console.info("ScrollBarChartPage onValueSelected: " + e.getX());
    },
    onNothingSelected: () => {
      console.info("ScrollBarChartPage onNothingSelected");
    }
  }
  // 为图表添加手势识别监听器
  private chartGestureListener: OnChartGestureListener = {
    onChartGestureStart: (isTouchEvent: boolean, me: TouchEvent | GestureEvent, lastPerformedGestureMode: ChartGesture) => {
      console.info("-----------------chartGestureListener onChartGestureStart lastMode: " + lastPerformedGestureMode);
    },
    onChartGestureEnd: (isTouchEvent: boolean, me: TouchEvent | GestureEvent, lastPerformedGestureMode: ChartGesture) => {
      console.info("-----------------chartGestureListener onChartGestureEnd lastMode: " + lastPerformedGestureMode);
    },
    onChartLongPressed: (isTouchEvent: boolean, me: TouchEvent | GestureEvent) => {
      console.info("-----------------chartGestureListener onChartLongPressed");
    },
    onChartDoubleTapped: (isTouchEvent: boolean, me: TouchEvent | GestureEvent) => {
      console.info("-----------------chartGestureListener onChartDoubleTapped");
    },
    onChartSingleTapped: (isTouchEvent: boolean, me: TouchEvent | GestureEvent) => {
      console.info("-----------------chartGestureListener onChartSingleTapped");
    },
    onChartFling: (isTouchEvent: boolean, me1: TouchEvent | GestureEvent, me2: TouchEvent, velocityX: number, velocityY: number) => {
      console.info("-----------------chartGestureListener onChartFling velocityX: " + velocityX + "  velocityY: " + velocityY);
    },
    onChartScale: (isTouchEvent: boolean, me: TouchEvent | GestureEvent, scaleX: number, scaleY: number) => {
      console.info("-----------------chartGestureListener onChartScale scaleX: " + scaleX + "  scaleY: " + scaleY);
    },
    onChartTranslate: (isTouchEvent: boolean, me: TouchEvent | GestureEvent, dX: number, dY: number) => {
      console.info("-----------------chartGestureListener onChartTranslate dx: " + dX + "  dy: " + dY);
    }
  }

  // 图表数据初始化
  aboutToAppear() {
    // TODO 知识点：必须初始化图表配置构建类
    this.model = new BarChartModel();
    // TODO 知识点：配置图表指定样式，为图表添加数据选择的监听器。
    this.model.setOnChartValueSelectedListener(this.valueSelectedListener);
    // 为图表添加手势识别监听器
    this.model.setOnChartGestureListener(this.chartGestureListener);
    // 获取图表描述部件，设置图表描述部件不可用，即图表不进行绘制描述部件
    let description: Description | null = this.model.getDescription();
    if (description) {
      description.setEnabled(false);
    }
    // 获取图表图例部件，设置图表图例部件不可用
    let legend: Legend | null = this.model.getLegend();
    if (legend) {
      legend.setEnabled(true);
    }
    // 禁用x和y轴方向同时缩放，但是可以单独x轴方向或者y轴方向缩放
    this.model.setPinchZoom(false);
    // 启用绘制网格背景
    this.model.setDrawGridBackground(false);
    // 设置网格背景颜色
    this.model.setGridBackgroundColor('#500000ff');
    // 设置不绘制柱状图的柱体阴影背景
    this.model.setDrawBarShadow(false);
    // 设置柱状图的高亮范围是否为整个柱体，只在堆叠柱状图中有区别
    this.model.setHighlightFullBarEnabled(false);
    // 为左Y轴设置LimitLine,可设置限制线的宽度，线段样式，限制标签的位置，标签字体大小等
    this.limitLine1 = new LimitLine(80, 'Upper Limit');
    this.limitLine1.setLineWidth(4);
    this.limitLine1.enableDashedLine(10, 10, 0);
    this.limitLine1.setLabelPosition(LimitLabelPosition.RIGHT_TOP);
    this.limitLine1.setTextSize(vp2px(10));

    this.limitLine2 = new LimitLine(30, 'Lower Limit');
    this.limitLine2.setLineWidth(4);
    this.limitLine2.enableDashedLine(10, 10, 0);
    this.limitLine2.setLineColor(Color.Yellow);
    this.limitLine2.setLabelPosition(LimitLabelPosition.RIGHT_BOTTOM);
    this.limitLine2.setTextSize(vp2px(10));

    // 设置图表左Y轴信息
    this.leftAxis = this.model.getAxisLeft();
    if (this.leftAxis) {
      this.leftAxis.setAxisMinimum(0); // this replaces setStartAtZero(true);
      this.leftAxis.setDrawLimitLinesBehindData(false);

      // 添加LimitLines
      this.leftAxis.addLimitLine(this.limitLine1);
      this.leftAxis.addLimitLine(this.limitLine2);
    }
    // 设置图表右Y轴信息
    this.rightAxis = this.model.getAxisRight();
    if (this.rightAxis) {
      this.rightAxis.setEnabled(false);
      this.rightAxis.setAxisMinimum(0);
    }
    // 设置X轴信息
    this.xAxis = this.model.getXAxis();
    if (this.xAxis) {
      this.xAxis.setPosition(XAxisPosition.BOTTOM);
    }
    // 为图表设置markerView
    this.normalMarker = new MarkerView();
    this.model.setMarker(this.normalMarker);
    // 生成单一颜色数据
    this.data = this.getNormalData();
    // TODO 知识点：将数据与图表配置类绑定
    this.model.setData(this.data);
    // 设置图表最大的X轴显示范围，如不设置，则默认显示全部数据
    this.model.setVisibleXRangeMaximum(this.mMaxVisibleXCount);
  }

  // 生成单一颜色数据
  private getNormalData(): BarData {
    let values: JArrayList<BarEntry> = new JArrayList<BarEntry>();
    values.add(new BarEntry(1, 73.3));
    values.add(new BarEntry(2, 5.4));
    values.add(new BarEntry(3, 73.9));
    values.add(new BarEntry(4, 79.9));
    values.add(new BarEntry(5, 69.3));
    values.add(new BarEntry(6, 70.7));
    values.add(new BarEntry(7, 81.2));
    values.add(new BarEntry(8, 13.1));
    values.add(new BarEntry(9, 34.2));
    values.add(new BarEntry(10, 58.4));
    values.add(new BarEntry(11, 44.7));
    values.add(new BarEntry(12, 10.5));
    values.add(new BarEntry(13, 15.6));
    values.add(new BarEntry(14, 95.8));
    values.add(new BarEntry(15, 57.4));
    values.add(new BarEntry(16, 64.5));
    values.add(new BarEntry(17, 21.4));
    values.add(new BarEntry(18, 33.2));
    values.add(new BarEntry(19, 96.9));

    let dataSet: BarDataSet = new BarDataSet(values, 'DataSet');
    dataSet.setHighLightColor(Color.Black);
    dataSet.setDrawIcons(false);
    // 为柱体添加颜色信息
    dataSet.setColorByColor(Color.Pink);

    let dataSetList: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
    dataSetList.add(dataSet);

    let barData: BarData = new BarData(dataSetList);
    barData.setBarWidth(0.85);
    return barData;
  }

  // 生成渐变颜色数据
  private getGradientData(): BarData {
    let values: JArrayList<BarEntry> = new JArrayList<BarEntry>();
    values.add(new BarEntry(1, 32.9));
    values.add(new BarEntry(2, 44.7));
    values.add(new BarEntry(3, 2.1));
    values.add(new BarEntry(4, 46.9));
    values.add(new BarEntry(5, 8.8));
    values.add(new BarEntry(6, 82.1));
    values.add(new BarEntry(7, 86.9));
    values.add(new BarEntry(8, 15.9));
    values.add(new BarEntry(9, 29.4));
    values.add(new BarEntry(10, 71.6));
    values.add(new BarEntry(11, 55.7));
    values.add(new BarEntry(12, 35.8));
    values.add(new BarEntry(13, 67.7));
    values.add(new BarEntry(14, 34.9));
    values.add(new BarEntry(15, 50.9));
    values.add(new BarEntry(16, 40.5));
    values.add(new BarEntry(17, 27.1));
    values.add(new BarEntry(18, 45.7));
    values.add(new BarEntry(19, 26.8));

    let dataSet: BarDataSet = new BarDataSet(values, 'DataSet');
    dataSet.setHighLightColor(Color.Black);
    dataSet.setDrawIcons(false);
    let startColor1: string = '#ffffbb33';
    let startColor2: string = '#ff33b5e5';
    let startColor3: string = '#ffffbb33';
    let startColor4: string = '#ff99cc00';
    let startColor5: string = '#ffff4444';
    let endColor1: string = '#ff0099cc';
    let endColor2: string = '#ffaa66cc';
    let endColor3: string = '#ff669900';
    let endColor4: string = '#ffcc0000';
    let endColor5: string = '#ffff8800';
    let gradientFills: JArrayList<Fill> = new JArrayList<Fill>();
    gradientFills.add(new Fill(startColor1, endColor1));
    gradientFills.add(new Fill(startColor2, endColor2));
    gradientFills.add(new Fill(startColor3, endColor3));
    gradientFills.add(new Fill(startColor4, endColor4));
    gradientFills.add(new Fill(startColor5, endColor5));
    // 为柱体添加渐变的颜色信息
    dataSet.setFills(gradientFills);

    let dataSetList: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
    dataSetList.add(dataSet);

    let barData: BarData = new BarData(dataSetList);
    barData.setBarWidth(0.85);
    return barData;
  }

  // 生成堆叠颜色数据
  private getStackData(): BarData {
    let values: JArrayList<BarEntry> = new JArrayList<BarEntry>();
    values.add(new BarEntry(1, [38.0, 28.0, 39.8]));
    values.add(new BarEntry(2, [18.2, 16.1, 16.1]));
    values.add(new BarEntry(3, [45.8, 49.8, 26.7]));
    values.add(new BarEntry(4, [36.5, 43.8, 15.1]));
    values.add(new BarEntry(5, [51.5, 35.4, 24.1]));
    values.add(new BarEntry(6, [44.9, 21.4, 15.9]));
    values.add(new BarEntry(7, [32.9, 40.4, 32.7]));
    values.add(new BarEntry(8, [24.3, 31.0, 47.1]));
    values.add(new BarEntry(9, [17.4, 48.4, 49.6]));
    values.add(new BarEntry(10, [32.0, 29.8, 20.0]));
    values.add(new BarEntry(11, [43.9, 52.7, 27.7]));
    values.add(new BarEntry(12, [28.4, 46.2, 51.8]));
    values.add(new BarEntry(13, [42.6, 51.9, 44.0]));
    values.add(new BarEntry(14, [14.8, 22.4, 31.2]));
    values.add(new BarEntry(15, [50.3, 18.7, 18.3]));
    values.add(new BarEntry(16, [20.7, 22.9, 40.2]));
    values.add(new BarEntry(17, [49.4, 38.3, 41.7]));
    values.add(new BarEntry(18, [45.9, 40.7, 29.5]));
    values.add(new BarEntry(19, [37.1, 31.8, 42.9]));

    let dataSet: BarDataSet | null = null;
    dataSet = new BarDataSet(values, "Statistics Vienna 2014");
    dataSet.setDrawIcons(false);
    // 为柱体添加指定分段的颜色信息
    dataSet.setColorsByArr([Color.Red, Color.Green, Color.Pink]);
    dataSet.setStackLabels(["Births", "Divorces", "Marriages"]);

    let dataSets: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
    dataSets.add(dataSet);

    let data: BarData = new BarData(dataSets);
    data.setValueTextColor(Color.White);
    return data;
  }

  private refresh(): void {
    if (this.model) {
      this.model.notifyDataSetChanged();
      this.model.invalidate();
    }
  }

  build() {
    Column() {
      Column({ space: 5 }) {
        // TODO 知识点：为组件设置配置构建类。可通过在事件中使用this.model.notifyDataSetChanged()触发坐标轴数据更新。通过在事件中使用this.model.invalidate()触发绘制更新。
        BarChart({ model: this.model })
          .width($r('app.string.common_bar_chart_width'))
          .height($r('app.string.common_bar_chart_height'))
      }
      .border({ width: 1, color: $r('app.color.border_color'), radius: 10, style: BorderStyle.Solid })
      .backgroundColor(Color.White)

      Divider()
        .width($r('app.string.common_divider'))
        .padding({ top: $r('app.integer.common_padding_top') })

      Column({ space: 5 }) {
        Row({ space: 10 }) {
          Text($r('app.string.control_data_type'))
          Row() {
            Text($r('app.string.control_normal'))
            Radio({ value: 'normal', group: 'dataType' })
              .checked(true)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.data = this.getNormalData();
                  if (this.model) {
                    if (this.normalMarker) {
                      this.model.setMarker(this.normalMarker);
                    }
                    this.model.setData(this.data);
                  }
                }
              })
          }

          Row() {
            Text($r('app.string.control_gradient'))
            Radio({ value: 'gradient', group: 'dataType' })
              .checked(false)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.data = this.getGradientData();
                  if (this.model) {
                    if (this.normalMarker) {
                      this.model.setMarker(this.normalMarker);
                    }
                    this.model.setData(this.data);
                  }
                }
              })
          }

          Row() {
            Text($r('app.string.control_stack'))
            Radio({ value: 'stack', group: 'dataType' })
              .checked(false)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.data = this.getStackData();
                  if (this.model) {
                    this.model.setData(this.data);
                  }
                }
              })
          }
        }.alignSelf(ItemAlign.Start)

        Row() {
          Text($r('app.string.control_XAxis_is_display'))
          Row() {
            Checkbox({ name: 'isShowXAxis', group: 'xAxis' })
              .select(true)
              .onChange((isChecked: boolean) => {
                if (this.xAxis) {
                  this.xAxis.setEnabled(isChecked);
                  this.refresh();
                }
              })
          }
        }.alignSelf(ItemAlign.Start)

        Row({ space: 10 }) {
          Text($r('app.string.control_leftYAxis_is_display'))
          Row() {
            Text($r('app.string.control_leftYAxis'))
            Checkbox({ name: 'leftYAxis', group: 'yAxis' })
              .select(true)
              .onChange((isChecked: boolean) => {
                if (this.leftAxis) {
                  this.leftAxis.setEnabled(isChecked);
                  this.refresh();
                }
              })
          }

          Row() {
            Text($r('app.string.control_rightYAxis'))
            Checkbox({ name: 'rightYAxis', group: 'yAxis' })
              .onChange((isChecked: boolean) => {
                if (this.rightAxis) {
                  this.rightAxis.setEnabled(isChecked);
                  this.refresh();
                }
              })
          }
        }.alignSelf(ItemAlign.Start)

        Row({ space: 10 }) {
          Text($r('app.string.control_leftYAxis_location'))
          Row() {
            Text($r('app.string.control_outSideChart'))
            Radio({ value: 'outSideChart', group: 'leftYAxisLabelPosition' })
              .checked(true)
              .onChange((isChecked: boolean) => {
                if (this.leftAxis && isChecked) {
                  this.leftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
                  this.refresh();
                }
              })
          }

          Row() {
            Text($r('app.string.control_inSideChart'))
            Radio({ value: 'inSideChart', group: 'leftYAxisLabelPosition' })
              .checked(false)
              .onChange((isChecked: boolean) => {
                if (this.leftAxis && isChecked) {
                  this.leftAxis.setPosition(YAxisLabelPosition.INSIDE_CHART);
                  this.refresh();
                }
              })
          }
        }.alignSelf(ItemAlign.Start)

        Row({ space: 10 }) {
          Text($r('app.string.control_right_YAxis_location'))
          Row() {
            Text($r('app.string.control_right_outSideChart'))
            Radio({ value: 'outSideChart', group: 'rightYAxisLabelPosition' })
              .checked(true)
              .onChange((isChecked: boolean) => {
                if (this.rightAxis && isChecked) {
                  this.rightAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
                  this.refresh();
                }
              })
          }

          Row() {
            Text($r('app.string.control_left_outSideChart'))
            Radio({ value: 'inSideChart', group: 'rightYAxisLabelPosition' })
              .checked(false)
              .onChange((isChecked: boolean) => {
                if (this.rightAxis && isChecked) {
                  this.rightAxis.setPosition(YAxisLabelPosition.INSIDE_CHART);
                  this.refresh();
                }
              })
          }
        }.alignSelf(ItemAlign.Start)

        Row() {
          Text($r('app.string.control_is_draw_background'))
          Checkbox({ name: 'isDrawBackground', group: 'isDrawBackground' })
            .select(false)
            .onChange((isChecked: boolean) => {
              if (this.model) {
                this.model.setDrawGridBackground(isChecked);
                this.model.notifyDataSetChanged();
                this.model.invalidate();
              }
            })
        }.alignSelf(ItemAlign.Start)

        Row() {
          Text($r('app.string.control_is_show_markerview'))
          Checkbox({ name: 'isShowMarkerView', group: 'isShowMarkerView' })
            .select(true)
            .onChange((isChecked: boolean) => {
              if (this.model) {
                // 使用setDrawMarkerViews设置true，点击柱状图中柱子会有弹窗效果
                this.model.setDrawMarkerViews(isChecked);
                this.model.notifyDataSetChanged();
                this.model.invalidate();
              }
            })
            .margin({ left: $r('app.integer.margin_fu_3') })
        }.alignSelf(ItemAlign.Start)

        Row() {
          Text($r('app.string.control_is_show_limitline_behinddata'))
          Checkbox({ name: 'isShowLimitLineBehindData', group: 'isShowLimitLineBehindData' })
            .select(false)
            .onChange((isChecked: boolean) => {
              if (this.leftAxis) {
                this.leftAxis.setDrawLimitLinesBehindData(isChecked);
                this.refresh();
              }
            })
        }.alignSelf(ItemAlign.Start)

        Row() {
          Text($r('app.string.control_leftYAxis_limitline_location'))
        }.alignSelf(ItemAlign.Start)

        Flex({ wrap: FlexWrap.Wrap }) {
          Row() {
            Text('Both')
            Radio({ value: 'both', group: 'limitLinePosition' })
              .checked(true)
              .onChange((isChecked: boolean) => {
                if (this.leftAxis && isChecked) {
                  this.leftAxis.removeAllLimitLines();
                  if (this.limitLine1) {
                    this.leftAxis.addLimitLine(this.limitLine1);
                  }
                  if (this.limitLine2) {
                    this.leftAxis.addLimitLine(this.limitLine2);
                  }
                  this.refresh();
                }
              })
          }.margin({ right: $r('app.integer.common_margin_left') })

          Row() {
            Text('None')
            Radio({ value: 'none', group: 'limitLinePosition' })
              .checked(false)
              .onChange((isChecked: boolean) => {
                if (this.leftAxis && isChecked) {
                  this.leftAxis.removeAllLimitLines();
                  this.refresh();
                }
              })
          }.margin({ right: $r('app.integer.common_margin_left') })

          Row() {
            Text('Upper')
            Radio({ value: 'upper', group: 'limitLinePosition' })
              .checked(false)
              .onChange((isChecked: boolean) => {
                if (this.leftAxis && isChecked) {
                  this.leftAxis.removeAllLimitLines();
                  if (this.limitLine1) {
                    this.leftAxis.addLimitLine(this.limitLine1);
                  }
                  this.refresh();
                }
              })
          }.margin({ right: $r('app.integer.common_margin_left') })

          Row() {
            Text('Lower')
            Radio({ value: 'lower', group: 'limitLinePosition' })
              .checked(false)
              .onChange((isChecked: boolean) => {
                if (this.leftAxis && isChecked) {
                  this.leftAxis.removeAllLimitLines();
                  if (this.limitLine2) {
                    this.leftAxis.addLimitLine(this.limitLine2);
                  }
                  this.refresh();
                }
              })
          }
        }.alignSelf(ItemAlign.Start)

        Row() {
          Text($r('app.string.control_XAxis_location'))
        }.alignSelf(ItemAlign.Start)

        Flex({ wrap: FlexWrap.Wrap }) {
          Row() {
            Text('Top')
            Radio({ value: 'top', group: 'xAxisLabelPosition' })
              .checked(false)
              .onChange((isChecked: boolean) => {
                if (this.xAxis && isChecked) {
                  this.xAxis.setPosition(XAxisPosition.TOP);
                  this.refresh();
                }
              })
          }.margin({ right: $r('app.integer.common_margin_left') })

          Row() {
            Text('Bottom')
            Radio({ value: 'bottom', group: 'xAxisLabelPosition' })
              .checked(true)
              .onChange((isChecked: boolean) => {
                if (this.xAxis && isChecked) {
                  this.xAxis.setPosition(XAxisPosition.BOTTOM);
                  this.refresh();
                }
              })
          }.margin({ right: $r('app.integer.common_margin_left') })

          Row() {
            Text('Both Side')
            Radio({ value: 'both', group: 'xAxisLabelPosition' })
              .checked(false)
              .onChange((isChecked: boolean) => {
                if (this.xAxis && isChecked) {
                  this.xAxis.setPosition(XAxisPosition.BOTH_SIDED);
                  this.refresh();
                }
              })
          }.margin({ right: $r('app.integer.common_margin_left') })

          Row() {
            Text('Top InSide')
            Radio({ value: 'topInSide', group: 'xAxisLabelPosition' })
              .checked(false)
              .onChange((isChecked: boolean) => {
                if (this.xAxis && isChecked) {
                  this.xAxis.setPosition(XAxisPosition.TOP_INSIDE);
                  this.refresh();
                }
              })
          }.margin({ right: $r('app.integer.common_margin_left') })

          Row() {
            Text('Bottom InSide')
            Radio({ value: 'bottomInSide', group: 'xAxisLabelPosition' })
              .checked(false)
              .onChange((isChecked: boolean) => {
                if (this.xAxis && isChecked) {
                  this.xAxis.setPosition(XAxisPosition.BOTTOM_INSIDE);
                  this.refresh();
                }
              })
          }
        }.alignSelf(ItemAlign.Start)
      }
      .border({ width: 1, color: $r('app.color.border_color'), radius: 10, style: BorderStyle.Solid })
      .backgroundColor(Color.White)
      .padding($r('app.integer.common_padding'))
    }
    .height($r('app.string.common_column_height'))
    .backgroundColor($r('app.color.background_color'))
    .padding($r('app.integer.common_padding'))
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getBarChartPage(): void {
  BarChartPage();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.BAR_CHAT, wrapBuilder(getBarChartPage));