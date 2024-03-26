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

/**
 * 实现步骤：
 *  1. 通过双重ForEach循环分别横向、纵向渲染数字。
 *  2. 通过Math.random()生成随机数，并更新到currentData数组中。
 *  3. 使用显示动画animateTo，对currentData数组中的每个数字执行不同的滚动动效。
 *  4. 设置数字所在容器属性.clip(true)，将多余的数字裁剪。
 */

import { DATA_CONFIG, STYLE_CONFIG } from '../model/ConstData';

@Component
export struct DigitalScrollDetail {
  private dataItem: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]; // 数据项
  @State scrollYList: number[] = []; // 数字Y轴滚动位移集合
  private currentData: number[] = new Array(DATA_CONFIG.NUMBER_LEN).fill(0); // 当前数据值
  private preData: number[] = new Array(DATA_CONFIG.NUMBER_LEN).fill(0); // 上一次数据值
  @Prop @Watch('onDataRefresh') isRefresh: boolean; // 是否刷新

  /**
   * 监听到刷新状态变化，执行回调
   */
  onDataRefresh() {
    if (this.isRefresh === false) {
      this.refreshData();
    }
  }

  /**
   * 更新当前显示数据
   */
  refreshData() {
    let tempArr: number[] = [];
    for (let i = 0; i < DATA_CONFIG.NUMBER_LEN; i++) {
      tempArr.push(Math.floor(Math.random() * 10)); // 向数组添加随机数
    }
    this.currentData = tempArr; // 更新当前数据
    // 性能知识点：forEach场景下，每个列表项都会创建animateTo对象，要注意不能进行大数据量的遍历创建过多动画对象导致内存占用问题
    this.currentData.forEach((item: number, index: number) => {
      animateTo({
        // TODO:知识点：1.根据上一次数据值，计算差值。差值越大，执行动画时长越长。
        duration: Math.abs(item - this.preData[index]) * DATA_CONFIG.DURATION_TIME,
        curve: Curve.LinearOutSlowIn, // 减速曲线
        onFinish: () => {
          this.preData = this.currentData; // 动画执行结束后，更新上一次数据值
          this.isRefresh = false; // 刷新完毕
        }
      },
        () => {
          this.scrollYList[index] = -item * STYLE_CONFIG.ITEM_HEIGHT; // 更新每个数字Y轴偏移量
        })
    })
  }

  build() {
    Row() {
      // 性能知识点：数据量小并且可确定的场景，使用ForEach进行循环渲染。
      ForEach(this.currentData, (item: number, index: number) => {
        if ((DATA_CONFIG.NUMBER_LEN - index) % DATA_CONFIG.MILLENNIAL_LEN === 0 && index !== 0) {
          Text($r('app.string.comma'))
            .fontColor($r('sys.color.ohos_id_color_palette9'))
        }

        Column() {
          Column() {
            ForEach(this.dataItem, (subItem: number) => {
              Text(subItem.toString())
                .fontColor(Color.Orange)
                .fontWeight(FontWeight.Bold)
                .height($r('app.string.max_size'))
                .textAlign(TextAlign.Center)
            })
          }
          .translate({ x: 0, y: this.scrollYList[index] })
        }
        .height(STYLE_CONFIG.ITEM_HEIGHT)
        .clip(true) // 裁剪超出容器的视图
      })
    }
  }
}

