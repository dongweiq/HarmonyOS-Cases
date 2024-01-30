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
import { SelectPictures } from '@bundle:com.north.commonappdevelopment/picturemanager/ets/components/SelectPictures';
import { SaveNetWorkPictures } from '@bundle:com.north.commonappdevelopment/picturemanager/ets/components/SaveNetWorkPictures';
export class PictureManage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.setInitiallyProvidedValue(params);
    }
    setInitiallyProvidedValue(params) {
    }
    updateStateVars(params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
    }
    aboutToBeDeleted() {
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("feature/picturemanager/src/main/ets/components/PictureManage.ets(23:5)");
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("feature/picturemanager/src/main/ets/components/PictureManage.ets(24:7)");
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("feature/picturemanager/src/main/ets/components/PictureManage.ets(25:9)");
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create("选择图片预览");
            Text.debugLine("feature/picturemanager/src/main/ets/components/PictureManage.ets(26:11)");
            Text.fontSize(20);
            Text.fontWeight(500);
        }, Text);
        Text.pop();
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let paramsLambda = () => {
                        return {};
                    };
                    ViewPU.create(new SelectPictures(this, {}, undefined, elmtId, paramsLambda, { page: "feature/picturemanager/src/main/ets/components/PictureManage.ets", line: 29 }));
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {});
                }
            }, { name: "SelectPictures" });
        }
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Divider.create();
            Divider.debugLine("feature/picturemanager/src/main/ets/components/PictureManage.ets(31:11)");
            Divider.margin({ top: 15, bottom: 15 });
        }, Divider);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create("下载图片");
            Text.debugLine("feature/picturemanager/src/main/ets/components/PictureManage.ets(33:11)");
            Text.fontSize(20);
            Text.fontWeight(500);
        }, Text);
        Text.pop();
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let paramsLambda = () => {
                        return {};
                    };
                    ViewPU.create(new SaveNetWorkPictures(this, {}, undefined, elmtId, paramsLambda, { page: "feature/picturemanager/src/main/ets/components/PictureManage.ets", line: 36 }));
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {});
                }
            }, { name: "SaveNetWorkPictures" });
        }
        Column.pop();
        Row.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName() {
        return "PictureManage";
    }
}
registerNamedRoute(() => new PictureManage(undefined, {}), "", { bundleName: "com.north.commonappdevelopment", moduleName: "picturemanager", pagePath: "components/PictureManage" });
//# sourceMappingURL=PictureManage.js.map