# 手写绘制及保存图片

### 介绍

本示例使用drawing库的Pen和Path结合NodeContainer组件实现手写绘制功能，并通过image库的packToFile和packing接口将手写板的绘制内容保存为图片。

### 效果图预览

![](../../product/entry/src/main/resources/base/media/hand_wring_to_image.gif)

**使用说明**

1. 在虚线区域手写绘制，点击撤销按钮撤销前一笔绘制，点击重置按钮清空绘制。 
2. 点击packToFile保存图片按钮和packing保存图片按钮可以将绘制内容保存为图片写入文件，显示图片保存路径。

### 实现思路

1. 创建NodeController的子类MyNodeController，用于获取根节点的RenderNode和绑定的NodeContainer组件宽高。源码参考[RenderNodeModel.ets](./src/main/ets/model/RenderNodeModel.ets)

```ts
export class MyNodeController extends NodeController {
  private rootNode: FrameNode | null = null; // 根节点
  rootRenderNode: RenderNode | null = null; // 从NodeController根节点获取的RenderNode，用于添加和删除新创建的MyRenderNode实例
  width: number = 0; // 实例绑定的NodeContainer组件的宽，单位px
  height: number = 0; // 实例绑定的NodeContainer组件的宽，单位px

  // MyNodeController实例绑定的NodeContainer创建时触发，创建根节点rootNode并将其挂载至NodeContainer
  makeNode(uiContext: UIContext): FrameNode {
    this.rootNode = new FrameNode(uiContext);
    if (this.rootNode !== null) {
      this.rootRenderNode = this.rootNode.getRenderNode();
    }
    return this.rootNode;
  }

  // 绑定的NodeContainer布局时触发，获取NodeContainer的宽高
  aboutToResize(size: Size): void {
    this.width = size.width;
    this.height = size.height;
    // 设置画布底色为白色
    if (this.rootRenderNode !== null) {
      // NodeContainer布局完成后设置rootRenderNode的背景色为白色
      this.rootRenderNode.backgroundColor = 0XFFFFFFFF;
      // rootRenderNode的位置从组件NodeContainer的左上角(0,0)坐标开始，大小为NodeContainer的宽高
      this.rootRenderNode.frame = { x: 0, y: 0, width: this.width, height: this.height };
    }
  }
}
```
2. 创建RenderNode的子类MyRenderNode，初始化画笔和绘制path路径。源码参考[RenderNodeModel.ets](./src/main/ets/model/RenderNodeModel.ets)

```ts
export class MyRenderNode extends RenderNode {
  path: drawing.Path = new drawing.Path(); // 新建路径对象，用于绘制手指移动轨迹

  // RenderNode进行绘制时会调用draw方法，初始化画笔和绘制路径
  draw(context: DrawContext): void  {
    const canvas = context.canvas;
    // 创建一个画笔Pen对象，Pen对象用于形状的边框线绘制
    const pen = new drawing.Pen();
    // 设置画笔开启反走样，可以使得图形的边缘在显示时更平滑
    pen.setAntiAlias(true);
    // 设置画笔颜色为黑色
    const pen_color: common2D.Color = { alpha: 0xFF, red: 0x00, green: 0x00, blue: 0x00 };
    pen.setColor(pen_color);
    // 开启画笔的抖动绘制效果。抖动绘制可以使得绘制出的颜色更加真实。
    pen.setDither(true);
    // 设置画笔的线宽为5px
    pen.setStrokeWidth(5);
    // 将Pen画笔设置到canvas中
    canvas.attachPen(pen);
    // 绘制path
    canvas.drawPath(this.path);
  }
}
```
3. 创建变量currentNode用于存储当前正在绘制的节点，变量nodeCount用来记录已挂载的节点数量。源码参考[HandWritingToImage.ets](./src/main/ets/view/HandWritingToImage.ets)

```ts                          
  private currentNode: MyRenderNode | null = null; // 当前正在绘制的节点
  private nodeCount: number = 0; // 已挂载到根节点的子节点数量
```
4. 创建自定义节点容器组件NodeContainer，接收MyNodeController的实例，将自定义的渲染节点挂载到组件上，实现自定义绘制。源码参考[HandWritingToImage.ets](./src/main/ets/view/HandWritingToImage.ets)

```ts
  NodeContainer(this.myNodeController)
    .width('100%')
    .height($r('app.integer.hand_writing_canvas_height'))
    .onTouch((event: TouchEvent) => {
      this.onTouchEvent(event);
    })
    .id(NODE_CONTAINER_ID)
```
4. 在NodeContainer组件的onTouch回调函数中，手指按下创建新的节点并挂载到rootRenderNode，nodeCount加一，手指移动更新节点中的path对象，绘制移动轨迹，并将节点重新渲染。源码参考[HandWritingToImage.ets](./src/main/ets/view/HandWritingToImage.ets)

```ts
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
```

5. rootRenderNode调用getChild方法获取最后一个挂载的子节点，再使用removeChild方法移除，实现撤销上一笔的效果。源码参考[HandWritingToImage.ets](./src/main/ets/view/HandWritingToImage.ets)

```ts
  goBack() {
    if (this.myNodeController.rootRenderNode !== null && this.nodeCount > 0) {
      // getChild获取最后挂载的子节点
      const node = this.myNodeController.rootRenderNode.getChild(this.nodeCount - 1);
      // removeChild移除指定子节点
      this.myNodeController.rootRenderNode.removeChild(node);
      this.nodeCount--;
    }
  }
```

6. 使用clearChildren清除当前rootRenderNode的所有子节点，实现画布重置，nodeCount清零。源码参考[HandWritingToImage.ets](./src/main/ets/view/HandWritingToImage.ets)

```ts
  resetCanvas() {
    if (this.myNodeController.rootRenderNode !== null && this.nodeCount > 0) {
      // 清除当前rootRenderNode的所有子节点
      this.myNodeController.rootRenderNode.clearChildren();
      this.nodeCount = 0;
    }
  }
```

7. 使用componentSnapshot.get获取组件NodeContainer的PixelMap对象，用于保存图片。源码参考[HandWritingToImage.ets](./src/main/ets/view/HandWritingToImage.ets)

```ts
  componentSnapshot.get(NODE_CONTAINER_ID, async (error: Error, pixelMap: image.PixelMap) => {
    if (pixelMap !== null) {
      // 图片写入文件
      this.filePath = await this.saveFile(getContext(), pixelMap);
      logger.info(TAG, `Images saved using the packing method are located in : ${this.filePath}`);
    }
  })
```

8. 使用image库的packToFile()和packing()将获取的PixelMap对象保存为图片。源码参考[HandWritingToImage.ets](./src/main/ets/view/HandWritingToImage.ets)
  - ImagePacker.packToFile()可直接将PixelMap对象写入为图片。

```ts
  async packToFile(context: Context, pixelMap: PixelMap): Promise<string> {
    // 创建图像编码ImagePacker对象
    const imagePackerApi = image.createImagePacker();
    // 设置编码输出流和编码参数。format为图像的编码格式；quality为图像质量，范围从0-100，100为最佳质量
    const options: image.PackingOption = { format: "image/jpeg", quality: 100 };
    // 图片写入的沙箱路径
    const filePath: string = `${context.filesDir}/${getTimeStr()}.jpg`;
    const file: fs.File = await fs.open(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
    // 使用packToFile直接将pixelMap写入文件
    await imagePackerApi.packToFile(pixelMap, file.fd, options);
    fs.closeSync(file);
    return filePath;
  }
```
  - ImagePacker.packing()可获取图片的ArrayBuffer数据，再使用fs将数据写入为图片。

```ts
  async saveFile(context: Context, pixelMap: PixelMap): Promise<string> {
    // 创建图像编码ImagePacker对象
    const imagePackerApi = image.createImagePacker();
    // 设置编码输出流和编码参数。format为图像的编码格式；quality为图像质量，范围从0-100，100为最佳质量
    const options: image.PackingOption = { format: "image/jpeg", quality: 100 };
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
```

### 高性能知识点

不涉及

### 工程结构&模块类型

   ```
   handwritingtoimage                            // har类型
   |---/src/main/ets/model                        
   |   |---RenderNodeModel.ets                   // 模型层-节点数据模型
   |---/src/main/ets/view                        
   |   |---HandWritingToImage.ets                // 视图层-手写板场景页面
   ```

### 模块依赖

1. 本实例依赖common模块中的[日志工具类logger](../../common/utils/src/main/ets/log/Logger.ets)。

### 参考资料

[@ohos.graphics.drawing (绘制模块)](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-graphics-drawing-0000001775981772)

[NodeController](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-arkui-nodecontroller-0000001821000757)

[自渲染节点RenderNode](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-arkui-rendernode-0000001820880781)

[@ohos.multimedia.image(图片处理)](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-image-0000001821001457)

[@ohos.file.fs(文件管理)](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-file-fs-0000001820881405)