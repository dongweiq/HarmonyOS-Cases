
# 应用启动页场景开发范例

### 简介

在应用开发时，基本上都需要一个应用的启动页，包含logo和应用的说明语。根据需求在启动页后，展示广告内容，用户任意时刻可点击跳转进入首页。


### 效果预览图

![](../../screenshots/device/LaunchScenes.gif)


### 场景概述

### 实现思路

> 通过router.replaceUrl(options: RouterOptions, mode: RouterMode): Promise<void> 进行当前页面的替换，[router.replaceUrl详情](https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/reference/apis/js-apis-router.md/#routerreplaceurl9-3)。

### 开发步骤

通过onclick事件或定时器调用router.replaceUrl方法替换当前页面。源码参考[LaunchPage.ets](../../product/entry/src/main/ets/pages/LaunchPage.ets)
  ```ts
  setTimeout(() => {
      try {
        router.replaceUrl({ url: 'pages/LaunchAdvertPage' }, router.RouterMode.Standard)
      } catch (err) {
        logger.error(TAG, '%{public}s', `replaceUrl failed, code: ${err.code}, message: ${err.message}`);
      }
    }, 5000)
  ```