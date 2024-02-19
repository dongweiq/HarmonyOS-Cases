import { ListData } from '../model/ListData'

// TODO: 后续修改为单独页面进行搜索，增加列表list，点击listItem可以跳转到相应页面
@Component
export struct SearchComponent {
  @Link listData: ListData[];
  // 存储初始数据用户搜索筛选
  @StorageLink('listData') searchListData: ListData[] | undefined = AppStorage.get('listData')

  searchFunc(value: string) {
    let newListData: ListData[] = [];
    if (this.searchListData !== undefined) {
      for (let i = 0; i < this.searchListData.length; i++) {
        // 通过includes对输入的字符进行查询
        if (this.searchListData[i].name.toLowerCase().includes(value.toLowerCase())) {
          newListData.push(this.searchListData[i])
        }
      }
    }
    this.listData = newListData
  }

  build() {
    // 顶部搜索框
    Column() {
      Column() {
        Search({ placeholder: $r('app.string.search_placeholder') })
          .backgroundColor('#E7E9E8')
          .width('100%')
          .onChange((value: string) => {
            this.searchFunc(value)
          })
      }
      .backgroundColor('#E7E9E8')
      .borderRadius($r('app.string.main_page_top_borderRadius'))
    }
    .padding({ left: $r('app.string.main_page_padding'), right: $r('app.string.main_page_padding') })
  }
}
