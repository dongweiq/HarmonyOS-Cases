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
  callback: Function,
  needBackground?: boolean
}

@Component
export struct MusicPlayerCtrlComp {
  // 当前页面的vm实例
  @Consume('musicPlayerViewModel') viewModel: MusicPlayerViewModel;

  // 音乐当前播放时间和总时间显示
  @Builder
  showTimeBuilder($$: ShowTimeBuilderParam) {
    Text($$.str)
      .fontSize($r('app.integer.font_size_music_time'))
      .fontColor(Color.White)
      .maxLines(CommonConstants.MUSIC_TIME_MAX_LINES)
      .textOverflow({ overflow: TextOverflow.Clip })
      .flexShrink(CommonConstants.MUSIC_TIME_FLEX_SHRINK)
  }

  // 播放器控制按钮
  @Builder
  ctrlBtnBuilder($$: CtrlBtnBuilderParam) {
    Button({ type: ButtonType.Circle, stateEffect: true, buttonStyle: ButtonStyleMode.TEXTUAL }) {
      Image($$.imgSrc)
        .width($$.btnSize)
        .height($$.btnSize)
        .fillColor(Color.White)
        .flexShrink(CommonConstants.MUSIC_CTRL_BTN_FLEX_SHRINK)
    }
    .onClick(() => {
      $$.callback();
    })
    .backgroundColor($$.needBackground ? Color.Gray : '#00000000')
    .padding($$.needBackground ? $r('app.integer.btn_ctrl_padding') : 0)
  }

  aboutToAppear(): void {
    this.viewModel.init();
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        this.showTimeBuilder({ str: this.viewModel.curTimeStr })
        Slider({
          value: this.viewModel.curProgress,
          min: CommonConstants.MUSIC_SLIDER_MIN,
          max: CommonConstants.MUSIC_SLIDER_MAX,
          style: SliderStyle.InSet
        })
          .selectedColor(Color.Gray)
          .trackThickness($r('app.integer.music_progress_slider_trackthickness'))
          .onChange((value: number, mode: SliderChangeMode) => {
            if (!this.viewModel.musicModel) {
              return;
            }

            // 当前进度到达最大进度时，不响应onChange事件
            if (this.viewModel.curProgress >= CommonConstants.MUSIC_SLIDER_MAX) {
              return;
            }

            // slider由于鼠标或手势开始进行变化时，禁止进度条通过avplayer同步进度
            if (mode === SliderChangeMode.Begin) {
              this.viewModel.progressLock = true;
            }

            // 计算滑动条拖动到的地方，对应的时间值
            const toTime = this.viewModel.musicModel.totalTime * value / CommonConstants.MUSIC_SLIDER_MAX;
            // 更新当前拖动到的时间值
            this.viewModel.updateCurTime(toTime);
            // 播放器seek到指定时间
            if (mode === SliderChangeMode.End) {
              this.viewModel.seek(toTime);
            }
          })
        this.showTimeBuilder({ str: this.viewModel.totalTimeStr })
      }
      .margin($r('app.integer.music_progress_margin'))
      .width($r('app.string.music_ctrl_width'))

      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        // 播放模式切换按钮
        this.ctrlBtnBuilder({
          imgSrc: $r('app.media.ic_public_order_play'),
          btnSize: CommonConstants.MUSIC_PLAYER_CTRL_BTN_SIZE_COMMON,
          callback: () => {
            this.viewModel.showTodoToast();
            // TODO：需求：播放模式切换逻辑
          }
        });
        // 切换到前一首歌曲按钮
        this.ctrlBtnBuilder({
          imgSrc: $r('app.media.ic_public_play_last'),
          btnSize: CommonConstants.MUSIC_PLAYER_CTRL_BTN_SIZE_COMMON,
          callback: () => {
            this.viewModel.showTodoToast();
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
          },
          needBackground: true
        });
        // 切换到后一首歌曲按钮
        this.ctrlBtnBuilder({
          imgSrc: $r('app.media.ic_public_play_next'),
          btnSize: CommonConstants.MUSIC_PLAYER_CTRL_BTN_SIZE_COMMON,
          callback: () => {
            this.viewModel.showTodoToast();
            // TODO：需求：切换到后一首歌曲逻辑
          }
        });
        // 其他功能菜单按钮
        this.ctrlBtnBuilder({
          imgSrc: $r('app.media.ic_public_drawer'),
          btnSize: CommonConstants.MUSIC_PLAYER_CTRL_BTN_SIZE_COMMON,
          callback: () => {
            this.viewModel.showTodoToast();
            // TODO：需求：其他功能菜单逻辑
          }
        });
      }
      .margin({ top: $r('app.integer.music_ctrl_margin_top'), bottom: $r('app.integer.music_ctrl_margin_bottom') })
      .width($r('app.string.music_ctrl_width'))
    }
  }
}