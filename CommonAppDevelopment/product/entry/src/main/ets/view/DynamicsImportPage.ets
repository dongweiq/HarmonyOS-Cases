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
 * 1.在模块的主页面中添加createDynamicsImportView接口，使用@Builder装饰，实现模块中页面的调用。
 * 2.在模块根目录的Index.ets文件中，将createDynamicsImportView接口export。
 * 3.在entry的oh-package.json5中配置需要依赖的模块。
 * 4.在entry的build-profile.json5中添加动态import的模块名，和oh-package.json5中配置的依赖名相同。
 * 5.将需要动态加载的模块名传入当前组件，在aboutToAppear()接口中通过import()方法加载模块。
 * 6.模块加载成功后，通知页面刷新。
 */

@Component
export struct DynamicsImportPage {
  moduleName: string = '';
  // 动态import是否成功，使用@State修饰，可以在值更改后及时刷新页面。
  @State isDynamicsImportSucceed: boolean = false;
  // 使用@BuilderParam装饰变量dynamicsImportPage，指向一个@Builder方法，用于构造页面。
  @BuilderParam dynamicsImportPage: ESObject = this.initComponentMethod;

  // @Builder方法，用于初始化@BuilderParam变量。
  @Builder
  initComponentMethod(): void {
  }

  aboutToAppear(): void {
    // TODO：知识点：使用动态import的方式加载模块中的页面，只有当需要展示页面时才将模块写入内存，可以减少主页面启动时间、初始化效率以及初始内存的占用。
    import(this.moduleName).then((dynamicsImportResult: ESObject) => {
      // 动态import成功后，将创建View的接口赋值给变量dynamicsImportPage
      this.dynamicsImportPage = dynamicsImportResult.createDynamicsImportView;
      // 动态import成功后，修改状态值，用于刷新页面
      this.isDynamicsImportSucceed = true;
    });
  }

  build() {
    Column() {
      // 当动态import成功时，加载页面
      if (this.isDynamicsImportSucceed) {
        this.dynamicsImportPage();
      }
    }
  }
}