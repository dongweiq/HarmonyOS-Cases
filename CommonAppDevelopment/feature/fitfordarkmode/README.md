# 深色模式适配

### 介绍

本示例介绍在开发应用以适应深色模式时，对于深色和浅色模式的适配方案，采取了多种策略如下：
1. **固定属性适配**：对于部分组件的颜色属性，如背景色或字体颜色，若保持不变，可直接设定固定色值或引用固定的资源文件。
2. **双资源目录适配**：在resources目录下新增dark子目录，用于存放深色模式下的特定颜色配置（color.json文件）和图片资源（media文件）。在深色模式下，系统会自动加载此目录中的颜色及图片资源，确保与浅色模式下的UI元素色彩差异性。
3. **利用系统分层参数**：对于支持深浅模式切换的系统层级颜色资源，我们可以直接引用这些具有分层特性的参数，使得当切换设备主题时，相关组件的颜色能根据系统当前颜色模式自动更新。
4. **监听当前颜色模式变化**：通过注册AbilityStage.onConfigurationUpdate事件监听器，实时捕捉到设备深浅颜色模式的变化，并据此动态调整UI布局结构或逻辑处理，以适应不同模式下的最佳视觉体验。

### 效果图预览

![](../../product/entry/src/main/resources/base/media/fit_for_dark_mode.gif)

**使用说明**

1. 在应用主页点击“深色模式”案例，将应用切至后台，系统颜色模式发生改变（如在系统设置中切换深浅色模式），当应用重新被激活至前台时，能够立即检测到系统颜色模式的变化，并自动更新为对应颜色主题的视图界面。

### 实现思路

1. 当UI组件的颜色属性被设置为固定颜色值时，其在深色模式和浅色模式下的显示颜色将保持不变。
```javascript
// 将Text直接设置成'#000000'固定色值
Text("精品好礼")
 .opacity(0.6)
 .fontColor($r('app.color.black_font_color'))
 .margin({ left: $r('app.integer.text_margin_left') })
```
2. 为了实现深色模式下的颜色适配，可以在resources目录下新建'dark/element'的子目录，并在此目录中创建color.json文件。为深色模式下的各个UI组件指定相应的颜色值，务必确保与浅色模式下同名颜色资源名称一致，以确保系统能够正确识别并切换。
```javascript
// 用资源ID方式设置Column背景色。（浅色模式色值为'#FA5A3C'、深色模式色值为'#000000'）
.backgroundColor($r('app.color.column_bg_color'))
```
3. 若UI组件的颜色属性引用的是系统提供的具有层级参数的颜色资源，则当设备在深色模式和浅色模式间切换时，这些颜色会自动调整至对应模式下的预设色值。
```javascript   
// 用系统提供的分层参数颜色资源方式设置色值 
Text(item.price)
 .fontSize($r('app.integer.goods_font'))
 .offset({ x: -3 })// 因为￥是中文字符，上面的是中文字符，占的宽度不一样，所以需要对齐，添加offset
 .fontColor($r('sys.color.ohos_id_color_foreground'))
```
4. 对于PNG、WEBP或JPEG格式的图片资源，若需支持深色模式，应在resources目录下新增一个'dark/media'子目录，将深色模式下对应的图片放入此目录，并确保图片文件名与浅色模式下的图片相同，以便系统根据当前模式加载合适的图片资源。
```javascript   
// SVG格式图片fillColor颜色资源ID方式设置（浅色模式色值为'#000000'、深色模式色值为'#FFFFFF'）
Image($r('app.media.view'))
 .fillColor($r('app.color.view_fill_color'))
 .width($r('app.integer.view_image_width'))
 .aspectRatio(1)
 .objectFit(ImageFit.Contain)
```
5. 在存在深浅两种模式下布局结构或逻辑处理有所差异的情况时，开发者应当利用AbilityStage.onConfigurationUpdate监听接口来实时感知系统主题的变化，并据此做出相应的布局调整或逻辑处理，从而确保应用能够在不同模式下呈现出理想的界面效果及功能体验。
 - 第一步保存全局参数，并通过onConfigurationUpdate刷新状态栏
```javascript   
// 获取当前的颜色模式并保存并在onConfigurationUpdate
AppStorage.setOrCreate('currentColorMode', this.context.config.colorMode);
// 保存windowStage供fitfordarkmode的har包中FitForDarkPage.ets中setStatusBar方法修改状态栏颜色。
AppStorage.setOrCreate('windowStage', windowStage);

// 检测当前的深浅模式是否发生变化，刷新状态栏
onConfigurationUpdate(config: Configuration) {
 // 获取最新的变更颜色并更新到AppStorage
 AppStorage.setOrCreate('currentColorMode', config.colorMode);
 logger.info(`onConfigurationUpdate, config: ${JSON.stringify(config)}`);
}
```
- 第二步在FitForDarKMode.ets中获取并监听当前颜色模式
```javascript   
// @StorageProp + @Watch 获取并监听当前颜色模式
@StorageProp('currentColorMode') @Watch('onColorModeChange') currentMode: number = 0;
// @Watch回调函数，监听颜色模式刷新状态变量
onColorModeChange(): void {
  if (this.currentMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
    this.banner = $r("app.media.dark_mode_banner");
  } else {
    this.banner = $r("app.media.light_mode_banner");
  }
}
```
- 第三步在FitForDarKMode.ets生命周期aboutToAppear中根据当前颜色模式刷新banner状态变量，切换不同的图片。
```javascript   
// 在自定义组件生命周期aboutToAppear中，根据当前颜色模式刷新banner状态变量，切换不同的图片。
aboutToAppear(): void {
  if (this.currentMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
    this.banner = $r("app.media.dark_mode_banner");
} else {
    this.banner = $r("app.media.light_mode_banner");
    // 在当前为浅色模式中，确保界面美观且颜色统一，设置导航栏的背景色。
    setStatusBar(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
  }
}
```
- 第四步在FitForDarKMode.ets生命周期aboutToDisappear中，重置导航栏的背景色避免影响其它页面的导航栏为红色。
```javascript   
// 在自定义组件生命周期aboutToDisappear中，重置导航栏的背景色避免影响其它页面的导航栏为红色。
aboutToDisappear(): void {
  setStatusBar(this.currentMode)
}
```
- 第五步在FitForDarKMode.ets生命周期aboutToDisappear中，重置导航栏的背景色避免影响其它页面的导航栏为红色。
```javascript  
// 调用setWindowSystemBarProperties()设置状态栏及导航栏的颜色
windowClass.setWindowSystemBarProperties(sysBarProps, (err) => {
  if (err.code) {
    logger.error('Failed to set the system bar properties. Cause: ' + JSON.stringify(err));
    return;
  }
  logger.info('Succeeded in setting the system bar properties.');
});
```

### 高性能知识点

不涉及

### 工程结构&模块类型

```
fitfordarkmode                                   // har类型
|---mock
|   |---GoodsMock.ets                            // 商品列表数据 
|---mode
|   |---GoodsModel.ets                           // 商品数据类型定义 
|---view
|   |---FitForDarkMode.ets                       // 深色模式适配主页面 
|   |---GoodsList.ets                            // 商品列表自定义组件 
```

### 模块依赖

本实例依赖common模块来实现[资源](../../common/utils/src/main/resources/base/element)的调用以及[公共组件FunctionDescription](../../common/utils/src/main/ets/component/FunctionDescription.ets)的引用。 还需要依赖[EntryAbility.ets模块](../../product/entry/src/main/ets/entryability/EntryAbility.ets)。

### 参考资料

[设置深色模式](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V2/web-set-dark-mode-0000001630145893-V2)

[@ohos.app.ability.ConfigurationConstant (ConfigurationConstant)](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V2/js-apis-app-ability-configurationconstant-0000001580185482-V2)
