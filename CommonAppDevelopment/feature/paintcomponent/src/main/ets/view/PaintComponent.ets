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

import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';
import Constants from "../constants/Constants";

/**
 * 本示例介绍使用绘制组件中的Circle组件以及Path组件实现实时进度效果。该场景多用于手机电池电量、汽车油量、水位变化等动态变化中。
 * 实现步骤：
 * 1. 使用Circle组件绘制外层的圆环。
 * 2. 绘制中间的进度的填充。中间的填充有两个状态：1、在进度100%时是填充颜色的圆形；2、在进度不足100%时，使用Path组件绘制闭合曲线实现。
 * 3. 计算封闭曲线。水位线的端点的纵坐标y与进度k的关系为：y=(1-k)*2r，而圆心坐标为(r,r)，以此确定水位线的坐标，然后拼接成绘制封闭曲线的commands。
 * 4. 绘制最上层的百分比显示。
 */
@Component
export struct PaintComponent {
  // 进度
  @State progressNum: number = 0;
  // 绘制封闭曲线的命令
  @State pathCommands: string = '';
  // 随着进度填充封闭曲线的颜色
  @State colorBackgroundFill: string = Constants.COLOR_NORMAL;
  // 背景颜色
  @State bgColor: string = Constants.COLOR_TRANSPARENT;
  // 进度是否在变化
  isRunning: boolean = false;

  aboutToAppear(): void {
    this.pathCommands = this.getPathCommands(this.progressNum);
    this.changeColor();
  }

  /**
   * 根据进度拿到水位线的端点的纵坐标
   *
   * @param progressPercent 进度百分比
   * @returns 水位线的端点的纵坐标
   */
  getOrdinate(progressPercent: number): number {
    return (Constants.UNIT_ONE - progressPercent) * (Constants.RADIUS_IN_PX + Constants.RADIUS_IN_PX);
  }

  /**
   * 根据圆心，以及纵坐标拿到水位线两个端点的距离的平方
   *
   * @param ordinate 纵坐标
   * @returns 端点间距离的平方
   */
  getDistanceSquare(ordinate: number): number {
    return Constants.RADIUS_IN_PX * Constants.RADIUS_IN_PX - (ordinate - Constants.RADIUS_IN_PX) * (ordinate - Constants.RADIUS_IN_PX);
  }

  /**
   * 计算闭合曲线
   *
   * @param progressNum 进度
   * @returns 绘制闭合曲线的commands
   */
  getPathCommands(progressNum: number): string {
    // 拿到水位线的端点的纵坐标
    const ordinate: number = this.getOrdinate(progressNum / Constants.PERCENT_RATE);
    // 拿到端点之间的距离的平方
    const distanceSquare: number = this.getDistanceSquare(ordinate);
    if (distanceSquare >= Constants.ZERO) {
      // 开平方得到端点间的距离
      const distance: number = Math.sqrt(distanceSquare);
      // 计算得出第一个端点的横坐标
      const firstAbscissa: number = Constants.RADIUS_IN_PX - distance;
      // 计算得到第二个端点的横坐标
      const secondAbscissa: number = Constants.RADIUS_IN_PX + distance;
      return this.formatPathCommands(firstAbscissa, secondAbscissa, ordinate, Constants.RADIUS_IN_PX);
    }
    return "";
  }

  /**
   * 拼接绘制闭合曲线的commands
   *
   * @param firstAbscissa
   * @param secondAbscissa
   * @param ordinate
   * @param radius
   * @returns
   */
  formatPathCommands(firstAbscissa: number, secondAbscissa: number, ordinate: number, radius: number): string {
    return `M${firstAbscissa} ${ordinate} A${radius} ${radius} 0 ${ordinate > Constants.RADIUS_IN_PX ? 0 : 1} 0 ${secondAbscissa} ${ordinate}`
      + `Q${(firstAbscissa + 3 * secondAbscissa) / 4} ${ordinate + 12.5 * (secondAbscissa - firstAbscissa) / radius}, ${(firstAbscissa + secondAbscissa) / 2} ${ordinate} T${firstAbscissa} ${ordinate}`;
  }

  /**
   * 改变进度
   *
   * @param isIncrease 是否增加
   */
  changeProgressNum(isIncrease: boolean) {
    // 根据isIncrease来决定是对progressNum自增还是自减
    isIncrease ? this.progressNum += Constants.PROGRESS_STEP : this.progressNum -= Constants.PROGRESS_STEP;
    this.changeColor();
    this.pathCommands = this.getPathCommands(this.progressNum);
  }

  /**
   * 根据不同进度设置不同颜色
   */
  changeColor() {
    if (this.progressNum === Constants.FULL_PROGRESS) {
      // 进度为100时，封闭曲线不生效，此时将内心圆背景色设为COLOR_HEALTHY
      this.bgColor = Constants.COLOR_HEALTHY;
    } else {
      // 其他进度则将内心圆背景色设为透明色，防止影响进度填充色
      this.bgColor = Constants.COLOR_TRANSPARENT;
    }

    if (this.progressNum >= Constants.HEALTHY_PROGRESS) {
      // 当进度达到HEALTHY_PROGRESS时将进度填充色设为COLOR_HEALTHY
      this.colorBackgroundFill = Constants.COLOR_HEALTHY;
    } else if (this.progressNum <= Constants.WARN_PROGRESS) {
      // 当进度达到WARN_PROGRESS时，将进度填充色设为WARN_PROGRESS
      this.colorBackgroundFill = Constants.COLOR_WARN;
    } else {
      // 其他进度将进度填充色设为COLOR_NORMAL
      this.colorBackgroundFill = Constants.COLOR_NORMAL;
    }
  }

  build() {
    Column() {
      Column() {
        Text($r("app.string.title_name"))
          .fontSize($r("app.string.title_font_size"))
          .textAlign(TextAlign.Center)
          .margin({ bottom: $r("app.integer.title_margin_bottom") })
          .fontColor(Constants.COLOR_NORMAL)
        Stack() {
          // 外框圆环
          Circle({ width: Constants.BIG_DIAMETER, height: Constants.BIG_DIAMETER })
            .fill(Constants.COLOR_TRANSPARENT)
            .stroke(this.colorBackgroundFill)
            .strokeWidth($r("app.integer.outer_circle_stroke_width"))

          // 进度展示
          Circle({ width: Constants.DIAMETER, height: Constants.DIAMETER })
            .fill(this.bgColor)

          // TODO:知识点:使用Path组件绘制封闭曲线，实现水位线效果
          Path()
            .width(Constants.DIAMETER)
            .height(Constants.DIAMETER)
            .commands(this.pathCommands)
            .fill(this.colorBackgroundFill)
            .antiAlias(true)
            .stroke(this.colorBackgroundFill)
            .strokeWidth($r("app.integer.path_stroke_width"))

          // 进度百分比
          Row() {
            Text($r("app.string.progress_percentage_symbol_name"))
              .fontColor(Constants.COLOR_NORMAL)
              .fontSize($r("app.integer.progress_percentage_symbol_font_size"))
            Text(this.progressNum.toFixed(Constants.ZERO) + Constants.PERCENTAGE_STR)
              .fontSize($r("app.integer.progress_percentage_font_size"))
          }

        }
        .width(Constants.BIG_DIAMETER)
        .height(Constants.BIG_DIAMETER)
        .margin({ bottom: $r("app.integer.stack_margin_bottom") })

        Row() {
          Button($r("app.string.increase_button_name"))
            .type(ButtonType.Capsule)
            .margin({ right: $r("app.integer.decrease_button_margin_right") })
            .onClick(() => {
              if (this.progressNum >= Constants.FULL_PROGRESS || this.isRunning) {
                // 此为充电按钮，若进度达到100，或者正在进行进度变化，则按钮不生效，提前退出
                return;
              }
              // 将进度变换状态置为运行中
              this.isRunning = true;
              // 开启定时器对进度进行自增
              const id = setInterval(() => {
                this.changeProgressNum(true);
                if (this.progressNum >= Constants.FULL_PROGRESS) {
                  // 此为充电按钮，若进度达到100，则取消定时器并将进度变化状态置为停止
                  this.isRunning = false;
                  clearInterval(id)
                }
              }, Constants.PROGRESS_CHANGE_INTERVAL)
            })

          Button($r("app.string.decrease_button_name"))
            .type(ButtonType.Capsule)
            .backgroundColor(Constants.COLOR_WARN)
            .onClick(() => {
              if (this.progressNum <= Constants.ZERO_PROGRESS || this.isRunning) {
                // 此为耗电按钮，若进度达到0，或者正在进行进度变化，则按钮不生效，提前退出
                return;
              }
              // 将进度变换状态置为运行中
              this.isRunning = true;
              // 开启定时器对进度进行自减
              const id = setInterval(() => {
                this.changeProgressNum(false);
                if (this.progressNum <= Constants.ZERO_PROGRESS) {
                  this.isRunning = false;
                  // 此为耗电按钮，若进度达到0，则取消定时器并将进度变化状态置为停止
                  clearInterval(id)
                }
              }, Constants.PROGRESS_CHANGE_INTERVAL)
            })
        }
      }
      .width($r("app.string.column_children_width"))
    }
    .height($r("app.string.column_parent_height"))
    .justifyContent(FlexAlign.Center)
  }
}

/**
 * 创建WrappedBuilder对象，动态路由跳转时构建页面
 */
@Builder
export function getPaintComponentView(): void {
  PaintComponent();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.PAINT_COMPONENT,wrapBuilder(getPaintComponentView));