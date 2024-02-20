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
   |---common                          // 公共能力层
   |   |---utils  
   |   |   |---component               // 公共布局，如功能介绍布局
   |   |   |---log                     // 日志打印 
   |---feature                         // 基础特性层
   |   |---addressexchange             // 地址交换动画案例
   |   |---akiusepractice              // AKI使用实践
   |   |---applicationexception        // 应用异常处理案例
   |   |---barchart                    // MpChart图表实现案例
   |   |---customtabbar                // 自定义TabBar页签 案例
   |   |---eventpropagation            // 阻塞事件冒泡案例
   |   |---fitfordarkmode              // 深色模式适配案例
   |   |---functionalscenes            // 主页瀑布流实现 
   |   |---gbktranscoding              // Axios获取网络数据案例
   |   |---handletabs                  // Tab组件实现增删Tab标签案例
   |   |---imageviewer                 // 图片预览方案
   |   |---marquee                     // 跑马灯案例
   |   |---modalwindow                 // 全屏登录页面案例
   |   |---nativeprogressnotify        // Native侧进度通知到ArkTS
   |   |---nativerawfile               // Native读取Rawfile中文件部分内容
   |   |---navigationparametertransfer // Navigation页面跳转对象传递案例
   |   |---pageturninganimation        // 翻页动效案例
   |   |---pendingitems                // 列表编辑实现案例
   |   |---photopickandsave            // 图片选择和下载保存案例
   |   |---pulltorefreshnews           // 下拉刷新与上滑加载案例
   |   |---secondarylinkage            // 二级联动实现案例
   |   |---slidetohideanddisplace      // 滑动页面信息隐藏与组件位移效果案例
   |   |---variablewatch               // 多层嵌套类对象监听案例
   |   |---verifycode                  // 验证码布局
   |   |---vibrateeffect               // 基础特性层-抖动动画及手机振动效果
   |   |---customcalendarpickerdialog  // 基础特性层-自定义日历选择器
   |   |---navigationbarchange         // 基础特性层-状态栏显隐变化案例
   |   |---customview                  // 基础特性层-自定义视图实现Tab效果
   |   |---waterripples                // 基础特性层-听歌识曲水波纹特效案例
   |---libs
   |---product 
   |   |---entry                       // 产品定制层-应用入口
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

<img src="./CommonAppDevelopment/product/entry/src/main/resources/base/media/secondary_linkage.gif" width="200">

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

#### Axios获取解析网络数据案例

本示例介绍使用第三方库的Axios获取GBK格式的网络数据时，通过util实现GBK转换UTF-8格式。该场景多用于需要转换编码格式的应用。[详细说明文档](./CommonAppDevelopment/feature/gbktranscoding/README.md)。

<img src="./CommonAppDevelopment/screenshots/device/FriendsBook.jpeg" width="200">

#### Tab组件实现增删Tab标签方案案例

本示例介绍使用了Tab组件实现自定义增删Tab页签的功能。该场景多用于浏览器等场景。[详细说明文档](./CommonAppDevelopment/feature/handletabs/README.md)。

<img src="./CommonAppDevelopment/screenshots/device/HandleTabs.gif" width="200">

#### 使用AKI轻松实现跨语言调用

AKI提供了极简语法糖使用方式，一行代码完成JS与C/C++的无障碍跨语言互调，使用方便。本模块将介绍使用AKI编写C++跨线程调用JS函数场景，为开发者使用AKI提供参考。AKI使用实践可参考此[详细说明文档](./CommonAppDevelopment/feature/akiusepractice/README.md)。

<img src="./CommonAppDevelopment/screenshots/device/AkiUsePractice.gif" width="200">

#### 多层嵌套类监听案例

对于多层嵌套的情况，比如二维数组，或者数组项class，或者class的属性是class，他们的第二层的属性变化是无法观察到的。@Observed/@ObjectLink装饰器可以解决，
多层嵌套类对象监听方案可以参考[详细说明文档](./CommonAppDevelopment/feature/variablewatch/README.md)。

<img src="./CommonAppDevelopment/screenshots/device/VariableWatch.gif" width="200">

#### 图片选择和下载保存案例

本示例介绍图片相关场景的使用：包含访问手机相册图片、选择预览图片并显示选择的图片到当前页面，下载并保存网络图片到手机相册或到指定用户目录两个场景。[详细说明文档](./CommonAppDevelopment/feature/photopickandsave/README.md)。

<img src="./CommonAppDevelopment/product/entry/src/main/resources/base/media/photo_pick_and_save.gif" width="200">

#### 应用异常处理案例

本示例介绍了通过应用事件打点hiAppEvent获取上一次应用异常信息的方法，主要分为应用崩溃、应用卡死以及系统查杀三种。[详细说明文档](./CommonAppDevelopment/feature/applicationexception/README.md)。

<img src="./CommonAppDevelopment/product/entry/src/main/resources/base/media/application_exception.gif" width="200">

#### 深色模式案例

本示例介绍在开发应用以适应深色模式时，对于深色和浅色模式的适配方案，采取了多种策略。[详细说明文档](./CommonAppDevelopment/feature/fitfordarkmode/README.md)。

<img src="./CommonAppDevelopment/product/entry/src/main/resources/base/media/fit_for_dark_mode.gif" width="200">

#### 跑马灯案例

本示例介绍了文本宽度过宽时，如何实现文本首尾相接循环滚动并显示在可视区，以及每循环滚动一次之后会停滞一段时间后再滚动。[详细说明文档](./CommonAppDevelopment/feature/marquee/README.md)。

<img src="./CommonAppDevelopment/product/entry/src/main/resources/base/media/marquee.gif" width="200">

#### 下拉刷新上滑加载案例

本示例介绍使用第三方库的PullToRefresh组件实现列表的下拉刷新数据和上滑加载后续数据。[详细说明文档](./CommonAppDevelopment/feature/pulltorefreshnews/README.md)。

<img src="./CommonAppDevelopment/product/entry/src/main/resources/base/media/pull_to_refresh_news.gif" width="200">

#### 翻页动效案例

翻页动效是应用开发中常见的动效场景，常见的有书籍翻页，日历翻页等。本例将介绍如何通过ArkUI提供的显示动画接口animateTo实现翻页的效果。[详细说明文档](./CommonAppDevelopment/feature/pageturninganimation/README.md)。

<img src="./CommonAppDevelopment/product/entry/src/main/resources/base/media/page_turning_animation.gif" width="200">

#### 在Native侧实现进度通知功能

本示例通过模拟下载场景介绍如何将Native的进度信息实时同步到ArkTS侧。[详细说明文档](./CommonAppDevelopment/feature/nativeprogressnotify/README.md)。

<img src="./CommonAppDevelopment/product/entry/src/main/resources/base/media/native_progress_notify.gif" width="200">

#### 验证码布局

本示例介绍如何使用Text组件实现验证码场景，并禁用对内容的选中、复制、光标。[详细说明文档](./CommonAppDevelopment/feature/verifycode/README.md)。

<img src="./CommonAppDevelopment/product/entry/src/main/resources/base/media/verify_code.gif" width="200">

#### 使用弹簧曲线实现抖动动画及手机振动效果案例

抖动动画和手机振动效果是手机使用时常见的效果。抖动动画及手机振动效果案例可以参考[详细说明文档](./CommonAppDevelopment/feature/vibrateeffect/README.md)。

<img src="./CommonAppDevelopment/product/entry/src/main/resources/base/media/vibrate_effect.gif" width="200">

#### 自定义日历选择器

日历选择器是出行类应用常见模块。自定义日历选择器案例可以参考[详细说明文档](./CommonAppDevelopment/feature/customcalendarpickerdialog/README.md)。

<img src="./CommonAppDevelopment/product/entry/src/main/resources/base/media/custom_calendar_picker_dialog.gif" width="200">

#### 状态栏显隐变化案例

本示例介绍使用Scroll组件的滚动事件 **onScroll** 实现状态栏显隐变化。该场景多用于各种软件的首页、我的等页面中。状态栏显隐变化的方案可以参考此[详细说明文档](./CommonAppDevelopment/feature/navigationbarchange/README.md)。

<img src="./CommonAppDevelopment/product/entry/src/main/resources/base/media/navigation_bar_change.gif" width="200">

#### 自定义视图实现Tab效果

本示例介绍使用Text、List等组件，添加点击、动画等事件 **onClick** **animateTo** 自定义视图实现类似Tab效果。自定义视图实现Tab效果的方案可以参考此[详细说明文档](./CommonAppDevelopment/feature/customview/README.md)。

<img src="./CommonAppDevelopment/product/entry/src/main/resources/base/media/custom_view.gif" width="200">

#### 听歌识曲水波纹特效案例

本示例介绍水波纹的特效。该场景多用于各种软件的按钮。听歌识曲水波纹特效案例可以参考此[详细说明文档](./CommonAppDevelopment/feature/waterripples/README.md)。

<img src="./CommonAppDevelopment/product/entry/src/main/resources/base/media/water_ripples.gif" width="200">

### 公共能力层

公共功能层用于存放公共基础能力，集中了例如公共UI组件、数据管理、外部交互以及工具库等的共享功能。应用与元服务都可以共享和调用这些公共能力。

公共能力层为上层的基础特性层和产品定制层提供稳定可靠的功能支持，确保整个应用/元服务的稳定性和可维护性。

应用通用开发范例App公共能力层包含以下模块：[**日志打印**](./CommonAppDevelopment/common/utils/src/main/ets/log/Logger.ets)、[**功能介绍布局**](./CommonAppDevelopment/common/utils/src/main/ets/component/FunctionDescription.ets)

## 配套平台

1. 适用最新HarmonyOS Next版本；

2. 适用Stage模型，SDK版本为API11；

3. 适用最新DevEco Studio版本。

