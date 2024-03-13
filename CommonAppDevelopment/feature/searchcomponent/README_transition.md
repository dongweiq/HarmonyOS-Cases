# 搜索页一镜到底案例

### 介绍

本示例介绍使用bindContentCover、transition、animateTo实现一镜到底转场动画，常用于首页搜索框点击进入搜索页场景。

### 效果图预览

<img src="../../product/entry/src/main/resources/base/media/search_trasition.gif" width="200">

**使用说明**

1. 点击首页搜索框跳转到搜索页面显式一镜到底转场动画

### 实现思路

通过点击首页搜索框改变bindContentCover全屏模态转场中的isSearchPageShow参数控制页面是否显示，同时将modalTransition设置为NONE关闭全屏模态转场的动画，使用transition和animateTo实现首页到搜索页面的转场动画通过bindContentCover全屏模态转场衔接动画。
通过geometryTransition同时绑定首页和搜索页面的search框实现丝滑的上下文传承过渡，达到一镜到底的效果。

1. 通过bindContentCover全屏模态转场实现对搜索页面显示的控制。源码参考[SearchComponent.ets](./src/main/ets/components/mainpage/SearchComponent.ets)
```ts
    Column() {
      Column() {
        Search({ placeholder: $r('app.string.search_placeholder') })
          .focusOnTouch(false)
          .focusable(false)
          .enableKeyboardOnFocus(false)
          .backgroundColor('#E7E9E8')
          .width(this.searchWidth)
          .height(40)
          .borderRadius($r('app.string.main_page_top_borderRadius'))
          .onClick(() => {
            this.onSearchClicked()
          })
          .geometryTransition(this.geometryId, { follow: true })
          // 搜索框转场过渡动画，cubicBezierCurve为三阶贝塞尔曲线动画
          .transition(TransitionEffect.OPACITY.animation({
            duration: 200,
            curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1)
          }))
      }
      .alignItems(HorizontalAlign.Start)
      .backgroundColor('#E7E9E8')
      .borderRadius($r('app.string.main_page_top_borderRadius'))
    }
    .position({ x: this.XPosition })
    // TODO：知识点：通过bindContentCover属性为组件绑定全屏模态页面，在组件插入和删除时可通过设置转场参数ModalTransition显示过渡动效
    .bindContentCover(this.isSearchPageShow, this.SearchPage(), {
      modalTransition: ModalTransition.NONE,
      onDisappear: () => {
        this.onArrowClicked()
      }
    })
    .alignItems(HorizontalAlign.Start)
    .padding({ left: $r('app.string.main_page_padding'), right: $r('app.string.main_page_padding'), top: 48,bottom: 40})
  }
  ```

2.通过geometryTransition同时绑定首页和搜索页面的search框实现丝滑的上下文传承过渡，使得原本独立的transition动画在空间位置上发生联系，将视觉焦点由旧视图位置引导到新视图位置。源码参考[SearchComponent.ets](./src/main/ets/components/mainpage/SearchComponent.ets)
```ts
Column() {
  Search({ placeholder: $r('app.string.search_placeholder') })
    .focusOnTouch(false)
    .focusable(false)
    .enableKeyboardOnFocus(false)
    .backgroundColor('#E7E9E8')
    .width(this.searchWidth)
    .height(40)
    .borderRadius($r('app.string.main_page_top_borderRadius'))
    .onClick(() => {
       this.onSearchClicked()
    })
    .geometryTransition(this.geometryId, { follow: true })
    // 搜索框转场过渡动画，cubicBezierCurve为三阶贝塞尔曲线动画
    .transition(TransitionEffect.OPACITY.animation({
       duration: 200,
       curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1)
    }))
  }
  ```

3.通过transition组件内转场实现搜索页面消失显示过程中的过渡效果。源码参考[SearchComponent.ets](./src/main/ets/components/mainpage/SearchComponent.ets)
```ts
    Image($r('app.media.ic_public_back'))
      .width(20)
      .onClick(() => {
         this.onArrowClicked()
      })
      // TODO：知识点：通过transition属性配置转场参数，在组件插入和删除时显示过渡动效。非对称对称转场，第一个为出现动效有150的延迟，第二个为消失动效
      .transition(TransitionEffect.asymmetric(
        TransitionEffect.opacity(0)
          .animation({ curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1), duration: 200, delay: 150 }),
        TransitionEffect.opacity(0)
          .animation({ curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1), duration: 200 }),
      ))
  ```

4.在切换过程中使用animateTo显式动画配合改变搜索框大小实现转换过程中的动画和一镜到底的效果。源码参考[SearchComponent.ets](./src/main/ets/components/mainpage/SearchComponent.ets)
```ts
  private onSearchClicked(): void {
    this.geometryId = 'search';
    animateTo({
      duration: 100,
      // 构造插值器弹簧曲线对象，生成一条从0到1的动画曲线
      curve: curves.interpolatingSpring(0, 1, 324, 38),
      onFinish: () => {
        this.geometryId = ''
      }
    }, () => {
      this.searchWidth = 400;
      this.isSearchPageShow = true;
    })
  }
  ```

### 高性能知识点

**不涉及**

### 工程结构&模块类型

   ```
   SearchComponent                                 // har类型(默认使用har类型，如果使用hsp类型请说明原因)
   |---model
   |   |---ListData.ets                            // 筛选数据模型
   |---SearchComponent.ets                         // 搜索模块
   ```

### 模块依赖

本场景依赖了路由模块[注册路由](../routermodule/src/main/ets/router/DynamicsRouter.ets)。

### 参考资料

1.[transition详细用法可参考文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-enter-exit-transition-0000001820879809)

2.[animateTo详细用法可参考文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-explicit-animation-0000001774121350)

3.[bindContentCover详细用法可参考文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-universal-attributes-modal-transition-0000001821000821)

4.[geometryTransition详细用法可参考文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-transition-animation-geometrytransition-0000001820880997)

