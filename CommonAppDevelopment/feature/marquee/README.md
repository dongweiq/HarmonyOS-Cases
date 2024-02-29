# 跑马灯案例

### 介绍

本示例介绍了文本宽度过宽时，如何实现文本首尾相接循环滚动并显示在可视区，以及每循环滚动一次之后会停滞一段时间后再滚动。

### 效果图预览

![](../../product/entry/src/main/resources/base/media/marquee.gif) 

**使用说明**：

1.进入页面，检票口文本处，实现文本首尾相接循环滚动，且在同一可视区，滚动完成之后，停滞一段时间后继续滚动。

### 实现思路

由于ArkUI中的Marquee组件无法实现文本接替并显示在同一可视区的效果，它只能等文本完全消失在可视区之后，才会再次显示在可视区，
因此需要以下方案实现。

1. Text组件外层包裹一层Scroll组件，Scroll组件设置一定的百分比宽度值，并获取当前文本内容宽度和Scroll组件宽度，文本宽度大于
   Scroll组件宽度时，通过添加判断显示同样的文本，在偏移过程中可实现文本接替并显示在同一显示区的效果。源码参考[Marquee.ets](./src/main/ets/view/Marquee.ets)

```
    // TODO：知识点：使用Scroll组件和文本内容组件结合来判断文本宽度过宽时执行文本滚动，否则不执行
    Scroll() {
      Row() {
        Text(this.tripDataItem.ticketEntrance)
          .onAreaChange((oldValue, newValue) => {
            logger.info(`TextArea oldValue:${JSON.stringify(oldValue)},newValue:${JSON.stringify(newValue)}`);
            // 获取当前文本内容宽度
            this.ticketCheckTextWidth = Number(newValue.width);
          })
        // TODO：知识点：文本宽度大于Scroll组件宽度时显示。在偏移过程中可实现文本接替并显示在同一显示区的效果
        if (this.ticketCheckTextWidth >= this.ticketCheckScrollWidth) {
          Blank()
            .width(50)
          Text(this.tripDataItem.ticketEntrance)
        }
      }.offset({ x: this.ticketCheckTextOffset })
    }
    .width('50%')
    .align(Alignment.Start)
    .enableScrollInteraction(false)
    .flexGrow(1)
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .onAreaChange((oldValue, newValue) => {
      logger.info(`scrollArea oldValue:${JSON.stringify(oldValue)},newValue:${JSON.stringify(newValue)}`);
      // 获取当前Scroll组件宽度
      this.ticketCheckScrollWidth = Number(newValue.width);
    })
   }
   .width('46%')
```

2. 页面进来执行文本滚动函数scrollAnimation()，在指定的时间内完成文本的偏移，当循环一次之后，通过定时器setTimeout
   来实现停滞操作。源码参考[Marquee.ets](./src/main/ets/view/Marquee.ets)

```
   // 文本滚动函数
  scrollAnimation() {
    // 文本宽度小于Scroll组件宽度，不执行滚动操作
    if (this.ticketCheckTextWidth < this.ticketCheckScrollWidth) {
      return;
    }
    /**
     * 文本向左偏移动画
     *
     * @param duration:动画总时长
     * @param curve:动画曲线
     * @param delay:延迟时间
     * @param onFinish:完成回调函数
     * 性能：播放动画时，系统需要在一个刷新周期内完成动画变化曲线的计算，完成组件布局绘制等操作。建议使用系统提供的动画接口，
     * 只需设置曲线类型、终点位置、时长等信息，就能够满足常用的动画功能，减少UI主线程的负载。
     * 参考资料：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-attribute-animation-apis-0000001820879805
     */
    animateTo({
      duration: Constants.ANIMATION_DURATION,
      curve: Curve.Linear,
      delay: this.delay,
      onFinish: () => {
        // TODO：知识点：动画完成时，添加定时器，1s之后重新执行动画函数，达到停滞操作。
        setTimeout(() => {
          // 初始化文本偏移量
          this.ticketCheckTextOffset = 0;
          this.scrollAnimation();
        }, Constants.DELAY_TIME)
      }
    }, () => {
      // 文本偏离量
      this.ticketCheckTextOffset = -(this.ticketCheckTextWidth + Constants.BLANK_SPACE)
    })
  }
```
### 高性能知识点

本示例使用了[LazyForEach](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-rendering-control-lazyforeach-0000001820879609)
进行数据懒加载，动态添加行程信息以及[显示动画animateTo](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-attribute-animation-apis-0000001820879805)实现文本偏移。

### 工程结构&模块类型

```
marquee                                         // har类型
|---model
|   |---Constants.ets                           // 数据模型层-常量
|   |---DataSource.ets                          // 模型层-懒加载数据源
|   |---DataType.ets                            // 数据模型层-数据类型
|   |---MockData.ets                            // 数据模型层-模拟数据
|---view
|   |---Marquee.ets                             // 视图层-应用主页面
```

### 模块依赖

本实例依赖common模块来实现[日志](../../common/utils/src/main/ets/log/Logger.ets)的打印、[资源](../../common/utils/src/main/resources/base/element)
的调用。

### 参考资料

[显示动画animateTo](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-attribute-animation-apis-0000001820879805)

[数据懒加载LazyForEach](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-rendering-control-lazyforeach-0000001820879609)


