import { CardData } from '../../model/CardData'
@Component
export struct MyCard {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @Prop cardData: CardData;
  onCardReadyExpand?: Function;
  onBack?: Function;
  onAnimationFinish?: ()=> void;
  @Prop @Watch('onExpandCardIdChange') expandCardId?: number = -1;
  @State isCardExpand:boolean = false;

  onExpandCardIdChange() {
    animateTo({duration:200, onFinish: this.onAnimationFinish}, ()=>{
      this.isCardExpand = this.expandCardId == this.cardData.id
    })
  }

  @Builder
  TopBar() {
    if (this.isCardExpand) {
      Row() {
        Column(){
          Image($r('app.media.left'))
            .width('100%')
        }
        .width(20)
        .clip(true)
        .margin({left: 10})
        .onClick(()=>{
          if (this.onBack) {
            this.onBack();
          }
        })
        Column() {
          Image(this.cardData.avatorSrc)
            .width('100%')
        }
        .margin({left: 10})
        .width(26)
        .clip(true)
        Text(this.cardData.authorName)
          .padding({left: 10})
      }
      .margin({
        top: 0,
        bottom: 10
      })
      .height(40)
      .alignSelf(ItemAlign.Start)
    }
  }

  @Builder
  ContentImage() {
    Image(this.cardData.imageSrc)
      .width('100%')
      .onComplete(() => {
        if (this.onCardReadyExpand) {
          this.onCardReadyExpand();
        }
      })
  }

  @Builder
  Title() {
    Text(this.cardData.title).textAlign(TextAlign.Start)
      .margin({
        left: 10,
        top: 10,
        bottom: 10
      })
  }

  @Builder
  BottomContent() {
    Column() {
      if (!this.isCardExpand) {
        Row() {
          Row() {
            Image(this.cardData.avatorSrc)
          }
          .width(26)
          .height(26)
          .clip(true)
          Text(this.cardData.authorName)
            .align(Alignment.Start)
            .fontColor(Color.Grey)
            .fontSize(12)
            .lineHeight(26)
            .padding({ left: 8 })
        }
        .margin({
          left: 10,
          top: 0,
          bottom: 10
        })
      }
      else {
        Column(){
          Text(this.cardData.content)
            .textAlign(TextAlign.Start)
        }
        .padding({left:7, right:7})
        .width('100%')
        Button('父页面（点击进入子页面）')
          .onClick(() => {
            this.pageInfos.pushPath({name: 'NewNavPage'}, true)
          })
          .width("60%")
          .margin({top:10, bottom: 40})
      }
    }
  }

  build() {
    List() {
      this.TopBar();
      this.ContentImage();
      this.Title();
      this.BottomContent();
    }
    .scrollBar(BarState.Off)
    .backgroundColor(Color.White)
    .clip(true)
  }
}