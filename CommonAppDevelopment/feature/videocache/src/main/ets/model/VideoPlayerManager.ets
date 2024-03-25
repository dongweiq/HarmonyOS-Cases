/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { CacheListener } from '@ohos/video-cache';
import media from '@ohos.multimedia.media';
import { logger } from '@ohos/base';
import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import GlobalProxyServer from '../model/GlobalProxyServer';

const ORIGIN_URL: string = 'https://assets.mixkit.co/videos/preview/mixkit-countryside-meadow-4075-large.mp4';
const TAG: string = 'AVPlayManager';

// 播放管理
export default class AvPlayManager {
  private static instance: AvPlayManager | null = null;
  private avPlayer: media.AVPlayer = {} as media.AVPlayer;
  // 播放管理类
  private surfaceID: string = '';

  public static getInstance(): AvPlayManager {
    if (!AvPlayManager.instance) {
      AvPlayManager.instance = new AvPlayManager();
    }
    return AvPlayManager.instance;
  }

  /**
   * 初始化视频播放管理器
   * @param context
   * @param surfaceId
   * @param callback
   * @returns
   */
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

  /**
   * 状态机函数，监听视频状态
   * @param callback 回调函数
   * @returns
   */
  async setAVPlayerCallback(callback: (avPlayer: media.AVPlayer) => void): Promise<void> {
    logger.info(TAG, `setAVPlayerCallback start`);
    if (this.avPlayer === null) {
      logger.info(TAG, 'avPlayer has not init');
      return;
    }
    // seek操作结果回调函数
    this.avPlayer.on('seekDone', (seekDoneTime) => {
      logger.info(TAG, `AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    })
    // error回调监听函数,当avPlayer在操作过程中出现错误时调用reset接口触发重置流程
    this.avPlayer.on('error', (err) => {
      logger.error(TAG, `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      this.avPlayer.reset(); // 调用reset重置资源，触发idle状态
    })
    // 状态机变化回调函数
    this.avPlayer.on('stateChange', async (state, reason) => {
      switch (state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报
          logger.info(TAG, 'AVPlayer state idle called.');
          this.videoRelease(); // 调用release接口销毁实例对象
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          logger.info(TAG, 'AVPlayer state initialized called.');
          if (this.surfaceID) {
            this.avPlayer.surfaceId = this.surfaceID; // 设置显示画面，当播放的资源为纯音频时无需设置
            logger.info(TAG, `setAVPlayerCallback this.avPlayer.surfaceId = ${this.avPlayer.surfaceId}`);
            this.avPlayer.prepare();
          }
          break;
        case 'prepared': // prepare调用成功后上报该状态机
          logger.info(TAG, 'AVPlayer state prepared called.');
          callback(this.avPlayer);
          logger.info(TAG, 'AVPlayer state prepared duration.' + this.avPlayer.duration);
          this.avPlayer.play(); // 调用播放接口开始播放
          break;
        case 'playing': // play成功调用后触发该状态机上报
          logger.info(TAG, 'AVPlayer state playing called.');
          AppStorage.setOrCreate('playStatus', 'playing');
          break;
        case 'paused': // pause成功调用后触发该状态机上报
          logger.info(TAG, 'AVPlayer state paused called.');
          break;
        case 'completed': // 播放结束后触发该状态机上报
          logger.info(TAG, 'AVPlayer state completed called.');
          AppStorage.setOrCreate('playStatus', 'completed'); // 双向数据绑定播放状态，这里播放完成之后，改变视图层播放图标的切换
          break;
        case 'stopped': // stop接口成功调用后触发该状态机上报
          logger.info(TAG, 'AVPlayer state stopped called.');
          break;
        case 'released':
          logger.info(TAG, 'AVPlayer state released called.');
          break;
        default:
          logger.info(TAG, 'AVPlayer state unknown called.');
          break;
      }
    })
  }

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

  /**
   * 视频播放
   */
  videoPlay(): void {
    logger.info(TAG, `videoPlay start`);
    if (this.avPlayer !== null) {
      try {
        this.avPlayer.play();
      } catch (err) {
        logger.error(TAG, `videoPlay = ${JSON.stringify(err)}`);
      }
    }
  }

  /**
   * 视频暂停
   */
  videoPause(): void {
    logger.info(TAG, `videoPause start`);
    if (this.avPlayer !== null) {
      try {
        this.avPlayer.pause();
      } catch (err) {
        logger.info(TAG, `videoPause== ${JSON.stringify(err)}`);
      }
    }
  }

  /**
   * 释放视频
   */
  videoRelease(): void {
    logger.info(TAG, `videoRelease start`);
    if (this.avPlayer !== null) {
      try {
        this.avPlayer.release();
      } catch (err) {
        logger.info(TAG, `videoRelease== ${JSON.stringify(err)}`);
      }
    }
  }
}

