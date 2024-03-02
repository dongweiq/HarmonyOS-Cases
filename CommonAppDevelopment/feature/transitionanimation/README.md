# 一镜到底“页面转场”动画
# 介绍
本方案做的是模仿小红书页面点击卡片跳转到详情预览的转场动画效果
### 效果图预览
![](../../product/entry/src/main/resources/base/media/transition_animation.gif)
##### 使用说明
点击首页卡片跳转到详情页，再点击进入路由页面按钮，进入新的路由页面
### 实现思路
小红书的首页使用了一种视觉上看起来像是组件的转场动画，这种转场动画通常是通过组件的动态加载和切换来实现的，而不是简单的页面之间的路由跳转。
实现方案如下：
1、首页TransitionAnimationPage渲染了两个Page, 瀑布流卡片列表CardList和卡片详情页DetailPage
```ts
build() {
    Navigation(this.pageInfos) {
      Stack() {
        this.CardList();
        this.DetailPage();
      }
    }
    .hideTitleBar(true)
    .navDestination(this.PageMap)
  }
```
2、点击卡片后，触发this.clickedCardIndex = index记录当前被点击卡片在数组中的索引；
使用onAreaChange存储每个Card被点击时的位置、宽高信息，用于设置返回动画组件的状态信息；
```ts
LazyForEach(this.dataSource, (item: CardData, index) => {
          FlowItem() {
            MyCard({cardData: item})
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
3、onCardReadyExpand回调在DetailPage内部Image渲染结束时触发；
使用Stack布局，设置this.isDetailPageShow = true，动态设置DetailPage zIndex值大于CardList，使DetailPage覆盖到CardList上，方便DetailPage展开覆盖全屏；
再设置 expandCardId  为被点击的卡片Id，触发CardList.MyCard -> DetailPage.MyCard的属性动画；
```ts
MyCard({
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
          .height(this.expandCardId > -1 ? px2vp( this.currentDiaplayHeight as number) : this.dataSource.getData(this.clickedCardIndex).cardArea.height)
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
4、MyCard内部监听expandCardId值变化，触发expandCardId相关的显示动画，用于CardList.MyCard -> DetailPage.MyCard涉及到的内容结构变化动画
    ```ts
    @Prop @Watch('onExpandCardIdChange') expandCardId?: number = -1;
    
      onExpandCardIdChange() {
        animateTo({duration:200, onFinish: this.onAnimationFinish}, ()=>{
          this.isCardExpand = this.expandCardId == this.cardData.id
        })
      }
    ```
### 工程结构&模块类型
```ts
transitionanimation             // har包
   |---model
   |   |---CardData.ets          // 卡片页面的model层数据结构
   |   |---WaterFlowDataSource.ets    // 瀑布流列表 model 数据层      
   |---pages
   |   |---TransitionAnimationPage.ets           // 转场动画效果实现页面
   |   |---MyCard.ets                            // 卡片和卡片详情页面
   |   |---NewNavPage.ets                        // 从卡片详情页面使用路由跳转到的页面
```
### 模块依赖
不涉及
### 参考资料
[动画](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/4_10_u52a8_u753b-0000001820880989)
