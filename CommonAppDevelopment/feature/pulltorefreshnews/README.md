# 下拉刷新与上滑加载案例

### 介绍

本示例介绍使用第三方库的PullToRefresh组件实现列表的下拉刷新数据和上滑加载后续数据。

### 效果图预览

<img src="../../product/entry/src/main/resources/base/media/pull_to_refresh_news.gif" width="200">

**使用说明**

1. 进入页面，下拉列表触发刷新数据事件，等待数据刷新完成。
2. 上滑列表到底部，触发加载更多数据事件，等待数据加载完成。

### 实现思路

1. 使用第三方库pullToRefresh组件，将列表组件、绑定的数据对象和scroller对象包含进去，并添加上滑与下拉方法。源码参考[PullToRefreshNews.ets](./src/main/ets/pages/PullToRefreshNews.ets)
    ```typescript
    PullToRefresh({
      // 必传项，列表组件所绑定的数据
      data: $newsData,
      // 必传项，需绑定传入主体布局内的列表或宫格组件
      scroller: this.scroller,
      // 必传项，自定义主体布局，内部有列表或宫格组件
      customList: () => {
        // 一个用@Builder修饰过的UI方法
        this.getListView();
      },
      // 下拉刷新回调
      onRefresh: () => {
        return new Promise<string>((resolve, reject) => {
          ...
        });
      },
      // 上滑加载回调
      onLoadMore: () => {
        return new Promise<string>((resolve, reject) => {
          ...
        });
      },
      customLoad: null,
      customRefresh: null,
    })
    ```
2. 使用LazyForEach循环渲染列表。源码参考[PullToRefreshNews.ets](./src/main/ets/pages/PullToRefreshNews.ets)
    ```typescript
    LazyForEach(this.newsData, (item: NewsData) => {
      ListItem() {
        ...
      }
    });
    ```

### 高性能知识点

不涉及

### 工程结构&模块类型
   ```
   pulltorefreshnews                                  // har类型
   |---pages
   |---|---PullToRefreshNews.ets                      // 视图层-场景列表页面
   ```

### 模块依赖

[@ohos/PullToRefresh](https://gitee.com/openharmony-sig/PullToRefresh)

### 参考资料

[@ohos/PullToRefresh](https://gitee.com/openharmony-sig/PullToRefresh)
[@ohos/LazyForEach](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-rendering-control-lazyforeach-0000001820879609)
[PullToRefresh第三方库](https://ohpm.openharmony.cn/#/cn/detail/@ohos%2Fpulltorefresh)