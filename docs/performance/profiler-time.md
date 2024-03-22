# 耗时分析器Time Profiler使用指导

DevEco Studio集成的DevEco Profiler性能调优工具（以下简称为Profiler），提供Time、Allocation、Snapshot、CPU等场景化分析任务类型。开发应用或服务过程中，如果遇到卡顿、加载耗时等性能问题，开发者通常会关注相关函数执行的耗时情况。Profiler提供的Time场景分析任务，可在应用/服务运行时，展示热点区域内基于CPU和进程耗时分析的调用栈情况，并提供跳转至相关代码的能力，使开发者更便捷地进行代码优化。

## 使用约束

已通过USB连接设备并在设备上打开需要调试的设备。

仅在应用为debug编译模式时使用。

仅支持OpenHarmony API 9及以上版本的Stage工程。

## 场景示例

本示例设置两个页面，示例场景存在页面跳转时间过长的问题。

主页面代码如下，包含一个页面跳转按钮。

```ts
import router from '@ohos.router'

@Entry
@Component
struct Index {
 build() {
  Row() {
   Column() {
    Button("点击跳转").onClick(() => {
     onJumpClick();
    })
   }
   .width('100%')
  }
  .height('100%')
 }
}

// 跳转下个页面
function onJumpClick(): void {
 router.pushUrl({
  url: 'pages/second' // 目标url
 }, router.RouterMode.Standard, (err) => {
  if (err) {
   console.error(`Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
   return;
  }
  console.info('Invoke pushUrl succeeded.');
 });
}
```

跳转后页面代码如下，页面包含100个Swiper组件，每个Swiper组件的子组件为带有100个ListItem的List组件，搭配ForEach进行渲染。

```ts
@Component
struct SwiperChild { // Swiper的子组件:带有100个ListItem的List组件
 @State arr: number[] = [];

 aboutToAppear(): void {
  for (let i = 1; i <= 100; i++) {
   this.arr.push(i);
  }
 }

 build() {
  Column() {
   List({ space: 20 }) {
    ForEach(this.arr, (index: number) => {
     ListItem() {
      Text(index.toString())
       .height('4.5%')
       .fontSize(16)
       .textAlign(TextAlign.Center)
       .backgroundColor(0xFFFFFF)
     }
     .border({ width: 2, color: Color.Green })
    }, (index: number) => index.toString());
   }
   .height("95%")
   .width("95%")
   .border({ width: 3, color: Color.Red })
   .lanes({ minLength: 40, maxLength: 40 })
   .alignListItem(ListItemAlign.Start)
   .scrollBar(BarState.Off)

  }.width('100%').height('100%').padding({ top: 5 });
 }
}

@Entry
@Preview
@Component
struct SecondPage { // 跳转后的页面
 @State data: Number[] = [];

 aboutToAppear(): void {
  for (let i = 1; i <= 100; i++) {
   this.data.push(i)
  }
 }

 build() {
  Column({ space: 5 }) {
   Swiper() {
    ForEach(this.data, (_: number) => {
     ChildPage();
    }, (item: number) => item.toString());
   }
   .loop(false)
   .indicator(true)
   .duration(100)
   .curve(Curve.Linear)

  }.width('100%')
  .margin({ top: 5 })
 }
}
```

## 打开耗时分析器

以DevEco Studio 4.0.0.400版本为例，在DevEco Studio菜单栏上单击***\*View\**** > ***\*Tool Windows\**** > ***\*Profiler\****，或者在DevEco Studio底部工具栏单击Profiler按钮，打开Profiler性能分析器，点选Time选项，再点击Create Session按钮创建耗时分析任务。

![img](imagesrofiler_time.jpg)

## 开始耗时分析任务录制

耗时分析任务创建完成后，窗口显示如下：

![img](imagesrofiler_create_session.jpg)

耗时分析任务支持在录制前单击![img](imagesrofiler_select.jpg)按钮指定要录制的泳道：

ArkTS Callstack：基于时间轴展示CPU使用率和状态的变化，以及当前调用栈名称和调用类型。调用栈的类型包括：System、ArkTS、NAPI、Native。

User Trace：基于时间轴展示当前时段内触发用户自定义打点任务的具体情况。

Native Callstack：基于时间轴展示进程/线程的活动状态，以及在一段时间内对CPU的占用情况和函数调用栈。

点击![img](imagesrofiler_action.jpg)按钮即可开始耗时分析任务录制，开始录制后在应用首页点击页面跳转按钮，等待成功跳转至下个页面后，结束录制任务。

### 提示

在任务录制（recording）及分析（analyzing）的过程中，请不要主动断开应用或者设备，否则可能导致分析任务异常失败。

## 进行耗时分析

耗时分析任务录制结束后，任务分析窗口如下：

![img](imagesrofiler_analyse.jpg)

在“ArkTS Callstack”泳道或“Native Callstack”子泳道上长按鼠标左键并拖拽，框选应用正在进行页面跳转的时间段。

此时“Details”区域显示所选时间段内的函数栈耗时分布情况，“Heaviest Stack”列表给出所选时段内函数栈耗时排序，并展示这些函数的节点路径。

分析函数栈耗时排序可以发现，跳转页面加载时间达到了1.46s，图中框出的ForEach接口占用了大部分页面跳转耗时间。在“Details”中双击ForEach接口下的(ARKUI_ENGINE)节点，可快速跳转至对应工程源码。

函数栈耗时分布有两种展现方式：

默认为列表方式，其中，“Weight”字段表示当前所属函数的总耗时，“Self”字段表示函数自身耗时，“Category”字段表示函数调用类型。

打开页面下方的“Flame Chart”开关，以火焰图模式展示函数栈调用情况。其中，横轴表示调用栈，纵轴表示栈的深度。火焰图模式如下，利用火焰图可以更清晰地发现ForEach接口的异常耗时。

![img](imagesrofiler_fire.jpg)

### 提示

在任务分析窗口，可以通过“Ctrl+鼠标滚轮”缩放时间轴，通过“Shift+鼠标滚轮”左右移动时间轴。

将鼠标置于泳道任意位置，可查看到对应时间点的CPU使用率。

单击任意泳道名称后方的![img](imagesrofiler_star.jpg)按钮可将其置顶。

火焰图条块支持搜索，搜索结果不匹配的条块会被置灰。

在火焰图中选中任一节点，使用“Alt+左键”可将该节点左置底并将其占比放大到100%，其上从属节点按同比例放大显示。该快捷操作同样适用于列表方式，用于将指定节点置顶并截取所属下级节点。

可使用工具页左下方的搜索栏通过关键词搜索函数栈。

## 代码优化

使用LazyForEach懒加载机制替换ForEach，使得页面跳转时不一次性加载所有的Swiper子组件。跳转后页面代码修改为如下所示：

```ts
class MyDataSource implements IDataSource { // LazyForEach的数据源
 private list: number[] = [];

 constructor(list: number[]) {
  this.list = list;
 }

 totalCount(): number {
  return this.list.length;
 }

 getData(index: number): number {
  return this.list[index];
 }

 registerDataChangeListener(_: DataChangeListener): void {
 }

 unregisterDataChangeListener(): void {
 }
}

@Component
struct ChildPage { // 带有100个ListItem的List组件
 @State arr: number[] = [];

 aboutToAppear(): void {
  for (let i = 1; i <= 100; i++) {
   this.arr.push(i);
  }
 }

 build() {
  Column() {
   List({ space: 20 }) {
    ForEach(this.arr, (index: number) => {
     ListItem() {
      Text(index.toString())
       .height('4.5%')
       .fontSize(16)
       .textAlign(TextAlign.Center)
       .backgroundColor(0xFFFFFF)
     }
     .border({ width: 2, color: Color.Green })
    }, (index: number) => index.toString());
   }
   .height("95%")
   .width("95%")
   .border({ width: 3, color: Color.Red })
   .lanes({ minLength: 40, maxLength: 40 })
   .alignListItem(ListItemAlign.Start)
   .scrollBar(BarState.Off)

  }.width('100%').height('100%').padding({ top: 5 });
 }
}

@Entry
@Preview
@Component
struct SecondPage {
 private dataSrc: MyDataSource = new MyDataSource([]);

 aboutToAppear(): void {
  let list = []
  for (let i = 1; i <= 100; i++) {
   list.push(i);
  }
  this.dataSrc = new MyDataSource(list);
 }

 build() {
  Column({ space: 5 }) {
   Swiper() {
    LazyForEach(this.dataSrc, (_: number) => { // 使用懒加载机制
     ChildPage();
    }, (item: number) => item.toString());
   }
   .loop(false)
   .cachedCount(1) // 提前加载后一项的内容
   .indicator(true)
   .duration(100)
   .curve(Curve.Linear)

  }.width('100%')
  .margin({ top: 5 })
 }
}
```

## 优化结果

如图所示，跳转页面加载时间从1.46s降低至19ms。

![img](imagesrofiler_result.jpg)
