/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
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
 * 实现步骤
 * 1. 使用一个@Builder修饰的方法实现LazyForEach列表懒加载。
 * 2. 使用pullToRefresh组件实现上拉下滑加载数据，将UI方法传入组件中。
 */

import util from '@ohos.util';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';
import { PullToRefresh } from '@ohos/pulltorefresh/index';
import { BasicDataSource } from '../viewModel/BasicDataSource';

const NEWS_TITLE_MAX_LINES: number = 1;
const NEWS_TITLE_TEXT_FONT_WEIGHT: number = 500;
const NEWS_CONTENT_MAX_LINES: number = 2;
const NEWS_TIME_MAX_LINES: number = 1;
const NEWS_PAGE_TEXT_FONT_WEIGHT: number = 600;
const NEWS_RESOLVE_SUCCESS : string = '刷新成功';
const NEWS_MOCK_DATA_COUNT: number = 8; // 每份模拟数据所含的新闻个数为8
const MOCK_DATA_FILE_ONE_DIR: string = 'mockDataOne.json'; // 模拟数据路径
const MOCK_DATA_FILE_TWO_DIR: string = 'mockDataTwo.json'; // 模拟数据路径
const NEWS_REFRESH_TIME: number = 1500; // 数据刷新时间

@Component
export struct PullToRefreshNews {
  // 创建用于懒加载的数据对象
  @State newsData: NewsDataSource = new NewsDataSource();
  private mockFlag: boolean = true;
  // 需绑定列表或宫格组件
  private scroller: Scroller = new Scroller();

  aboutToAppear() {
    let newsModelMockData: Array<NewsData> = getNews(MOCK_DATA_FILE_ONE_DIR)
    for (let j = 0; j < NEWS_MOCK_DATA_COUNT; j++) {
      this.newsData.pushData(newsModelMockData[j]);
    }
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.news_page_title'))
          .fontSize($r('app.integer.news_page_text_font_size'))
          .fontWeight(NEWS_PAGE_TEXT_FONT_WEIGHT)
          .textAlign(TextAlign.Start)
          .lineHeight($r('app.integer.news_page_text_font_line_height'))
          .margin({ left: $r('app.string.news_page_text_margin_left') })
      }
      .width($r('app.string.news_page_text_width'))
      .height($r('app.string.news_page_text_height'))
      .backgroundColor($r('app.color.listColor'))

      Column() {
        PullToRefresh({
          // TODO: 知识点：使用PullToRefresh组件时需要先绑定数据与主体布局。若使用LazyForEach组件渲染列表时，需将UI方法使用@Builder修饰并传入customList属性中。
          // 必传项，列表组件所绑定的数据
          data: $newsData,
          // 必传项，需绑定传入主体布局内的列表或宫格组件
          scroller: this.scroller,
          // 必传项，自定义主体布局，内部有列表或宫格组件
          customList: () => {
            // 一个用@Builder修饰过的UI方法
            this.getListView();
          },
          // TODO: 知识点：设置onRefresh下拉刷新回调方法，该方法必须返回一个Promise类型。
          onRefresh: () => {
            return new Promise<string>((resolve, reject) => {
              // 模拟网络请求操作，请求网络1.5秒后得到数据，通知组件，变更列表数据
              setTimeout(() => {
                this.newsData.clear();
                let newsModelMockData: Array<NewsData> = new Array<NewsData>();
                // 根据mockFlag切换获取的数据文件
                if (this.mockFlag) {
                  newsModelMockData = getNews(MOCK_DATA_FILE_TWO_DIR);
                }
                else {
                  newsModelMockData = getNews(MOCK_DATA_FILE_ONE_DIR);
                }
                this.mockFlag = !this.mockFlag;
                for (let j = 0; j < NEWS_MOCK_DATA_COUNT; j++) {
                  this.newsData.pushData(newsModelMockData[j]);
                }
                resolve(NEWS_RESOLVE_SUCCESS)
              }, NEWS_REFRESH_TIME);
            });
          },
          // TODO: 知识点：设置onLoadMore上滑加载更多数据回调方法，该方法必须返回一个Promise类型。
          onLoadMore: () => {
            return new Promise<string>((resolve, reject) => {
              // 模拟网络请求操作，请求网络1.5秒后得到数据，通知组件，变更列表数据
              setTimeout(() => {
                let newsModelMockData: Array<NewsData> = getNews(MOCK_DATA_FILE_ONE_DIR)
                for (let j = 0; j < NEWS_MOCK_DATA_COUNT; j++) {
                  this.newsData.pushData(newsModelMockData[j]);
                }
                resolve(NEWS_RESOLVE_SUCCESS)
              }, NEWS_REFRESH_TIME);
            });
          },
          customLoad: null,
          customRefresh: null,
        })
      }
      .backgroundColor($r('app.color.listColor'))
    }
    .height($r('app.string.news_page_height'))
  }

  // 必须使用@Builder修饰方法
  @Builder
  private getListView() {
    List({ space: 3, scroller: this.scroller }) {
      // TODO: 性能知识点：使用懒加载组件渲染数据
      LazyForEach(this.newsData, (item: NewsData) => {
        ListItem() {
          newsItem({
            newsTitle: item.newsTitle,
            newsContent: item.newsContent,
            newsTime: item.newsTime
          })
        }
        .backgroundColor($r('app.color.white'))
        .margin({ bottom: $r('app.string.news_list_margin_bottom'), left: $r('app.string.news_list_item_margin_left') })
        .borderRadius($r('app.integer.news_list_border_radius'))
      }, (item: NewsData, index?: number) => JSON.stringify(item) + index);
    }
    .width($r('app.string.news_List_width'))
    .backgroundColor($r('app.color.listColor'))
    // TODO: 知识点：必须设置列表为滑动到边缘无效果，否则无法触发pullToRefresh组件的上滑下拉方法。
    .edgeEffect(EdgeEffect.None)
  }

  aboutToDisappear() {
    this.newsData.clear();
  }
}

// 单一列表样式组件
@Component
struct newsItem {
  private newsTitle: string | Resource = '';
  private newsContent: string | Resource = '';
  private newsTime: string | Resource = '';

  build() {
    Column() {
      Row() {
        Image($r('app.media.news'))
          .width($r('app.string.news_title_image_width'))
          .height($r('app.string.news_title_image_height'))
          .objectFit(ImageFit.Fill)
        Text(this.newsTitle)
          .fontSize($r('app.integer.news_title_text_font_size'))
          .fontColor($r('app.color.news_title_fontColor'))
          .width($r('app.string.news_title_text_width'))
          .maxLines(NEWS_TITLE_MAX_LINES)
          .margin({ left: $r('app.string.news_title_text_margin_left') })
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontWeight(NEWS_TITLE_TEXT_FONT_WEIGHT)
      }
      .alignItems(VerticalAlign.Center)
      .height($r('app.string.news_title_row_height'))
      .margin({ top: $r('app.string.news_title_row_margin_top'), left: $r('app.string.news_title_image_margin_left') })

      Text(this.newsContent)
        .fontSize($r('app.integer.news_content_font_size'))
        .lineHeight($r('app.integer.news_content_font_line_height'))
        .fontColor($r('app.color.news_content_fontColor'))
        .height($r('app.string.news_content_height'))
        .width($r('app.string.news_content_width'))
        .maxLines(NEWS_CONTENT_MAX_LINES)
        .margin({ left: $r('app.string.news_content_margin_left'), top: $r('app.string.news_content_margin_top') })
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(this.newsTime)
        .fontSize($r('app.integer.news_time_font_size'))
        .fontColor($r('app.color.news_time_fontColor'))
        .height($r('app.string.news_time_height'))
        .width($r('app.string.news_time_width'))
        .maxLines(NEWS_TIME_MAX_LINES)
        .margin({ left: $r('app.string.news_time_margin_left'), top: $r('app.string.news_time_margin_top') })
        .textOverflow({ overflow: TextOverflow.None })
    }
    .alignItems(HorizontalAlign.Start)
  }
}

// 新闻数据对象
class NewsData {
  newsId: string
  newsTitle: string | Resource
  newsContent: string | Resource
  newsTime: string | Resource

  toString(): string {
    return this.newsId + ' ' + this.newsTitle + ' ' + this.newsContent + ' ' + this.newsTime;
  }

  constructor(id: string, title: string | Resource, content: string | Resource, time: string | Resource) {
    this.newsId = id;
    this.newsTitle = title;
    this.newsContent = content;
    this.newsTime = time;
  }
}

// 懒加载列表对象
class NewsDataSource extends BasicDataSource {
  dataArray: Array<NewsData> = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): Object {
    return this.dataArray[index];
  }

  public addData(index: number, data: NewsData): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: NewsData): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public clear(): void {
    this.dataArray = [];
  }
}

class JsonObjType {
  newsList: Array<NewsData> = new Array<NewsData>();
}

class JsonObject {
  private jsonFileDir: string = '';

  constructor(jsonFileDir: string) {
    this.jsonFileDir = jsonFileDir;
  }

  // 获取数据
  getNewsData(): Array<NewsData> {
    // 从本地文件中获取数据
    let value = getContext().resourceManager.getRawFileContentSync(this.jsonFileDir);
    // 解码为utf-8格式
    let textDecoder = util.TextDecoder.create('utf-8', {
      ignoreBOM: true
    });
    let textDecoderResult = textDecoder.decodeWithStream(new Uint8Array(value.buffer));
    let jsonObj: JsonObjType = JSON.parse(textDecoderResult) as JsonObjType;
    let newsModelBuckets: Array<NewsData> = new Array<NewsData>();
    // 映射json数据为NewsModel对象
    let newsModelObj = jsonObj.newsList;
    for (let i = 0; i < newsModelObj.length; i++) {
      let contactTemp = new NewsData(newsModelObj[i].newsId, newsModelObj[i].newsTitle,
        newsModelObj[i].newsContent, newsModelObj[i].newsTime);
      newsModelBuckets.push(contactTemp);
    }
    return newsModelBuckets;
  }
}

function getNews(mockFileDir: string): Array<NewsData> {
  let jsonObj: JsonObject = new JsonObject(mockFileDir);
  let newsModelMockData: Array<NewsData> = jsonObj.getNewsData()
  return newsModelMockData
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getPullToRefreshNews(): void {
  PullToRefreshNews();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.PULL_TO_REFRESH,wrapBuilder(getPullToRefreshNews));