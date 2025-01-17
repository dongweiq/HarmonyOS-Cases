# 使用弹簧曲线实现抖动动画及手机振动效果案例

### 介绍

本示例介绍使用vibrator.startVibration方法实现手机振动效果，用animateTo显示动画实现点击后的抖动动画。

### 效果图预览

![](../../product/entry/src/main/resources/base/media/vibrate_effect.gif)

**使用说明**

1. 加载完成后显示登录界面，未勾选协议时点击一键登录按钮会触发手机振动效果和提示文本的抖动动画。

### 实现思路

1. 创建一个函数startVibrate()调用vibrator.startVibration方法实现手机振动效果（需要权限：ohos.permission.VIBRATE）。源码参考[VibrateEffect.ets](./src/main/ets/VibrateEffect.ets)
```ts
  startVibrate() {
    try {
      // TODO: 知识点：vibrator.startVibration 根据指定振动效果和振动属性触发马达振动
      vibrator.startVibration({
        type: 'time',
        // 持续触发马达振动时间600ms
        duration: CONFIGURATION.VIBRATION_TIME,
      }, {
        id: 0,
        usage: 'alarm',
      }, (error: BusinessError) => {
        if (error) {
          logger.error(`Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
          return;
        }
        logger.info('Succeed in starting vibration');
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      logger.error(`An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
    }
  }
  ```
2. 创建一个函数startAnimation()使用animateTo显示动画实现提示文本的抖动动画。源码参考[VibrateEffect.ets](./src/main/ets/VibrateEffect.ets)
```ts
  startAnimation() {
    if (!this.uiContext) {
      return;
    }
    this.translateX = CONFIGURATION.POSITION_ZERO;
    // TODO: 知识点：通过keyframeAnimateTo关键帧动画指定状态变化过渡动效
    this.uiContext.keyframeAnimateTo({ iterations: CONFIGURATION.PLAYBACK_COUNT }, [
      {
        // 第一段动画时长为100ms，translateX属性从0到5
        duration: CONFIGURATION.ANIMATION_TIME,
        event: () => {
          this.translateX = CONFIGURATION.TRANSLATE_OFFSET_X;
        }
      },
      {
        // 第二段动画时长为100ms，translateX属性从5到0
        duration: CONFIGURATION.ANIMATION_TIME,
        event: () => {
          this.translateX = CONFIGURATION.POSITION_ZERO;
        }
      }
    ]);
  }
```
### 高性能知识点

**不涉及**

### 工程结构&模块类型

   ```
   vibrateeffect                                   // har类型
   |---components
   |   |---constantsData.ets                       // 定义常量数据
   |---ProductView.ets                             // 视图层-场景列表页面
   ```

### 模块依赖

本实例依赖common模块来实现[日志](../../common/utils/src/main/ets/log/Logger.ets)的打印、[资源](../../common/utils/src/main/resources/base/element)的调用

### 参考资料

[显式动画](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V2/ts-explicit-animation-0000001478341181-V2)

[@ohos.vibrator (振动)](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V2/js-apis-vibrator-0000001451155026-V2#ZH-CN_TOPIC_0000001574248809__vibrateeffect9)

[访问控制授权申请](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/accesstoken-guidelines-0000001493744016-V2)