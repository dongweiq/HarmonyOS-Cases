# 多层级轮播图方案

### 介绍

本示例介绍使用ArkUI[stack](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V2/ts-container-stack-0000001427584888-V2)组件实现多层级瀑布流。该场景多用于购物、资讯类应用。

### 效果图预览

<img src="./src/main/resources/base/media/swiper_component.gif" width="200">

**使用说明**

1. 加载完成后显示轮播图可以左右滑动。

### 实现思路

1. SwiperDataSource，实现IDataSource接口的对象，用于LazyForEach加载数据。源码参考[SwiperData.ets](./src/main/ets/components/model/SwiperData.ets)
```ts
/**
 * 实现IDataSource接口的对象，用于轮播图组件加载数据
 */
class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: SwiperData[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): SwiperData {
    return this.originDataArray[index];
  }

  /**
   * 该方法为框架侧调用，为LazyForEach组件向其数据源处添加listener监听
   */
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  /**
   * 该方法为框架侧调用，为对应的LazyForEach组件在数据源处去除listener监听
   */
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }
  ...
  ```
2. 通过stack和offsetx实现多层级堆叠。源码参考[SwiperComponent.ets](./src/main/ets/components/mainpage/SwiperComponent.ets)
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
3. 通过手势控制调用显式动画同时修改数据中间值currentIndex来修改组件zIndex提示组件层级实现动画切换效果。源码参考[SwiperComponent.ets](./src/main/ets/components/mainpage/SwiperComponent.ets)
```ts
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

本示例使用了LazyForEach进行数据懒加载以降低内存占用。

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