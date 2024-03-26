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

import { display, mediaquery } from '@kit.ArkUI';
import { logger } from '@ohos/utils';

import CommonConstants from '../common/constants/CommonConstants';

import { MusicModel } from '../model/MusicModel';
import { DynamicsRouter } from '@ohos/dynamicsrouter/Index';

/**
 * 播放器歌曲信息组件，包括歌名、歌手、歌曲封面、歌词
 * 实现步骤：
 * 1.组件创建时，根据当前折叠屏状态和横竖屏状态初始化组件树上各组件属性
 * 2.通过父组件监听屏幕折叠态变更事件，同时通过单项绑定通知到此组件的状态变量，修改组件树上各组件属性
 * 3.通过媒体查询监听横竖屏变更，修改组件树上各组件属性
 * 4.通过配置属性动画，动态变更各组件样式
 */
@Component
export struct MusicPlayerInfoComp {
  // 音乐模型数据实例
  @Prop musicModel: MusicModel;
  // 父组件单向绑定的屏幕状态
  @Prop @Watch('updateWithFoldStatus') curFoldStatus: display.FoldStatus;
  // 通知Navigation组件隐藏导航栏
  @Consume('fullScreenSize') fullScreenSize: string;
  // list控制器
  private lyricsScrollerCtrl: Scroller = new Scroller();
  // 当前是否横屏状态
  private isLandscape: boolean = false;
  // TODO：知识点：通过媒体查询监听显示屏幕横竖屏方向状态变更
  private landscapeListener: mediaquery.MediaQueryListener = mediaquery.matchMediaSync('(orientation: landscape)');
  // 属性动画配置
  private attrAniCfg: AnimateParam = {
    duration: 2000,
    curve: Curve.EaseOut,
    iterations: 1,
    playMode: PlayMode.Normal
  }
  // 歌曲信息组件整体高度百分比
  @State totalHeightPer: string = CommonConstants.MUSIC_INFO_COMP_HEIGHT_COMMON;
  // 歌词子组件高度百分比
  @State lyricsHeightPer: string = CommonConstants.MUSIC_LYRICS_COMP_HEIGHT_EXPANDED;
  // 歌词子组件外边距
  @State lyricsMargin: Margin = { top: 0 };
  // 歌曲封面图片尺寸
  @State curImgSize: number = CommonConstants.MUSIC_COVER_SIZE_COMMON;
  // 歌曲信息组件Flex布局方向
  @State curFlexDirection: FlexDirection = FlexDirection.Row;

  aboutToAppear(): void {
    // 初始化各组件样式
    this.updateWithFoldStatus();
    // 隐藏navigation导航栏，设置为全屏。
    animateTo({
      duration: 400,
      curve: Curve.EaseInOut,
    }, () => {
      this.fullScreenSize = '0.01%';
    })
    // 监听媒体查询横屏切换
    this.landscapeListener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.updateWithOrientation(mediaQueryResult);
    });
  }

  aboutToDisappear(): void {
    this.landscapeListener.off('change');
  }

  build() {
    Flex({ direction: this.curFlexDirection }) {
      Image($r('app.media.ic_public_back'))
        .width($r('app.integer.font_size_music_title'))
        .height($r('app.integer.font_size_music_title'))
        .onClick(() => {
          DynamicsRouter.pop()
          // 呈现navigation导航栏，设置为半屏。
          animateTo({
            duration: 200,
            curve: Curve.EaseInOut,
          }, () => {
            this.fullScreenSize = '50%';
          })
        })
        .position({ x: $r('app.integer.image_position_x'), y: $r('app.integer.image_position_y') })
        .fillColor(Color.White)
      Column() {
        Text(this.musicModel.title)
          .fontSize($r('app.integer.font_size_music_title'))
          .fontColor(Color.White)
        Text(this.musicModel.singer)
          .fontSize($r('app.integer.font_size_music_singer'))
          .fontColor(Color.White)
        Image(this.musicModel.cover)
          .width(this.curImgSize)
          .height(this.curImgSize)
          .margin(20)
          .animation(this.attrAniCfg)
          .interpolation(ImageInterpolation.High)
          .draggable(false)
      }
      .width('100%')
      .height('50%')
      .margin({ top: 10 })

      /**
       * TODO：高性能知识点：歌词列表数据较多，不需要全部渲染上屏，采用LazyForEach，仅渲染可视区域的歌词
       * https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/performance/lazyforeach_optimization.md/
       */
      List({ space: 20, scroller: this.lyricsScrollerCtrl }) {
        LazyForEach(this.musicModel.lyricsInfo, (lyricsLine: string) => {
          ListItem() {
            Column() {
              Text(lyricsLine)
                .width('100%')
                .textAlign(TextAlign.Center)
                .fontColor(Color.White)
            }
          }
        })
      }
      .width('100%')
      .height(this.lyricsHeightPer)
      .margin(this.lyricsMargin)
      .scrollBar(BarState.Off)
      .animation(this.attrAniCfg)
    }
    .width('100%')
    .height(this.totalHeightPer)
    .animation(this.attrAniCfg)
  }

  /**
   * 根据折叠态和屏幕方向，修改样式，包括折叠屏设备和非折叠屏设备
   * @param curFoldStatus
   * @returns {void}
   */
  updateWithFoldStatus() {
    // 修改图片尺寸、整个信息组件高度百分比、歌词百分比、歌词和其他信息的布局方向
    if (this.curFoldStatus === display.FoldStatus.FOLD_STATUS_EXPANDED) {
      // 折叠屏展开态
      // 使用展开态的属性样式
      logger.info("The device is currently in the expanded state");
      this.curImgSize = CommonConstants.MUSIC_COVER_SIZE_EXPANDED;
      this.totalHeightPer = CommonConstants.MUSIC_INFO_COMP_HEIGHT_COMMON;
      this.lyricsHeightPer = CommonConstants.MUSIC_LYRICS_COMP_HEIGHT_EXPANDED;
      this.lyricsMargin.top = 100;
      this.curFlexDirection = FlexDirection.Row;
    } else if (this.curFoldStatus === display.FoldStatus.FOLD_STATUS_FOLDED) {
      // 折叠屏折叠态
      // 使用折叠态的属性样式
      logger.info("The device is currently in the folded state");
      this.curImgSize = CommonConstants.MUSIC_COVER_SIZE_COMMON;
      this.totalHeightPer = CommonConstants.MUSIC_INFO_COMP_HEIGHT_COMMON;
      this.lyricsHeightPer = CommonConstants.MUSIC_LYRICS_COMP_HEIGHT_COMMON;
      this.lyricsMargin.top = 0;
      this.curFlexDirection = FlexDirection.Column;
    } else if (this.curFoldStatus === display.FoldStatus.FOLD_STATUS_HALF_FOLDED) {
      // 折叠屏半折叠态
      logger.info("The device is currently in the half folded state");
      if (this.isLandscape) {
        // 半折叠态同时横屏
        // 使用半折叠态的属性样式
        this.curImgSize = CommonConstants.MUSIC_COVER_SIZE_HALF_FOLDED;
        this.totalHeightPer = CommonConstants.MUSIC_INFO_COMP_HEIGHT_HALF_FOLDED;
        this.lyricsHeightPer = CommonConstants.MUSIC_LYRICS_COMP_HEIGHT_HALF_FOLDED;
        this.lyricsMargin.top = 100;
      } else {
        // 半折叠态同时竖屏
        // 使用展开态的属性样式
        this.curImgSize = CommonConstants.MUSIC_COVER_SIZE_EXPANDED;
        this.totalHeightPer = CommonConstants.MUSIC_INFO_COMP_HEIGHT_COMMON;
        this.lyricsHeightPer = CommonConstants.MUSIC_LYRICS_COMP_HEIGHT_EXPANDED;
        this.lyricsMargin.top = 100;
      }
      this.curFlexDirection = FlexDirection.Row;
    } else {
      // 非折叠屏设备
      // 使用非折叠屏的属性样式
      this.curImgSize = CommonConstants.MUSIC_COVER_SIZE_COMMON;
      this.totalHeightPer = CommonConstants.MUSIC_INFO_COMP_HEIGHT_COMMON;
      this.lyricsHeightPer = CommonConstants.MUSIC_LYRICS_COMP_HEIGHT_COMMON;
      this.lyricsMargin.top = 0;
      this.curFlexDirection = FlexDirection.Column;
    }
  }

  /**
   * 屏幕方向变更时，修改展示样式
   * @param mediaQueryResult 媒体查询横屏结论
   * @returns {void}
   */
  updateWithOrientation(mediaQueryResult: mediaquery.MediaQueryResult): void {
    this.isLandscape = mediaQueryResult.matches;
    this.updateWithFoldStatus();
  }
}