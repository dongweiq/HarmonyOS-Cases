# 使用绘制组件实现自定义进度动画

### 介绍

本示例介绍使用绘制组件中的Circle组件以及Path组件实现实时进度效果。该场景多用于手机电池电量、汽车油量、水位变化等动态变化中。

### 效果预览图

![](../../product/entry/src/main/resources/base/media/paint_component.gif)

**使用说明**
1. 加载完成后初始显示进度为0%，颜色为红色，且有充电、放电两个按钮。
2. 点击充电按钮，进度会持续增长，直到100%时绿色填充满整个圆形，当到达20%以上和80%以上时，颜色动态变化。
3. 点击耗电按钮，进度会持续下降，直到0%恢复1中的初始效果，当到达20%以下和80%以下时，颜色动态变化。

### 实现思路
1. 使用Circle组件绘制外层的圆环。 源码参考[PaintComponent.ets](src/main/ets/view/PaintComponent.ets)。

```typescript
  // 外框圆环
  Circle({ width: Constants.BIG_DIAMETER, height: Constants.BIG_DIAMETER })
    .fill(Constants.COLOR_TRANSPARENT)
    .stroke(this.colorBackgroundFill)
    .strokeWidth($r("app.integer.outer_circle_stroke_width"))
```

2. 绘制中间的进度的填充。中间的填充有两个状态：1、在进度100%时是填充颜色的圆形；2、在进度不足100%时，使用Path组件绘制闭合曲线实现。源码参考[PaintComponent.ets](src/main/ets/view/PaintComponent.ets)。

```typescript
  // 进度展示
  Circle({ width: Constants.DIAMETER, height: Constants.DIAMETER })
    .fill(this.bgColor)

  // TODO:知识点:使用Path组件绘制封闭曲线，实现水位线效果
  Path()
    .width(Constants.DIAMETER)
    .height(Constants.DIAMETER)
    .commands(this.pathCommands)
    .fill(this.colorBackgroundFill)
    .antiAlias(true)
    .stroke(this.colorBackgroundFill)
    .strokeWidth($r("app.integer.path_stroke_width"))
```

3. 计算封闭曲线。水位线的端点的纵坐标y与进度k的关系为：y=(1-k)*2r，而圆心坐标为(r,r)，以此确定水位线的坐标，然后拼接成绘制封闭曲线的commands。源码参考[PaintComponent.ets](src/main/ets/view/PaintComponent.ets)。

```typescript
  /**
   * 根据进度拿到水位线的端点的纵坐标
   *
   * @param progressPercent 进度百分比
   * @returns 水位线的端点的纵坐标
   */
  getOrdinate(progressPercent: number): number {
    return (Constants.UNIT_ONE - progressPercent) * (Constants.RADIUS_IN_PX + Constants.RADIUS_IN_PX);
  }

  /**
   * 根据圆心，以及纵坐标拿到水位线两个端点的距离的平方
   *
   * @param ordinate 纵坐标
   * @returns 端点间距离的平方
   */
  getDistanceSquare(ordinate: number): number {
    return Constants.RADIUS_IN_PX * Constants.RADIUS_IN_PX - (ordinate - Constants.RADIUS_IN_PX) * (ordinate - Constants.RADIUS_IN_PX);
  }

  /**
   * 计算闭合曲线
   *
   * @param progressNum 进度
   * @returns 绘制闭合曲线的commands
   */
  getPathCommands(progressNum: number): string {
    // 拿到水位线的端点的纵坐标
    const ordinate: number = this.getOrdinate(progressNum / Constants.PERCENT_RATE);
    // 拿到端点之间的距离的平方
    const distanceSquare: number = this.getDistanceSquare(ordinate);
    if (distanceSquare >= Constants.ZERO) {
      // 开平方得到端点间的距离
      const distance: number = Math.sqrt(distanceSquare);
      // 计算得出第一个端点的横坐标
      const firstAbscissa: number = Constants.RADIUS_IN_PX - distance;
      // 计算得到第二个端点的横坐标
      const secondAbscissa: number = Constants.RADIUS_IN_PX + distance;
      return this.formatPathCommands(firstAbscissa, secondAbscissa, ordinate, Constants.RADIUS_IN_PX);
    }
    return "";
  }

  /**
   * 拼接绘制闭合曲线的commands
   *
   * @param firstAbscissa
   * @param secondAbscissa
   * @param ordinate
   * @param radius
   * @returns
   */
  formatPathCommands(firstAbscissa: number, secondAbscissa: number, ordinate: number, radius: number): string {
    return `M${firstAbscissa} ${ordinate} A${radius} ${radius} 0 ${ordinate > Constants.RADIUS_IN_PX ? 0 : 1} 0 ${secondAbscissa} ${ordinate}`
      + `Q${(firstAbscissa + 3 * secondAbscissa) / 4} ${ordinate + 12.5 * (secondAbscissa - firstAbscissa) / radius}, ${(firstAbscissa + secondAbscissa) / 2} ${ordinate} T${firstAbscissa} ${ordinate}`;
  }
```

4. 绘制最上层的百分比显示。源码参考[PaintComponent.ets](src/main/ets/view/PaintComponent.ets)。

```typescript
  // 进度百分比
  Row() {
    Text($r("app.string.progress_percentage_symbol_name"))
      .fontColor(Constants.COLOR_NORMAL)
      .fontSize($r("app.integer.progress_percentage_symbol_font_size"))
    Text(this.progressNum.toFixed(Constants.ZERO) + Constants.PERCENTAGE_STR)
      .fontSize($r("app.integer.progress_percentage_font_size"))
```

### 高性能知识点

**不涉及**

### 工程结构&模块类型

   ```
   paintcomponent                                        // har类型
   |---components
   |   |---Constants.ets                                 // 常量类
   |---view
   |   |---PaintComponent.ets                            // 视图层-绘制组件页面 
   ```

### 模块依赖

本场景依赖了路由模块来[注册路由](../routermodule/src/main/ets/router/DynamicsRouter.ets)。

### 参考资料

[Circle组件](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V2/ts-drawing-components-circle-0000001427584896-V2)

[Path组件](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V2/ts-drawing-components-path-0000001477981225-V2)
