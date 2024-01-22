
# 地址切换动画场景开发范例

### 效果预览图

![](../../screenshots/device/AddressExchange.gif)

## 简介

在出行类订票软件中，一般都有此动画效果，点击切换后，起点和终点互换。

## 场景概述

通过状态变量控制中间图片旋转角度，控制左右两边文本组件偏移量，达成地址切换动画效果。


### 开发步骤

通过onclick事件调用animationTo方法实现动画效果。源码参考[AddressExchangeView.ets](./src/main/ets/view/AddressExchangeView.ets)
  ```ts
  animateTo({ curve: curves.springMotion() }, () => {
    if (this.swap) {
      this.translateX = this.distance
    } else {
      this.translateX = 0
    }
  })
  ```