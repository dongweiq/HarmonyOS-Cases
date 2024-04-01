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

import { image } from '@kit.ImageKit';
import { matrix4, window } from '@kit.ArkUI';
import { OffsetModel } from '../model/OffsetModel';
import { ScaleModel } from '../model/ScaleModel';
import { runWithAnimation } from '../utils/FuncUtils';
import { windowSizeManager } from '../utils/Managers';
import { BusinessError } from '@kit.BasicServicesKit';

// TODO：知识点：组件复用
@Reusable
@Component
export struct ImageItemView {
  @Consume private bgc: Color;
  @Link isEnableSwipe: boolean; // TODO：需求：多图切换
  @State isEnableOffset: boolean = false;
  @State imageScaleInfo: ScaleModel = new ScaleModel(1.0, 1.0, 1.5, 0.3);
  @State imageOffsetInfo: OffsetModel = new OffsetModel(0, 0);
  @State matrix: matrix4.Matrix4Transit = matrix4.identity().copy();
  @State imagePixelMap: image.PixelMap | null = null; // 当前图片pixelMap，用于Image组件显示
  @State fitWH: "width" | "height" | undefined = undefined; // 表示当前图片是根据宽度适配还是高度适配
  @State imageDefaultSize: image.Size = { width: 0, height: 0 }; // 图片默认大小，即，与屏幕大小最适配的显示大小
  imageUri: string = ""; // 当前图片uri
  imageWHRatio: number = 0; // 图片原始宽高比

  aboutToAppear(): void {
    this.initCurrentImageInfo();
  }

  /**
   * 根据图片宽高比及窗口大小计算图片的默认宽高，即，图片最适配屏幕的大小
   * @param imageWHRatio：图片原始宽高比
   * @param size：窗口大小{with:number,height:number}
   * @returns image.Size
   */
  calcImageDefaultSize(imageWHRatio: number, size: window.Size): image.Size {
    let width = 0
    let height = 0;
    if (imageWHRatio > size.width / size.height) {
      // 图片宽高比大于屏幕宽高比，图片默认以屏幕宽度进行显示
      width = size.width;
      height = size.width / imageWHRatio;
    } else {
      height = size.height;
      width = size.height * imageWHRatio;
    }
    return { width: width, height: height };
  }

  /**
   * TODO：知识点：根据图片大小（宽高<=屏幕宽高）和屏幕大小计算图片放大适配屏幕进行显示的缩放倍率
   * @param imageSize：图片当前大小
   * @param windowSize：窗口大小
   * @returns：缩放倍率
   */
  calcFitScaleRatio(imageSize: image.Size, windowSize: window.Size): number {
    let ratio: number = 1.0;
    if (windowSize.width > imageSize.width) {
      ratio = windowSize.width / imageSize.width;
    } else {
      ratio = windowSize.height / imageSize.height;
    }
    return ratio;
  }

  /**
   * 设置当前图片的相关信息：uri、whRatio、pixelMap、fitWH、defaultSize、maxScaleValue
   * TODO：知识点：提前获取图片的信息，以进行Image组件的尺寸设置及后续的相关计算
   */
  initCurrentImageInfo(): void {
    this.matrix = matrix4.identity().copy();
    const imageSource: image.ImageSource = image.createImageSource(this.imageUri);
    imageSource.getImageInfo(0).then((data: image.ImageInfo) => {
      this.imageWHRatio = data.size.width / data.size.height;
      this.imageDefaultSize = this.calcImageDefaultSize(this.imageWHRatio, windowSizeManager.get());
      if (this.imageDefaultSize.width === windowSizeManager.get().width) {
        this.fitWH = "width";
      } else {
        this.fitWH = "height";
      }
      this.imageScaleInfo.maxScaleValue += this.fitWH === "width" ?
        (windowSizeManager.get().height / this.imageDefaultSize.height) :
        (windowSizeManager.get().width / this.imageDefaultSize.width);
    }).catch((err: BusinessError) => {
      console.error(`[error][getImageInfo]${err.message}`);
    });
    imageSource.createPixelMap().then((data: image.PixelMap) => {
      this.imagePixelMap = data;
    }).catch((err: BusinessError) => {
      console.error(`[error][createPixelMap]${err.message}`);
    });
    this.isEnableOffset = false;
    this.imageScaleInfo.reset();
    this.imageOffsetInfo.reset();
  }

  /**
   * 在图片消失时，将当前图片的信息设置为默认值
   */
  resetCurrentImageInfo(): void {
    this.imageScaleInfo.reset();
    this.imageOffsetInfo.reset();
    this.matrix = matrix4.identity().copy();
  }

  /**
   * TODO：需求：在偏移时评估是否到达边界，以便进行位移限制与图片的切换
   * @returns：长度为4的boolean数组，表示上下左右是否到达边界
   */
  evaluateBound(): boolean[] {
    return [false, false, false, false];
  }

  build() {
    Stack() {
      Image(this.imagePixelMap)// TODO：知识点：宽高只根据其尺寸设置一个，通过保持宽高比来设置另一个属性
        .width(this.fitWH === "width" ? $r("app.string.image_default_width") : undefined)
        .height(this.fitWH === "height" ? $r("app.string.image_default_height") : undefined)
        .aspectRatio(this.imageWHRatio)
        .objectFit(ImageFit.Cover)// TODO：知识点：保持宽高比进行缩放，可以超出父组件，以便实现多图切换的增强功能
        .autoResize(false)
        .transform(this.matrix)// TODO：知识点：通过matrix控制图片的缩放
        .defaultFocus(true)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .offset({
          // TODO：知识点：通过offset控制图片的偏移
          x: this.imageOffsetInfo.currentX,
          y: this.imageOffsetInfo.currentY
        })
    }
    .onBlur(() => {
      this.resetCurrentImageInfo();
    })
    .backgroundColor(this.bgc)
    .alignContent(Alignment.Center)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .width($r("app.string.image_item_stack_width"))
    .height($r("app.string.image_item_stack_height"))
    .gesture(
      GestureGroup(
        GestureMode.Exclusive,
        // TODO：知识点：双击切换图片大小
        TapGesture({ count: 2 })
          .onAction(() => {
            let fn: Function;
            // 已经是放大状态下，双击缩小
            if (this.imageScaleInfo.scaleValue > this.imageScaleInfo.defaultScaleValue) {
              fn = () => {
                this.isEnableSwipe = true;
                this.imageScaleInfo.reset();
                this.imageOffsetInfo.reset();
                this.matrix = matrix4.identity().copy();
              };
            } else {
              // 已经是缩小状态，双击放大
              fn = () => {
                this.isEnableSwipe = false;
                const ratio: number = this.calcFitScaleRatio(this.imageDefaultSize, windowSizeManager.get());
                this.imageScaleInfo.scaleValue = ratio;
                this.imageOffsetInfo.reset();
                this.matrix = matrix4.identity().scale({
                  x: ratio,
                  y: ratio,
                }).copy();
                this.imageScaleInfo.stash();
              }
            }
            runWithAnimation(fn);
          }),
        // 单击切换背景色
        TapGesture({ count: 1 }).onAction(() => {
          runWithAnimation(() => {
            this.bgc = this.bgc === Color.White ? Color.Black : Color.White;
          });
        }),
        // TODO：知识点：双指捏合缩放图片
        PinchGesture({ fingers: 2, distance: 1 })
          .onActionUpdate((event: GestureEvent) => {
            this.imageScaleInfo.scaleValue = this.imageScaleInfo.lastValue * event.scale;
            // TODO：知识点：缩放时不允许大于最大缩放因子+额外缩放因子，不允许小于默认大小-额外缩放因子，额外缩放因子用于提升用户体验
            if (this.imageScaleInfo.scaleValue > this.imageScaleInfo.maxScaleValue *
              (1 + this.imageScaleInfo.extraScaleValue)
            ) {
              this.imageScaleInfo.scaleValue = this.imageScaleInfo.maxScaleValue *
                (1 + this.imageScaleInfo.extraScaleValue);
            }
            if (this.imageScaleInfo.scaleValue < this.imageScaleInfo.defaultScaleValue *
              (1 - this.imageScaleInfo.extraScaleValue)) {
              this.imageScaleInfo.scaleValue = this.imageScaleInfo.defaultScaleValue *
                (1 - this.imageScaleInfo.extraScaleValue);
            }
            // TODO：知识点：matrix默认缩放中心为组件中心
            this.matrix = matrix4.identity().scale({
              x: this.imageScaleInfo.scaleValue,
              y: this.imageScaleInfo.scaleValue,
            }).copy();
            console.debug(this.imageScaleInfo.toString());
          })
          .onActionEnd((event: GestureEvent) => {
            /**
             * TODO：知识点：当小于默认大小时，恢复为默认大小
             */
            if (this.imageScaleInfo.scaleValue < this.imageScaleInfo.defaultScaleValue) {
              runWithAnimation(() => {
                this.imageScaleInfo.reset();
                this.imageOffsetInfo.reset();
                this.matrix = matrix4.identity().copy();
              })
            }
            // TODO：知识点：当大于最大缩放因子时，恢复到最大
            if (this.imageScaleInfo.scaleValue > this.imageScaleInfo.maxScaleValue) {
              runWithAnimation(() => {
                this.imageScaleInfo.scaleValue = this.imageScaleInfo.maxScaleValue;
                this.matrix = matrix4.identity()
                  .scale({
                    x: this.imageScaleInfo.maxScaleValue,
                    y: this.imageScaleInfo.maxScaleValue
                  });
              })
            }
            this.imageScaleInfo.stash();
          }),
        // TODO：知识点：滑动图片
        PanGesture({ fingers: 1 })// TODO：需求：默认大小下左右滑动应当是切换图片
          .onActionUpdate((event: GestureEvent) => {
            if (this.imageScaleInfo.scaleValue === this.imageScaleInfo.defaultScaleValue) {
              // 默认大小下不允许移动
              return;
            }
            this.imageOffsetInfo.currentX = this.imageOffsetInfo.lastX + event.offsetX;
            this.imageOffsetInfo.currentY = this.imageOffsetInfo.lastY + event.offsetY;
          })
          .onActionEnd((event: GestureEvent) => {
            this.imageOffsetInfo.stash();
          })
      ),
    )
  }
}