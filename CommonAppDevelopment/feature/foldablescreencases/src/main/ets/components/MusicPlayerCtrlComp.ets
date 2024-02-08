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

import { MusicModel } from '../model/MusicModel';
import { MusicPlayerViewModel } from '../viewmodel/MusicPlayViewModel';

/**
 * 时间显示builder函数参数接口
 */
interface ShowTimeBuilderParam {
  str: string
}

/**
 * 控制按钮builder函数参数接口
 */
interface CtrlBtnBuilderParam {
  imgSrc: Resource,
  btnSize: number,
  callback: Function
}

@Component
export struct MusicPlayerCtrlComp {
  // 音乐模型数据实例
  @Prop musicModel: MusicModel;
  // 播放器vm实例
  @State viewModel: MusicPlayerViewModel = MusicPlayerViewModel.getInstance(this.musicModel);

  // 音乐当前播放时间和总时间显示
  @Builder
  showTimeBuilder($$: ShowTimeBuilderParam) {
    Text($$.str)
      .fontSize($r('app.integer.font_size_music_time'))
      .fontColor(Color.White)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Clip })
      .margin(10)
      .flexShrink(0)
  }

  // 播放器控制按钮
  @Builder
  ctrlBtnBuilder($$: CtrlBtnBuilderParam) {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      Image($$.imgSrc)
        .width($$.btnSize)
        .height($$.btnSize)
        .fillColor(Color.White)
        .padding(6)
        .flexShrink(1)
    }
    .backgroundColor(Color.Gray)
    .onClick(() => {
      $$.callback();
    })
  }

  aboutToAppear(): void {
    this.viewModel.init();
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
        this.showTimeBuilder({ str: this.viewModel.curTimeStr })
        Progress({
          value: this.viewModel.curProgress,
          type: ProgressType.Linear
        })
          .color(Color.Gray)
          .flexGrow(0.8)
        this.showTimeBuilder({ str: this.viewModel.totalTimeStr })
      }
      .margin(10)
      Flex({ justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
        // 播放模式切换按钮
        this.ctrlBtnBuilder({
          imgSrc: $r('app.media.ic_public_order_play'),
          btnSize: CommonConstants.MUSIC_PLAYER_CTRL_BTN_SIZE_COMMON,
          callback: () => {
            // TODO：需求：播放模式切换逻辑
          }
        });
        // 切换到前一首歌曲按钮
        this.ctrlBtnBuilder({
          imgSrc: $r('app.media.ic_public_play_last'),
          btnSize: CommonConstants.MUSIC_PLAYER_CTRL_BTN_SIZE_COMMON,
          callback: () => {
            // TODO：需求：切换到前一首歌曲逻辑
          }
        });
        // 播放、暂停按钮
        this.ctrlBtnBuilder({
          imgSrc: this.viewModel.curPlayerState === CommonConstants.AVPLAYER_STATE_PLAYING ?
            $r('app.media.ic_public_pause') : $r('app.media.ic_public_play'),
          btnSize: CommonConstants.MUSIC_PLAYER_CTRL_BTN_SIZE_BIG,
          callback: () => {
            if (this.viewModel.curPlayerState === CommonConstants.AVPLAYER_STATE_IDLE) {
              this.viewModel.play();
            } else if (this.viewModel.curPlayerState === CommonConstants.AVPLAYER_STATE_PLAYING) {
              this.viewModel.pause();
            } else {
              this.viewModel.resume();
            }
          }
        });
        // 切换到后一首歌曲按钮
        this.ctrlBtnBuilder({
          imgSrc: $r('app.media.ic_public_play_next'),
          btnSize: CommonConstants.MUSIC_PLAYER_CTRL_BTN_SIZE_COMMON,
          callback: () => {
            // TODO：需求：切换到后一首歌曲逻辑
          }
        });
        // 其他功能菜单按钮
        this.ctrlBtnBuilder({
          imgSrc: $r('app.media.ic_public_drawer'),
          btnSize: CommonConstants.MUSIC_PLAYER_CTRL_BTN_SIZE_COMMON,
          callback: () => {
            // TODO：需求：其他功能菜单逻辑
          }
        });
      }
      .margin({top: 20, bottom: 50})
    }
  }
}