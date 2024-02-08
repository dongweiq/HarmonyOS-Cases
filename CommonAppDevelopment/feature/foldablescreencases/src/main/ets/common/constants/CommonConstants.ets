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

import { MusicInfo } from '../../model/MusicModel';

/**
 * 通用常量
 */
export default class CommonConstants {
  static readonly TEST_MUSIC_INFO = {
    title: '后来',
    cover: $rawfile('cover.webp'),
    singer: '刘若英',
    duration: 341000,
    lyrics: ['歌词', 'coming soon...'],
    res: 'houlai.mp3'
  } as MusicInfo;

  /**
   * FolderStack组件中，需要在折叠态下移动到上屏的组件id
   */
  static readonly FOLDER_STACK_UP_COMP_ID = 'folderStackUpperSubComp';
  /**
   * 1分钟内的秒数
   */
  static readonly SECONDS_IN_MINUTE = 60;
  /**
   * 1小时内的秒数
   */
  static readonly SECONDS_IN_HOUR = 3600;
  /**
   * avplayer闲置状态
   */
  static readonly AVPLAYER_STATE_IDLE = 'idle';
  /**
   * avplayer资源初始化状态
   */
  static readonly AVPLAYER_STATE_INITIALIZED = 'initialized';
  /**
   * avplayer已准备状态
   */
  static readonly AVPLAYER_STATE_PREPARED = 'prepared';
  /**
   * avplayer正在播放状态
   */
  static readonly AVPLAYER_STATE_PLAYING = 'playing';
  /**
   * avplayer暂停状态
   */
  static readonly AVPLAYER_STATE_PAUSED = 'paused';
  /**
   * avplayer播放至结尾状态
   */
  static readonly AVPLAYER_STATE_COMPLETED = 'completed';
  /**
   * avplayer停止状态
   */
  static readonly AVPLAYER_STATE_STOPPED = 'stopped';
  /**
   * avplayer销毁状态
   */
  static readonly AVPLAYER_STATE_RELEASED = 'released';
  /**
   * avplayer错误状态
   */
  static readonly AVPLAYER_STATE_ERROR = 'error';
  /**
   * 音乐播放器控制按钮尺寸（普通）
   */
  static readonly MUSIC_PLAYER_CTRL_BTN_SIZE_COMMON = 30;
  /**
   * 音乐播放器控制按钮尺寸（大）
   */
  static readonly MUSIC_PLAYER_CTRL_BTN_SIZE_BIG = 40;
  /**
   * 歌曲封面图尺寸（折叠屏展开态）
   */
  static readonly MUSIC_COVER_SIZE_EXPANDED = 300;
  /**
   * 歌曲封面图尺寸（折叠屏半折叠态）
   */
  static readonly MUSIC_COVER_SIZE_HALF_FOLDED = 200;
  /**
   * 歌曲封面图尺寸（折叠屏折叠态或者非折叠屏）
   */
  static readonly MUSIC_COVER_SIZE_COMMON = 150;
  /**
   * 歌曲信息组件高度（折叠屏半折叠态）
   */
  static readonly MUSIC_INFO_COMP_HEIGHT_HALF_FOLDED = '100%';
  /**
   * 歌曲信息组件高度（折叠屏其他状态）
   */
  static readonly MUSIC_INFO_COMP_HEIGHT_COMMON = '90%';
  /**
   * 歌曲歌词组件高度（折叠屏展开态）
   */
  static readonly MUSIC_LYRICS_COMP_HEIGHT_EXPANDED = '50%';
  /**
   * 歌曲歌词组件高度（折叠屏半折叠态）
   */
  static readonly MUSIC_LYRICS_COMP_HEIGHT_HALF_FOLDED = '25%';
  /**
   * 歌曲歌词组件高度（折叠屏折叠态或者非折叠屏）
   */
  static readonly MUSIC_LYRICS_COMP_HEIGHT_COMMON = '30%';
}

