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

import { media } from '@kit.MediaKit';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import { logger } from '@ohos/utils';
import CommonConstants from '../common/constants/CommonConstants';

export class AVPlayerModel {
  // avPlayer播放器实例
  private avPlayer?: media.AVPlayer = undefined;

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
   * 释放AVPlayer资源
   */
  releaseAVPlayer(): void {
    if (!this.avPlayer) {
      return;
    }

    this.avPlayer.release();
    this.avPlayer = undefined;
  }

  /**
   * 注册avplayer回调函数
   * @param avPlayer AVPlayer实例
   * @returns {void}
   */
  private regAVPlayerCallback(avPlayer: media.AVPlayer, timeUpdateCb: Function, stateUpdateCb: Function): void {
    // seek操作结果回调函数
    avPlayer.on('seekDone', (seekDoneTime: number) => {
      logger.debug(`AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
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
    avPlayer.on('stateChange', (state: media.AVPlayerState) => {
      stateUpdateCb(state);

      switch (state) {
        // 成功调用reset接口后触发该状态机上报
        case CommonConstants.AVPLAYER_STATE_IDLE:
          logger.debug('AVPlayer state idle called.');
          break;
        // avplayer 设置播放源后触发该状态上报
        case CommonConstants.AVPLAYER_STATE_INITIALIZED:
          logger.debug('AVPlayer state initialized called.');
          avPlayer.prepare();
          break;
        // prepare调用成功后上报该状态机
        case CommonConstants.AVPLAYER_STATE_PREPARED:
          logger.debug('AVPlayer state prepared called.');
          break;
        // play成功调用后触发该状态机上报
        case CommonConstants.AVPLAYER_STATE_PLAYING:
          logger.debug('AVPlayer state playing called.');
          break;
        // pause成功调用后触发该状态机上报
        case CommonConstants.AVPLAYER_STATE_PAUSED:
          logger.debug('AVPlayer state paused called.');
          break;
        // 播放结束后触发该状态机上报
        case CommonConstants.AVPLAYER_STATE_COMPLETED:
          logger.debug('AVPlayer state completed called.');
          break;
        // stop接口成功调用后触发该状态机上报
        case CommonConstants.AVPLAYER_STATE_STOPPED:
          logger.debug('AVPlayer state stopped called.');
          // 调用reset接口初始化avplayer状态
          avPlayer.reset();
          break;
        // avplayer实例释放状态
        case CommonConstants.AVPLAYER_STATE_RELEASED:
          logger.debug('AVPlayer state released called.');
          this.avPlayer = undefined;
          break;
        default:
          logger.debug('AVPlayer state unknown called.');
          break;
      }
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
   * 加载本地沙箱内的rawfile资源
   * @param fileName 本地沙箱内的rawfile资源文件名
   * @returns {Promise<void>}
   */
  async prepare(fileName: string): Promise<void> {
    if (!this.avPlayer) {
      logger.error('avPlayer no create.');
      return;
    }

    // 通过UIAbilityContext的resourceManager成员的getRawFd接口获取媒体资源播放地址
    const context = getContext(this) as common.UIAbilityContext;
    // 返回类型为{fd,offset,length},fd为HAP包fd地址，offset为媒体资源偏移量，length为播放长度
    const fileDescriptor = await context.resourceManager.getRawFd(fileName);
    const avFileDescriptor: media.AVFileDescriptor = {
      fd: fileDescriptor.fd,
      offset: fileDescriptor.offset,
      length: fileDescriptor.length
    };
    // 为fdSrc赋值触发initialized状态机上报
    this.avPlayer.fdSrc = avFileDescriptor;
  }

  /**
   * 开始播放
   * @returns {void}
   */
  play(): void {
    if (!this.avPlayer) {
      logger.error('avPlayer no create.');
      return;
    }

    this.avPlayer.play();
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