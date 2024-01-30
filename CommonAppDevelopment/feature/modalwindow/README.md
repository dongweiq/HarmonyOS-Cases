# 全屏登录页面

### 介绍

本例介绍各种应用登录页面。

1. 全屏登录页面：在主页面点击跳转到全屏登录页后，显示全屏模态页面，全屏模态页面从下方滑出并覆盖整个屏幕，模态页面内容自定义，此处分为默认一键登录方式和其他登录方式。

### 效果图预览

![](../../screenshots/device/ModalWindow.gif)

##### 使用说明

1. 点击主页面按钮"点击跳转到全屏登录页"，显示全屏模态页面。
2. 不选中"阅读并同意服务协议及个人信息处理规则"，点击一键登录，提示"请先阅读并同意协议"；选中则提示"登录成功"。
3. 点击左下方"其他登录方式"，页面中显示其他登录方式页面。
4. 在手机号输入框输入11位数字后，"发送短信验证码"按钮由灰变蓝，选中"阅读并同意服务协议及个人信息处理规则"，点击"发送短信验证码"按钮，提示"验证码已发送"。
5. 点击左上角返回图标回到一键登录页面，再次点击返回图标收起模态页面。



### 实现思路

本例涉及的关键特性和实现方案如下：

1. 通过[bindContentCover](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-universal-attributes-modal-transition-0000001821000821)组件绑定全屏模态页面，模态页面内容通过[@Builder装饰器](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-builder-0000001774119930)自定义。源码参考[ModalWindow](./src/main/ets/ModalWindow.ets)
```typescript
Button($r('app.string.full_screen_modal_login_description'))
  .fontColor(Color.White)
  .borderRadius($r('app.integer.border_radius'))
  .type(ButtonType.Normal)
  .backgroundColor($r('app.color.grey_2'))
  .width($r('app.string.size_full'))
  .bindContentCover(this.isPresent, this.loginBuilder)
  .onClick(() => {
    this.isPresent = true;
  })
```
2. 模态页面显示后，默认展示一键登录页面。页面需要在一个模态页面中切换，此处使用if进行条件渲染。源码参考[DefaultLogin](./src/main/ets/model/DefaultLogin.ets)

```typescript
if (this.isDefaultLogin) {
  // 默认一键登录方式
  ...
} else {
  // 其他登录方式
  OtherWaysToLogin()
    .transition(this.effect)
}
```

3. 点击其他登录方式，切换过程涉及到组件的显示和消失，使用[transition](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-transition-animation-component-0000001774121354)属性设置出现或消失转场。源码参考[DefaultLogin](./src/main/ets/model/DefaultLogin.ets)

```typescript
  OtherWaysToLogin()
    .transition(this.effect)
```

4. 通过Stack组件，两个页面共用一个返回图标。源码参考[DefaultLogin](./src/main/ets/model/DefaultLogin.ets)

```typescript
Stack() {
  Image($r('app.media.arrow_back')) // 通过Stack组件，两个页面只实现一个back
    .width($r('app.integer.height_twenty_five')).height($r('app.integer.height_twenty_five'))
    .margin({ top: $r('app.integer.margin_mid') })
    .onClick(() => {
      if (this.isDefaultLogin) {
        this.isPresentInLoginView = false;
      } else {
        this.isDefaultLogin = true
      }
    })
}
```



### 高性能知识点

不涉及。

### 工程结构&模块类型

```
   modalwindow                                      // har包
   |---model
   |   |---DefaultLogin.ets                         // 默认一键登录页面
   |   |---OtherWaysToLogin.ets                     // 其他登录方式页面      
   |---ModalWindow.ets                              // 主页面，提供登录类型选项
```

### 模块依赖

不涉及。

### 参考资料

[全屏模态转场(bindContentCover)](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-universal-attributes-modal-transition-0000001821000821)

[组件内转场(transition)](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-transition-animation-component-0000001774121354)

[@Builder装饰器](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-builder-0000001774119930)