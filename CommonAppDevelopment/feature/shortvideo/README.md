# 短视频切换实现案例

### 介绍

短视频切换在应用开发中是一种常见场景，上下滑动可以切换视频，十分方便。本模块基于Swiper组件和Video组件实现短视频切换功能。

### 效果图预览

<img src="../../product/entry/src/main/resources/base/media/short_video.gif" width="400">

**使用说明**

1. 上下滑动可以切换视频。
2. 点击屏幕暂停视频，再次点击继续播放。

### 实现思路

1. 使用Swiper创建一个竖直的可上下滑动的框架。源码参考[VideoSwiper.ets](./src/main/ets/view/VideoSwiper.ets)。

   ```typescript
   Swiper(this.swiperController) { 
      LazyForEach(this.data, (item: VideoData, index: number) => {
         Stack({ alignContent: Alignment.BottomEnd }) {
            Vedio()
         }, (item: VideoData) => JSON.stringify(item))
      }
    }
   .index(videoIndex)
   .autoPlay(false)
   .indicator(false)
   .loop(true)
   .duration(200)
   .vertical(true)
   ```

2. 在Swiper组件中使用Video组件承载视频。源码参考[VideoSwiper.ets](./src/main/ets/view/VideoSwiper.ets)。

   ```typescript
   // Video组件
    Video({
      src: item.video,
      controller: item.controller
    })
      .width('100%')
      .height('100%')
      .objectFit(ImageFit.Contain)
      .loop(true)
      .autoPlay(item.auto)
      .controls(false) // 控制视频播放的控制栏是否显示
   }
   ```

### 高性能知识点

本示例使用了[LazyForEach](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkts-rendering-control-lazyforeach-0000001524417213-V3)进行数据懒加载，LazyForEach懒加载可以通过设置cachedCount属性来指定缓存数量，同时搭配[组件复用](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/best-practices-long-list-0000001728333749#section36781044162218)能力以达到性能最优效果。


### 工程结构&模块类型

   ```
   shortvideo                             // har类型
   |---model
   |   |---BasicDataSource.ets            // 模型层-懒加载数据源
   |   |---DataModel.ets                  // 数据模型层-视频数据
   |---view
   |   |---ShortVideo.ets                 // 视图层-主页
   |   |---Side.ets                       // 视图层-视频右侧页面操作栏与左侧信息栏
   |   |---VideoSwiper.ets                // 视图层-短视频切换
   ```

### 模块依赖

1. 本实例依赖common模块来实现[公共组件FunctionDescription](../../common/utils/src/main/ets/component/FunctionDescription.ets)。

### 参考资料
[Swiper](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-container-swiper-0000001774121298)

[Video](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-media-components-video-0000001821000921)

[LazyForEach详细用法](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-rendering-control-lazyforeach-0000001820879609)