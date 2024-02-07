# 状态栏显隐变化

### 介绍

本示例介绍使用Scroll组件的滚动事件 **onScroll** 实现状态栏显隐变化。该场景多用于各种软件的首页、我的等页面中。

### 效果预览图

![](../../product/entry/src/main/resources/base/media/navigation_bar_change.gif)

**使用说明**
1. 加载完成后显示状态栏显隐变化页面，上下拖动屏幕，顶端状态栏出现显隐变化。

### 实现思路
1. 在置顶位置使用stack组件添加两层状态栏。 源码参考[NavigationBarChangeView.ets](./src/main/ets/view/NavigationBarChange.ets)。

```ts
Stack() {
  ...
  Header({headOpacity: this.headOpacity, titleBackgroundColor: $r('app.color.ohos_id_color_background'), isTop: false});
  Header({headOpacity: this.opacityDefaultValue, titleBackgroundColor: $r('app.color.transparent_color'), isTop: true});
}
```

2. 通过获取Scroll的偏移量，计算透明度，分别对状态栏的组件设置透明度来实现状态栏的显隐变化效果。 源码参考[NavigationBarChangeView.ets](./src/main/ets/view/NavigationBarChange.ets)。

```ts
Scroll(this.scroller) {
  ...
}
.width($r('app.string.width_and_height_value12'))
.height($r('app.string.width_and_height_value12'))
.scrollable(ScrollDirection.Vertical)
.scrollBar(BarState.Off)
.edgeEffect(EdgeEffect.None)
.onScroll(() => {
  this.scrollOffset = this.scroller.currentOffset().yOffset;
  if(this.scrollOffset <= this.opacityComputeRadix) {
    this.headOpacity = this.scrollOffset / this.opacityComputeRadix;
  }
  else {
    this.headOpacity = this.opacityDefaultValue;
  }
})
```

### 高性能知识点

本示例使用了onScroll回调监听接口，此接口属于频繁回调接口，应该避免在内部进行冗余和耗时操作，例如避免打印日志。

### 工程结构&模块类型

   ```
   navigationbarchange                                        // har类型
   |---view
   |   |---NavigationBarChange.ets                            // 视图层-状态栏显隐变化页面 
   ```

### 模块依赖

[**utils**](../../common/utils)

### 参考资料

[Scroll组件](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-container-scroll-0000001821000913)
