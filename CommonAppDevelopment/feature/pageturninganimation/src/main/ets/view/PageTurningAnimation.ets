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

/**
 * 实现步骤
 * 1. 创建文本组件。创建时添加rotate属性，用来控制组件旋转。由于各组件旋转的角度和旋转中心不同，
 * 需要父组件在调用时传入对应的参数，所以为对应变量添加@Prop装饰器，用来控制变量传递。
 * 2. 创建父组件框架。由于文本组件分为上下两层，所以在父组件中采用Stack组件进行层叠布局。同时使用
 * Divider组件作为书籍两个页面间的分隔线。
 * 3.添加翻页动效。在父组件中定义对应的变量，并在调用子组件时分别传入子组件。自定义pageTurningAnimate
 * 函数，在其中使用animateTo方法添加动画效果，同时控制动画的时长，以及动画过程中各元素状态的改变。
 * 在aboutToAppear方法中，使用setInterval方法重复调用pageTurningAnimate函数，以实现连续翻页动效。
 */

// 单个页面
@Component
struct BookPage {
  // 为变量添加@Prop装饰器，用于接收父组件的动态传参
  @Prop pageNum: number; // 页面编号
  @Prop rotateAngle: number; // 旋转角度
  @Prop positionX: string; // 旋转中心点参数x,表示水平方向上旋转起始位置
  @Prop positionY: string; // 旋转中心点参数y,表示垂直方向上旋转起始位置

  build() {
    // TODO: 知识点: 创建文本组件。创建时添加rotate属性，用来控制组件旋转。
    Text(`${this.pageNum}`)
      .fontSize($r('app.integer.common_font_size'))
      .fontColor(Color.White)
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Center)
      .backgroundColor($r('app.color.common_color_dark_blue'))
      .width($r('app.string.common_text_width'))
      .height($r('app.string.common_text_height'))
      .borderRadius($r('app.integer.common_border_radius'))
      .rotate({
        // 使用rotate属性控制旋转
        x: 0,
        y: 1, // 指定y轴作为旋转轴
        z: 0,
        angle: this.rotateAngle,
        centerX: this.positionX,
        centerY: this.positionY,
      })
  }
}

@Component
export struct PageTurningAnimation {
  // 父组件变量设置，使用@State做状态管理
  @State originalAngle: number = 0; // 初始角度
  @State rotateAngleTextA: number = 0; // Text组件A的旋转角度
  @State rotateAngleTextB: number = 0; // Text组件B的旋转角度
  @State pageNumTextA: number = 0; // Text组件A的页面编号，用于刷新翻页动画结束时的页面编号
  @State animatePageNumTextB: number = 1; // Text组件B的页面编号，用于显示翻页动画的页面编号
  @State pageNumTextC: number = 0; // Text组件C的页面编号，用于占位不显示，在Text组件A的下层
  @State nextPageNumTextD: number = 0; // Text组件D的页面编号，用于刷新下一个翻页的页面编号
  @State leftX: string = '0%'; // 旋转中心点参数x,表示水平方向上旋转起始位置。本例中指定y轴作为旋转轴，所以这里设置'0%'表示旋转动效组件的左侧边缘位置作为旋转轴的水平起始点位置。
  @State leftY: string = '0%'; // 旋转中心点参数y,表示垂直方向上旋转起始位置。
  @State centerX: string = '50%'; // 旋转中心点参数x。本例中设置'50%'表示以组件的纵向中线为轴旋转。
  @State centerY: string = '50%'; // 旋转中心点参数y。

  // 在UI显示前，传入各项变量的具体值
  aboutToAppear(): void {
    // 通过setInterval函数每秒调用一次动画效果，实现连续翻页
    setInterval(() => {
      this.pageTurningAnimate();
    }, 1000) // 函数调用周期要大于每次动画持续的时长
  }

  // 通过animateTo方法为组件添加动效，动效时长要小于setInterval函数调用周期
  private pageTurningAnimate() {
    // TODO: 知识点: 使用animateTo方法添加动画效果，同时控制动画的时长，以及动画过程中各元素状态的改变。
    animateTo(
      {
        duration: 700, onFinish: () => {
        // 动画结束时，Text组件A显示的页面编号和B显示的页面编号相等
        this.pageNumTextA = this.animatePageNumTextB;
        // 动画结束时，Text组件A以中心线为轴旋转180度，用于显示左侧翻页动画结束时的页面编号
        this.rotateAngleTextA = 180;
        // 动画结束时，Text组件B的旋转角度重置为0度
        this.rotateAngleTextB = 0;
        // 动画结束时，Text组件B显示的页面编号加1
        this.animatePageNumTextB = (this.animatePageNumTextB + 1) % 8;
      }
      },
      () => {
        // 动画开始，Text组件B的旋转角度设置为180度
        this.rotateAngleTextB = 180;
        //动画开始，Text组件D的页面编号加1，用于刷新显示下一个翻页的页面编号
        this.nextPageNumTextD = this.animatePageNumTextB + 1;
      })
  }

  build() {
    // TODO: 知识点: 创建父组件框架。由于文本组件分为上下两层，所以在父组件中采用Stack组件进行层叠布局。同时使用Divider组件作为书籍两个页面间的分隔线。
    Stack() {
      // 下层Row
      Row() {
        // Text组件C，用于占位不显示，在Text组件A的下层
        BookPage({
          pageNum: this.pageNumTextC,
          rotateAngle: this.originalAngle,
          positionX: this.leftX,
          positionY: this.leftY
        })
        // Text组件D，用于刷新下一个翻页的页面编号
        BookPage({
          pageNum: this.nextPageNumTextD,
          rotateAngle: this.originalAngle,
          positionX: this.leftX,
          positionY: this.leftY
        })
      }

      // 上层Row
      Row() {
        // Text组件A的页面编号，用于刷新翻页动画结束时的页面编号
        BookPage({
          pageNum: this.pageNumTextA,
          rotateAngle: this.rotateAngleTextA,
          positionX: this.centerX,
          positionY: this.centerY
        })
        // Text组件B的页面编号，用于显示翻页动画的页面编号
        BookPage({
          pageNum: this.animatePageNumTextB,
          rotateAngle: this.rotateAngleTextB,
          positionX: this.leftX,
          positionY: this.leftY
        })
      }

      // 添加两个页面间的分隔线
      Divider().strokeWidth(5).color(Color.White).height($r('app.string.divider_height')).vertical(true)
    }
    .width($r('app.string.common_stack_width'))
    .height($r('app.string.common_stack_height'))
    .backgroundColor($r('app.color.stack_background_color'))
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getPageTurningAnimation(): void {
  PageTurningAnimation();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.PAGE_TURNING_ANIMATION, wrapBuilder(getPageTurningAnimation));