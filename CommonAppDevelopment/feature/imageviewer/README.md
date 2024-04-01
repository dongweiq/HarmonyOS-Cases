# 图片缩放效果实现

### 介绍

图片预览在应用开发中是一种常见场景，在诸如QQ、微信、微博等应用中均被广泛使用。本模块基于Image组件实现了简单的图片预览功能。

**使用说明：**

1. 双指捏合对图片进行缩放
1. 双击图片进行图片的大小切换，在放大状态下，双击可恢复默认状态
1. 图片在放大模式下，滑动图片查看图片的对应位置

### 效果图预览

![demo](../../product/entry/src/main/resources/base/media/image_viewer.gif)

### 实现思路

1. 使用matrix实现图片的缩放。详情见[ImageItemView.ets](./src/main/ets/view/ImageItemView.ets)。
    ```typescript
    @State matrix: matrix4.Matrix4Transit = matrix4.identity().copy();
    Image(this.imagePixelMap)
        .transform(this.matrix)
    ```
1. 使用offset属性对图片进行偏移。详情见[ImageItemView.ets](./src/main/ets/view/ImageItemView.ets)。
    ```typescript
    @State imageOffsetInfo: OffsetModel = new OffsetModel(0, 0);
    Image(this.imagePixelMap)
        .offset({
            x: this.imageOffsetInfo.currentX,
            y: this.imageOffsetInfo.currentY
        })
    ```
1. Image的objectFit属性设置为Cover，锁定图片宽高比，并使其能够超出父组件边界显示。详情见[ImageItemView.ets](./src/main/ets/view/ImageItemView.ets)。
   ```typescript
   Image(this.imagePixelMap)
       .objectFit(ImageFit.Cover)
   ```
1. 提前计算图片信息，并通过Image的宽或高配合aspectRatio设置默认尺寸。详情见[ImageItemView.ets](./src/main/ets/view/ImageItemView.ets)。
   ```typescript
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
   }
   
   Image(this.imagePixelMap)
      .width(this.fitWH === "width" ? $r("app.string.image_default_width") : undefined)
      .height(this.fitWH === "height" ? $r("app.string.image_default_height") : undefined)
      .aspectRatio(this.imageWHRatio)
   ```

#### 高性能知识点

1. [数据懒加载](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V4/arkts-rendering-control-lazyforeach-0000001820879609-V4)
1. [组件复用](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-create-custom-components-0000001820999549#ZH-CN_TOPIC_0000001820999549__自定义组件的基本结构)

### 模块依赖

[动态路由模块](../routermodule/src/main/ets/router)

### 工程结构&模块类型

```
imageviewer                                     // har类型
|---constants                                   // 常量
|---model                                       // 模型层-自定义数据模型
|---utils                                       // 工具类
|---view                                        // 视图层-图片预览方案涉及的主要组件
|---|---ImageViewerView.ets                     // 视图层-入口
|---|---ImageItemView.ets                       // 视图层-单张图片的显示组件
```

### 其他

1. TODO：增强需求：限制位移边界
1. TODO：增强需求：多图切换

### 参考资料

1. [image](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V2/ts-basic-components-image-0000001580026342-V2?catalogVersion=V2)
1. [gesture](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V2/3_3_u624b_u52bf_u5904_u7406-0000001580185734-V2v)
1. [swiper](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V2/ts-container-swiper-0000001630306301-V2)
1. [window](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V2/js-apis-window-0000001630146157-V2)
1. [matrix4](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-matrix4-0000001820880769)