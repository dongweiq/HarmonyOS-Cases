/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// 动态import的页面，用于加载商品列表页。

@Component
export struct DynamicsImportView {
  // 动态import是否成功，使用@State修饰，可以在值更改后及时刷新页面。
  @State isDynamicsImportSucceed: boolean = false;
  // 使用@BuilderParam装饰变量dynamicsImportPage，指向一个@Builder方法，用于构造页面。
  @BuilderParam dynamicsImportPage: ESObject = this.initComponentMethod;

  // @Builder方法，用于初始化@BuilderParam变量。
  @Builder
  initComponentMethod() {
  }

  aboutToAppear(): void {
    // TODO: 知识点：使用动态import的方式引入商品列表页面，页面显示时加载，页面不显示时不会被加载。
    import('@ohos/dynamicsimport').then((dynamicsImportResult: ESObject) => {
      // 动态import成功后，将创建View的接口赋值给变量dynamicsImportPage。
      this.dynamicsImportPage = dynamicsImportResult.createDynamicsImportView;
      // 动态import成功后，修改状态值，用于刷新页面
      this.isDynamicsImportSucceed = true;
    });
  }

  build() {
    Column() {
      // 当动态import商品列表页面成功时，显示商品列表页面
      if (this.isDynamicsImportSucceed) {
        this.dynamicsImportPage();
      }
    }
  }
}