# 使用colorPicker实现背景跟随主题颜色转换

### 介绍

本示例介绍使用image库以及effectKit库中的colorPicker对目标图片进行取色，将获取的颜色作为背景渐变色，通过swiper组件对图片进行轮播，
### 效果图预览

<img src="../../product/entry/src/main/resources/base/media/color_picker.gif" width="200">

**使用说明**

直接进入页面，对图片进行左右滑动，或者等待几秒，图片会自动轮播,图片切换后即可改变背景颜色。

### 实现思路

1. 在事件onAnimationStart切换动画过程中通过Image模块相关能力，获取图片颜色平均值，使用effectKit库中的ColorPicker智能取色器进行颜色取值。源码参考[MainPage.ets](./src/main/ets/components/mainpage/MainPage.ets)
    ```typescript
    const context = getContext(this);
    //获取resourceManager资源管理器
    const resourceMgr: resourceManager.ResourceManager = context.resourceManager;
    const fileData: Uint8Array = await resourceMgr.getMediaContent(this.imgData[targetIndex]);
    //获取图片的ArrayBuffer
    const buffer = fileData.buffer;
    //创建imageSource
    const imageSource: image.ImageSource = image.createImageSource(buffer);
    //创建pixelMap
    const pixelMap: image.PixelMap = await imageSource.createPixelMap();

    effectKit.createColorPicker(pixelMap, (err, colorPicker) => {
      //读取图像主色的颜色值，结果写入Color
      let color = colorPicker.getMainColorSync();
    })
    ```
2. 同时通过接口animateTo开启背景颜色渲染的属性动画。全局界面开启沉浸式状态栏。源码参考[MainPage.ets](./src/main/ets/components/mainpage/MainPage.ets)
    ```typescript
   animateTo({ duration: 500, curve: Curve.Linear, iterations: 1 }, () => {
      //将取色器选取的color示例转换为十六进制颜色代码
      this.bgColor = "#" + color.alpha.toString(16) + color.red.toString(16) + color.green.toString(16) + color.blue.toString(16);
   })
    ```
3. 通过属性linearGradient设置背景色渲染方向以及渲染氛围。源码参考[MainPage.ets](./src/main/ets/components/mainpage/MainPage.ets)
    ```typescript
    linearGradient({
      //渐变方向
      direction: GradientDirection.Bottom,
      //数组末尾元素占比小于1时，满足重复着色的效果
      colors: [[this.bgColor, 0.0], [Color.White, 0.5]]
    })
    ```


### 工程结构&模块类型
   ```
   effectKit                                  // har类型
   |---pages
   |---|---MainPage.ets                       // 视图层-场景列表页面
   ```

### 高性能知识点

不涉及。

### 模块依赖

不涉及。

### 参考资料

[@ohos.multimedia.image(图片处理)](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-image-0000001821001457)
[swiper](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V2/ts-container-swiper-0000001630306301-V2)
[animationTo参考文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V2/ts-explicit-animation-0000001478341181-V2)