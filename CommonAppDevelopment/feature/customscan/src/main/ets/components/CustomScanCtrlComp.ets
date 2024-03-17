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

import CommonConstants from '../common/constants/CommonConstants';
import CustomScanViewModel from '../viewmodel/CustomScanViewModel';

/**
  * 扫码控制组件
  * 实现步骤：
  * 1.通过重复显式动画，依赖divider组件位移，展示扫描动画效果
  * 2.闪光灯按钮支持相机闪光灯开启和关闭
  */
@Component
export default struct CustomScanCtrlComp {
  // 主工程navgation路由栈
  @Consume('pageStack') pageStack: NavPathStack;
  // 自定义扫码vm实例
  @State customScanVM: CustomScanViewModel = CustomScanViewModel.getInstance();
  // 扫码动画组件偏移量
  @State dividerOffset: number = CommonConstants.SCAN_DIVIDER_OFFSET_BEGIN;
  // 扫码动画组件透明度
  @State dividerOpacity: number = CommonConstants.SCAN_DIVIDER_OPACITY_BEGIN;
  // 相机闪光灯开启状态
  @State isCameraLightOpen: boolean = false;

  aboutToAppear() {
    // 设置扫描动画
    this.setQRCodeScanAnimation();
    // 注册闪光灯状态回调
    this.customScanVM.regCameraLightUpdateListener((isOpen: boolean) => {
      console.log('regCameraLightUpdateListener', isOpen);
      this.isCameraLightOpen = isOpen;
    })
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        // 自定义退出按钮
        Image($r('app.media.scan_close'))
          .width(CommonConstants.SCAN_CTRL_BTN_CLOSE_SIZE)
          .height(CommonConstants.SCAN_CTRL_BTN_CLOSE_SIZE)
          .fillColor(Color.White)
          .backgroundColor(Color.Gray)
          .alignSelf(ItemAlign.Start)
          .margin({
            top: $r('app.integer.btn_scan_close_margin_top'),
            left: $r('app.integer.btn_scan_close_margin_left')
          })
          .padding($r('app.integer.btn_scan_close_padding'))
          .clip(new Circle({
            width: CommonConstants.SCAN_CTRL_BTN_CLOSE_SIZE,
            height: CommonConstants.SCAN_CTRL_BTN_CLOSE_SIZE
          }))
          .onClick(() => {
            this.pageStack.pop();
          })
        // 自定义退出按钮
        Image($r('app.media.scan_picture'))
          .width(CommonConstants.SCAN_CTRL_BTN_CLOSE_SIZE)
          .height(CommonConstants.SCAN_CTRL_BTN_CLOSE_SIZE)
          .fillColor(Color.White)
          .backgroundColor(Color.Gray)
          .alignSelf(ItemAlign.Start)
          .margin({
            top: $r('app.integer.btn_scan_close_margin_top'),
            right: $r('app.integer.btn_scan_close_margin_left')
          })
          .padding($r('app.integer.btn_scan_close_padding'))
          .clip(new Circle({
            width: CommonConstants.SCAN_CTRL_BTN_CLOSE_SIZE,
            height: CommonConstants.SCAN_CTRL_BTN_CLOSE_SIZE
          }))
          .onClick(() => {
            this.customScanVM.openSysPicture();
          })
      }

      // 扫描动画组件
      Column() {
        Divider()
          .width('100%')
          .strokeWidth(CommonConstants.SCAN_DIVIDER_STROKE_WIDTH)
          .position({ x: 0, y: 0 })
          .translate({ x: 0, y: this.dividerOffset })
          .opacity(this.dividerOpacity)
          .backgroundColor(Color.Blue)
      }
      .width($r('app.string.scan_ani_width'))
      .height($r('app.string.scan_ani_height'))

      // 扫描二维码文案
      Text($r('app.string.text_put_code_to_scan'))
        .height($r('app.string.text_scan_height'))
        .fontSize($r('app.integer.text_scan_font_size'))
        .fontColor(Color.White)
        .margin({ top: $r('app.integer.text_scan_margin_top') })

      // 闪光灯按钮，启动相机流后才能使用
      Image($r('app.media.scan_camera_light'))
        .width(CommonConstants.SCAN_CTRL_BTN_LIGHT_SIZE)
        .height(CommonConstants.SCAN_CTRL_BTN_LIGHT_SIZE)
        .fillColor(this.isCameraLightOpen ? Color.Yellow : Color.White)
        .onClick(() => {
          this.customScanVM.updateFlashLightStatus();
        })
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 扫描动画
   * @returns {void}
   */
  setQRCodeScanAnimation(): void {
    // TODO：知识点：显式设置扫描属性动画，根据偏移量和透明度变化，重复播放动画
    animateTo(CommonConstants.SCAN_ANI_CONFIG, () => {
      // 扫描动画结束Y坐标
      this.dividerOffset = CommonConstants.SCAN_DIVIDER_OFFSET_END;
      // 扫描动画结束透明度
      this.dividerOpacity = CommonConstants.SCAN_DIVIDER_OPACITY_END;
    })
  }
}
