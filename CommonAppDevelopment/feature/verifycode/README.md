# 多层嵌套类对象监听

### 介绍

本示例介绍如何使用Text组件实现验证码场景，并禁用对内容的选中、复制、光标。

### 效果图预览

<img src="../../screenshots/device/VariableWatch.gif" width="200">

**使用说明**

1. 单击组件可弹出输入法
2. 在进行验证码输入时，无法对中间单个数字进行更改，无法选中输入内容，无光标

### 实现思路

1. 验证码通常是6位数，这里使用6个Text组件实现，每个Text组件显示1个数字
2. 因为要禁用复制、选中等功能，这里使用了Text组件，而不是TextInput
3. 使用输入法框架inputMethod获取输入内容

### 高性能知识点

**不涉及**

### 工程结构&模块类型

   ```
   verifycode                                       // har类型
   |---constants
   |   |---VerifyCodeConstants.ets                  // 常量
   |   utils
   |   |---Logger                                   // 日志工具类
   |---view
   |   |---VerifyCodeView.ets                       // 视图层-验证码组件
   ```

### 模块依赖

**不涉及**

### 参考资料

1. [Text](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-text-0000001821000881)
2. [inputMethod](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-inputmethod-0000001774281542)