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

import { promptAction } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import { logger } from '@ohos/utils';

export class AVPlayerModel {
  /**
   * AVPlayerModel 单例
   */
  private static instance?: AVPlayerModel;

  /**
   * 获取AVPlayerModel单例实例
   * @returns {AVPlayerModel} AVPlayerModel
   */
  static getInstance(): AVPlayerModel {
    if (!AVPlayerModel.instance) {
      AVPlayerModel.instance = new AVPlayerModel();
    }

    return AVPlayerModel.instance;
  }

  private avPlayer?: media.AVPlayer;
  private constructor() {
  }

  /**
   * 初始化AVPlayer
   * @param timeUpdateCb AVPlayer timeUpdate 事件回调
   * @param stateUpdateCb AVPlayer stateChange 事件回调
   * @returns {Promise<void>}
   */
  async initAVPlayer(timeUpdateCb: Function, stateUpdateCb: Function): Promise<void> {
    if (this.avPlayer) {
      return;
    }

    // 创建AVPlayer实例对象
    let avPlayer: media.AVPlayer = await media.createAVPlayer();
    if (!avPlayer) {
      logger.error('avPlayer init failed.');
      return;
    }
    // 创建状态机变化回调函数
    this.regAVPlayerCallback(avPlayer, timeUpdateCb, stateUpdateCb);

    this.avPlayer = avPlayer;
  }

  /**
   * 注册avplayer回调函数
   * @param avPlayer AVPlayer实例
   * @returns {void}
   */
  private regAVPlayerCallback(avPlayer: media.AVPlayer, timeUpdateCb: Function, stateUpdateCb: Function): void {
    // seek操作结果回调函数
    avPlayer.on('seekDone', (seekDoneTime: number) => {
      logger.info(`AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    })
    // error回调监听函数,当avPlayer在操作过程中出现错误时调用 reset接口触发重置流程
    avPlayer.on('error', (err: BusinessError) => {
      logger.error(`Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      // 调用reset重置资源，触发idle状态
      avPlayer.reset();
    })
    // 歌曲时间进度更新
    avPlayer.on('timeUpdate', (newTime: number) => {
      timeUpdateCb(newTime);
    })
    // 状态机变化回调函数
    avPlayer.on('stateChange', (state: string, reason: media.StateChangeReason) => {
      stateUpdateCb(state);

      switch (state) {
        // 成功调用reset接口后触发该状态机上报
        case 'idle':
          logger.info('AVPlayer state idle called.');
          this.showToast('avPlayer in idle');
          break;
        // avplayer 设置播放源后触发该状态上报
        case 'initialized':
          logger.info('AVPlayer state initialized called.');
          avPlayer.prepare();
          this.showToast('avPlayer in initialized');
          break;
        // prepare调用成功后上报该状态机
        case 'prepared':
          logger.info('AVPlayer state prepared called.');
          // 调用播放接口开始播放
          avPlayer.play();
          this.showToast('avPlayer in prepared');
          break;
        // play成功调用后触发该状态机上报
        case 'playing':
          logger.info('AVPlayer state playing called.');
          this.showToast('avPlayer in playing');
          break;
        // pause成功调用后触发该状态机上报
        case 'paused':
          logger.info('AVPlayer state paused called.');
          this.showToast('avPlayer in paused');
          break;
        // 播放结束后触发该状态机上报
        case 'completed':
          logger.info('AVPlayer state completed called.');
          this.showToast('avPlayer in completed');
          break;
        // stop接口成功调用后触发该状态机上报
        case 'stopped':
          logger.info('AVPlayer state stopped called.');
          // 调用reset接口初始化avplayer状态
          avPlayer.reset();
          this.showToast('avPlayer in stopped');
          break;
        // avplayer实例释放状态
        case 'released':
          logger.info('AVPlayer state released called.');
          this.avPlayer = undefined;
          this.showToast('avPlayer in released');
          break;
        default:
          logger.info('AVPlayer state unknown called.');
          this.showToast('avPlayer in unknown');
          break;
      }
    })
  }

  /**
   * 状态提示弹窗
   * @param msg 提示内容
   */
  private showToast(msg: string): void {
    promptAction.showToast({
      message: msg
    })
  }

  /**
   * 获取当前avplayer状态
   * @returns {media.AVPlayerState | undefined}
   */
  getAVPlayerState(): media.AVPlayerState | undefined {
    if (!this.avPlayer) {
      logger.error('avPlayer no create.');
      return;
    }

    return this.avPlayer.state;
  }

  /**
   * 播放本地沙箱内的rawfile资源
   * @param fileName 本地沙箱内的rawfile资源文件名
   * @returns {Promise<void>}
   */
  async playLocalRawfile(fileName: string): Promise<void> {
    if (!this.avPlayer) {
      logger.error('avPlayer no create.');
      return;
    }

    // 通过UIAbilityContext的resourceManager成员的getRawFd接口获取媒体资源播放地址
    let context = getContext(this) as common.UIAbilityContext;
    // 返回类型为{fd,offset,length},fd为HAP包fd地址，offset为媒体资源偏移量，length为播放长度
    let fileDescriptor = await context.resourceManager.getRawFd(fileName);
    let avFileDescriptor: media.AVFileDescriptor = {
      fd: fileDescriptor.fd,
      offset: fileDescriptor.offset,
      length: fileDescriptor.length
    };
    // 为fdSrc赋值触发initialized状态机上报
    this.avPlayer.fdSrc = avFileDescriptor;
  }

  /**
   * 暂停播放
   * @returns {void}
   */
  pause(): void {
    if (!this.avPlayer) {
      logger.error('avPlayer no create.');
      return;
    }

    this.avPlayer.pause();
  }

  /**
   * 恢复播放
   * @returns {void}
   */
  resume(): void {
    if (!this.avPlayer) {
      logger.error('avPlayer no create.');
      return;
    }

    this.avPlayer.play();
  }

  /**
   * 跳跃播放
   * @param timeMs 跳跃到歌曲的毫秒时间点
   * @returns {void}
   */
  seek(timeMs: number): void {
    if (!this.avPlayer) {
      logger.error('avPlayer no create.');
      return;
    }

    this.avPlayer.seek(timeMs);
  }
}