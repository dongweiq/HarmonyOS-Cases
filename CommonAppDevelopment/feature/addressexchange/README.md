
# 地址交换动画

### 介绍

本示例介绍使用显式动画 **animateTo** 实现左右地址交换动画。该场景多用于机票、火车票购买等出行类订票软件中。

### 效果预览图

![](../../screenshots/device/AddressExchange.gif)

**使用说明**
1. 加载完成后显示地址交换动画页面，点击中间的图标，左右两边地址交换。

### 实现思路
1. 创建左右两边Text组件显示地址。设置初始偏移量以及文本对齐方式。
2. 点击中间的图标时，修改是否切换的状态变量值和通过animateTo修改偏移量的值，来实现动态更新左右两边地址的显示，完成动画效果。

### 工程结构&模块类型

   ```
   addressexchange                                            // har类型
   |---view
   |   |---AddressExchangeView.ets                            // 视图层-地址交换动画页面 
   ```

### 模块依赖

[**utils**](../../common/utils)

### 参考资料

[显式动画](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V3/ts-explicit-animation-0000001478341181-V3)
