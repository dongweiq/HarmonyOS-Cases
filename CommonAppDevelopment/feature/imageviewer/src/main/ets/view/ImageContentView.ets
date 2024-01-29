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

import { ImageScaleModel } from '../model/ImageScaleModel';
import { ImageViewerConstants } from '../constants/ImageViewerConstants';
import { ImagePositionModel } from '../model/ImagePositionModel';
import window from '@ohos.window';
import { BusinessError } from '@ohos.base';

@Component
export struct ImageContentView {
  @State imageScale: ImageScaleModel = new ImageScaleModel(1, 1);
  // windowHeight与windowWidth在entryAbility中进行设置，单位px
  @State windowWidth: number = 0;
  @State windowHeight: number = 0;
  swiperController: SwiperController | undefined;
  image: Resource = $r("app.media.test1");
  @State imagePosition: ImagePositionModel = new ImagePositionModel();
  @Consume('pageStack') pageInfo: NavPathStack;

  /**
   * 获取应用主窗口的宽高
   */
  aboutToAppear() {
    window.getLastWindow(getContext(this), (err: BusinessError, data: window.Window) => {
      let rect: window.Rect = data.getWindowProperties().windowRect;
      this.windowWidth = px2vp(rect.width);
      this.windowHeight = px2vp(rect.height);
      data.on("windowSizeChange", (size: window.Size) => {
        this.windowWidth = px2vp(size.width);
        this.windowHeight = px2vp(size.height);
      })
    })
  }

  /**
   * 在图片缩放时，保证图片的缩放中心始终保持在原始位置
   * 通常紧跟在图片的缩放之后使用
   * @param targetX：缩放中心的x轴坐标
   * @param targetY：缩放中心的y轴坐标
   * @param eventScale：当前缩放因子的大小
   */
  moveToOriginAfterScale(targetX: number, targetY: number, eventScale: number) {
    this.imagePosition.currentX = targetX - (targetX - this.imagePosition.lastX) * eventScale;
    this.imagePosition.currentY = targetY - (targetY - this.imagePosition.lastY) * eventScale;
  }

  build() {
    Image(this.image)
      .width(this.windowWidth * this.imageScale.scaleValue)
      .height(this.windowHeight * this.imageScale.scaleValue)
      .objectFit(ImageFit.Contain)
      .position({ x: this.imagePosition.currentX, y: this.imagePosition.currentY })
      .gesture(
        GestureGroup(
          GestureMode.Exclusive,
          // TODO: 知识点：双击时进行图片的大小切换
          TapGesture({ count: 2 }).onAction((event: GestureEvent) => {
            if (this.imageScale.scaleValue > this.imageScale.defaultScaleValue) {
              animateTo({ duration: ImageViewerConstants.SCALE_DURATION }, () => {
                this.imageScale.reset();
                this.imagePosition.reset();
              })
            } else {
              animateTo({ duration: ImageViewerConstants.SCALE_DURATION }, () => {
                // 记录点击的位置
                let targetX: number = event.fingerList[0].globalX;
                let targetY: number = event.fingerList[0].globalY;
                // 缩放
                this.imageScale.scaleValue = this.imageScale.defaultMaxScaleValue;
                // 偏移
                this.moveToOriginAfterScale(targetX, targetY, this.imageScale.scaleValue)
                this.imageScale.stash();
                this.imagePosition.stash();
              })
            }
          }),
          // TODO: 知识点：双指捏合时进行图片的缩放，并通过在onActionUpdate中调整图片的位置保持图片的缩放中心位置不变
          PinchGesture({ fingers: 2 })
            .onActionUpdate((event: GestureEvent) => {
              this.imageScale.scaleValue = this.imageScale.pinchValue * event.scale;
              this.moveToOriginAfterScale(event.pinchCenterX, event.pinchCenterY, event.scale);
            })
            .onActionEnd((event: GestureEvent) => {
              if (this.imageScale.scaleValue < this.imageScale.defaultScaleValue) {
                animateTo({ duration: ImageViewerConstants.SCALE_DURATION }, () => {
                  this.imageScale.reset();
                  this.imagePosition.reset();
                })
              }
              this.imageScale.stash();
              this.imagePosition.stash();
            }),
          // TODO: 知识点：拖动图片进行位移，这里通过设置image组件的position来实现
          PanGesture({ direction: PanDirection.All, fingers: 1 }).onActionUpdate((event: GestureEvent) => { // 拖动
            this.imagePosition.currentX = event.offsetX + this.imagePosition.lastX;
            this.imagePosition.currentY = event.offsetY + this.imagePosition.lastY;
          }).onActionEnd((event: GestureEvent) => {
            this.imagePosition.stash();
            // 避免图片左右边框离开屏幕边缘
            if (this.imagePosition.currentX * -1 > this.windowWidth * (this.imageScale.scaleValue - 1)) { // 图片右边缘的位置<屏幕右边缘的位置，切换下一张
              animateTo({ duration: ImageViewerConstants.SCALE_DURATION }, () => {
                this.imagePosition.currentX = this.windowWidth * (this.imageScale.scaleValue - 1) * (-1);
              })
            } else if (this.imagePosition.currentX > 0) {
              animateTo({ duration: ImageViewerConstants.SCALE_DURATION }, () => {
                this.imagePosition.currentX = 0;
              })
            }
          }),
          TapGesture({ fingers: 1 }).onAction(() => {
            this.pageInfo.pop();
          })
        )
      )
  }
}