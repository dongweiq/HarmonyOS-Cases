# 边缓存边播放案例

### 介绍

OhosVideoCache是一个支持边播放边缓存的库，只需要将音视频的url传递给OhosVideoCache处理之后再设置给播放器，
OhosVideoCache就可以一边下载音视频数据并保存在本地，一边读取本地缓存返回给播放器，使用者无需进行其他操作。

### 效果图预览

<img src="../../product/entry/src/main/resources/base/media/video_cache.gif" width="300"/>

**使用说明**：

1. 进入页面，自动播放视频，点击暂停，视频停止播放，点击播放，视频继续播放。
2. 视频播放完成之后，点击播放按钮，视频重新播放。

### 实现思路

边缓存播放功能主要是通过Xcomponent组件、@ohos.multimedia.media以及OhosVideoCache三方库实现，XComponent组件主要用于绘制
视频播放的窗口，页面进来初始化服务器然后利用XComponent组件的onLoad函数来调用[VideoPlayerManager](./src/main/ets/model/VideoPlayerManager.ets)
中的initPlayer方法创建一个音视频管理实例，并通过setAVPlayerCallback函数和cacheAndPlayVideo函数来实现视频状态的监听以及边缓存边播放功能。

1. XComponent组件绘制视频播放窗口。源码参考[VideoCacheView.ets](./src/main/ets/view/VideoCacheView.ets)。
```
 XComponent({
   id: 'xcomponent',
   type: 'surface',
   controller: this.componentController
 })
   .height(`${this.xComponentHeight}px`)
   .width(`${this.xComponentWidth}px`)
   .onLoad(() => {
     // 设置XComponent持有Surface的宽度和高度
     this.componentController.setXComponentSurfaceSize({
       surfaceWidth: SURFACE_WIDTH,
       surfaceHeight: SURFACE_HEIGHT
     });
     this.surfaceId = this.componentController.getXComponentSurfaceId();
     // 创建音视频播放实例
     AvPlayManager.getInstance()
       .initPlayer(getContext(this) as common.UIAbilityContext, this.surfaceId, (avPlayer: media.AVPlayer) => {
         avPlayer.on('timeUpdate', (time: number) => {
           this.currentTime = time;
         });
         this.videoDuration = handleTime(avPlayer.duration);
         this.total = avPlayer.duration;
       })
   })
```
2. 初始化代理服务器，页面一进来需要使用setServer方法来初始化代理服务器，以便后续调用此服务器处理url。源码参考[GlobalProxyServer.ets](./src/main/ets/model/GlobalProxyServer.ets)
```
import common from '@ohos.app.ability.common';
import { HttpProxyCacheServer } from '@ohos/video-cache';

const CONTEXT_STR: string = 'context';
const SERVER_STR: string = 'server';

export default class GlobalProxyServer {
  private static instance: GlobalProxyServer | null = null;
  private objects: Map<string, Object | null> = new Map<string, Object | null>();

  public static getInstance(): GlobalProxyServer {
    if (!GlobalProxyServer.instance) {
      GlobalProxyServer.instance = new GlobalProxyServer();
    }
    return GlobalProxyServer.instance;
  }
  /**
   * 获取上下文信息
   * @returns
   */
  getContext(): common.UIAbilityContext {
    return this.objects.get(CONTEXT_STR) as common.UIAbilityContext;
  }
  /**
   * 设置上下文信息
   * @param context
   */
  setContext(context: common.UIAbilityContext): void {
    this.objects.set(CONTEXT_STR, context);
  }

  /**
   * 获取服务器
   * @returns
   */
  getServer(): HttpProxyCacheServer {
    return this.objects.get(SERVER_STR) as HttpProxyCacheServer;
  }

  /**
   * 设置服务器
   * @param objectClass
   */
  setServer(objectClass: HttpProxyCacheServer): void {
    try {
      const currentServer: HttpProxyCacheServer = this.getServer();
      currentServer.shutdown();
    } catch (err) {
    }
    this.objects.set(SERVER_STR, objectClass);
  }
}
```
3. media.createAVPlayer()创建播放管理类，用于管理和播放媒体资源。源码参考[VideoPlayerManager.ets](./src/main/ets/model/VideoPlayerManager.ets)
```
  async initPlayer(context: common.UIAbilityContext, surfaceId: string,
                   callback: (avPlayer: media.AVPlayer) => void): Promise<void> {
    logger.info(TAG, `initPlayer==initCamera surfaceId== ${surfaceId}`);
    this.surfaceID = surfaceId;
    try {
      // 创建avPlayer实例对象
      this.avPlayer = await media.createAVPlayer();
      // 创建状态机变化回调函数
      await this.setAVPlayerCallback(callback);
      // 边缓存边播放
      this.cacheAndPlayVideo(context);
    } catch (err) {
      logger.error(TAG, `initPlayer initPlayer err：${JSON.stringify(err)}`);
    }
  }
```
4. 边播放边缓存，MyCacheListener监听缓存进度，getProxyUrl(ORIGIN_URL)获取视频播放地址并设置给播放器。源码参考[VideoPlayerManager.ets](./src/main/ets/model/VideoPlayerManager.ets)
```
 /**
   * 边缓存边监听函数
   * @param context 上下文信息
   * @returns
   */
  async cacheAndPlayVideo(context: common.UIAbilityContext): Promise<void> {
    logger.info(TAG, `cacheAndPlayVideo start`);

    // TODO:知识点:监听缓存进度
    class MyCacheListener implements CacheListener {
      onCacheAvailable(cacheFilePath: string, url: string, percentsAvailable: number): void {
        AppStorage.setOrCreate('currentCachePercent', percentsAvailable);
      }
    }

    GlobalProxyServer?.getInstance()?.getServer()?.registerCacheListener(new MyCacheListener(), ORIGIN_URL);
    // TODO:知识点:将原始的音视频url交给OhosVideoCache
    let proxyUrl: string | undefined = await GlobalProxyServer?.getInstance()?.getServer()?.getProxyUrl(ORIGIN_URL);
    // 由于avplayer不支持直接加载本地文件路径 这里需要转化为fd的路径
    if (proxyUrl.startsWith(context.cacheDir)) {
      const file = fs.openSync(proxyUrl, fs.OpenMode.READ_ONLY);
      proxyUrl = `fd://${file.fd}`;
    }
    logger.info(TAG, `proxyUrl ${proxyUrl}`);
    // 将处理之后的url设置给播放器
    this.avPlayer.url = proxyUrl;
  }
```
### 高性能知识点

**不涉及。**

### 工程结构&模块类型

```
videocache                                         // har类型
|---model
|   |---GlobalProxyServer.ets                      // 模型层-服务器管理
|   |---VideoPlayerManager.ets                     // 模型层-音视频管理
|---utils
|   |---utils.ets                                  // 工具
|---view
|   |---VideoCacheView.ets                         // 视图层-应用主页面
```

### 模块依赖

本实例依赖common模块来实现[日志](../../common/utils/src/main/ets/log/Logger.ets)的打印、[资源](../../common/utils/src/main/resources/base/element)
的调用、[动态路由模块](../../feature/routermodule/src/main/ets/router/DynamicsRouter.ets)来实现页面的动态加载以及[video-cache](oh-package.json5)，版本为1.0.0。

### 参考资料

[音视频管理](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V2/js-apis-audio-0000001478181621-V2)


