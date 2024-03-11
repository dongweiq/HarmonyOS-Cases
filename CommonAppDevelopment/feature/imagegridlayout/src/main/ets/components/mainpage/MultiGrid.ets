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

// 常量定义
const COLUMNS_0 = 0;
const COLUMNS_1 = 1;
const COLUMNS_2 = 2;
const COLUMNS_3 = 3;
const IMAGE_SET_SIZE_1 = 1;
const IMAGE_SET_SIZE_4 = 4;
const IMAGE_SET_SIZE_9 = 9;
const IMAGE_ASPECT_RATIO_0 = 0;


// 九宫格图片布局实现
@Component
export struct MultiGrid {
  @Prop modifier: AttributeModifier<ImageAttribute> | null = null;
  private imageSource: (string | Resource)[] = [];
  private flexWidth: string = '75%';
  private col: number = 0;
  private row: number = 0;
  private imageSpacing: number = 3;
  private imageWidth: string = '';
  private imageAspectRatio: number = 1;
  private imageFit: ImageFit = ImageFit.Fill;
  private arraySize: number = 0;

  aboutToAppear() {
    this.arraySize = this.imageSource.length
    // 未传入col值时所走的逻辑，此时图片按默认方式布局
    if (this.col <= COLUMNS_0) {
      this.arraySize = Math.min(this.imageSource.length, IMAGE_SET_SIZE_9)
      this.row = Math.ceil(this.arraySize / COLUMNS_3)

      // 不同数量的图片对应不同的参数、布局
      if (this.arraySize === IMAGE_SET_SIZE_1) {
        this.col = COLUMNS_1
        this.imageAspectRatio = IMAGE_ASPECT_RATIO_0
        this.imageFit = ImageFit.Contain
        this.imageWidth = '60%'
      } else if (this.arraySize === IMAGE_SET_SIZE_4) {
        this.col = COLUMNS_2
        this.flexWidth = '50%'
        this.imageWidth = `calc((100% - ${this.imageSpacing}vp ) / 2)`
      }
      else {
        this.col = COLUMNS_3
        this.imageWidth = `calc((100% - ${this.imageSpacing * COLUMNS_2}vp ) / 3)`
      }
    }
    // 传入col值时所走的逻辑，此时图片传入的col值进行布局
    else {
      this.row = Math.ceil(this.arraySize / this.col)
      this.imageWidth = `calc((100% - ${this.imageSpacing * (this.col - 1)}vp ) / ${this.col})`
    }

  }

  build() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
      ForEach(this.imageSource.slice(0, this.arraySize), (item: string | Resource, idx: number) => {
        Image(item)
          .attributeModifier(this.modifier)
          .autoResize(true)
          .objectFit(this.imageFit)
          .aspectRatio(this.imageAspectRatio)
          .width(this.imageWidth)
          .margin(
            {
              bottom: (idx + 1) > ((this.row - 1) * this.col) ? 0 : this.imageSpacing,
              right: (idx + 1) % this.col === 0 ? 0 : this.imageSpacing
            }
          )
      })
    }
    .width(this.flexWidth)
  }
}