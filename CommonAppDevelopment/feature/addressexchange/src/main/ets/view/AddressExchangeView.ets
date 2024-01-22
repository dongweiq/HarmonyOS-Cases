import curves from '@ohos.curves';

@Component
export struct AddressExchangeView {
  // 旋转角度
  @State rotateAngle: number = 0;
  // 偏移量
  @State translateX: number = 0;
  // 是否已切换
  @State swap: boolean = false;
  rowWidth: number = 300
  distance: number = this.rowWidth * 0.6
  columnSpace: number = 40
  zeroTranslate: number = 0
  rotateAddAngle: number = 180
  contentBackgroundColor: Color = 0x888888

  build() {
    Column({ space: this.columnSpace }) {
      Text($r('app.string.address_exchange_title'))
        .margin({ top: $r('app.integer.address_exchange_title_top_space') })

      Text($r('app.string.address_exchange_detail'))

      Row() {
        Text($r('app.string.address_exchange_address_left'))
          .translate({ x: this.translateX })
          .width($r('app.string.address_exchange_address_width'))
          .fontSize($r('app.integer.address_exchange_address_font_size'))
          .textAlign(this.swap ? TextAlign.End : TextAlign.Start)

        Stack() {
          Image($r('app.media.address_exchange_airplane'))
            .size({
              height: $r('app.integer.address_exchange_airplane_size'),
              width: $r('app.integer.address_exchange_airplane_size')
            })
          Image($r('app.media.address_exchange_recycle'))
            .size({
              height: $r('app.integer.address_exchange_recycle_size'),
              width: $r('app.integer.address_exchange_recycle_size')
            })
            .rotate({ angle: this.rotateAngle })
            .animation({
              curve: Curve.EaseOut,
              playMode: PlayMode.Normal,
            })
        }
        .width($r('app.string.address_exchange_image_width'))
        .onClick(() => {
          this.swap = !this.swap
          // TODO 知识点：动画效果，修改偏移量，修改旋转角度，实现效果
          animateTo({ curve: curves.springMotion() }, () => {
            if (this.swap) {
              this.translateX = this.distance
            } else {
              this.translateX = this.zeroTranslate
            }
          })
          this.rotateAngle += this.rotateAddAngle
        })

        Text($r('app.string.address_exchange_address_right'))
          .translate({ x: -this.translateX })
          .width($r('app.string.address_exchange_address_width'))
          .fontSize($r('app.integer.address_exchange_address_font_size'))
          .textAlign(this.swap ? TextAlign.Start : TextAlign.End)
      }
      .width(this.rowWidth)
      .justifyContent(FlexAlign.SpaceBetween)
      .height($r('app.integer.address_exchange_content_height'))
      .backgroundColor(this.contentBackgroundColor)
    }
    .justifyContent(FlexAlign.Start)
    .width($r('app.string.full_size'))
    .height($r('app.string.full_size'))
  }
}