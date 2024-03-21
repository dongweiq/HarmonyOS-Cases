# 多层级轮播图方案

### 介绍

本示例介绍使用ArkUI[stack](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V2/ts-container-stack-0000001427584888-V2)
组件实现多层级轮播图。该场景多用于购物、资讯类应用。

### 效果图预览

<img src="./src/main/resources/base/media/swiper_component.gif" width="200">

**使用说明**

1. 加载完成后显示轮播图可以左右滑动。

### 实现思路

1.通过stack和offsetx实现多层级堆叠。源码参考[SwiperComponent.ets](./src/main/ets/components/mainpage/SwiperComponent.ets)

```ts
Stack() {
  LazyForEach(this.swiperDataSource, (item: SwiperData, index: number) => {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(item.imageSrc)
        .objectFit(ImageFit.Auto)
        .width('100%')
        .height('100%')
        .borderRadius($r('app.string.main_page_top_borderRadius'))
  ...
  ```

3.通过手势控制调用显式动画同时修改数据中间值currentIndex来修改组件zIndex提示组件层级实现动画切换效果。源码参考[SwiperComponent.ets](./src/main/ets/components/mainpage/SwiperComponent.ets)

```ts
Stack() {
  ForEach(this.swiperDataSource, (item: SwiperData, index: number) => {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(item.imageSrc)
        .objectFit(ImageFit.Auto)
        .width('100%')
        .height('100%')
        .borderRadius($r('app.string.main_page_top_borderRadius'))
      // 轮播图底部蒙层
       Stack() {
         Column() {
         }
         .width('100%')
         .height('100%')
         .backgroundColor(Color.Black)
         .opacity(0.3)
         .borderRadius({
            topLeft: 0,
            topRight: 0,
            bottomLeft: $r('app.string.main_page_top_borderRadius'),
            bottomRight: $r('app.string.main_page_top_borderRadius')
          })

          Text(item.name)
            .width('100%')
            .height('100%')
            .fontSize(16)
            .fontColor(Color.White)
            .textAlign(TextAlign.Start)
            .padding($r('app.string.main_page_padding5'))
        }
        .height('17%')
}
.gesture(
   PanGesture({ direction: PanDirection.Horizontal })
     .onActionStart((event: GestureEvent) => {
        this.startAnimation(event.offsetX < 0);
     })
 )
startAnimation(isLeft: boolean): void {
  animateTo({
    duration: 300,
  }, () => {
      let dataLength: number = this.swiperData.length;
      let tempIndex: number = isLeft ? this.currentIndex + 1 : this.currentIndex - 1 + dataLength;
      this.currentIndex = tempIndex % dataLength;
    })
}
  ```

### 高性能知识点

**不涉及**

### 工程结构&模块类型

   ```
   functionalscenes                                // har类型
   |---model
   |   |---SwiperData.ets                          // 轮播数据模型和数据控制器 
   |---mainpage
   |   |---FunctionalScenes.ets                    // 轮播页面
   ```

### 模块依赖

**不涉及**

### 参考资料

1.[lazyForeach参考文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/arkts-rendering-control-lazyforeach-0000001524417213-V2)
2.[animationTo参考文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V2/ts-explicit-animation-0000001478341181-V2)