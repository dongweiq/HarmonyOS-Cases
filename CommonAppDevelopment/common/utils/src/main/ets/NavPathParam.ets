import advertising from '@ohos.advertising';

// 路由param
export class NavPathParam {
  // 广告列表
  ads?: Array<advertising.Advertisement>;
  // 是否是全屏广告
  isFullScreenAdvert?: boolean;

  constructor(ads?: Array<advertising.Advertisement>, isFullScreenAdvert?: boolean) {
    this.ads = ads;
    this.isFullScreenAdvert = isFullScreenAdvert;
  }
}
