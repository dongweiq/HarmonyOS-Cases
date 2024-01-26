# 阻塞事件冒泡方案

### 介绍

本示例主要介绍在点击事件中，子组件enabled属性设置为false的时候，如何解决点击子组件模块区域会触发父组件的点击事件问题；以及触摸事件中当子组件触发触摸事件的时候，父组件如果设置触摸事件的话，如何解决父组件也会被触发的问题。

### 效果图预览

![](../../screenshots/device/EventPropagation.gif)

**场景1**

enabled的值为false时，点击Button按钮，会导致父组件的点击事件触发。这时需要对Button组件包裹一层容器组件，并设置[hitTestBehavior](https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/reference/arkui-ts/ts-universal-attributes-hit-test-behavior.md/)属性，
属性值设置为HitTestMode.Block，可阻止事件的冒泡。具体代码可参考[EventPropagation.ets](./src/main/ets/view/EventPropagation.ets)。

**场景2**

触摸事件中，当子组件触发触摸事件的时候，父组件如果设置触摸事件的话，也会触发。这时需要在onTouch函数中执行event.stopPropagation()
可阻止冒泡。具体代码可参考[EventPropagation.ets](./src/main/ets/view/EventPropagation.ets)

**使用说明**：

1. 开启使能开关点击事件中点击子组件，不能触发本身和父组件的点击事件。
2. 触摸事件中触摸子组件，能够触发子组件的触摸事件，不会触发父组件的触摸事件。
3. 关闭使能开关，点击事件中点击子组件，不触发子组件点击事件，但能够触发父组件点击事件。
4. 触摸事件中触摸子组件，触发子组件的触摸事件和父组件的触摸事件。