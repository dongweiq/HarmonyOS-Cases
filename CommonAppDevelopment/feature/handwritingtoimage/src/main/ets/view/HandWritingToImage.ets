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

import componentSnapshot from '@ohos.arkui.componentSnapshot';
import { image } from '@kit.ImageKit';
import fs from '@ohos.file.fs';
import { FunctionDescription, logger } from '@ohos/base';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter';
import { MyRenderNode, MyNodeController } from '../model/RenderNodeModel';

const TAG = 'HandWritingToImageView';
const MAX_LINES: number = 1; // Text最大行数设置为1
const LAYOUT_WEIGHT: number = 1; // 属性layoutWeight设置为1，自动分配剩余空间
const NODE_CONTAINER_ID = 'root'; // 组件NodeContainer的id

/**
 * 实现步骤：
 *  1. 创建NodeController的子类MyNodeController，用于获取根节点的RenderNode和绑定的NodeContainer组件宽高。
 *  2. 创建RenderNode的子类MyRenderNode，初始化画笔和绘制path路径。
 *  3. 创建变量currentNode用于存储当前正在绘制的节点，变量nodeCount用来记录已挂载的节点数量。
 *  4. 创建自定义节点容器组件NodeContainer，接收MyNodeController的实例，将自定义的渲染节点挂载到组件上，实现自定义绘制。
 *  5. 在NodeContainer组件的onTouch回调函数中，手指按下创建新的节点并挂载到rootRenderNode，nodeCount加一，手指移动更新节点中的path对象，绘制移动轨迹，并将节点重新渲染。
 *  6. rootRenderNode调用getChild方法获取最后一个挂载的子节点，再使用removeChild方法移除，实现撤销上一笔的效果。
 *  7. 使用clearChildren清除当前rootRenderNode的所有子节点，实现画布重置，nodeCount清零。
 *  8. 使用componentSnapshot.get获取组件NodeContainer的PixelMap对象，用于保存图片。
 *  9. ImagePacker.packToFile()可直接将PixelMap对象写入为图片；ImagePacker.packing()可获取图片的ArrayBuffer数据，再使用fs将数据写入为图片。
 */

@Component
export struct HandWritingToImageView {
  @State filePath: string = ''; // 保存图片后的文件路径
  private myNodeController: MyNodeController = new MyNodeController();
  private currentNode: MyRenderNode | null = null; // 当前正在绘制的节点
  private nodeCount: number = 0; // 已挂载到根节点的子节点数量

  build() {
    Column() {
      // 功能描述
      FunctionDescription({
        title: $r('app.string.hand_writing_title'),
        content: $r('app.string.hand_writing_description')
      })
        .margin({ top: 30, bottom: $r('app.integer.hand_writing_margin_bottom') })
      // 画布
      Row() {
        // TODO：知识点：自定义节点容器组件NodeContainer，接收MyNodeController的实例，将自定义的渲染节点挂载到组件上，实现自定义绘制
        NodeContainer(this.myNodeController)
          .width('100%')
          .height($r('app.integer.hand_writing_canvas_height'))
          .onTouch((event: TouchEvent) => {
            this.onTouchEvent(event);
          })
          .id(NODE_CONTAINER_ID)
      }
      .border({
        width: $r('app.integer.hand_writing_border_width'),
        style: BorderStyle.Dashed,
        color: $r('app.color.hand_writing_border_color')
      })
      .margin({ bottom: $r('app.integer.hand_writing_margin_bottom') })

      // 控制按钮
      Row() {
        Button($r('app.string.hand_writing_revert'), { buttonStyle: ButtonStyleMode.NORMAL })
          .onClick(() => {
            this.goBack();
          })
          .width('40%')
        Button($r('app.string.hand_writing_reset'), { buttonStyle: ButtonStyleMode.NORMAL })
          .onClick(() => {
            this.resetCanvas();
          })
          .width('40%')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ bottom: $r('app.integer.hand_writing_margin_bottom') })

      // 保存图片
      Row() {
        Button($r('app.string.hand_writing_pack_to_file'), { buttonStyle: ButtonStyleMode.NORMAL })
          .onClick(async () => {
            componentSnapshot.get(NODE_CONTAINER_ID, async (error: Error, pixelMap: image.PixelMap) => {
              if (pixelMap !== null) {
                // 图片写入文件
                this.filePath = await this.packToFile(getContext(), pixelMap);
                logger.info(TAG, `Images saved using the packToFile method are located in : ${this.filePath}`);
              }
            })
          })
          .width('40%')
        Button($r('app.string.hand_writing_packing'), { buttonStyle: ButtonStyleMode.NORMAL })
          .onClick(async () => {
            componentSnapshot.get(NODE_CONTAINER_ID, async (error: Error, pixelMap: image.PixelMap) => {
              if (pixelMap !== null) {
                // 图片写入文件
                this.filePath = await this.saveFile(getContext(), pixelMap);
                logger.info(TAG, `Images saved using the packing method are located in : ${this.filePath}`);
              }
            })
          })
          .width('40%')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ bottom: $r('app.integer.hand_writing_margin_bottom') })

      // 保存的图片所处路径
      if (this.filePath !== '') {
        Row() {
          Text($r('app.string.hand_writing_image_save_path'))
          Text(this.filePath)
            .wordBreak(WordBreak.BREAK_ALL)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(MAX_LINES)
            .layoutWeight(LAYOUT_WEIGHT)
        }
        .width('100%')
        .height($r('app.integer.hand_writing_save_row_height'))
        .margin({ bottom: $r('app.integer.hand_writing_margin_bottom') })
      }
      // TODO：需求：手写内容使用ocr识别
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .padding($r('app.integer.hand_writing_view_padding'))
    .backgroundColor($r('app.color.ohos_id_color_background'))
  }

  /**
   * touch事件触发后绘制手指移动轨迹
   */
  onTouchEvent(event: TouchEvent): void {
    // TODO：知识点：在手指按下时创建新的MyRenderNode对象，挂载到rootRenderNode上，手指移动时根据触摸点坐标绘制线条，并重新渲染节点
    // 获取手指触摸位置的坐标点
    const positionX: number = vp2px(event.touches[0].x);
    const positionY: number = vp2px(event.touches[0].y);
    logger.info(TAG, `Touch positionX: ${positionX}, Touch positionY: ${positionY}`);
    switch (event.type) {
      case TouchType.Down: {
        // 每次手指按下，创建一个MyRenderNode对象，用于记录和绘制手指移动的轨迹
        const newNode = new MyRenderNode();
        // 定义newNode的大小和位置，位置从组件NodeContainer的左上角(0,0)坐标开始，大小为NodeContainer的宽高
        newNode.frame = { x: 0, y: 0, width: this.myNodeController.width, height: this.myNodeController.height };
        this.currentNode = newNode;
        // 移动新节点中的路径path到手指按下的坐标点
        this.currentNode.path.moveTo(positionX, positionY);
        if (this.myNodeController.rootRenderNode !== null) {
          // appendChild在renderNode最后一个子节点后添加新的子节点
          this.myNodeController.rootRenderNode.appendChild(this.currentNode);
          // 已挂载的节点数量加一
          this.nodeCount++;
        }
        break;
      }
      case TouchType.Move: {
        if (this.currentNode !== null) {
          // 手指移动，绘制移动轨迹
          this.currentNode.path.lineTo(positionX, positionY);
          // 节点的path更新后需要调用invalidate()方法触发重新渲染
          this.currentNode.invalidate();
        }
        break;
      }
      case TouchType.Up: {
        // 手指抬起，释放this.currentNode
        this.currentNode = null;
      }
      default: {
        break;
      }
    }
  }

  /**
   * 撤销上一笔绘制
   */
  goBack() {
    if (this.myNodeController.rootRenderNode !== null && this.nodeCount > 0) {
      // getChild获取最后挂载的子节点
      const node = this.myNodeController.rootRenderNode.getChild(this.nodeCount - 1);
      // removeChild移除指定子节点
      this.myNodeController.rootRenderNode.removeChild(node);
      this.nodeCount--;
    }
  }

  /**
   * 重置画布
   */
  resetCanvas() {
    if (this.myNodeController.rootRenderNode !== null && this.nodeCount > 0) {
      // 清除当前rootRenderNode的所有子节点
      this.myNodeController.rootRenderNode.clearChildren();
      this.nodeCount = 0;
    }
  }

  /**
   * packToFile将图片打包进文件
   */
  async packToFile(context: Context, pixelMap: PixelMap): Promise<string> {
    // 创建图像编码ImagePacker对象
    const imagePackerApi = image.createImagePacker();
    // 设置编码输出流和编码参数。format为图像的编码格式；quality为图像质量，范围从0-100，100为最佳质量
    const options: image.PackingOption = { format: 'image/jpeg', quality: 100 };
    // 图片写入的沙箱路径
    const filePath: string = `${context.filesDir}/${getTimeStr()}.jpg`;
    const file: fs.File = await fs.open(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
    // 使用packToFile直接将pixelMap写入文件
    await imagePackerApi.packToFile(pixelMap, file.fd, options);
    fs.closeSync(file);
    return filePath;
  }

  /**
   * packing获取图片的ArrayBuffer数据，再使用fs库将图片写入文件
   */
  async saveFile(context: Context, pixelMap: PixelMap): Promise<string> {
    // 创建图像编码ImagePacker对象
    const imagePackerApi = image.createImagePacker();
    // 设置编码输出流和编码参数。format为图像的编码格式；quality为图像质量，范围从0-100，100为最佳质量
    const options: image.PackingOption = { format: 'image/jpeg', quality: 100 };
    // 图片写入的沙箱路径
    const filePath: string = `${context.filesDir}/${getTimeStr()}.jpg`;
    const file: fs.File = await fs.open(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    // 使用packing打包获取图片的ArrayBuffer
    const data: ArrayBuffer = await imagePackerApi.packing(pixelMap, options);
    // 将图片的ArrayBuffer数据写入文件
    fs.writeSync(file.fd, data);
    fs.closeSync(file);
    return filePath;
  }
}

/**
 * 获取当前时间的拼接字符串，用于图片命名
 */
function getTimeStr() {
  const now: Date = new Date();
  const year: number = now.getFullYear();
  const month: number = now.getMonth() + 1;
  const day: number = now.getDate();
  const hours: number = now.getHours();
  const minutes: number = now.getMinutes();
  const seconds: number = now.getSeconds();
  return `${year}${month}${day}_${hours}${minutes}${seconds}`;
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getHandWritingToImageView(): void {
  HandWritingToImageView();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.HAND_WRITING_TO_IMAGE, wrapBuilder(getHandWritingToImageView));