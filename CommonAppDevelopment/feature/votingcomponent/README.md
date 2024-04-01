# 投票动效实现案例

### 介绍

本示例介绍使用绘制组件中的Polygon组件配合使用显式动画以及borderRadius实现投票pk组件。

### 效果预览图

![](../../product/entry/src/main/resources/base/media/voting_component.gif)

**使用说明**
1. 加载完成后会有一个胶囊块被切割成两个等大的图形来作为投票的两个选项，中间由PK两字分隔开
2. 点击左边选项，两个图形会随着选择人数的比例同步变化，且有变化的动画效果，PK两字消失，图形间间隙变小，选项颜色变淡，
分别在两个图形上显示选择对应选项的人数比例，下方提示文字也会同步改成已选择的选项，且显示总参与投票人数

### 实现思路
1. 使用Column绘制胶囊块图形，为实现胶囊块的切割效果以及投票后的比例变换，这里使用两个Colum分别绘制两个半个胶囊块拼接而成。源码参考[VotingComponent.ets](src/main/ets/view/VotingComponent.ets)。

```typescript
// 使用Column绘制出胶囊块
Column()
  // 设置左上和左下两个角为圆角
  .borderRadius(
    {
      topLeft: $r("app.integer.fillet_radius"),
      bottomLeft: $r("app.integer.fillet_radius"),
      topRight: $r("app.integer.right_angle_radius"),
      bottomRight: $r("app.integer.right_angle_radius")
    }
  )
  .backgroundColor(Constants.LEFT_COLOR)
  .opacity(this.fillOpacity) // 动态变化透明度
  .width(this.leftOptionWidth) // 选项宽度
  .height($r("app.integer.option_background_height"))
```

2. 使用绘制组件中的Polygon实现胶囊块中间被分割的效果。中间的间隙有两个状态：1、未投票时是个宽度比较大的平行四边形，且有PK两字；2、投票后是个宽度很窄的平行四边形，且PK两字消失。源码参考[VotingComponent.ets](src/main/ets/view/VotingComponent.ets)。

```typescript
  // TODO：知识点3：使用绘制组件Polygon投票组件中间的平行四边形空隙效果
  Polygon()
    .points(this.points)
    .fill(Color.White)
    .stroke(Color.White)
    .antiAlias(true)
    .width($r("app.integer.polygon_width"))
    .height($r("app.integer.polygon_height"))
  // 点击前，空隙宽度稍微大一些，且其中有PK两字
  if (!this.isClick) {
    Text() {
      Span($r("app.string.mid_text_left"))
        .fontColor(Constants.LEFT_COLOR)
      Span($r("app.string.mid_text_right"))
        .fontColor(Constants.RIGHT_COLOR)
    }
    .fontSize($r("app.integer.mid_text_font_size"))
    .fontStyle(FontStyle.Italic)
    .fontWeight(Constants.MID_TEXT_FONT_WEIGHT)
    .textAlign(TextAlign.Center)
  }
}
// TODO：知识点4：因为Polygon是以一个矩形框为基准来绘制的，因此会受到这个矩形框的影响，使用position以及markAnchor来偏移，以抵消前述影响
.position({ x: this.leftOptionWidth })
.markAnchor({ x: $r("app.string.mid_gap_mark_anchor") })
```

3. 计算投票比例作为左右图形宽度，且定义动画效果。源码参考[VotingComponent.ets](src/main/ets/view/VotingComponent.ets)。

```typescript
  // 定义动画
  animateParam: AnimateParam = {
    duration: Constants.ANIMATE_DURATION,
    curve: Curve.EaseOut
  }

  /**
   * 投票后改变属性
   *
   * @param option 投了左边还是右边
   */
  changeState(option: string) {
    // 投票后将点击状态置为已点击，实现投票只能投一次的效果
    this.isClick = true;
    // 左下角文字提示投票已选择的选项
    this.notice = '已选择"' + option + '"';
    // 投票后设置透明度，实现颜色变浅的效果
    this.fillOpacity = Constants.END_FILL_OPACITY;
    // 根据投票人数来计算选项两边的比例
    const leftOptionPercent: number = this.leftOptionChoose / (this.leftOptionChoose + this.rightOptionChoose) * Constants.PERCENTAGE;
    // TODO：知识点1：使用显式动画，只有在宽度变化时生效
    animateTo(this.animateParam, () => {
      this.leftOptionWidth = leftOptionPercent.toFixed(0) + '%';
      this.rightOptionWidth = (Constants.PERCENTAGE - leftOptionPercent).toFixed(0) + '%';
      this.points = Constants.END_POINTS;
    });
  }
```
### 高性能知识点

**不涉及**

### 工程结构&模块类型

   ```
   votingcomponent                                        // har类型
   |---constants
   |   |---Constants.ets                                 // 常量类
   |---view
   |   |---VotingComponent.ets                            // 视图层-投票组件页面 
   ```

### 模块依赖

本场景依赖了路由模块来[注册路由](../routermodule/src/main/ets/router/DynamicsRouter.ets)。

### 参考资料

[Polygon](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-drawing-components-polygon-0000001774280982)

[animationTo](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-explicit-animation-0000001774121350)

[borderRadius](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-universal-attributes-border-0000001774280846#ZH-CN_TOPIC_0000001774280846__borderradius)
