
# 应用启动页+开屏广告页

### 介绍

在应用开发时，基本上都需要一个应用的启动页，包含logo和应用的说明语。根据需求在启动页后，展示广告内容，用户任意时刻可点击跳转进入首页。 本示例介绍使用 **AdsKit** 来实现开屏广告的开发。

### 效果预览图

![](../../screenshots/device/LaunchScenes.gif)

**使用说明**
1. 加载完成后显示应用启动页。
2. 在应用启动页中，获取广告信息后自动跳转广告展示页面，广告结束后，回到首页。

### 实现思路

1. 创建启动页Component，在aboutToAppear方法中申请广告跟踪权限，使用getOAID方法获取OAID信息。
2. 将OAID信息作为请求参数，获取广告信息。
3. 跳转广告展示页面，广告结束后，回到首页。

### 工程结构&模块类型

   ```
   launchscenes                                    // har类型
   |---view
   |   |---LaunchAdvertView.ets                    // 视图层-开屏广告展示页面
   |   |---LaunchAppView.ets                       // 视图层-应用启动页面
   ```

### 模块依赖

[**utils**](../../common/utils)

### 参考资料

[AdsKit](https://harmonyosdevelopertest.devccsrnd.hwcloudtest.cn:3087/cn/docs/documentation/doc-guides/ads-publisher-service-splash-0000001819969069)