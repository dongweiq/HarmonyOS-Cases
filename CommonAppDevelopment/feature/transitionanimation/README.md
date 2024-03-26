# 一镜到底“页面转场”动画
### 介绍
本方案做的是页面点击卡片跳转到详情预览的转场动画效果
### 效果图预览
![](../../product/entry/src/main/resources/base/media/transition_animation.gif)
##### 使用说明
点击首页卡片跳转到详情页，再点击进入路由页面按钮，进入新的路由页面
### 实现思路
首页使用了一种视觉上看起来像是组件的转场动画，这种转场动画通常是通过组件的动态加载和切换来实现的，不是路由页面转场动画。
实现方案如下：

1、入场动画：采用stack布局，容器内有瀑布流卡片列表CardList和卡片详情页DetailPage（展开时是详情页，未展开是卡片组件）
  ```ts
  build() {
    Stack() {
      this.CardList();
      this.DetailPage();
    }
  }
  ```
2、入场动画：点击卡片后，记录当前被点击卡片在数组中的索引，DetailPage渲染被点击卡片组件，使用onAreaChange存储每个Card被点击时的位置、宽高信息，用于设置返回动画卡片组件的结束状态位置尺寸信息；
  ```ts
  LazyForEach(this.dataSource, (item: CardData, index) => {
    FlowItem() {
      CardPage({cardData: item})
        .onClick(() => {
          this.clickedCardIndex = index;
        })
    }
    .onAreaChange((oldValue, newValue) => {
      this.dataSource.getData(index).cardArea = newValue;
    })
    .width('100%')
  })
  ```
3、入场动画：onCardReadyExpand回调在DetailPage内部Image渲染结束时触发；（用于解决 Image 组件的渲染期间就发生页面转场导致的白色闪屏问题）
使用Stack布局，动态设置DetailPage zIndex值大于CardList，使DetailPage覆盖到CardList上；
设置expandCardId为被点击的卡片Id，触发DetailPage卡片组件-> DetailPage详情页的属性动画；（显式动画改变宽高）
  ```ts
  CardPage({
    cardData: this.dataSource.getData(this.clickedCardIndex),
    expandCardId: this.expandCardId,
    onCardReadyExpand: () => {
      if (!this.isDetailPageShow) {
        animateTo({duration: 5,onFinish: ()=>{
          this.expandCardId = this.dataSource.getData(this.clickedCardIndex).id;
        }}, ()=> { 
          this.isDetailPageShow = true
        })
      }
    },
    onBack: () => {
      this.expandCardId = -1;
    },
    onAnimationFinish: () => {
      if (this.expandCardId < 0) {
          this.clickedCardIndex = -1;
          this.isDetailPageShow = false;
      }
    }
  })
  .width(this.expandCardId > -1 ? '100%' : this.dataSource.getData(this.clickedCardIndex).cardArea.width)
  .height(this.expandCardId > -1 ? px2vp( this.currentDisplayHeight as number) : this.dataSource.getData(this.clickedCardIndex).cardArea.height)
  .position({
    x: this.expandCardId > -1 ? 0 : this.dataSource.getData(this.clickedCardIndex).cardArea.position.x,
    y: this.expandCardId > -1 ? 0 : (this.dataSource.getData(this.clickedCardIndex).cardArea.position.y)
  })
  .animation({duration: 200})
  .backgroundColor(Color.White)
  ```
  ```ts
  .zIndex(this.isDetailPageShow ? 2 : 0)
  ```
4、入场动画：CardPage内部监听expandCardId值变化，触发expandCardId相关的显式动画，透明度动画控制卡片组件和卡片详情页不共用组件的显隐
  ```ts
    @Prop @Watch('onExpandCardIdChange') expandCardId?: number = -1;
    onExpandCardIdChange() {
      animateTo({duration:200, onFinish: this.onAnimationFinish}, ()=>{
        this.isCardExpand = this.expandCardId === this.cardData.id
      })
    }
  ```
5、出场动画：点击返回按钮，触发重置为this.expandCardId = -1，卡片组件宽高动画和卡片组件和卡片详情页不共用组件的显隐动画，都关联expandCardId属性。即可实现出场动画。

6、一镜到底实际上是在动画开始前将UI显示相同的A组件覆盖到B卡片组件上，入场动画和出场动画作用A一个组件上。

### 高性能知识点

本示例使用了LazyForEach进行数据懒加载以降低内存占用。

### 工程结构&模块类型
  ```ts
  transitionanimation             // har包
     |---model
     |   |---CardData.ets          // 卡片页面的model层数据结构
     |   |---WaterFlowDataSource.ets    // 瀑布流列表 model 数据层      
     |---pages
     |   |---TransitionAnimationPage.ets           // 转场动画效果实现页面
     |   |---CardPage.ets                            // 卡片和卡片详情页面
     |   |---NewNavPage.ets                        // 从卡片详情页面使用路由跳转到的页面
  ```
### 模块依赖

[**routermodule**](../routermodule)

### 参考资料
[动画](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/4_10_u52a8_u753b-0000001820880989)
