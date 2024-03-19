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
  Controller, // 引导页控制器
  GuidePage, // 引导页配置
  HighLightGuideBuilder, // 引导页通用配置项的构建类
  HighLightGuideComponent, // 引导页组件
  HighLightOptionsBuilder, // 高亮区域的额外配置构建类实例
  HighLightShape, // 高亮区域的形状
  OnGuideChangedListener, // 为引导页组件添加显示/移除监听
  OnHighLightDrewListener, // 高亮区域的图形重绘事件
  OnPageChangedListener, // 为引导页组件添加引导页页面切换监听
  RectF // 形状类型
} from '@ohos/high_light_guide';
import { AnimatorOptions } from '@ohos.animator';
import { Tab } from '../model/Tabs';
import promptAction from '@ohos.promptAction';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter';

/**
 * 1.在需要使用的页面引入high_light_guide库中的引导页组件。
 * 2.初始化引导页构建类，通过addHighLight绑定对应id组件的高光。
 * 3.添加引导页布局。
 * 4.自定义Builder，分别设定基础布局和引导层内容。
 */

const DURATION = 600;
const DELAY = 0;
const ITERATIONS = 1;
const BEGIN = 0.0;
const END = 1.0;
const RADIUS = 2;
const DIFF = 10;
const START_ANGLE = 0;
const END_ANGLE = 360;

@Component
export struct HighLightGuide {
  private builder: HighLightGuideBuilder | null = null;
  private controller: Controller | null = null;
  // 设定进入动画参数
  private enterAnimatorParam: AnimatorOptions = {
    duration: DURATION,
    easing: 'friction',
    delay: DELAY,
    fill: 'forwards',
    direction: 'normal',
    iterations: ITERATIONS,
    begin: BEGIN,
    end: END
  };
  // 设定退出动画参数
  private exitAnimatorParam: AnimatorOptions = {
    duration: DURATION,
    easing: 'friction',
    delay: DELAY,
    fill: 'forwards',
    direction: 'normal',
    iterations: ITERATIONS,
    begin: END,
    end: BEGIN
  };
  private visibleChangeListener: OnGuideChangedListener = {
    onShowed: (controller: Controller) => {
      // 此处可自定义显示后逻辑;
    },
    onRemoved: (controller: Controller) => {
      // 此处可自定义移除后逻辑;
    }
  };
  private pageChangeListener: OnPageChangedListener = {
    onPageChanged: (pageIndex: number) => {
      // 此处可添加监听逻辑;
    }
  };

  aboutToAppear() {
    // 自定义高光形状
    let onDrewListener: OnHighLightDrewListener = {
      onHighLightDrew(context2d: CanvasRenderingContext2D, rectF: RectF) {
        context2d.strokeStyle = '#ffffff';
        let radius = Math.max(rectF.getWidth(), rectF.getHeight()) / RADIUS - DIFF;
        context2d.arc(rectF.getCenterX(), rectF.getCenterY(), radius, START_ANGLE, END_ANGLE, false);
        context2d.fill();
        context2d.lineWidth = 2;
      }
    }
    let options = new HighLightOptionsBuilder().setOnHighLightDrewListener(onDrewListener).build();
    // 设定高光组件
    this.builder = new HighLightGuideBuilder()
      .setLabel('guide')
      .alwaysShow(true)// 总是显示，调试时可以打开
      .setOnGuideChangedListener(this.visibleChangeListener)
      .setOnPageChangedListener(this.pageChangeListener)
      .addGuidePage(GuidePage.newInstance()// 设定第一处提示
        .setEverywhereCancelable(true)// 允许点击任意处关闭
        .addHighLightWithOptions('test', HighLightShape.CIRCLE, options)
        .setHighLightIndicator(this.firstIndicator)
        .setEnterAnimation(this.enterAnimatorParam)
        .setExitAnimation(this.exitAnimatorParam))
      .addGuidePage(GuidePage.newInstance()// 设定第二处提示
        .setHighLightIndicator(this.secondIndicator)
        .setEnterAnimation(this.enterAnimatorParam)
        .setExitAnimation(this.exitAnimatorParam))
      .addGuidePage(GuidePage.newInstance()// 设定第三处提示
        .setEverywhereCancelable(false)
        .setHighLightIndicator(this.thirdIndicator));
  }

  build() {
    Stack() {
      // 添加引导页布局
      HighLightGuideComponent({
        highLightContainer: this.highLightComponent,
        currentHLIndicator: null,
        builder: this.builder,
        onReady: (controllerParam: Controller) => {
          this.controller = controllerParam;
          this.controller.show();
        }
      })
    }
    .height('100%')
    .width('100%')
  }

  @Builder
  highLightComponent() {
    //布局页面
    Column() {
      Tab()
    }
    .alignItems(HorizontalAlign.Center)
  }

  // 功能引导部分布局
  @Builder
  firstIndicator() {
    Column() {
      Text($r('app.string.new_show'))
        .textAlign(TextAlign.Center)
        .fontColor(Color.White)
        .width('70%')
        .onClick(() => {
          if (this.controller) {
            this.controller.showPage(1);
          }
        })
        .margin({ left: $r('app.integer.common_margin') })
      Image($r('app.media.ic_gallery_sort_order'))
        .width($r('app.integer.sort_order_width'))
        .height($r('app.integer.sort_order_width'))
        .margin({ top: $r('app.integer.common_margin_top') })
        .onClick(() => {
          if (this.controller) {
            this.controller.showPage(1);
          }
        })
    }
    .width('100%')
    .position({ x: "48", y: '31%' })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  secondIndicator() {
    Column() {
      Row() {
        Text($r('app.string.custom_show'))
          .fontColor(Color.Black)
      }
      .backgroundColor($r('app.color.module_back_ground'))
      .justifyContent(FlexAlign.Center)
      .width($r('app.integer.first_indicator_width'))
      .height($r('app.integer.first_indicator_height'))
      .borderRadius($r('app.integer.border_radius'))

      Text($r('app.string.tips'))
        .fontColor(Color.White)
        .margin($r('app.integer.common_margin'))
      Button($r('app.string.access'))
        .fontColor(Color.White)
        .fontSize($r('app.integer.access_font_size'))
        .backgroundColor($r('app.color.first_direct_background'))
        .border({ width: 1, color: Color.White })
        .width($r('app.integer.high_light_button_width'))
        .onClick(() => {
          if (this.controller) {
            this.controller.showPage(2);
          }
        })
    }
    .width('100%')
    .height('100%')
    .position({ y: '30%' })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  thirdIndicator() {
    Column()
      .onAppear(() => {
        promptAction.showDialog({
          message: $r('app.string.show_prompt'),
          buttons: [
            {
              text: $r('app.string.agree'),
              color: $r('app.color.toast_success_back_ground')
            }
          ],
        }).then(() => {
          if (this.controller) {
            this.controller.remove();
          }
        })
      })

  }
}

@Builder
export function getImageCommentView(): void {
  HighLightGuide();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.LIGHT, wrapBuilder(getImageCommentView));