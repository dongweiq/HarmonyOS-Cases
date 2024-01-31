# HarmonyOS NEXT应用开发案例集

## 概述

随着应用代码的复杂度提升，为了使应用有更好的可维护性和可扩展性，良好的应用架构设计变得尤为重要。本篇文章将介绍一个应用通用架构的设计思路，以减少模块间的耦合、提升团队开发效率，为开发者呈现一个清晰且结构化的开发框架。
本文以“应用通用开发范例App”为例，从分层架构设计和模块化设计的方面介绍应用的架构组成。

**分层架构设计**：将应用划分为产品定制层、基础特性层和公共能力层，可以降低层间的依赖性，从而提升代码的可维护性。应用通用开发范例App分层架构如下：

   ```
   common_app_development
   |---AppScope
   |---common    // 公共能力层，包括公共UI组件、数据管理、通信和工具库等
   |---feature   // 基础特性层，包含独立的业务模块，如启动页、登录模块、导航栏等
   |---libs      // 三方依赖库
   |---product   // 产品定制层，作为不同设备或场景应用入口，例如phone、tv等
   ```

**模块化设计**：应用被分解为多个功能模块，其中每个模块负责执行特定的功能。通过模块化设计提高了代码的可理解性和可复用性，使应用的扩展和维护变得更为简便，同时降低了系统各部分之间的耦合度。应用通用开发范例App模块化结构如下：

   ```
   common_app_development
   |---AppScope
   |---common    
   |   |---utils         
   |   |   |---log                    // 公共能力层-日志打印
   |---feature
   |   |---addressexchange            // 基础特性层-地址交换动画方案
   |   |---barchart                   // 基础特性层-MpChart图表实现案例
   |   |---customtabbar               // 基础特性层-自定义TabBar页签 
   |   |---eventpropagation           // 基础特性层-阻塞事件冒泡方案   
   |   |---functionalscenes           // 基础特性层-主页瀑布流实现 
   |   |---imageviewer                // 基础特性层-图片预览方案
   |   |---nativerawfile              // 基础特性层-Native读取Rawfile中文件部分内容
   |   |---pendingitems               // 基础特性层-列表编辑实现方案 
   |   |---secondarylinkage           // 基础特性层-二级联动实现方案   
   |   |---launchscenes               // 基础特性层-应用广告页实现方案 
   |   |---gbktranscoding             // 基础特性层-Axios获取GBK数据转换UTF-8方案
   |   |---handletabs                 // 基础特性层-Tab组件实现增删Tab标签方案方案
   |   |---modalwindow                // 基础特性层-全屏登录页面方案
   |   |---slidetohideanddisplace     // 基础特性层-滑动页面信息隐藏与组件位移效果方案
   |   |---akiusepractice             // 基础特性层-AKI使用实践
   |   |---variablewatch              // 基础特性层-多层嵌套类对象监听
   |---libs
   |---product 
   |   |---entry                      // 产品定制层-应用入口
   ```

## 工程框架和实现设计

### 产品定制层

产品定制层专注于满足不同设备或使用场景（如应用/元服务）的个性化需求，包括UI设计、资源和配置，以及针对特定场景的交互逻辑和功能特性。

产品定制层的功能模块独立运作，同时依赖基础特性层和公共能力层来实现具体功能。

可参考如下示例：

[**phone产品应用入口**](./CommonAppDevelopment/product/entry/src/main/ets/pages/EntryView.ets)

### 基础特性层

基础特性层位于公共能力层之上，用于存放基础特性集合，例如相对独立的功能UI和业务逻辑实现。该层的每个功能模块都具有高内聚、低耦合、可定制的特点，以支持产品的灵活部署。

基础特性层为上层的产品定制层提供稳健且丰富的基础功能支持，包括UI组件、基础服务等。同时依赖于下层的公共能力层为其提供通用功能和服务。

首页[以Navigation组件为基础，实现了主要页面或模块的路由管理和跳转](./CommonAppDevelopment/product/entry/README.md)。

#### 主页瀑布流实现案例

本示例使用WaterFlow+LazyForeEach实现了瀑布流场景。具体方案可以参考[详细说明文档](./CommonAppDevelopment/feature/functionalscenes/README.md)。

<img src="./CommonAppDevelopment/screenshots/device/FunctionalScenes.gif" width="200">

#### 全屏登录页面案例

本例介绍各种应用登录页面。在主页面点击跳转到全屏登录页后，显示全屏模态页面，全屏模态页面从下方滑出并覆盖整个屏幕，模态页面内容自定义，此处分为默认一键登录方式和其他登录方式。[详细说明文档](./CommonAppDevelopment/feature/modalwindow/README.md)。

<img src="./CommonAppDevelopment/product/entry/src/main/resources/base/media/modal_window.gif" width="200">

#### 滑动页面信息隐藏与组件位移效果案例

在很多应用中，向上滑动"我的"页面，页面顶部会有如下变化效果：一部分信息逐渐隐藏，另一部分信息逐渐显示，同时一些组件会进行缩放或者位置移动。向下滑动时则相反。[详细说明文档](./CommonAppDevelopment/feature/slidetohideanddisplace/README.md)。

<img src="./CommonAppDevelopment/product/entry/src/main/resources/base/media/slide_to_hide_and_displace.gif" width="200">

#### 地址交换动画案例

在出行类订票软件中，一般都有此动画效果，点击交换后，起点和终点互换。地址交换动画的方案可以参考此[详细说明文档](./CommonAppDevelopment/feature/addressexchange/README.md)。

<img src="./CommonAppDevelopment/screenshots/device/AddressExchange.gif" width="200">

#### 阻塞事件冒泡案例

事件冒泡是指触发子组件事件的时候，事件会传递到父组件，这样会导致父组件的事件也会触发。阻塞事件冒泡的方案可以参考此[详细说明文档](./CommonAppDevelopment/feature/eventpropagation/README.md)。

<img src="./CommonAppDevelopment/screenshots/device/EventPropagation.gif" width="200">

#### 自定义TabBar页签案例

TabBar在大部分的APP当中都能够使用到，不同的APP可能存在不一样的TabBar样式，Tab组件自带的TabBar属性对于部分效果无法满足，如页签中间显示一圈圆弧外轮廓等，
因此我们需要去自己定义一个TabBar页签来满足开发的需要。自定义TabBar页签的方案可以参考此[详细说明文档](./CommonAppDevelopment/feature/customtabbar/README.md)。

<img src="./CommonAppDevelopment/screenshots/device/CustomTabBar.gif" width="200">

#### 二级联动实现案例

二级联动是指一个列表（一级列表）的选择结果，来更新另一个列表（二级列表）的选项。二级联动的方案可以参考此[详细说明文档](./CommonAppDevelopment/feature/secondarylinkage/README.md)。

<img src="./CommonAppDevelopment/screenshots/device/SecondaryLinkage.gif" width="200">

#### 列表编辑实现案例

列表的编辑模式用途十分广泛，常见于待办事项管理、文件管理、备忘录的记录管理等应用场景。列表编辑实现方案可以参考此[详细说明文档](./CommonAppDevelopment/feature/pendingitems/README_zh.md)。

<img src="./CommonAppDevelopment/screenshots/device/TodoList.gif" width="200">

#### MpChart图表实现案例

MpChart是一个包含各种类型图表的图表库，方便开发者快速实现图表UI。使用MpChart可以实现柱状图UI效果，具体方案可以参考此[详细说明文档](./CommonAppDevelopment/feature/barchart/README.md)。

<img src="./CommonAppDevelopment/screenshots/device/BarChart.gif" width="200">

#### 读取Rawfile中文件部分内容案例

使用native从rawfile中文件读取部分内容。具体方案可以参考此[详细说明文档](./CommonAppDevelopment/feature/nativerawfile/README.md)。

<img src="./CommonAppDevelopment/screenshots/device/raw_file.gif" width="200">

#### 图片缩放效果实现案例

本模块基于Image组件实现了简单的图片预览功能，支持双指捏合等效果。图片预览方案可参考此[详细说明文档](./CommonAppDevelopment/feature/imageviewer/README.md)。

<img src="./CommonAppDevelopment/screenshots/device/ImageViewer.gif" width="200">

#### 应用广告页实现案例

在大部分应用软件中，都需要开屏展示广告内容，用户任意时刻可点击跳转查看广告详情，或点击跳过进入首页。应用广告页实现方案可以参考此[详细说明文档](./CommonAppDevelopment/feature/launchscenes/README.md)。

#### Axios获取解析网络数据案例

本示例介绍使用第三方库的Axios获取GBK格式的网络数据时，通过util实现GBK转换UTF-8格式。该场景多用于需要转换编码格式的应用。[详细说明文档](./CommonAppDevelopment/feature/gbktranscoding/README.md)。

<img src="./CommonAppDevelopment/screenshots/device/FriendsBook.jpeg" width="200">

#### Tab组件实现增删Tab标签方案案例

本示例介绍使用了Tab组件实现自定义增删Tab页签的功能。该场景多用于浏览器等场景。[详细说明文档](./CommonAppDevelopment/feature/handletabs/README_zh.md)。

<img src="./CommonAppDevelopment/screenshots/device/HandleTabs.gif" width="200">

#### AKI使用案例

AKI提供了极简语法糖使用方式，一行代码完成JS与C/C++的无障碍跨语言互调，使用方便。本模块将介绍使用AKI编写C++跨线程调用JS函数场景，为开发者使用AKI提供参考。AKI使用实践可参考此[详细说明文档](./CommonAppDevelopment/feature/akiusepractice/README.md)。

<img src="./CommonAppDevelopment/screenshots/device/AkiUsePractice.gif" width="200">

对于多层嵌套的情况，比如二维数组，或者数组项class，或者class的属性是class，他们的第二层的属性变化是无法观察到的。@Observed/@ObjectLink装饰器可以解决，
多层嵌套类对象监听方案可以参考[详细说明文档](./CommonAppDevelopment/feature/variablewatch/README.md)。

<img src="./CommonAppDevelopment/screenshots/device/VariableWatch.gif" width="200">

### 公共能力层

公共功能层用于存放公共基础能力，集中了例如公共UI组件、数据管理、外部交互以及工具库等的共享功能。应用与元服务都可以共享和调用这些公共能力。

公共能力层为上层的基础特性层和产品定制层提供稳定可靠的功能支持，确保整个应用/元服务的稳定性和可维护性。

应用通用开发范例App公共能力层包含一下模块：[**日志打印**](./CommonAppDevelopment/common/utils/src/main/ets/Logger.ets)

## 配套平台

1. 适用最新HarmonyOS Next版本；

2. 适用Stage模型，SDK版本为API11；

3. 适用最新DevEco Studio版本。

