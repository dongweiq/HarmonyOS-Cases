# 搜索功能实现案例

### 介绍

本示例介绍使用includes方法对数据实现模糊查询

### 效果图预览

<img src="../../product/entry/src/main/resources/base/media/search_component.gif" width="200">

**使用说明**

1. 点击首页搜索框跳转到搜索页面
2. 在搜索页面输入框中输入搜索的内容，下方列表自动根据搜索的内容进行筛选渲染
3. 点击筛选后的列表跳转到相应的页面
4. 跳转后会保存搜索历史，搜索历史使用持久化存储处理退出应用再次进入依旧存在
5. 点击搜索历史可以跳转到相应页面

### 实现思路

1. 通过include方法判读是否存在符合条件的数据。源码参考[SearchPage.ets](./src/main/ets/components/mainpage/SearchComponent.ets)
```ts
  searchFunc(value: string) {
    let newListData: ListData[] = [];
    if (this.searchListData !== undefined) {
      for (let i = 0; i < this.searchListData.length; i++) {
        // 通过includes对输入的字符进行查询
        if (this.searchListData[i].name.toLowerCase().includes(value.toLowerCase())) {
          newListData.push(this.searchListData[i])
        }
      }
    }
    this.listData = newListData
  }
  ```
2通过PersistentStorage进行持久化数据存储。源码参考[SearchPage.ets](./src/main/ets/components/mainpage/SearchComponent.ets)
```ts
  PersistentStorage.persistProp('searchHistoryData', [])
  @StorageLink('searchHistoryData') searchHistoryData: ListData[] = []
  ListItem() {
    Column() {
      Row() {
        Image($r('app.media.search'))
          .width($r('app.string.search_list_image_width'))
        Text(item.name)
          .fontSize($r('app.string.search_history_font_size2'))
          .margin({ left: $r('app.string.search_history_text_padding_margin2') })
      }

      Divider()
        .width('100%')
        .height(1)
        .margin({ top: $r('app.string.search_history_text_padding_margin1') })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
  .width('100%')
  .margin({ top: $r('app.string.search_history_text_padding_margin1') })
  .onClick(() => {
     if (this.searchHistoryData.includes(item)) {
       return;
     }
     // 更新搜索历史数据
     this.searchHistoryData.push(item);
     // 调用动态路由相关方法实现页面跳转
     DynamicsRouter.push(item.routerInfo, item.param);
     })
  ```

### 高性能知识点

**不涉及**

### 工程结构&模块类型

   ```
   SearchComponent                                 // har类型(默认使用har类型，如果使用hsp类型请说明原因)
   |---model
   |   |---ListData.ets                            // 筛选数据模型
   |---SearchComponent.ets                         // 搜索组件
   |---SearchPage.ets                              // 搜索页面
   ```

### 模块依赖

**不涉及**

### 参考资料

[search组件详细用法可参考性能范例](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V2/ts-basic-components-search-0000001428061740-V2)