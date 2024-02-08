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

import { logger } from '@ohos/utils';
import CommonConstants from '../common/constants/CommonConstants';
import { AVPlayerModel } from '../model/AVPlayerModel';
import { MusicModel } from '../model/MusicModel';

export class MusicPlayerViewModel {
  /**
   * MusicPlayerViewModel 单例
   */
  private static instance?: MusicPlayerViewModel;

  /**
   * 获取MusicPlayerViewModel单例实例
   * @returns {MusicPlayerViewModel} MusicPlayerViewModel
   */
  static getInstance(musicModel: MusicModel): MusicPlayerViewModel {
    if (!MusicPlayerViewModel.instance) {
      MusicPlayerViewModel.instance = new MusicPlayerViewModel(musicModel);
    }

    return MusicPlayerViewModel.instance;
  }

  private musicModel: MusicModel;
  private avplayerModel: AVPlayerModel = AVPlayerModel.getInstance();

  private totalTimeStrRaw: string = '';

  public get totalTimeStr(): string {
    return this.totalTimeStrRaw;
  }

  private curTimeStrRaw: string = '';

  public get curTimeStr(): string {
    return this.curTimeStrRaw;
  }

  private curProgressRaw: number = 0;

  public get curProgress(): number {
    return this.curProgressRaw;
  }

  private curPlayerStateRaw: string = CommonConstants.AVPLAYER_STATE_IDLE;

  public get curPlayerState(): string {
    return this.curPlayerStateRaw;
  }

  private constructor(musicModel: MusicModel) {
    this.musicModel = musicModel;
  }

  /**
   * vm初始化
   * @returns {Promise<void>}
   */
  async init(): Promise<void> {
    this.updateTotalTime();
    this.updateCurTime(0);
    await this.avplayerModel.initAVPlayer(
      (newTime: number) => {
        this.updateCurTime(newTime);
      },
      (state: string) => {
        this.curPlayerStateRaw = state;
      }
    );
  }

  /**
   * 启动播放
   * @returns {void}
   */
  play(): void {
    logger.info('vm play');
    this.avplayerModel.playLocalRawfile(this.musicModel.res);
  }

  /**
   * 暂停播放
   * @returns {void}
   */
  pause(): void {
    logger.info('vm pause');
    this.avplayerModel.pause();
  }

  /**
   * 恢复播放
   * @returns {void}
   */
  resume(): void {
    logger.info('vm resume');
    this.avplayerModel.resume();
  }

  /**
   * 跳跃播放
   * @param timeMs 跳跃到歌曲的毫秒时间点
   * @returns {void}
   */
  seek(timeMs: number): void {
    logger.info('vm seek');
    this.avplayerModel.seek(timeMs);
  }

  /**
   * 生成时间字符串
   * @param timeMs 毫秒数
   * @returns 时:分:秒 规格的字符串
   */
  private genTimeStr(timeMs: number) {
    const totalTime = timeMs / 1000;
    let hours = Math.floor(totalTime / CommonConstants.SECONDS_IN_HOUR);
    let leftTime = totalTime % CommonConstants.SECONDS_IN_HOUR;
    let minutes = Math.floor(leftTime / CommonConstants.SECONDS_IN_MINUTE);
    let seconds = Math.floor(leftTime % CommonConstants.SECONDS_IN_MINUTE);

    let hoursStr = '';
    let minutesStr = '';
    let secondsStr = '';

    if (hours < 10) {
      hoursStr = `0${hours}`;
    } else {
      hoursStr = hours.toString();
    }

    if (minutes < 10) {
      minutesStr = `0${minutes}`;
    } else {
      minutesStr = minutes.toString();
    }

    if (seconds < 10) {
      secondsStr = `0${seconds}`;
    } else {
      secondsStr = seconds.toString();
    }

    const totalTimeStr = `${hoursStr}:${minutesStr}:${secondsStr}`;
    return totalTimeStr;
  }

  /**
   * 更新播放歌曲总时间
   */
  updateTotalTime(): void {
    const totalTime = this.musicModel.totalTime;
    this.totalTimeStrRaw = this.genTimeStr(totalTime);
  }

  /**
   * 更新播放歌曲当前进度时间
   * @param curTime 当前进度时间
   */
  updateCurTime(curTime: number) {
    this.curTimeStrRaw = this.genTimeStr(curTime);
    this.curProgressRaw = curTime / this.musicModel.totalTime * 100;
  }
}

