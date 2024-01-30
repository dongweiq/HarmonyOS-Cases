# 应用广告页实现

### 介绍

在大部分应用软件中，都需要开屏展示广告内容，用户任意时刻可点击跳转查看广告详情，或点击跳过进入首页。 本示例介绍使用 **广告服务** 来实现开屏广告的开发。

### 效果预览图

**不涉及**

**使用说明**
1. 加载完成后显示应用启动页。点击加载视频广告或加载图片广告，申请广告跟踪权限，获取OAID信息。
2. 根据已获取的OAID信息，获取广告信息后自动跳转广告展示页面，广告结束后，回到首页。

### 实现思路

1. 创建启动页组件，点击获取视频广告按钮和获取图片按钮,申请广告跟踪权限，使用getOAID方法获取OAID信息。源码参考[LaunchAdvertView.ets](./src/main/ets/view/LaunchAdvertView.ets)。

```ts
  // 进入页面时触发动态授权弹框，向用户请求授权广告跟踪权限。需在模块的module.json5文件中，申请广告跟踪权限ohos.permission.APP_TRACKING_CONSENT。
  requestOAIDTrackingConsentPermissions(context: common.Context): void {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    try {
      atManager.requestPermissionsFromUser(context, ["ohos.permission.APP_TRACKING_CONSENT"]).then((data) => {
        if (data.authResults[0] == this.requestOAIDPermissionSuccess) {
          // 申请权限成功
          logger.info(TAG, 'request permission success');
          // 获取OAID信息
          this.getOAIDString();
        } else {
          logger.info(TAG, 'user rejected APP_TRACKING_CONSENT permission');
        }
      }).catch((err: BusinessError) => {
        logger.error(TAG, `request permission failed. error: ${JSON.stringify(err)}`);
      })
    } catch (err) {
      logger.error(TAG, `request permission catch error: ${JSON.stringify(err)}`);
    }
  }

  // 调用getOAID方法获取OAID信息
  getOAIDString() {
    try {
      if (canIUse('SystemCapability.Advertising.OAID')) {
        identifier.getOAID((err: BusinessError, data: string) => {
          if (err.code) {
            logger.error(TAG, `get oaid failed. error: ${JSON.stringify(err)}`);
          } else {
            logger.info(TAG, `get oaid by callback success. oaid: ${data}`);
            // 请求广告信息
            ...
          }
        });
      }
    } catch (err) {
      logger.error(TAG, `get oaid catch error: ${JSON.stringify(err)}`);
    }
  }
```

2. 将OAID信息作为请求参数，获取广告信息。源码参考[LaunchAdvertView.ets](./src/main/ets/view/LaunchAdvertView.ets)。

```ts
  // 获取广告信息
  private requestAd(adReqParams: advertising.AdRequestParams, adOptions: advertising.AdOptions): void {
    // 广告请求回调监听
    const adLoaderListener: advertising.AdLoadListener = {
      // 广告请求失败回调
      onAdLoadFailure: (errorCode: number, errorMsg: string) => {
        logger.error(TAG, `request ad failed. errorCode is: ${errorCode}, errorMsg is: ${errorMsg}`);
        promptAction.showToast({
          message: `request ad failed. errorCode is: ${errorCode}, errorMsg is: ${errorMsg}`,
          duration: this.promtionDuration
        });
      },
      // 广告请求成功回调
      onAdLoadSuccess: (ads: Array<advertising.Advertisement>) => {
        logger.info(TAG, 'request ad success');
        if (canIUse("SystemCapability.Advertising.Ads")) {
          if (ads[0].adType === AdType.SPLASH_AD) {
            // 开屏广告展示页面
            try {
              // 调用广告展示页面
              ...
            } catch (err) {
              logger.error(TAG, `show ad catch error: ${JSON.stringify(err)}`);
            }
          } else {
            logger.error(TAG, 'error adType');
          }
        }
      }
    }

    if (canIUse("SystemCapability.Advertising.Ads")) {
      // 创建AdLoader广告对象
      const load: advertising.AdLoader = new advertising.AdLoader(this.context);
      logger.info(TAG, 'start request ad');
      load.loadAd(adReqParams, adOptions, adLoaderListener);
    }
  }
```

3. 跳转广告展示页面，广告结束后，回到首页。源码参考[AdvertShowPage.ets](./src/main/ets/view/AdvertShowPage.ets)。

```ts
  // 广告展示组件
  AdComponent({ ads: this.ads, displayOptions: AdDisplayOptions,
    interactionListener: {
      onStatusChanged: (status: string, ad: advertising.Advertisement, data: string) => {
        switch (status) {
          // 广告打开
          case AdStatus.AD_OPEN:
            logger.info(TAG, 'onAdOpen');
            break;
          // 广告点击
          case AdStatus.AD_CLICKED:
            logger.info(TAG, 'onAdClick');
            break;
          // 广告关闭
          case AdStatus.AD_CLOSED:
            logger.info(TAG, 'onAdClose');
            promptAction.showToast({
              message: $r('app.string.advert_close'),
              duration: this.promtionDuration
            });
            // 跳转相应的页面
            this.advertShow = false;
            break;
        }
      }
    }
  })
    .width($r('app.string.full_size'))
    .height(this.advertHeight)
```

### 工程结构&模块类型

   ```
   launchscenes                                    // har类型
   |---view
   |   |---AdvertShowPage.ets                      // 视图层-开屏广告展示页面
   |   |---LaunchAdvertView.ets                    // 视图层-开屏广告选择页面
   ```

### 模块依赖

[**utils**](../../common/utils)

### 参考资料

[@ohos.identifier.oaid (广告标识服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-oaid-0000001774280650)

[@ohos.advertising (广告服务框架)](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-advertising-0000001820880621)

[@ohos.advertising.AdComponent (非全屏广告展示组件)](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-adcomponent-0000001821000601)

[申请广告位ID](https://developer.huawei.com/consumer/cn/forum/topic/0204858516053660175)