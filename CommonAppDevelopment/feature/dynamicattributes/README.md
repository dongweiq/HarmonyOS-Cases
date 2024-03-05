# 跨文件样式复用和组件复用

### 介绍

本示例主要介绍了跨文件样式复用和组件复用的场景。在应用开发中，我们通常需要使用相同功能和样式的ArkUI组件，例如购物页面中会使用相同样式的Button按钮、Text显示文字，我们常用的方法是抽取公共样式或者封装成一个自定义组件到公共组件库中以减少冗余代码。

### 效果图预览

<img src="../../product/entry/src/main/resources/base/media/dynamic_attributes.gif" width="200"> 

**使用说明**：

1. 点击购物车页面的list列表跳转商品详情页。
2. 两个页面的button组件、text组件、row组件复用相同的样式。
3. 两个页面都使用了自定义封装了的底部bar（Row和button的复合组件）。

### 实现思路

#### 一、跨文件样式复用

   适用场景：当需要向外提供单一组件的样式定制效果时，推荐使用这种方案。使用方在调用接口时，编码量相对方式二更少，仅需几行即可完成调用，使用便捷。

1. 自定义class实现AttributeModifier接口，export导出。

   ```javascript
   // attributeModifier.ets
   
   /*
       自定义class实现Text的AttributeModifier接口
   */
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
         instance.width($r('app.string.max_size'));
       } else if (this.textType === TextType.TYPE_TWO) {
         instance.fontSize(this.textSize);
         instance.fontWeight(FontWeight.Bold);
         instance.fontColor($r('sys.color.ohos_id_counter_title_font_color'));
         instance.width($r('app.string.max_size'));
       } else if (this.textType === TextType.TYPE_Three) {
         instance.fontColor(Color.Gray);
         instance.fontSize(this.textSize);
         instance.fontWeight(FontWeight.Normal);
         instance.width($r('app.string.max_size'));
       } else if (this.textType === TextType.TYPE_FOUR) {
         instance.fontSize(this.textSize);
         instance.fontColor($r('app.color.orange'));
         instance.textAlign(TextAlign.Center);
         instance.border({ width: 1, color: $r('app.color.orange'), radius: 0, style: BorderStyle.Solid });
         instance.margin({ right: $r('app.float.float_10') });
       }
     }
   }
   
   /*
     枚举文本类型
   */
   export enum TextType {
     TYPE_ONE,
     TYPE_TWO,
     TYPE_Three,
     TYPE_FOUR
   }
   
   ```

2. import自定义的AttributeModifier类到ets页面，实例化赋值给变量。

   ```javascript
   // ShoppingCart.ets
   import { MyTextModifier } from '../common/attributeModifier';
   
   @Entry
   @Component
     struct PageOne {
     // 实例化AttributeModifie类
     @State textOne: MyTextModifier = new MyTextModifier(TextType.TYPE_ONE, 15); 
   }
   
   // Details.ets
   import { MyTextModifier } from '../common/attributeModifier';
   
   @Entry
   @Component
     struct PageOne {
     // 实例化AttributeModifie类
     @State textOne: MyTextModifier = new MyTextModifier(TextType.TYPE_ONE, 30);
     ...    
   }
   ```

3. 组件设置attributeModifier属性，调用AttributeModifier类中定义的样式。

   ```javascript
   // ShoppingCart.ets
   Button($r('app.string.settlement'))
   	// 动态设置组件样式
    Text($r('app.string.store_name'))
   	.attributeModifier(this.textOne)
   	.fontColor($r('sys.color.ohos_id_counter_title_font_color'))
   
   // Details.ets
     Text($r('app.string.commodity_price'))
   	// 动态设置组件样式
   	.attributeModifier(this.textOne)
   	.width($r('app.float.float_100'))
   ```

#### 二、跨文件组件复用

​	适用场景：适用于多个原生组件结合的场景，如Image+Text等复合自定义组件。

1. 自定义class实现AttributeModifier接口，export导出。

   ```javascript
   // attributeModifier.ets
   
   /*
      自定义class实现button的AttributeModifier接口
   */
   export class MyButtonModifier implements AttributeModifier<ButtonAttribute> {
     applyNormalAttribute(instance: ButtonAttribute): void {
       instance.height($r('app.float.float_30'));
       instance.width($r('app.float.float_90'));
       instance.linearGradient({
         angle: LINEAR_ANGLE,
         colors: [[$r('app.color.buttonColor'), 0.5], [$r('app.color.orange'), 1.0]]
       });
     }
   }
   
   /*
      自定义class实现row组件的AttributeModifier接口
   */
   export class MyRowModifier implements AttributeModifier<RowAttribute> {
     applyNormalAttribute(instance: RowAttribute): void {
       instance.height($r('app.float.float_60'));
       instance.width($r('app.string.max_size'));
       instance.padding($r('app.float.float_15'));
       instance.backgroundColor($r('app.color.white'));
       instance.justifyContent(FlexAlign.End);
       instance.border({
         width: { top: $r('app.float.float_1') },
         color: { top: $r('sys.color.ohos_id_color_component_normal') },
       });
     }
   }
   ```

2. import自定义的AttributeModifier类到自定义组件页面，实例化赋值给变量。

   ```javascript
   import { MyRowModifier, MyButtonModifier } from '../common/AttributeModifier';
   
   // 自定义公共组件
   @Component
   export struct BottomRow {
     @State buttonModifie: MyButtonModifier = new MyButtonModifier();
     @State rowModifie: MyRowModifier = new MyRowModifier();
     @State buttonName: Resource = $r('app.string.settlement')
     @State barType: BarType = BarType.SHOPPING_CART
   
     build() {
       Row() {
         if(this.barType===BarType.DETAILS){
           Button($r('app.string.add_cart'))
             .attributeModifier(this.buttonModifie)
             .margin({right:$r('app.float.float_10')})
         }
         Button(this.buttonName)
           .attributeModifier(this.buttonModifie)
       }
       .attributeModifier(this.rowModifie)
     }
   }
   
   /*
     枚举底部bar类型
   */
   export enum BarType {
     SHOPPING_CART, // 购物车
     DETAILS,       // 详情页
   }
   ```

3. 页面引用自定义组件后，实例化使用。

   ```javascript
   // ShoppingCart.ets
   
   import { BottomRow } from '../common/CommonText';
   
   build() {
   	...
         BottomRow({buttonName:$r('app.string.settlement')})
   	...
   }
   
   // Details.ets
   
   import { CommonText,BarType } from '../common/CommonText';
   
   build() {
   	...
         BottomRow({ buttonName: $r('app.string.buy_now'), barType: BarType.DETAILS })
   	...
   }
   ```

   



### 高性能知识点

本示例使用了动态属性设置，实现了跨文件样式复用，减少了工程很多冗余的代码。

### 工程结构&模块类型

   ```
   |---common
   |   |---AttributeModifier.ets                        // 自定义AttributeModifier接口
   |   |---CommonText.ets                        		// 自定义组件封装
   |   |---LazyForEach.ets                              // 懒加载
   |---pages
   |   |---ShoppingCart.ets                             // 页面一：购物车
   |   |---Details.ets                					// 页面二：详情页
   ```

### 模块依赖

本示例依赖[路由管理模块](../../feature/routermodule)。

### 参考资料

[动态属性设置]([动态属性设置-通用属性-组件通用信息-基于ArkTS的声明式开发范式-ArkTS组件-ArkUI API参考-开发 | 华为开发者联盟 (huawei.com)](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-universal-attributes-attribute-modifier-0000001774280870#ZH-CN_TOPIC_0000001774280870__attributemodifier))