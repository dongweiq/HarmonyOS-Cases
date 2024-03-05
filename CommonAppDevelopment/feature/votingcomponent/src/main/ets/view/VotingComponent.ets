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
 * 投票组件，使用显示动画以及绘制组件实现
 * 实现步骤：
 * 1、使用Column绘制胶囊块图形，为实现胶囊块的切割效果以及投票后的比例变换，这里使用两个Colum分别绘制两个半个胶囊块拼接而成。
 * 2、使用绘制组件中的Polygon实现胶囊块中间被分割的效果。中间的间隙有两个状态：1、未投票时是个宽度比较大的平行四边形，且有PK两字；2、投票后是个宽度很窄的平行四边形，且PK两字消失。
 * 3、计算投票比例作为左右图形宽度，且定义动画效果。
 */
@Component
export struct VotingComponent {
  // 投票组件下方提示的内容
  @State notice: string = '点击上方按钮，选择你的观点';
  // 左选项的长度
  @State leftOptionWidth: string = '50%';
  // 右选项的长度
  @State rightOptionWidth: string = '50%';
  // 是否已投票
  @State isClick: boolean = false;
  // 绘制中间切割的平行四边形的坐标点
  @State points: number[][] = Constants.BEGIN_POINTS;
  // 填充选项的透明度
  @State fillOpacity: number = Constants.BEGIN_FILL_OPACITY;
  // 左右选项选择人数，目前是写死，真实业务场景通过请求获取
  leftOptionChoose: number = 4;
  rightOptionChoose: number = 13;
  // 定义动画
  animateParam: AnimateParam = {
    duration: Constants.ANIMATE_DURATION,
    curve: Curve.EaseOut
  }

  /**
   * 投票后改变属性
   *
   * @param option 投了左边还是右边
   */
  changeState(option: string) {
    // 投票后将点击状态置为已点击，实现投票只能投一次的效果
    this.isClick = true;
    // 左下角文字提示投票已选择的选项
    this.notice = '已选择"' + option + '"';
    // 投票后设置透明度，实现颜色变浅的效果
    this.fillOpacity = Constants.END_FILL_OPACITY;
    // 根据投票人数来计算选项两边的比例
    const leftOptionPercent: number = this.leftOptionChoose / (this.leftOptionChoose + this.rightOptionChoose) * Constants.PERCENTAGE;
    // TODO：知识点1：使用显式动画，只有在宽度变化时生效
    animateTo(this.animateParam, () => {
      this.leftOptionWidth = leftOptionPercent.toFixed(0) + '%';
      this.rightOptionWidth = (Constants.PERCENTAGE - leftOptionPercent).toFixed(0) + '%';
      this.points = Constants.END_POINTS;
    });
  }

  build() {
    Column() {
      // 投票主题
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start }) {
        Image($r("app.media.avatars"))// 投票举行者头像
          .width($r("app.integer.voting_theme_image_width"))
          .height($r("app.integer.voting_theme_image_height"))
          .margin({
            left: $r("app.integer.voting_theme_image_margin_left"),
            right: $r("app.integer.voting_theme_image_margin_right")
          })
        Text($r("app.string.voting_theme_image_text"))// 投票主题内容
          .fontSize($r("app.integer.voting_theme_image_text_font_size"))
      }

      // 投票动态UI
      Stack() {
        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Center }) {
          // 左边选项图案
          Stack() {
            // 使用Column绘制出胶囊块
            Column()// 设置左上和左下两个角为圆角
              .borderRadius(
                {
                  topLeft: $r("app.integer.fillet_radius"),
                  bottomLeft: $r("app.integer.fillet_radius"),
                  topRight: $r("app.integer.right_angle_radius"),
                  bottomRight: $r("app.integer.right_angle_radius")
                }
              )
              .backgroundColor(Constants.LEFT_COLOR)
              .opacity(this.fillOpacity)// 动态变化透明度
              .width(this.leftOptionWidth)// 选项宽度
              .height($r("app.integer.option_background_height"))
            // TODO：知识点2：使用if-else语句来控制点击前与点击后的显示不同
            if (!this.isClick) {
              Text(Constants.LEFT_OPTION)
                .fontColor(Color.White)
                .margin({ right: $r("app.integer.text_center_margin") })
            } else {
              Column() {
                Text(this.leftOptionWidth)
                  .fontColor(Constants.LEFT_COLOR)
                  .fontSize($r("app.integer.upper_text_font_size"))
                Text(Constants.LEFT_OPTION)
                  .fontColor(Constants.LEFT_COLOR)
                  .fontSize($r("app.integer.under_text_font_size"))
              }
            }
          }.onClick(() => {
            // 实现投票只能投一次的效果
            if (this.isClick) {
              return;
            }
            // 点击左边选项，则左边投票人数+1
            this.leftOptionChoose++;
            this.changeState(Constants.LEFT_OPTION);
          })

          Stack() {
            Column()
              .borderRadius(
                {
                  topLeft: $r("app.integer.right_angle_radius"),
                  bottomLeft: $r("app.integer.right_angle_radius"),
                  topRight: $r("app.integer.fillet_radius"),
                  bottomRight: $r("app.integer.fillet_radius")
                }
              )
              .backgroundColor(Constants.RIGHT_COLOR)
              .opacity(this.fillOpacity)
              .width(this.rightOptionWidth)
              .height($r("app.integer.option_background_height"))
            if (!this.isClick) {
              Text(Constants.RIGHT_OPTION)
                .fontColor(Color.White)
                .margin({ left: $r("app.integer.text_center_margin") })
            } else {
              Column() {
                Text(this.rightOptionWidth)
                  .fontColor(Constants.RIGHT_COLOR)
                  .fontSize($r("app.integer.upper_text_font_size"))
                Text(Constants.RIGHT_OPTION)
                  .fontColor(Constants.RIGHT_COLOR)
                  .fontSize($r("app.integer.under_text_font_size"))
              }
            }
          }.onClick(() => {
            if (this.isClick) {
              return;
            }
            // 点击右边选项，则右边投票人数+1
            this.rightOptionChoose++;
            this.changeState(Constants.RIGHT_OPTION);
          })
        }

        Stack() {
          // TODO：知识点3：使用绘制组件Polygon投票组件中间的平行四边形空隙效果
          Polygon()
            .points(this.points)
            .fill(Color.White)
            .stroke(Color.White)
            .antiAlias(true)
            .width($r("app.integer.polygon_width"))
            .height($r("app.integer.polygon_height"))
          // 点击前，空隙宽度稍微大一些，且其中有PK二字
          if (!this.isClick) {
            Text() {
              Span($r("app.string.mid_text_left"))
                .fontColor(Constants.LEFT_COLOR)
              Span($r("app.string.mid_text_right"))
                .fontColor(Constants.RIGHT_COLOR)
            }
            .fontSize($r("app.integer.mid_text_font_size"))
            .fontStyle(FontStyle.Italic)
            .fontWeight(Constants.MID_TEXT_FONT_WEIGHT)
            .textAlign(TextAlign.Center)
          }
        }
        // TODO：知识点4：因为Polygon是以一个矩形框为基准来绘制的，因此会受到这个矩形框的影响，使用position以及markAnchor来偏移，以抵消前述影响
        .position({ x: this.leftOptionWidth })
        .markAnchor({ x: $r("app.string.mid_gap_mark_anchor") })
      }.width($r("app.string.first_stack_width"))

      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween }) {
        // 提示
        Text(this.notice)
          .fontSize($r("app.integer.bottom_text_font_size"))
          .margin({ left: $r("app.integer.bottom_text_margin") })
        if (this.isClick) {
          Text(this.leftOptionChoose + this.rightOptionChoose + Constants.BOTTOM_TEXT_SUFFIX)
            .fontSize($r("app.integer.bottom_text_font_size"))
            .margin({ right: $r("app.integer.bottom_text_margin") })
        }
      }
    }
    .height($r("app.string.parent_column_height"))
    .width($r("app.string.parent_column_width"))
    .justifyContent(FlexAlign.Center)
  }
}

/**
 * 创建WrappedBuilder对象，动态路由跳转时构建页面
 */
@Builder
export function getVotingComponent(): void {
  VotingComponent();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.VOTING_COMPONENT,wrapBuilder(getVotingComponent));