
# 地址交换动画

### 介绍

本示例介绍使用显式动画 **animateTo** 实现左右地址交换动画。该场景多用于机票、火车票购买等出行类订票软件中。

### 效果预览图

![address_exchange](../../product/entry/src/main/resources/base/media/address_exchange.gif)

**使用说明**
1. 加载完成后显示地址交换动画页面，点击中间的图标，左右两边地址交换。

### 实现思路
1. 创建左右两边Text组件显示地址。设置初始偏移量以及文本对齐方式。源码参考[AddressExchangeView.ets](./src/main/ets/view/AddressExchangeView.ets)。

```ts
Row() {
  Text($r('app.string.address_exchange_address_left'))
    .translate({ x: this.translateX })
    .width($r('app.string.address_exchange_address_width'))
    .textAlign(this.swap ? TextAlign.End : TextAlign.Start)
  ...
  Text($r('app.string.address_exchange_address_right'))
    .translate({ x: -this.translateX })
    .width($r('app.string.address_exchange_address_width'))
    .textAlign(this.swap ? TextAlign.Start : TextAlign.End)
  ...
}
```

2. 点击中间的图标时，修改是否切换的状态变量值和通过animateTo修改偏移量的值，来实现动态更新左右两边地址的显示，完成动画效果。源码参考[AddressExchangeView.ets](./src/main/ets/view/AddressExchangeView.ets)。

```ts
Stack() {
  Image($r('app.media.address_exchange_airplane'))
    .size({
        height: $r('app.integer.address_exchange_airplane_size'),
        width: $r('app.integer.address_exchange_airplane_size')
    })
  Image($r('app.media.address_exchange_recycle'))
    .size({
        height: $r('app.integer.address_exchange_recycle_size'),
        width: $r('app.integer.address_exchange_recycle_size')
    })
    .rotate({ angle: this.rotateAngle })
    .animation({
        curve: Curve.EaseOut,
        playMode: PlayMode.Normal,
    })
}
  .width($r('app.string.address_exchange_image_width'))
  .onClick(() => {
    this.swap = !this.swap
    animateTo({ curve: curves.springMotion() }, () => {
        if (this.swap) {
            this.translateX = this.distance;
        } else {
            this.translateX = this.zeroTranslate;
        }
    })
    this.rotateAngle += this.rotateAddAngle;
  })
```

### 工程结构&模块类型

   ```
   addressexchange                                            // har类型
   |---view
   |   |---AddressExchangeView.ets                            // 视图层-地址交换动画页面 
   ```

### 模块依赖

[**utils**](../../common/utils)

### 参考资料

[显式动画](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-explicit-animation-0000001774121350)
