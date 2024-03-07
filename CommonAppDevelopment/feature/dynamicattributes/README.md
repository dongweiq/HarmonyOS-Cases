# 跨文件样式复用和组件复用

### 介绍

本示例主要介绍了跨文件样式复用和组件复用的场景。在应用开发中，我们通常需要使用相同功能和样式的ArkUI组件，例如购物页面中会使用相同样式的Button按钮、Text显示文字，我们常用的方法是抽取公共样式或者封装成一个自定义组件到公共组件库中以减少冗余代码。

### 效果图预览

<img src="../../product/entry/src/main/resources/base/media/dynamic_attributes.gif" width="200"> 

**使用说明**：

1. 点击购物车页面的list列表跳转商品详情页。
2. 两个页面的button组件、text组件、Image等组件复用相同的样式。
3. 购物车页面使用了自定义封装的Image+Text的图文复合组件。

### 实现思路

#### 一、跨文件样式复用

   适用场景：当需要向外提供单一组件的样式定制效果时，推荐使用这种方案。使用方在调用接口时，编码量相对方式二更少，仅需几行即可完成调用，使用便捷。

1. 提供者自定义class实现AttributeModifier接口，export导出。

   ```javascript
   // attributeModifier.ets
   
   /*
       自定义class实现Text的AttributeModifier接口
   */
   export class CommodityText implements AttributeModifier<TextAttribute> {
     textContent: string | Resource = ''
     textType: TextType = TextType.TYPE_ONE;
     textSize: number = 15;
   
     constructor(textContent: string | Resource, textType: TextType, textSize: number) {
       this.textContent = textContent;
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
         instance.border({ width: $r('app.float.float_1'), color: $r('app.color.orange'), style: BorderStyle.Solid });
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

2. 使用者import自定义的AttributeModifier类到ets页面，实例化赋值给变量。

   ```javascript
   // CommonText.ets
   import { CommodityText } from '../common/attributeModifier';
   
   @Component
     struct ImageText {
     // 自定义组件实例化AttributeModifie类，向外暴露Text的Modifier属性
     @State textOne: CommodityText = new CommodityText('', TextType.TYPE_ONE, 0);
   }
   
   // Details.ets
   import { MyTextModifier } from '../common/attributeModifier';
   
   @Component
     struct Details {
     // 实例化AttributeModifie类
     @State textOne: MyTextModifier = new MyTextModifier(TextType.TYPE_ONE, 30);
     ...    
   }
   ```

3. 使用者给组件设置attributeModifier属性，调用AttributeModifier类中定义的样式。

   ```javascript
   // CommonText.ets
   
    Text(this.textOne.textContent)
   	// 动态设置组件样式
   	.attributeModifier(this.textOne)
   	.fontColor($r('app.color.orange'))
   
   // Details.ets
    Text($r('app.string.commodity_price'))
   	// 动态设置组件样式
   	.attributeModifier(this.textOne)
   	.width($r('app.float.float_100'))
   ```

#### 二、跨文件组件复用

​	适用场景：适用于多个原生组件结合的场景，如Image+Text等复合自定义组件。

1. 提供者自定义封装组件，export导出。

   ```javascript
   // CommonTextr.ets
   
   /**
    * 自定义封装图文组件
    */
   @Component
   export struct ImageText {
     @Prop item: string
     @State textOne: CommodityText = new CommodityText('', TextType.TYPE_ONE, 0);
     @State textTwo: CommodityText = new CommodityText('', TextType.TYPE_TWO, 0);
     @State textThree: CommodityText = new CommodityText('', TextType.TYPE_Three, 0);
     @State imageModifier: ImageModifier = new ImageModifier(0,0,$r('app.media.icon'));
     @State checkboxModifier: CheckboxModifier = new CheckboxModifier();
   
     build() {
       Row() {
         Row() {
           Checkbox()
             .attributeModifier(this.checkboxModifier)
   
          Image(this.imageModifier.src)
            .attributeModifier(this.imageModifier)
   
         }
         .margin({ right: $r('app.float.float_10'), bottom: $r('app.float.float_15') })
   
         Column({ space: COLUMN_SPACE }) {
           // TODO：高性能知识点：动态设置组件的属性
           Text(this.item)
             .attributeModifier(this.textTwo)
   
           Text(this.textThree.textContent)
             .attributeModifier(this.textThree)
   
           CommonText({ textFour: new CommodityText('', TextType.TYPE_FOUR, TEXT_SIZE) })
   
           Text(this.textOne.textContent)
             .attributeModifier(this.textOne)
             .fontColor($r('app.color.orange'))
         }
       }
       .padding({ top: $r('app.float.float_5') })
       .width($r('app.string.max_size'))
       .height($r('app.string.max_size'))
     }
   }
   ```

2. 提供者实现Image和text的Modifier类，实现宽、高等属性的设置。

   ```javascript
   // AttributeModifier.ets
   import { MyRowModifier, MyButtonModifier } from '../common/AttributeModifier';
   
   /*
      自定义class实现Image组件的AttributeModifier接口
   */
   export class ImageModifier implements AttributeModifier<ImageAttribute> {
     width: Length | Resource = 0;
     height: Length | Resource = 0;
     src: PixelMap | Resource = $r('app.media.icon');
   
     constructor(width: Length | Resource, height: Length | Resource, src: PixelMap | Resource) {
       this.width = width;
       this.height = height;
       this.src = src;
     }
   
     applyNormalAttribute(instance: ImageAttribute): void {
       instance.width(this.width);
       instance.height(this.height);
       instance.borderRadius($r('app.float.float_10'));
     }
   }
   
   /*
   	自定义class实现Text的AttributeModifier接口
   */
   export class CommodityText implements AttributeModifier<TextAttribute> {
     textContent: string | Resource = ''
     textType: TextType = TextType.TYPE_ONE;
     textSize: number = 15;
   
     constructor(textContent: string | Resource, textType: TextType, textSize: number) {
       this.textContent = textContent;
       this.textType = textType;
       this.textSize = textSize;
     }
   
     applyNormalAttribute(instance: TextAttribute): void {
       ...
     }
   }
   ```

3. 使用者在页面import自定义组件后，初始化Image和Text的Modifier对象，然后作为参数传入自定义组件中。

   ```javascript
   // ShoppingCart.ets
   
   import { ImageText } from '../common/CommonText';
   import { CommodityText, ImageModifier } from '../common/AttributeModifier';
   
   @Component
   export struct ShoppingCart {
     // TODO：知识点：初始化自定义的样式类
   	@State textOne: CommodityText = new CommodityText($r('app.string.commodity_price'), TextType.TYPE_ONE, 15);
   	@State textTwo: CommodityText = new CommodityText($r('app.string.commodity_name'), TextType.TYPE_TWO, 17);
   	@State textThree: CommodityText = new CommodityText($r('app.string.commodity_model'), TextType.TYPE_Three, 15);
   	@State imageModifier: ImageModifier = new ImageModifier(100, 100,$r('app.media.icon'));
   	build() {
     		...
   		ImageText({
                     item: item,
                     textOne: this.textOne,
                     textTwo: this.textTwo,
                     textThree: this.textThree,
                     imageModifier: this.imageModifier
                   })
   		...
   	}
   }
   ```

### 高性能知识点

本示例使用了动态属性设置和自定义封装公共组件，实现了跨文件样式和组件复用，减少了工程很多冗余的代码。

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