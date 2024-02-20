# 城市选择案例

### 介绍

本示例介绍城市选择场景的使用：通过[AlphabetIndexer](https://docs.openharmony.cn/pages/v3.2/zh-cn/application-dev/reference/arkui-ts/ts-container-alphabet-indexer.md/)实现首字母快速定位城市的索引条导航。

### 效果图预览

![](../../product/entry/src/main/resources/base/media/city_search.gif)

**使用说明**

分两个功能
- 在搜索框中可以根据城市拼音模糊搜索出相近的城市，例如输入"a"，会出现"阿尔山"、"阿勒泰地区"、"安庆"、"安阳"。
- 下方城市列表通过AlphabetIndexer组件实现拼音索引条，通过滑动选择城市首拼，快速定位相关首拼城市。

### 实现思路
#### 场景：通过AlphabetIndexer实现索引条导航

城市列表中的右侧首拼索引条，通过AlphabetIndexer组件实现首字母快速定位城市的索引条导航。

- 通过AlphabetIndexer的selected属性与城市列表中List组件onScrollIndex事件绑定，[源码参考](src/main/ets/view/CityView.ets)

```
AlphabetIndexer({ arrayValue: TAB_VALUE, selected: this.stabIndex })
  .height('100%')
  .selectedColor($r('app.color.alphabet_select_color')) // 选中项文本颜色
  .popupColor($r('app.color.alphabet_pop_color')) // 弹出框文本颜色
  .selectedBackgroundColor($r('app.color.alphabet_selected_bgc')) // 选中项背景颜色
  .popupBackground($r('app.color.alphabet_pop_bgc')) // 弹出框背景颜色
  .popupPosition({ x: $r('app.integer.pop_position_x'), y: $r('app.integer.pop_position_y') })
  .usingPopup(true) // 是否显示弹出框
  .selectedFont({ size: $r('app.integer.select_font'), weight: FontWeight.Bolder }) // 选中项字体样式
  .popupFont({ size: $r('app.integer.pop_font'), weight: FontWeight.Bolder }) // 弹出框内容的字体样式
  .alignStyle(IndexerAlign.Right) // 弹出框在索引条左侧弹出
  .onSelect((tabIndex: number) => {
    this.scroller.scrollToIndex(tabIndex);
  })
```
- 当用户划入或划出List组件显示区域时触发，通过将onScrollIndex拿到的首字母firstIndex绑定赋值给AlphabetIndexer的selected属性，
从而实现List列表与AlphabetIndexer组件首字母联动吸顶展示，[源码参考](src/main/ets/view/CityView.ets)。
```
List({ space: 14, initialIndex: 0, scroller: this.scroller }) {
  .onScrollIndex((firstIndex: number, lastIndex: number) => {
     this.stabIndex = firstIndex;
  })
}
```


### 高性能知识点

由于需要通过搜索按钮频繁的控制自定义组件的显隐状态，[源码详见](src/main/ets/view/CityView.ets)，因此推荐使用显隐控制替代条件渲染，参考[合理选择条件渲染和显隐控制文章](https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/performance/proper-choice-between-if-and-visibility.md/)。

### 工程结构&模块类型

   ```
   citysearch                                      // har类型
   |---src/main/ets/view
   |   |---CitySearch.ets                          // 视图层-主页 
   |   |---CityView.ets                            // 视图层-城市列表组件
   |   |---SearchView.ets                          // 视图层-搜索组件
   |---src/main/ets/model
   |   |---DetailData.ets                          // 模型层-数据模块 
   ```

### 模块依赖

依赖[har包-common库中UX标准](../../common/utils/src/main/resources/base/element)


### 参考资料

[AlphabetIndexer参考文档](https://docs.openharmony.cn/pages/v3.2/zh-cn/application-dev/reference/arkui-ts/ts-container-alphabet-indexer.md/)