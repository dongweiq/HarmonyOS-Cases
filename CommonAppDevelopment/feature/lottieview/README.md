# Lottie

### 介绍

Lottie是一个适用于OpenHarmony的动画库，它可以解析Adobe After Effects软件通过Bodymovin插件导出的json格式的动画，并在移动设备上进行本地渲染， 
可以在各种屏幕尺寸和分辨率上呈现，并且支持动画的交互性，通过添加触摸事件或其他用户交互操作，使动画更加生动和具有响应性。

### 效果图预览

![](../../product/entry/src/main/resources/base/media/lottie_animation.gif) 

**使用说明**：

1.进入页面，点击动画卡片，动画播放并且文本发生变化。

### 实现思路
1. 添加Lottie模块，源码参考[oh-package.json5](./oh-package.json5)。
```
{
  "name": "lottieview",
  "version": "1.0.0",
  "description": "Please describe the basic information.",
  "main": "Index.ets",
  "author": "",
  "license": "Apache-2.0",
  "dependencies": {
    // Lottie模块
    "@ohos/lottie": "2.0.0",
  }
}
```
2. 将Lottie的资源文件data.json文件放置到Entry目录下的common文件夹下(放置本模块中，使用相对路径无法读取)。数据参考[politeChicky.json](../../product/entry/src/main/ets/common/lottie/politeChicky.json)

3. 进入页面，通过Canvas的onReady函数加载动画，点击播放动画，动画执行播放，文本刷新。源码参考[LotieView.ets](./src/main/ets/view/LottieView.ets)

```
  // 加载动画
  loadAnimation(autoplay: boolean) {
    if (this.animateItem !== null) {
      this.animateItem.destroy();
      this.animateItem = null;
    }
    // TODO:知识点:lottie.loadAnimation将json数据生成动画
    this.animateItem = lottie.loadAnimation({
      container: this.politeChickyController,
      renderer: 'canvas',
      loop: false,
      autoplay: autoplay,
      name: this.politeChicky,
      path: this.politeChickyPath,
      initialSegment: [FRAME_START, FRAME_END]
    })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 动画
      Canvas(this.politeChickyController)
        .width($r('app.integer.canvas_size'))
        .height($r('app.integer.canvas_size'))
        .backgroundColor($r('app.color.ohos_id_color_palette2'))
        .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
        .onReady(() => {
          this.loadAnimation(false);
        })
        .onClick(() => {
          this.loadAnimation(true);
          this.times++;
        })
      // 响应动画的文本
      Text(this.textArray[this.times % TEXT_DATA_LENGTH])
        .fontSize($r('app.string.ohos_id_text_size_headline'))
        .margin($r('app.string.ohos_id_elements_margin_vertical_m'))
        .fontColor(Color.White)
    }.margin({ top: $r('app.string.ohos_id_elements_margin_vertical_l') })
  }
}
```

### 高性能知识点

**不涉及。**

### 工程结构&模块类型

```
lottieview                                         // har类型
|---view
|   |---LottieView.ets                             // 视图层-应用主页面
```

### 模块依赖

本实例依赖common模块来实现[日志](../../common/utils/src/main/ets/Logger.ets)的打印、[资源](../../common/utils/src/main/resources/base/element)
的调用、[动态路由模块](../../feature/routermodule/src/main/ets/router/DynamicsRouter.ets)来实现页面的动态加载以及[Lottie模块](oh-package.json5)，版本为2.0.0。

### 参考资料

[Lottie](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-drawing-customization-on-canvas-0000001820999777)


