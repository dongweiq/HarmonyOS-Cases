# 自定义视图实现Tab效果

### 介绍

本示例介绍使用Text、List等组件，添加点击事件onclick,动画，animationTo实现自定义Tab效果。

### 效果预览图

![](../../product/entry/src/main/resources/base/media/custom_view.gif)

**使用说明**
1. 点击页签进行切换，选中态页签字体放大加粗，颜色由灰变黑，起到强调作用，同时，底部颜色条横线位移到当前选中页签下方，内容区翻页到当前选中页签对应区域。

### 实现思路
1. 页签实现：添加onClick方法，记录点击的index，index变化后，改变页签颜色、字体大小，使用animateTo方法实现页签切换动画。 源码参考[CustomView.ets](./src/main/ets/view/CustomView.ets)。

```ts
Text(title)
  .textAlign(TextAlign.Center)
  .height($r('app.integer.width_and_height_value4'))
  .width(this.titleLengthRadix3 * title.length)
  .fontColor(this.currentIndex == idx ?
            (this.wantGoIndex == idx ? $r('app.color.background_color1'):$r('app.color.background_color2')):
            (this.wantGoIndex == idx ? $r('app.color.background_color1'):$r('app.color.background_color2')))
  .fontSize(this.currentIndex == idx ? $r('app.integer.font_size2') : $r('app.integer.font_size1'))
  .fontWeight(this.currentIndex == idx ? FontWeight.Bold : FontWeight.Normal)
  .onClick(() => {
    if (this.currentIndex != idx) {
      // 记录点击index
      this.wantGoIndex = idx;
      // 动画效果
      animateTo({
        duration: Math.abs(idx - this.currentIndex) * this.durationRadix,
        curve: Curve.EaseInOut,
        iterations: this.iterationsDefault,
        playMode: PlayMode.Normal,
        onFinish: () => {
          this.currentIndex = idx;
          this.scroller.scrollToIndex(this.currentIndex, true, ScrollAlign.START);
        }
      }, () => {
        this.transitionX = this.getTransitionX(idx);
      })
    }
  })
```

2. 内容区实现：使用List，添加滑动手势来进行页面的切换，手势响应后，使用scrollToIndex方法来实现平滑的滑动到相应index。 源码参考[CustomView.ets](./src/main/ets/view/CustomView.ets)。

```ts
PanGesture(this.panOption)
  .onActionUpdate((event:GestureEvent) => {
    if (!this.isStartAction) {
      this.isStartAction = true;
      if (event.offsetX < this.judgmentValue) {
        if (this.currentIndex < this.titleArray.length - this.currentIndexRadix) {
          let temIndex: number = this.currentIndex + this.currentIndexRadix;
          this.scroller.scrollToIndex(temIndex, true, ScrollAlign.START);
          this.wantGoIndex = temIndex;
          animateTo({
            duration: Math.abs(temIndex - this.currentIndex) * this.durationRadix,
            curve: Curve.EaseInOut,
            iterations: this.iterationsDefault,
            playMode: PlayMode.Normal,
            onFinish: () => {
              this.currentIndex = temIndex;
            }
          }, () => {
            this.transitionX = this.getTransitionX(temIndex);
          })
        }
      } else {
        if (this.currentIndex > this.judgmentValue) {
          let temIndex: number = this.currentIndex - this.currentIndexRadix;
          this.scroller.scrollToIndex(temIndex, true, ScrollAlign.START);
          this.wantGoIndex = temIndex;
          animateTo({
            duration: Math.abs(temIndex - this.currentIndex) * this.durationRadix,
            curve: Curve.EaseInOut,
            iterations: this.iterationsDefault,
            playMode: PlayMode.Normal,
            onFinish: () => {
              this.currentIndex = temIndex;
            }
          }, () => {
            this.transitionX = this.getTransitionX(temIndex);
          })
        }
      }
    }
  })
```

### 高性能知识点

scrollToIndex方法，开启smooth动效时，会对经过的所有item进行加载和布局计算，当大量加载item时会导致性能问题

### 工程结构&模块类型

   ```
   customview                                       // har类型
   |---view
   |   |---CustomView.ets                           // 视图层-自定义视图实现Tab效果
   ```

### 模块依赖

[**utils**](../../common/utils)

### 参考资料

[PanGesture 事件](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-gestures-pangesture-0000001774280890)

[animateTo 显示动画](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-explicit-animation-0000001774121350)

[scrollToIndex 方法](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-container-scroll-0000001821000913)
