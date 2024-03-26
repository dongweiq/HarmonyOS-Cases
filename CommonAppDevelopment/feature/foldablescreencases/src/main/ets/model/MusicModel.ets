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

/**
 * 歌词数据类，待扩展
 */
export class LyricsDataSource implements IDataSource {
  private lyricsDataArr: Array<string>;

  constructor(lyricsArr: Array<string>) {
    this.lyricsDataArr = lyricsArr;
  }

  totalCount(): number {
    return this.lyricsDataArr.length;
  }

  getData(index: number): string {
    return this.lyricsDataArr[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
  }
}

/**
 * 歌曲信息接口
 */
export interface MusicInfo {
  title: string,
  cover: Resource,
  singer: string,
  duration: number,
  lyrics: Array<string>,
  res: string,
}

/**
 * 歌曲数据模型
 */
export class MusicModel {
  private titleRaw: string = '';

  public get title(): string {
    return this.titleRaw;
  }

  private coverRaw: Resource;

  public get cover(): Resource {
    return this.coverRaw;
  }

  private singerRaw: string = '';

  public get singer(): string {
    return this.singerRaw;
  }

  private rawTotalTime: number = 0;

  public get totalTime(): number {
    return this.rawTotalTime;
  }

  private curTimeRaw: number = 0;

  public get curTime(): number {
    return this.curTimeRaw;
  }

  private lyricsInfoRaw: LyricsDataSource;

  public get lyricsInfo(): LyricsDataSource {
    return this.lyricsInfoRaw;
  }

  private resRaw: string = '';

  public get res(): string {
    return this.resRaw;
  }

  constructor(options: MusicInfo) {
    this.titleRaw = options.title;
    this.coverRaw = options.cover;
    this.singerRaw = options.singer;
    this.rawTotalTime = options.duration;
    this.lyricsInfoRaw = new LyricsDataSource(options.lyrics);
    this.resRaw = options.res;
  }
}