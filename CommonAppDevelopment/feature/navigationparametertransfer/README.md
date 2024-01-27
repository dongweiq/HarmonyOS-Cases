# Navigation页面跳转对象传递方案

### 介绍

本示例主要介绍在使用Navigation实现页面跳转时，如何在跳转页面得到转入页面传的类对象的方法。实现过程中使用了第三方插件class-transformer
### 效果图预览

![](../../screenshots/device/navigationParameterTransfer.gif)

**使用说明**

1. 进入页面点击提交按钮，会弹出一个窗口，该窗口即为其他页面传过来的类对象的方法的实现效果。

### 实现思路

1. 在oh-package.json5中添加第三方插件class-transformer的依赖

   ```typescript
   // 图表数据初始化
   "dependencies": {
   "class-transformer": "^0.5.1"
   }
   ```

2. 在使用第三方插件class-transformer的页面导入class-transformer库。

   ```typescript
      import { plainToClass } from "class-transformer";
   ```

3. 将传递过来的参数通过class-transformer的plainToClass方法转化为类对象。

   ```typescript
   // 图表数据初始化
   let bookingString:string = this.pageStack.getParamByName('NavigationParameterTransfer')[0] as string;
   // 转化成普通对象
   let userBookingTmp: UserBookingInfo = JSON.parse(bookingString);
   // TODO：知识点：通过调用第三方插件class-transformer的plainToClass方法转换成类对象, 不进行转换直接使用userBookingTmp调用getUserInfo方法会造成crash
   this.userBooking = plainToClass(UserBookingInfo, userBookingTmp);
   ```

### 高性能知识点

**不涉及**

### 工程结构&模块类型

   ```
   pageJumpTransferFunction                           // har类型
   |---src\main\ets\components
   |   |---UserBookingInfo.ets                        // 要传递的类对象
   |---src\main\ets\view
   |   |---NavigationParameterTransferView.ets        //  视图层-Navigation主页面
   ```

### 模块依赖

1. 本模块依赖[class-transformer三方库](https://github.com/pleerock/class-transformer-demo)。
### 参考资料

[class-transformer三方库](https://github.com/pleerock/class-transformer-demo)