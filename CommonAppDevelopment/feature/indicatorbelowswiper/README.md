# swiper指示器导航点位于swiper下方

### 介绍

本示例介绍通过分割swiper区域，实现指示器导航点位于swiper下方的效果。

### 效果预览图

![](../../product/entry/src/main/resources/base/media/indicator_below_swiper.gif)

**使用说明**
1. 加载完成后swiper指示器导航点，位于显示内容下方。

### 实现思路
1. 将swiper区域分割为两块区域，上方为内容区域，下方为空白区域。 源码参考[IndicatorBelowSwiper.ets](./src/main/ets/view/IndicatorBelowSwiper.ets)。

```ts
Column() {
  Image(item)
    .width($r('app.string.one_hundred_percent'))
    .height($r('app.string.thirty_percent'))
    .borderRadius($r('app.integer.borderRadius_value'))

  Column()
    .width($r('app.string.one_hundred_percent'))
    .height($r('app.integer.blank_space_height'))
}
```

2. 通过indicator属性调整指示器导航点位置，使其位于空白区域。 源码参考[IndicatorBelowSwiper.ets](./src/main/ets/view/IndicatorBelowSwiper.ets)。

```ts
Swiper(this.swiperController) {
  ...
}
.width($r('app.string.ninety_five_percent'))
.loop(true)
.autoPlay(true)
.indicator(new DotIndicator().bottom($r('app.integer.offset_value')))
```

### 高性能知识点

**不涉及**

### 工程结构&模块类型

   ```
   indicatorbelowswiper                                        // har类型
   |---view
   |   |---IndicatorBelowSwiper.ets                            // 视图层-swiper指示器导航点位于swiper下方
   ```

### 模块依赖

[**utils**](../../common/utils)
[@ohos/routermodule(动态路由)](../../feature/routermodule)

### 参考资料

[Swiper组件](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-container-swiper-0000001774121298)
