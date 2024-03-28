# HarmonyOS NEXT应用开发性能优化入门引导

## 概述

在开发HarmonyOS NEXT应用时，优化应用性能是至关重要的。本文将介绍应用开发过程中常犯的一些性能问题，并提供相应的解决方案，配合相关参考示例，帮助开发者解决大部分性能问题。

我们把应用性能分析的方法划分为了**性能分析四板斧**，下面将介绍如何使用性能分析四板斧，解决应用开发过程中的性能问题。

* **第一板斧：合理使用并行化、预加载和缓存**，我们需要合理的使用并行化、预加载和缓存等方法，例如使用多线层并发、异步并发、Web预加载等能力，提升系统资源利用率，减少主线程负载，加快应用的启动速度和响应速度。

* **第二板斧：尽量减少布局的嵌套层数**，在进行页面布局开发时，应该去除冗余的布局嵌套，使用相对布局、绝对定位、自定义布局、Grid、GridRow等扁平化布局，减少布局的嵌套层数，避免系统绘制更多的布局组件，达到优化性能、减少内存占用的目的。

* **第三板斧：合理管理状态变量**，应该合理的使用状态变量，精准控制组件的更新范围，控制状态变量关联组件数量，控制对象级状态变量的成员变量关联组件数，减少系统的组件渲染负载，提升应用流畅度。

* **第四板斧：合理使用系统接口，避免冗余操作**，应该合理使用系统的高频回调接口，删除不必要的Trace和日志打印，避免注册系统冗余回调，减少系统开销。

## 第一板斧：合理使用并行化、预加载和缓存

我们需要合理的使用并行化、预加载和缓存等方法，提升系统资源利用率，减少主线程负载，加快应用的启动速度和响应速度。

### 使用并行化提升启动速度

自定义组件创建完成之后，在build函数执行之前，将先执行aboutToAppear()生命周期回调函数。此时若在该函数中执行耗时操作，将阻塞UI渲染，增加UI主线程负担。因此，应尽量避免在自定义组件的生命周期内执行高耗时操作。在aboutToAppear()生命周期函数内建议只做当前组件的初始化逻辑，对于不需要等待结果的高耗时任务，可以使用多线程处理该任务，通过并发的方式避免主线程阻塞；也可以把耗时操作改为异步并发或延后处理，保证主线程优先处理组件绘制逻辑。

#### 使用多线程执行耗时操作

在日常开发过程中经常会碰到这样的问题：主页的开发场景中有多个Tab页展示不同内容，在首次加载完主页后，切换到第二个Tab页时需要加载和处理网络数据，导致第二个Tab页的页面显示较慢，有较大的完成时延。

碰到此类问题，我们可以在生命周期aboutToApear中，使用多线程并发（详细介绍可参考文章：[高效并发编程](efficient-concurrent-programming.md)、[多线程能力场景化](multi_thread_capability.md)）的方法执行第二个Tab页的网络数据访问解析、数据加载等耗时操作，既可以提前完成数据加载，也不会影响主线程UI绘制和渲染。

使用TaskPool进行耗时操作的示例代码如下：
```typescript
import taskpool from '@ohos.taskpool';

aboutToApear() {
  ...
  // 在生命周期中，使用TaskPool加载和解析网络数据
  this.requestByTaskPool()
}

@Concurrent
getInfoFromHttp(): string[] {
  // 从网络加载数据
  return http.request();
}

requestByTaskPool(): void {
  // 创建任务项
  let task: taskpool.Task = new taskpool.Task(this.getInfoFromHttp);
  try {
	// 执行网络加载函数
	taskpool.execute(task, taskpool.Priority.HIGH).then((res: string[]) => {
	})
  } catch (err) {
	 logger.error(TAG, "failed, " + (err as BusinessError).toString());
  }
}
```

其他多线程并发相关文章：
* [利用native的方式实现跨线程调用](native-threads-call-js.md)

相关案例：
* [预加载so并读取RawFile文件](../../../CommonAppDevelopment/feature/nativerawfile/README.md)
* [Worker子线程中解压文件](../../../CommonAppDevelopment/feature/decompressfile/README.md)

#### 使用异步执行耗时操作

问题：在aboutToApear生命周期中，运行了业务数据解析和处理等耗时操作，影响了上一页面点击跳转该页面的响应时延。

可以把耗时操作的执行从同步执行改为异步或者延后执行（详细介绍可参考文章：[提升应用冷启动速度](improve-application-cold-start-speed.md)），比如使用setTimeOut执行耗时操作，示例如下：

```typescript
aboutToApear() {
  ...
  // 在生命周期中，使用异步处理数据，延时大小视情况确定
  setTimeout(() => {
    this.workoutResult()
  }, 1000)
}

workoutResult(): string[] {
  // 处理需要展示的业务数据
  let data: Data[] = []
  for(let i = 1; i < 100; i++) {
    result += data[i];
  }
  return result;
}
```

### 使用预加载提升页面启动和响应速度

应该合理使用系统的预加载能力，例如Web组件的预连接、预加载、预渲染，使用List、Swiper、Grid、WaterFlow等组件的cachedCount属性实现预加载，使用条件渲染实现预加载）等，提升页面的启动和响应速度。

#### 使用Web组件的预连接、预加载、预渲染能力

当我们碰到Web页面加载慢的场景，我们可以使用Web组件的预连接、预加载、预渲染能力（详细介绍可参考文章：[Web组件开发性能提升指导](performance-web-import.md)），在应用空闲时间提前进行Web引擎初始化和页面加载，提升下一页面的启动和响应速度。

示例代码如下：
```typescript
import webview from '@ohos.web.webview';

preload() {
  // Web组件引擎初始化
  webview.WebviewController.initializeWebEngine();
  // 启动预连接，连接地址为即将打开的网址
  webview.WebviewController.prepareForPageLoad('https://gitee.com/  harmonyos-cases/cases', true, 2);
}
```
相关案例：
* [Web组件的动态加载实现案例](https://gitee.com/harmonyos-cases/cases/blob/master/CommonAppDevelopment/product/entry/src/main/ets/view/HelperView.ets)

#### 使用cachedCount属性实现预加载

推荐在使用List、Swiper、Grid、WaterFlow等组件时，配合使用cachedCount属性实现预加载（详细介绍可参考文章：[WaterFlow高性能开发指导](waterflow_optimization.md)、[Swiper高性能开发指导](swiper_optimization.md)、[Grid高性能开发指导](grid_optimization.md)、[列表场景性能提升实践](list-perf-improvment.md)），示例代码如下所示：

```typescript
// TODO
```

#### 使用条件渲染实现预加载

问题：页面布局复杂度较高，导致跳转该页面的响应时延较慢。

可以使用条件渲染（详细介绍可参考文章：[合理选择条件渲染和显隐控制](proper-choice-between-if-and-visibility.md)的方式，添加页面的简单骨架图作为默认展示页面，等数据加载完成后再显示最终的复杂布局，加快点击响应速度。

示例代码如下：

```typescript
import skeletonComponent from "./skeletonComponent"
import businessComponent from "./businessComponent"

@State isInitialzed:boolean = false

aboutToAppear() {
  ...
  // 从网络获取页面数据
  requestByTaskPool()
}

build() {
  // 当数据未就位时展示骨架图，提升用户体验，减少页面渲染时间
  if(!this.isInitialzed) {
    skeletonComponent()
  } else {
    businessComponent()
  }
}

@Concurrent
getInfoFromHttp(): string[] {
  // 从网络加载数据
  return http.request();
}

requestByTaskPool(): void {
  // 创建任务项
  let task: taskpool.Task = new taskpool.Task(this.getInfoFromHttp);
  try {
	// 执行网络加载函数
	taskpool.execute(task, taskpool.Priority.HIGH).then((res: string[]) => {
    // 设置状态变量改变页面展示
    this.isInitialzed = true;
	})
  } catch (err) {
	 logger.error(TAG, "failed, " + (err as BusinessError).toString());
  }
}
```

### 使用缓存提升启动速度和滑动帧率

在列表场景钟，我们推荐使用LazyForEach+组件复用+缓存列表项的能力，替代Scroll/ForEach实现滚动列表场景的实现，加快页面启动速度，提升滑动帧率；在一些属性动画的场景下，我们可以使用renderGroup缓存提升属性动画性能；也可以使用显隐控制对页面进行缓存，加快页面的显示响应速度。

#### 组件复用

HarmonyOS应用框架提供了组件复用能力，可复用组件从组件树上移除时，会进入到一个回收缓存区。后续创建新组件节点时，会复用缓存区中的节点，节约组件重新创建的时间。

若业务实现中存在以下场景，并成为UI线程的帧率瓶颈，推荐使用组件复用（详细介绍可参考文章：[组件复用使用指导](component-recycle.md)、[列表场景性能提升实践](list-perf-improvment.md)）：

* 列表滚动（本例中的场景）：当应用需要展示大量数据的列表，并且用户进行滚动操作时，频繁创建和销毁列表项的视图可能导致卡顿和性能问题。在这种情况下，使用列表组件的组件复用机制可以重用已经创建的列表项视图，提高滚动的流畅度。
* 动态布局更新：如果应用中的界面需要频繁地进行布局更新，例如根据用户的操作或数据变化动态改变视图结构和样式，重复创建和销毁视图可能导致频繁的布局计算，影响帧率。在这种情况下，使用组件复用可以避免不必要的视图创建和布局计算，提高性能。
* 地图渲染：在地图渲染这种场景下，频繁创建和销毁数据项的视图可能导致性能问题。使用组件复用可以重用已创建的视图，只更新数据的内容，减少视图的创建和销毁，能有效提高性能。

示例代码如下：

```typescript
// xxx.ets
class MyDataSource implements IDataSource {
  private dataArray: string[] = [];
  private listener: DataChangeListener | undefined;
  ...
}

@Entry
@Component
struct MyComponent {
  private data: MyDataSource = new MyDataSource();

  aboutToAppear() {
    for (let i = 0; i < 1000; i++) {
      this.data.pushData(i.toString())
    }
  }

  build() {
    List({ space: 3 }) {
      LazyForEach(this.data, (item: string) => {
        ListItem() {
          ReusableChildComponent({ item: item })
        }
      }, (item: string) => item)
    }
    .width('100%')
    .height('100%')
  }
}

@Reusable
@Component
struct ReusableChildComponent {
  @State item: string = ''
  // 复用时触发的生命周期
  aboutToReuse(params: ESObject) {
    this.item = params.item;
  }

  build() {
    Row() {
      Text(this.item)
        .fontSize(20)
        .margin({ left: 10 })
    }.margin({ left: 10, right: 10 })
  }
}
```

#### 使用renderGroup缓存提升属性动画性能

页面响应时，可能大量使用属性动画和转场动画，当复杂度达到一定程度之后，就有可能出现卡顿的情况。renderGroup(详细介绍可参考文章:[合理使用renderGroup](reasonable-using-renderGroup.md))是组件通用方法，它代表了渲染绘制的一个组合。

具体原理是在首次绘制组件时，若组件被标记为启用renderGroup状态，将对组件及其子组件进行离屏绘制，将绘制结果合并保存到缓存中。此后当需要重新绘制相同组件时，就会优先使用缓存而不必重新绘制了，从而降低绘制负载，进而加快响应速度。

示例代码如下：
```typescript
// Index.ets

import { IconItem } from './IconItem'

// IconItem相关数据
class IconItemSource {
  image: string | Resource = ''
  text: string | Resource = ''
  ...
}

@Entry
@Component
struct Index {
  private iconItemSourceList: IconItemSource[] = [];

  aboutToAppear() {
    // 遍历添加IconItem的数据
    this.iconItemSourceList.push(
      new IconItemSource($r('app.media.img1'), `label1`),
      new IconItemSource($r('app.media.img2'), `label2`),
      new IconItemSource($r('app.media.img3'), `label3`),
    );
  }

  build() {
    Column() {
      // IconItem放置在grid内
      GridRow({}) {
        ForEach(this.iconItemSourceList, (item: IconItemSource) => {
          GridCol() {
            IconItem({ image: item.image, text: item.text })
              .transition(
                TransitionEffect.scale({})
                  .animation({})
                  .combine(TransitionEffect.rotate({})
                  .animation({ }))
              )
          }
        })
      }
    }
  }
}

// IconItem.ets

@Component
export struct IconItem {
  ...
  build()  {
    Flex()  {
      Image(this.image)
      Text(this.text)
    }
    // 在IconItem内开启renderGroup
    .renderGroup(true)
  }
}
```

#### 使用显隐控制进行页面缓存

控制元素显示与隐藏是一种常见的场景，使用Visibility.none、if条件判断等都能够实现该效果。其中if条件判断控制的是组件的创建、布局阶段，visibility属性控制的是元素在布局阶段是否参与布局渲染。使用时如果使用的方式不当，将引起性能上的问题。
如果会频繁响应显示与隐藏的交互效果，建议使用切换Visibility.None和Visibility.Visiable来控制元素显示与隐藏(详细介绍可参考文章: [合理选择条件渲染和显隐控制](proper-choice-between-if-and-visibility.md))，在组件无需展示的时候进行缓存，提高性能。

示例代码如下：
```typescript
@State isVisible: boolean = true;

build() {
  Column() {
    Button("Switch visible and hidden").onClick(() => {
        this.isVisible = !(this.isVisible);
    })
    Stack() {
      Scroll() {
        Column() {
          Image($r('app.media.icon'))
        }
      }.visibility(this.isVisible ? Visibility.Visible : Visibility.None)// 使用显隐控制切换，不会频繁创建与销毁组件
    }  
  }  
}
```

## 第二板斧：尽量减少布局的嵌套层数

在进行页面布局开发时，应该去除冗余的布局嵌套，使用相对布局、绝对定位、自定义布局、Grid、GridRow等扁平化布局，减少布局的嵌套层数，避免系统绘制更多的布局组件，达到优化性能(详细介绍可参考文章: [优化布局性能](reduce-view-nesting-levels.md))、减少内存占用的目的。

### 移除冗余节点

应该删除冗余的布局嵌套，例如build最外层的无用容器嵌套、无用的Stack或Column嵌套等，减少布局层数。


反例代码如下：
```typescript
@Componnet
struct componentA {
  build() {
    Column() {
      ComponentB();
    }
  }
}

@Componnet
struct componentB {
  build() {
    Column() {
      Text('');
    }
  }
}
```
正例代码如下：
```typescript
@Componnet
struct componentA {
  build() {
    Column() {
      ComponentB();
    }
  }
}

@Componnet
struct componentB {
  build() {
    Text('');
  }
}
```

#### 删除无用的Stack/Column/Row嵌套

例如可能会在Row容器包含一个同样也是Row容器的子级。这种嵌套实际是多余的，并且会给布局层次结构造成不必要的开销。示例代码如下：

```typescript
// 反例
Row() {
  Row() {
    Image()
    Text()
  }
  Image()
}

// 正例
Row() {
  Image()
  Text()
  Image()
}
```
#### 删除build函数中最外层无用容器嵌套

在开发过程中，布局的实现往往嵌套使用大量的自定义组件，build中冗余的最外层无用容器会大大增强嵌套层级，应该删除。

示例代码如下：
```typescript
// 反例
@Component
MyCompnent {
  build() {
    Stack() {
	  Row {
      Image()
      Text()
	  }
	}
  }
}

// 正例
@Component
MyCompnent {
  build() {
    Row {
      Image()
      Text()
    }
  }
}
```

### 使用扁平化布局减少节点数

#### 使用Column/Row替代Flex构建线性布局

由于Flex本身带来的二次布局的影响，Flex的性能明显低于Column和Row容器，因此推荐使用Column/Row替代Flex构建线性布局(详细介绍可参考文章: [Flex布局性能提升使用指导](flex-development-performance-boost.md))。

反例代码如下：
```typescript
@Entry
@Component
struct MyComponent {
  build() {
    Flex({ direction: FlexDirection.Column }) {
      Flex().width(300).height(200).backgroundColor(Color.Pink)
      Flex().width(300).height(200).backgroundColor(Color.Yellow)
      Flex().width(300).height(200).backgroundColor(Color.Grey)
    }
  }
}
```
正例代码如下：
```typescript
@Entry
@Component
struct MyComponent {
  build() {
    Column() {
      Row().width(300).height(200).backgroundColor(Color.Pink)
      Row().width(300).height(200).backgroundColor(Color.Yellow)
      Row().width(300).height(200).backgroundColor(Color.Grey)
    }
  }
}
```


#### 使用Flex、List、Grid、RelativeContainer、绝对布局和自定义布局等构建复杂布局

复杂布局提供了场景化的能力(详细介绍可参考文章: [优化布局性能](reduce-view-nesting-levels.md))，解决一种或者多种布局场景：

* 使用Flex构建弹性布局；
* List既具备线性布局的特点，同时支持懒加载和滑动的能力；
* Grid/GridItem提供了宫格布局的能力，同时也支持懒加载和滑动能力；
* RelativeContainer是一种相对布局，通过描述各个内容组件间相互关系来指导内容元素的布局过程，可从横纵两个方面进行布局描述，是一种二维布局算法；


反例代码如下：
```typescript
@Entry
@Component
struct AspectRatioExample12 {
    @State children: Number[] = Array.from(Array<number>(900), (v, k) => k);
    
    build() {
      Scroll() {
      Grid() {
        ForEach(this.children, (item: Number[]) => {
          GridItem() {
            Stack() {  
              Stack() {  
                Stack() {  
                  Text(item.toString())  
                }.size({ width: "100%"})  
              }.backgroundColor(Color.Yellow)  
            }.backgroundColor(Color.Pink)  
          }  
        }, (item: string) => item)  
      }  
      .columnsTemplate('1fr 1fr 1fr 1fr')  
      .columnsGap(0)  
      .rowsGap(0)  
      .size({ width: "100%", height: "100%" })  
    }  
  }  
}
```
正例代码如下：
```typescript
@Entry  
@Component  
struct AspectRatioExample11 {  
  @State children: Number[] = Array.from(Array<number>(900), (v, k) => k);  
  
  build() {  
    Scroll() {  
      Grid() {  
        ForEach(this.children, (item: Number[]) => {  
          GridItem() {  
            Text(item.toString())  
          }.backgroundColor(Color.Yellow)  
        }, (item: string) => item)  
      }  
      .columnsTemplate('1fr 1fr 1fr 1fr')  
      .columnsGap(0)  
      .rowsGap(0)  
      .size({ width: "100%", height: "100%" })  
    }  
  }  
}
```

## 第三板斧：合理管理状态变量

应该合理的使用状态变量，精准控制组件的更新范围(详细介绍可参考文章: [精准控制组件的更新范围](precisely-control-render-scope.md))，控制状态变量关联组件数量上限，控制对象级状态变量的成员变量关联组件数，减少系统的组件渲染负载，提升应用流畅度。

### 精准控制组件的更新范围

在复杂页面开发的场景下，精准控制组件更新的范围对提高应用运行性能尤为重要。我们应该避免状态变量的滥用引起的容器组件的刷新，进而影响帧率。

#### 使用Stack包裹条件悬案组件，减小更新范围

用条件渲染的方式控制组件的显示，在条件发生变化时会引起父组件的重新渲染。如果在同个父组件下存在复杂组件，在高频操作场景会产生性能问题。因此，对于该场景，我们应该用父容器组件包裹可能会频繁条件变化的组件


反例代码如下：
```typescript
@State isVisiable: boolean;
@State realData: Data[] = [];

aboutToAppear() {
  // 更新状态变量
  this.realData = [...]
}

build() {
  Column() {
    if(this.isVisiable) {
      Image()
    }
    ForEach(this.realData,(item: Data) => {
      Text(`${item.label}`)
    })
  }
}
```
正例代码如下：
```typescript
@State isVisiable: boolean;
@State realData: Data[] = [];

aboutToAppear() {
  // 更新状态变量
  this.realData = [...]
}

build() {
  Column() {
    Column() {
      if(this.isVisiable) {
        Image()
      }
    }
    ForEach(this.realData,(item: Data) => {
      Text(`${item.label}`)
    })
  }
}
```

#### 减少不必要的参数层次传递

@State+@Prop、@State+@Link、@State+@Observed+@ObjectLink三种方案的实现方式是逐级向下传递状态，当共享状态的组件间层级相差较大时，会出现状态层层传递的现象。对于没有使用该状态的中间组件而言，这是“额外的消耗”。因此，对于跨越多层的状态变量传递，使用@Provide+@Consume方案更为合理。


反例代码如下：
```typescript
// 父组件
@Component
struct componentParent{
  @State data: Data = {}
  
  aboutToAppear() {
    // 获取子组件数据
    this.data = getData()
  }

  build() {
    Colume() {
      componentSon({data: this.data})
    }
  }
}

// 子组件
@Component
struct componentSon{
  // 获取传递参数
  @Prop data: Data;

  build() {
    Colume() {
      Text(data.text)
      ComponentGrandSon({data: this.data})
    }
  }
}

@Component
struct componentGrandSon{
  // 获取传递参数
  @Prop data: Data;

  build() {
    Colume() {
      Text(data.text)
    }
  }
}
```
正例代码如下：
```typescript
// 父组件
@Component
struct componentParent{
  @Provide('data') data: Data = {};
  
  aboutToAppear() {
    // 获取子组件数据
    this.data = getData()
  }

  build() {
    Colume() {
      componentSon({data: this.data})
    }
  }
}

// 子组件
@Component
struct componentSon{
  // 获取传递参数
  @Consume("data") data: Data;

  build() {
    Colume() {
      Text(data.text)
      ComponentGrandSon({data: this.data})
    }
  }
}

@Component
struct componentGrandSon{
  // 获取传递参数
  @Consume("data") data: Data;

  build() {
    Colume() {
      Text(data.text)
    }
  }
}
```

#### 避免滥用@Provide+@Consume

在父子组件关联的场景下，@Provide+@Consume开销要大于@State+@Prop/@Link，因此在该场景下推荐使用@State+@Prop/@Link的组合。

反例代码如下：
```typescript
// 父组件
@Component
struct componentParent{
  @Provide("data") data: Data = {};
  
  aboutToAppear() {
    // 获取子组件数据
    this.data = getData();
  }

  build() {
    Colume() {
      componentSon()
    }
  }
}

// 子组件
@Component
struct componentSon{
  // 获取传递参数
  @Consume("data") data: Data;

  build() {
    Colume() {
      Text(data.text)
    }
  }
}
```

正例代码如下：
```typescript
// 父组件
@Component
struct componentParent{
  @State data:Data = {};
  
  aboutToAppear() {
    // 获取子组件数据
    this.data = getData();
  }

  build() {
    Colume() {
      componentSon({data: this.data})
    }
  }
}

// 子组件
@Component
struct componentSon{
  // 获取传递参数
  @Prop data:Data;

  build() {
    Colume() {
      Text(data.text)
    }
  }
}
```

### 精准控制状态变量关联组件数量

应该控制状态变量关联的组件数量，如果一个状态关联过多的组件，当这个变量更新时会引起过多的组件重新绘制渲染，建议关联数量限制在20个以内。

#### 控制状态变量关联组件数量

反例代码如下：
```typescript
@Observed
class Translate {
  translateX: number = 20;
}
@Component
struct Title {
  @ObjectLink translateObj: Translate;
  build() {
    Row() {
      Image($r('app.media.icon'))
        .translate({
          x:this.translateObj.translateX // this.translateObj.translateX used in two component both in Row
        })
      Text("Title")
        .translate({
          x: this.translateObj.translateX
        })
    }
  }
}
@Entry
@Component
struct Page {
  @State translateObj: Translate = new Translate();
  build() {
    Column() {
      Title({
        translateObj: this.translateObj
      })
      Stack() {
      }
      .translate({
        x:this.translateObj.translateX //this.translateObj.translateX used in two components both in Column
      })
      Button("move")
        .translate({
          x:this.translateObj.translateX
        })
        .onClick(() => {
          animateTo({
            duration: 50
          },()=>{
            this.translateObj.translateX = (this.translateObj.translateX + 50) % 150
          })
        })
    }
  }
}
```
正例代码如下：
```typescript
@Observed
class Translate {
  translateX: number = 20;
}
@Component
struct Title {
  build() {
    Row() {
      Image($r('app.media.icon'))
      Text("Title")
    }
  }
}
@Entry
@Component
struct Page1 {
  @State translateObj: Translate = new Translate();
  build() {
    Column() {
      Title()
      Stack() {
      }
      Button("move")
        .onClick(() => {
          animateTo({
            duration: 50
          },()=>{
            this.translateObj.translateX = (this.translateObj.translateX + 50) % 150
          })
        })
    }
    .translate({ // the component in Column shares the same property translate
      x: this.translateObj.translateX
    })
  }
}
```

#### 控制对象级状态变量成员数量

应该控制对象级状态变量的成员变量关联的组件数量。开发者封装一个数据结构类用于进行状态变量关联时，应该避免过多的成员变量关联大量ArkUI组件，这种情况下，当这个大对象的一个成员变量更新时，会导致所有关联这个大对象的组件都同时进行刷新，造成不必要的性能损耗，从而影响帧率。


反例代码如下：
```typescript
@Observed
class AnimationParams {
  translateX: number = 0;
  translateY: number = 0;
  alpha: number = 1;
  rotationX: number = 0;
  rotationY: number = 0;
  centerX: number = 0;
  centerY: number = 0;
  angle: number = 0;
  scaleX: number = 1;
  scaleY: number = 1;
}

@Entry
@Component
struct Page {
  @State animationParam: AnimationParams = new AnimationParams();

  build() {
    Column() {
      Row() {
        Image($r('app.media.startIcon'))
          .translate({
            x: this.animationParam.translateX,
            y: this.animationParam.translateY
          })
          .rotate({
            x: this.animationParam.rotationX,
            y: this.animationParam.translateY,
            centerX: this.animationParam.centerX,
            centerY: this.animationParam.centerY,
            angle: this.animationParam.angle
          })
          .opacity(this.animationParam.alpha)
          .scale({
            x: this.animationParam.scaleX,
            y: this.animationParam.scaleY,
            centerX: this.animationParam.centerX,
            centerY: this.animationParam.centerY
          })
          .animation({
            duration: 3000
          })
      }

      Button('点击播放动画')
        .onClick(() => {
          this.animationParam.translateX = 300;
          this.animationParam.translateY = 200;
          this.animationParam.rotationX = 90;
          this.animationParam.rotationY = 90;
          this.animationParam.centerX = 20;
          this.animationParam.centerY = 20;
          this.animationParam.angle = 270;
          this.animationParam.alpha = 0.5;
          this.animationParam.scaleX = 3;
          this.animationParam.scaleY = 3;
        })
    }
  }
}
```
正例代码如下：
```typescript
@Observed
class RotationAnimationParams {
  rotationX: number = 0;
  rotationY: number = 0;
  centerX: number = 0;
  centerY: number = 0;
  angle: number = 0;
}

@Observed
class TranslateAnimationParams {
  translateX: number = 0;
  translateY: number = 0;
}

@Observed
class AlphaAnimationParams {
  alpha: number = 1;
}

@Observed
class ScaleAnimationParams {
  scaleX: number = 1;
  scaleY: number = 1;
  centerX: number = 0;
  centerY: number = 0;
}

@Entry
@Component
struct Page {
  @State rotationAnimation: RotationAnimationParams = new RotationAnimationParams();
  @State translateAnimation: TranslateAnimationParams = new TranslateAnimationParams();
  @State alphaAnimation: AlphaAnimationParams = new AlphaAnimationParams();
  @State scaleAnimation: ScaleAnimationParams = new ScaleAnimationParams();

  build() {
    Column() {
      Row() {
        Image($r('app.media.startIcon'))
          .translate({
            x: this.translateAnimation.translateX,
            y: this.translateAnimation.translateY
          })
          .rotate({
            x: this.rotationAnimation.rotationX,
            y: this.rotationAnimation.rotationY,
            centerX: this.rotationAnimation.centerX,
            centerY: this.rotationAnimation.centerY,
            angle: this.rotationAnimation.angle
          })
          .opacity(this.alphaAnimation.alpha)
          .scale({
            x: this.scaleAnimation.scaleX,
            y: this.scaleAnimation.scaleY,
            centerX: this.scaleAnimation.centerX,
            centerY: this.scaleAnimation.centerY
          })
          .animation({
            duration: 3000
          })
      }

      Button('点击播放动画')
        .onClick(() => {
          this.rotationAnimation.rotationX = 90;
          this.rotationAnimation.rotationY = 90;
          this.rotationAnimation.centerX = 20;
          this.rotationAnimation.centerY = 20;
          this.rotationAnimation.angle = 270;

          this.translateAnimation.translateX = 300;
          this.translateAnimation.translateY = 200;

          this.alphaAnimation.alpha = 0.5;

          this.scaleAnimation.scaleX = 3;
          this.scaleAnimation.scaleY = 3;
          this.scaleAnimation.centerX = 20;
          this.scaleAnimation.centerY = 20;
        })
    }
  }
}
```

### 避免不必要的创建和读取状态变量

避免不必要的创建和读取状态变量，减少性能损耗。

#### 删除冗余的状态变量标记
状态变量的管理有一定的开销，应在合理场景使用，普通的变量用状态变量标记可能会导致性能劣化

反例代码如下：
```typescript
@Component
struct component {
  @State bgcolor: string | Color = '#ffffff';
  @State selectColor: string | Color = '#007DFF';

}
```
正例代码如下：
```typescript
@Component
struct component {
  bgcolor: string | Color = '#ffffff';
  selectColor: string | Color = '#007DFF';
  
}
```

#### 避免在For/while等循环函数中重复读取状态变量

状态变量的读取耗时远大于普通变量的读取耗时，因此要避免重复读取状态变量，而是应该放在循环外面读取，例如在打印For/while循环中打印状态变量的日志信息

反例代码如下：
```typescript
@Component
struct Page {
  @State message: string = '';

  build() {
    Column() {
      Button('点击打印日志')
        .onClick(() => {
          for (let i = 0; i < 10; i++) {
            console.debug(this.message);
          }
        })
    }
  }
}
```

正例代码如下：
```typescript
@Component
struct Page {
  @State message: string = '';

  build() {
    Column() {
      Button('点击打印日志')
        .onClick(() => {
          let logMessage: string = this.message;
          for (let i = 0; i < 10; i++) {
            console.debug(logMessage);
          }
        })
    }
  }
}
```

## 第四板斧：合理使用系统接口，避免冗余操作

应该合理使用系统的高频回调接口，删除不必要的Trace和日志打印，避免冗余操作，减少系统开销。

### 避免在系统高频回调用进行冗余和耗时操作

应该避免在onSroll、onAreaChange等系统高频的回调接口中进行冗余和耗时操作，这些接口在系统的每一帧绘制中都会执行回调操作，因此在这些接口中进行冗余和耗时操作会大量消耗系统资源，影响应用运行性能。

#### 避免在系统高频回调用打印Trace

Trace的打印是会额外消耗系统性能的，因此应该避免在这些系统高频回调接口中打印Trace，示例代码如下：

```typescript
// 反例
Scroll() {
  ForEach(this.arr, (item: number) => {
    Text("ListItem" + item)
    .width("100%")
    .height("100%")
  }, (item: number) => item.toString())
}
.width('100%')
.height('100%')
.onScroll(() => {
  hitrace.startTrace("ScrollSlide", 1002);
  // 业务逻辑
  // ...
  hitrace.finishTrace("ScrollSlide", 1002);
})

// 正例
Scroll() {
  ForEach(this.arr, (item: number) => {
    Text("ListItem" + item)
    .width("100%")
    .height("100%")
  }, (item: number) => item.toString())
}
.width('100%')
.height('100%')
.onScroll(() => {
  // 业务逻辑
  // ...
})
```

#### 避免在系统高频回调用打印日志

日志的打印是会额外消耗系统性能的，特别是有些日志还读取了状态变量的信息，会加剧资源开销，因此应该避免在这些系统高频回调接口中打印日志，示例代码如下：

```typescript
// 反例
Scroll() {
  ForEach(this.arr, (item: number) => {
    Text("ListItem" + item)
    .width("100%")
    .height("100%")
  }, (item: number) => item.toString())
}
.width('100%')
.height('100%')
.onScroll(() => {
  hilog.info(1002, 'Scroll', 'ListItem');
  // 业务逻辑
  // ...
})

// 正例
Scroll() {
  ForEach(this.arr, (item: number) => {
    Text("ListItem" + item)
    .width("100%")
    .height("100%")
  }, (item: number) => item.toString())
}
.width('100%')
.height('100%')
.onScroll(() => {
  // 业务逻辑
  // ...
})
```

### 删除冗余Trace和日志打印

Trace和日志打印会比较消耗系统性能，因此我们应该避免冗余的Trace和日志打印。推荐在Release版本中，尽量删除所有Trace信息，删除Debug日志，减少额外的系统开销。

#### 在Release版本中删除Trace

Trace会比较消耗系统性能，建议在Release版本删除Trace打印。

反例代码如下：
```typescript
@Component
struct ComponentA {
  aboutToAppear {
    hitrace.startTrace("HITRACE_TAG_APP", 1001);
    // 业务代码
    ...
    hitrace.finishTrace("HITRACE_TAG_APP", 1001);
  }
}
```
正例代码如下：
```typescript
@Component
struct ComponentA {
  aboutToAppear {
    // 业务代码
    ...
  }
}
```

#### 在Release版本中删除Debug日志

Trace会比较消耗系统性能，建议在Release版本删除Trace打印。

反例代码如下：
```typescript
@Component
struct ComponentA {
  aboutToAppear {
    hilog.debug(0xFF00, "testTag", "ComponentA_aboutToAppear_start");
    // 业务代码
    ...
    hilog.debug(0xFF00, "testTag", "ComponentA_aboutToAppear_end");
  }
}
```
正例代码如下：
```typescript
@Component
struct ComponentA {
  aboutToAppear {
    // 业务代码
    ...
  }
}
```

### 避免设置冗余系统回调监听

冗余的系统回调监听，会额外消耗系统开销去做计算和函数回调消耗。比如设置了onAreaChange，就算回调中没有任何逻辑，系统也会在C++侧去计算该组件的大小和位置变化情况，并且把结果回调到TS侧，额外消耗了系统开销。

反例代码如下：
```typescript
build() {
  Column() {
    Text(this.value)
      .onClick(() => {
      })
      .onAreaChange((oldValue: Area, newValue: Area) => {
        console.info(`Ace: on area change`)
      })
  }
}
```
正例代码如下：
```typescript
build() {
  Column() {
    Text(this.value)
  }
}
```

## 使用性能工具分析和定位问题

学会合理使用工具进行问题分析和定位，提升问题解决效率。

### 使用[SmartPerf-Host](performance-optimization-using-smartperf-host.md)分析应用性能
smartPerf-Host是一款深入挖掘数据、细粒度展示数据的性能功耗调优工具，可采集CPU调度、频点、进程线程时间片、堆内存、帧率等数据，采集的数据通过泳道图清晰地呈现给开发者，同时通过GUI以可视化的方式进行分析。工具当前为开发者提供了五个分析模板，分别是帧率分析、CPU/线程调度分析、应用启动分析、TaskPool分析、动效分析。

### 使用[耗时分析器Time Profiler](profiler-time.md)分析应用耗时

该工具为OpenHarmony应用开发者提供性能采样分析手段，可在不插桩情况下获取调用栈上各层函数的执行时间，并展示在时间轴上。

开发者可通过该工具查看TS/JS代码及NAPI代码执行过程中的时序及耗时情况，进而发现热点函数及性能瓶颈，进行应用层性能优化

### 使用[状态变量组件定位工具](state_variable_dfx_pratice.md)分析状态变量关联信息

开发者可以使用状态变量组件定位工具获取状态管理相关信息，例如自定义组件拥有的状态变量、状态变量的同步对象和关联组件等，了解状态变量影响UI的范围，写出高性能应用代码。

## 性能文章总览
- [性能优化概览](performance-overview.md)
  - ArkTS高性能编程
    - [高性能编程规范](high-performance-programming.md)
    - [高效并发编程](efficient-concurrent-programming.md)
    - [N-API高效开发指导](develop-Native-modules-using-NAPI-safely-and-efficiently.md)
    - [多线程能力场景化](multi_thread_capability.md)
    - [利用native的方式实现跨线程调用](native-threads-call-js.md)
  - 减少卡顿丢帧
    - [正确使用LazyForEach优化](lazyforeach_optimization.md)
    - [组件复用使用指导](component-recycle.md)
    - [WaterFlow高性能开发指导](waterflow_optimization.md)
    - [Swiper高性能开发指导](swiper_optimization.md)
    - [合理进行状态管理](proper_state_management.md)
    - [精准控制组件的更新范围](precisely-control-render-scope.md)
    - [合理使用renderGroup](reasonable-using-renderGroup.md)
    - [减少动画丢帧](reduce-animation-frame-loss.md)
    - [合理使用多线程共享内存](thread_memory_shared.md)
    - [Grid高性能开发指导](grid_optimization.md)
  - 提升应用启动和响应速度
    - [提升应用冷启动速度](improve-application-cold-start-speed.md)
    - [提升应用响应速度](improve-application-response.md)
    - [Flex布局性能提升使用指导](flex-development-performance-boost.md)
    - [优化布局性能](reduce-view-nesting-levels.md)
    - [合理选择条件渲染和显隐控制](proper-choice-between-if-and-visibility.md)
    - [合理使用IPC通信](reasonable-using-ipc.md)
    - [文件上传下载性能提升指导](improve-file-upload-and-download-performance.md)
    - [减少首帧绘制时的冗余操作](reduce-redundant-operations-when-render-first-frame.md)
    - [列表场景性能提升实践](list-perf-improvment.md)
    - [动效能力实践](animation_practice.md)
    - [性能提升的其他方法](arkts-performance-improvement-recommendation.md)
    - [运行时动态加载页面提升性能](performance-dynamic-import.md)
    - [合理运行后台任务](reasonable-running-backgroundTask.md)
    - [Web组件开发性能提升指导](performance-web-import.md)
  - [减小应用包大小](reduce-package-size.md)
  - 性能工具
    - [性能分析工具CPU Profiler](application-performance-analysis.md)
    - [页面布局检查器ArkUI Inspector](arkUI-inspector.md)
    - [内存分析器Allocation Profiler](profiler-allocation.md)
    - [帧率分析工具 Frame Profiler](profiler-frame.md)
    - [启动分析工具Launch Profiler](profiler-launch.md)
    - [内存快照Snapshot Profiler](profiler-snapshot.md)
    - [耗时分析器Time Profiler](profiler-time.md)
    - [性能测试工具SmartPerf Editor](smartperf-editor.md)
    - [性能优化工具HiDumper](performance-optimization-using-hidumper.md)
    - [性能优化工具SmartPerf-Host](performance-optimization-using-smartperf-host.md)
    - [常用trace使用指导](common-trace-using-instructions.md)
    - [状态变量组件定位工具实践](state_variable_dfx_pratice.md)



