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

import media from '@ohos.multimedia.media';
import common from '@ohos.app.ability.common';
import display from '@ohos.display';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';
import { logger } from '@ohos/base/Index';
import { HttpProxyCacheServer, HttpProxyCacheServerBuilder } from '@ohos/video-cache';
import { handleTime } from '../utils/utils';
import GlobalProxyServer from '../model/GlobalProxyServer';
import AvPlayManager from '../model/VideoPlayerManager';

const SURFACE_W = 0.9; // 表面宽比例
const SURFACE_H = 1.78; // 表面高比例
const TOTAL: number = 100; // 初始化下载总进度
const ROTATE_ANGLE: number = 360; // 初始化角度
const SURFACE_WIDTH: number = 1920; // XComponent持有Surface的宽度
const SURFACE_HEIGHT: number = 1080; // XComponent持有Surface的高度
const SET_TIMEOUT_TIME: number = 10; // 计时器延迟时间
const ANIMATION_DURATION: number = 500; // 动画总时长

/**
 * 1.XComponent组件绘制视频播放窗口。
 * 2.通过HttpProxyCacheServer初始化代理服务器。
 * 3.media.createAVPlayer()创建播放管理类，用于管理和播放媒体资源。
 * 4.边播放边缓存，MyCacheListener监听缓存进度，getProxyUrl(ORIGIN_URL)获取视频播放地址并设置给播放器。
 */
@Component
export struct VideoCacheView {
  @Provide isPlaying: boolean = true; // 是否处于播放中状态
  @Provide videoDuration: string = '00:00'; // 视频时长
  @Provide currentTime: string = '00:00'; // 当前播放时长

  build() {
    Column() {
      // 下载进度组件
      UpdateProcessView()
      // 视频播放组件
      VideoView()
    }
    .backgroundColor(Color.Black)
    .height($r('app.string.video_cache_container_height_size'))
    .width($r('app.string.video_cache_container_width_size'))
    .alignItems(HorizontalAlign.End)
    .padding($r('app.string.ohos_id_card_padding_start'))
  }
}

@Component
struct UpdateProcessView {
  @StorageLink('currentCachePercent') currentCachePercent: number = 0;

  build() {
    Stack() {
      Progress({ value: this.currentCachePercent, total: TOTAL, type: ProgressType.Ring })
        .width($r('app.integer.video_cache_download_progress_size'))
        .height($r('app.integer.video_cache_download_progress_size'))
        .backgroundColor(Color.White)
        .style({
          strokeWidth: 2,
          scaleWidth: 2
        })

      Image($r("app.media.video_cache_download"))
        .width($r('app.integer.video_cache_download_image_size'))
    }
    .visibility(this.currentCachePercent === 100 || this.currentCachePercent === 0 ? Visibility.Hidden : Visibility.Visible)
  }
}

@Component
struct VideoView {
  @State windowWidth: number = 300; // 初始化窗口宽度
  @State windowHeight: number = 300; // 初始化窗口高度
  @State xComponentWidth: number | null = null; // 初始化XComponent的宽度
  @State xComponentHeight: number | null = null; // 初始化XComponent的高度
  @State currentTime: number = 0; // 初始化当前视频时间
  @State total: number = 100; // 初始化总进度
  @State rotateAngle: number = 0; // 初始化角度
  private surfaceId: string = '';
  private componentController: XComponentController = new XComponentController();
  @StorageLink('playStatus') @Watch('updateImageStatus') playStatus: string = '';
  @Consume videoDuration: string;
  @Consume isPlaying: boolean;

  aboutToAppear() {
    // 执行加载动画
    setTimeout(() => {
      this.rotateAnimation();
    }, SET_TIMEOUT_TIME);
    this.windowWidth = display.getDefaultDisplaySync().width;
    this.windowHeight = display.getDefaultDisplaySync().height;
    this.xComponentWidth = this.windowWidth * SURFACE_W;
    this.xComponentHeight = this.xComponentWidth / SURFACE_H;
    // 初始化代理服务器
    const server: HttpProxyCacheServer = new HttpProxyCacheServerBuilder(getContext()).build();
    GlobalProxyServer?.getInstance()?.setServer(server);
  }

  /**
   * 旋转动画
   */
  rotateAnimation() {
    logger.info(`AVPlayManager, rotateAnimation start`);
    animateTo({
      duration: ANIMATION_DURATION, // 动画时长
      curve: Curve.Ease, // 动画曲线
      iterations: -1, // 播放次数,-1为无限循环
      playMode: PlayMode.Normal, // 动画模式
      onFinish: () => {
        logger.info('play end')
      }
    }, () => {
      this.rotateAngle = ROTATE_ANGLE;
    })
  }

  /**
   * 页面退出清除缓存
   */
  aboutToDisappear(): void {
    AvPlayManager.getInstance().videoRelease();
  }

  /**
   * 视频播放完成后,更新播放图片状态
   */
  updateImageStatus() {
    logger.info(`AVPlayManager, updateImageStatus start`);
    if (this.playStatus !== 'completed') {
      return;
    }
    this.isPlaying = false;
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        XComponent({
          id: 'xcomponent',
          type: 'surface',
          controller: this.componentController
        })
          .height(`${this.xComponentHeight}px`)
          .width(`${this.xComponentWidth}px`)
          .onLoad(() => {
            // 设置XComponent持有Surface的宽度和高度
            this.componentController.setXComponentSurfaceSize({
              surfaceWidth: SURFACE_WIDTH,
              surfaceHeight: SURFACE_HEIGHT
            });
            this.surfaceId = this.componentController.getXComponentSurfaceId();
            // 创建音视频播放实例
            AvPlayManager.getInstance()
              .initPlayer(getContext(this) as common.UIAbilityContext, this.surfaceId, (avPlayer: media.AVPlayer) => {
                avPlayer.on('timeUpdate', (time: number) => {
                  this.currentTime = time;
                });
                this.videoDuration = handleTime(avPlayer.duration);
                this.total = avPlayer.duration;
              })
          })
        // 视频未加载时显示加载图片
        Image($r("app.media.video_cache_loading"))
          .width($r('app.integer.video_cache_loading_image_size'))
          .height($r('app.integer.video_cache_loading_image_size'))
          .rotate({ angle: this.rotateAngle })// 视频未加载，显示加载动画，加载完成之后隐藏动画
          .visibility(this.currentTime === 0 ? Visibility.Visible : Visibility.None)
      }

      Row() {
        Image(this.isPlaying ? $r("app.media.video_cache_pause") : $r("app.media.video_cache_play"))
          .width($r('app.integer.video_cache_play_image_size'))
          .onClick(() => {
            this.isPlaying = !this.isPlaying;
            if (this.isPlaying) {
              AvPlayManager.getInstance().videoPlay();
            } else {
              AvPlayManager.getInstance().videoPause();
            }
          })
        Blank()
        Text(handleTime(this.currentTime))
          .fontColor(Color.White)
        Blank()
        Progress({
          value: this.currentTime,
          total: this.total,
          type: ProgressType.Linear
        })
          .width($r('app.string.video_cache_progress_width_size'))
          .backgroundColor(Color.White)
        Blank()
        Text(this.videoDuration)
          .fontColor(Color.White)
      }
      .width(`${this.xComponentWidth}px`)
      .margin({ top: $r('app.string.ohos_id_elements_margin_vertical_m') })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .layoutWeight(1)
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getVideoCacheView(): void {
  VideoCacheView();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.VIDEO_CACHE, wrapBuilder(getVideoCacheView));