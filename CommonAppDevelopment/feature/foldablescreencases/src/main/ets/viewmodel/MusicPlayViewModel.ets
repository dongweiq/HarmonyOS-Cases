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

import CommonConstants from '../common/constants/CommonConstants';
import { AVPlayerModel } from '../model/AVPlayerModel';
import { MusicModel } from '../model/MusicModel';
import { promptAction } from '@kit.ArkUI';

export class MusicPlayerViewModel {
  constructor() {
  }

  private avplayerModel: AVPlayerModel = new AVPlayerModel();

  private musicModelRaw?: MusicModel;

  public get musicModel(): MusicModel | undefined {
    return this.musicModelRaw;
  }

  public set musicModel(val: MusicModel | undefined) {
    this.musicModelRaw = val;
  }

  private totalTimeStrRaw: string = '';

  public get totalTimeStr(): string {
    return this.totalTimeStrRaw;
  }

  private curTimeRaw: number = 0;

  public get curTime(): number {
    return this.curTimeRaw;
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

  private progressLockRaw: boolean = false;

  public get progressLock(): boolean {
    return this.progressLockRaw;
  }

  public set progressLock(val: boolean) {
    this.progressLockRaw = val;
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
        // 如果slider进度正在被用户拖动或点击过程中，则不通过avplayer来同步进度
        if (this.progressLockRaw) {
          // 如果本次同步过来的时间与slider当前时间一致，表示用户拖动或点击结束，此次之后开始接收avplayer的同步进度
          if (Math.abs(this.curTimeRaw - newTime) < 5) {
            this.progressLockRaw = false;
          }

          return;
        }

        this.updateCurTime(newTime);
      },
      (state: string) => {
        this.curPlayerStateRaw = state;
      }
    );
    this.prepare();
  }

  /**
   * 加载播放资源
   * @returns {void}
   */
  prepare(): void {
    if (!this.musicModelRaw) {
      return;
    }

    this.avplayerModel.prepare(this.musicModelRaw.res);
  }

  /**
   * 启动播放
   * @returns {void}
   */
  play(): void {
    this.avplayerModel.play();
  }

  /**
   * 暂停播放
   * @returns {void}
   */
  pause(): void {
    this.avplayerModel.pause();
  }

  /**
   * 恢复播放
   * @returns {void}
   */
  resume(): void {
    this.avplayerModel.resume();
  }

  /**
   * 跳跃播放
   * @param timeMs 跳跃到歌曲的毫秒时间点
   * @returns {void}
   */
  seek(timeMs: number): void {
    this.avplayerModel.seek(timeMs);
  }

  /**
   * 释放播放器资源
   * @returns {void}
   */
  release(): void {
    this.avplayerModel.releaseAVPlayer();
  }

  /**
   * 生成时间字符串
   * @param timeMs 毫秒数
   * @returns {string} 时:分:秒 规格的字符串
   */
  genTimeStr(timeMs: number) {
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
   * @returns {void}
   */
  updateTotalTime(): void {
    if (!this.musicModelRaw) {
      return;
    }

    const totalTime = this.musicModelRaw.totalTime;
    this.totalTimeStrRaw = this.genTimeStr(totalTime);
  }

  /**
   * 更新播放歌曲当前进度时间
   * @param curTime 当前进度时间
   * @returns {void}
   */
  updateCurTime(curTime: number): void {
    if (!this.musicModelRaw) {
      return;
    }

    this.curTimeRaw = curTime;
    this.curTimeStrRaw = this.genTimeStr(curTime);
    this.curProgressRaw = curTime / this.musicModelRaw.totalTime * CommonConstants.MUSIC_SLIDER_MAX;
  }

  /**
   * 未完成的功能，显示TODO消息提示
   * @returns {void}
   */
  showTodoToast() {
    promptAction.showToast({
      message: $r('app.string.toast_todo_show')
    })
  }
}

