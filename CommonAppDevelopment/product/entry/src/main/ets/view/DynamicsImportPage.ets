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

/**
 * 实现步骤：
 * 1.通过动态import的方式，加载商品列表页面。
 * 2.在动态import成功后，修改状态变量，更新页面。
 */

const DYNAMICS_IMPORT_SUCCEED: string = "动态import商品列表页成功";

@Component
export struct DynamicsImportPage {
  // 动态import是否成功，使用@State修饰，可以在值更改后及时刷新页面。
  @State isDynamicsImportSucceed: boolean = false;
  // 使用@BuilderParam装饰变量dynamicsImportPage，指向一个@Builder方法，用于构造页面。
  @BuilderParam dynamicsImportPage: ESObject = this.initComponentMethod;

  // @Builder方法，用于初始化@BuilderParam变量。
  @Builder
  initComponentMethod() {
  }

  aboutToAppear(): void {
    // TODO: 知识点：1.使用动态import的方式引入商品列表页面，页面显示时加载，页面不显示时不会被加载；可以减少主页面的启动时间和初始化效率，以及内存的占用。
    import('@ohos/dynamicsimport').then((dynamicsImportResult: ESObject) => {
      // 动态import成功后，将创建View的接口赋值给变量dynamicsImportPage。
      this.dynamicsImportPage = dynamicsImportResult.createDynamicsImportView;
      // 动态import成功后，修改状态值，用于刷新页面
      this.isDynamicsImportSucceed = true;
      // TODO：知识点：2.间接动态import的使用方法（product/entry动态加载feature/dynamicsimport中的loggerInfo接口，feature/dynamicsimport中的loggerInfo接口动态加载common/utils中的Logger.info()接口实现打印日志的功能）。
      dynamicsImportResult.loggerInfo(DYNAMICS_IMPORT_SUCCEED);
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