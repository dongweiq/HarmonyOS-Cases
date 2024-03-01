# 跨文件样式复用和组件复用

### 介绍

本示例主要介绍了跨文件样式复用和组件复用的场景。在应用开发中，我们通常需要使用相同功能和样式的ArkUI组件，例如登录页面和购物页面中会使用相同样式的Button按钮、Text显示文字，我们常用的方法是抽取公共样式或者封装成一个自定义组件到公共组件库中以减少冗余代码。

### 效果图预览

<img src="../../product/entry/src/main/resources/base/media/dynamic_attributes.gif" width="200"> 

**使用说明**：

1. 点击页面一的list列表跳转页面二。
2. 两个页面的button组件和text组件复用相同的样式。
3. 两个页面都使用了封装了多个text组件的复合自定义组件（效果图中文本一、文本二、文本三）。

### 实现思路

#### 一、跨文件样式复用

   适用场景：当需要向外提供单一组件的样式定制效果时，推荐使用这种方案。使用方在调用接口时，编码亮相对方式二更少，仅需几行即可完成调用，使用便捷。

1. 自定义class实现AttributeModifier接口，export导出。

   ```javascript
   // attributeModifier.ets
   export class MyButtonModifier implements AttributeModifier<ButtonAttribute> {
     applyNormalAttribute(instance: ButtonAttribute): void {
       instance.height(30)
       instance.width(90)
       instance.linearGradient({
         angle: 90,
         colors: [['#EE7600', 0.5], ['#FF4500', 1.0]]
       })
     }
   }
   ```

2. import自定义的AttributeModifier类到ets页面，实例化赋值给我一个变量

   ```javascript
   // ShoppingCart.ets
   import { MyButtonModifier, MyTextModifier } from '../common/attributeModifier';
   
   @Entry
   @Component
     struct PageOne {
     // 实例化AttributeModifie类
     @State buttonModifie: MyButtonModifier = new MyButtonModifier();
     ...    
   }
   
   // Details.ets
   @Entry
   @Component
     struct PageOne {
     // 实例化AttributeModifie类
     @State buttonModifie: MyButtonModifier = new MyButtonModifier();
     ...    
   }
   ```

3. 组件设置attributeModifier属性，调用AttributeModifier类中定义的样式。

   ```javascript
   // ShoppingCart.ets
   Button($r('app.string.settlement'))
     // 引用组件样式
     .attributeModifier(this.buttonModifie) 
   
   // Details.ets
    Row() {
     Button($r('app.string.add_cart'))
       .attributeModifier(this.buttonModifie)
       .margin({ right: $r('app.float.float_10') })
     Button($r('app.string.buy_now'))
       .attributeModifier(this.buttonModifie)
    }
   ```

#### 二、跨文件组件复用

适用场景：适用于多个原生组件结合的场景，如Image+Text等复合自定义组件。

1.自定义class实现AttributeModifier接口，export导出。

```javascript
// attributeModifier.ets
export class MyTextModifier implements AttributeModifier<TextAttribute> {
  textType: TextType = TextType.TYPE_ONE;
  textSize: number = 15;

  constructor(textType: TextType, textSize: number) {
    this.textType = textType;
    this.textSize = textSize;
  }

  applyNormalAttribute(instance: TextAttribute): void {
    if (this.textType === TextType.TYPE_ONE) {
      instance.fontSize(this.textSize);
      instance.fontColor($r('app.color.orange'));
      instance.fontWeight(FontWeight.Bolder);
      instance.width('100%')
    } else if (this.textType === TextType.TYPE_TWO) {
      instance.fontSize(this.textSize);
      instance.fontWeight(FontWeight.Bold);
      instance.fontColor($r('sys.color.ohos_id_counter_title_font_color'));
      instance.width('100%');
    } else if (this.textType === TextType.TYPE_Three) {
      instance.fontColor(Color.Gray);
      instance.fontSize(this.textSize);
      instance.fontWeight(FontWeight.Normal);
      instance.width('100%');
    } else if (this.textType === TextType.TYPE_FOUR) {
      instance.fontSize(this.textSize);
      instance.fontColor($r('app.color.orange'));
      instance.textAlign(TextAlign.Center)
      instance.border({ width: 1, color: $r('app.color.orange'), radius: 0, style: BorderStyle.Solid });
      instance.margin({ right: $r('app.float.float_10')});
    }
  }
}

//枚举文本类型
export enum TextType {
  TYPE_ONE,
  TYPE_TWO,
  TYPE_Three,
  TYPE_FOUR
}
```

2.import自定义的AttributeModifier类到自定义组件页面，实例化赋值给我一个变量

```javascript
import { MyTextModifier } from '../common/AttributeModifier';

@Component
export struct CommonText {
  @State textFour: MyTextModifier | null = null;

  build() {
    Row() {
      Text($r('app.string.text_one'))
        .attributeModifier(this.textFour)

      Text($r('app.string.text_two'))
        .attributeModifier(this.textFour)

      Text($r('app.string.text_three'))
        .attributeModifier(this.textFour)
    }
    .width($r('app.string.max_size'))
  }
}
```

### 高性能知识点

本示例使用了动态属性设置，实现了跨文件样式复用，减少了工程很多冗余的代码。

### 工程结构&模块类型

   ```
   |---common
   |   |---attributeModifier.ets                        // 动态数据设置
   |   |---LazyForEach.ets                              // 懒加载
   |---pages
   |   |---ShoppingCart.ets                             // 页面一：购物车
   |   |---Details.ets                					// 页面二：详情页
   ```

### 模块依赖

本示例依赖[路由管理模块](../../feature/routermodule)。

### 参考资料

[动态属性设置]([动态属性设置-通用属性-组件通用信息-基于ArkTS的声明式开发范式-ArkTS组件-ArkUI API参考-开发 | 华为开发者联盟 (huawei.com)](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-universal-attributes-attribute-modifier-0000001774280870#ZH-CN_TOPIC_0000001774280870__attributemodifier))