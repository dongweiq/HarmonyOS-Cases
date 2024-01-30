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
import http from '@ohos:net.http';
import ResponseCode from '@ohos:net.http';
import image from '@ohos:multimedia.image';
import abilityAccessCtrl from '@ohos:abilityAccessCtrl';
import photoAccessHelper from '@ohos:file.photoAccessHelper';
import fs from '@ohos:file.fs';
import promptAction from '@ohos:promptAction';
import picker from '@ohos:file.picker';
const PERMISSIONS = [
    'ohos.permission.READ_MEDIA',
    'ohos.permission.WRITE_MEDIA'
];
export class SaveNetWorkPictures extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__image = new ObservedPropertyObjectPU(undefined, this, "image");
        this.__photoAccessHelper = new ObservedPropertyObjectPU(undefined, this, "photoAccessHelper");
        this.__imageBuffer = new ObservedPropertyObjectPU(undefined, this, "imageBuffer");
        this.__isShow = new ObservedPropertySimplePU(false, this, "isShow");
        this.setInitiallyProvidedValue(params);
    }
    setInitiallyProvidedValue(params) {
        if (params.image !== undefined) {
            this.image = params.image;
        }
        if (params.photoAccessHelper !== undefined) {
            this.photoAccessHelper = params.photoAccessHelper;
        }
        if (params.imageBuffer !== undefined) {
            this.imageBuffer = params.imageBuffer;
        }
        if (params.isShow !== undefined) {
            this.isShow = params.isShow;
        }
    }
    updateStateVars(params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__image.purgeDependencyOnElmtId(rmElmtId);
        this.__photoAccessHelper.purgeDependencyOnElmtId(rmElmtId);
        this.__imageBuffer.purgeDependencyOnElmtId(rmElmtId);
        this.__isShow.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__image.aboutToBeDeleted();
        this.__photoAccessHelper.aboutToBeDeleted();
        this.__imageBuffer.aboutToBeDeleted();
        this.__isShow.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    get image() {
        return this.__image.get();
    }
    set image(newValue) {
        this.__image.set(newValue);
    }
    get photoAccessHelper() {
        return this.__photoAccessHelper.get();
    }
    set photoAccessHelper(newValue) {
        this.__photoAccessHelper.set(newValue);
    }
    get imageBuffer() {
        return this.__imageBuffer.get();
    }
    set imageBuffer(newValue) {
        this.__imageBuffer.set(newValue);
    }
    get isShow() {
        return this.__isShow.get();
    }
    set isShow(newValue) {
        this.__isShow.set(newValue);
    }
    /**
     * 通过http的request方法从网络下载图片资源
     */
    async getPicture() {
        http.createHttp()
            .request('https://gitee.com/openharmony/applications_app_samples/raw/master/code/Solutions/Shopping/OrangeShopping/feature/navigationHome/src/main/resources/base/media/product002.png', (error, data) => {
            if (error) {
                // 下载失败时弹窗提示检查网络，不执行后续逻辑
                promptAction.showToast({
                    message: { "id": 218103813, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" },
                    duration: 2000
                });
                return;
            }
            this.transcodePixelMap(data);
            // 判断网络获取到的资源是否为ArrayBuffer类型
            if (data.result instanceof ArrayBuffer) {
                this.imageBuffer = data.result;
            }
        });
    }
    /**
     * 使用createPixelMap将ArrayBuffer类型的图片装换为PixelMap类型
     * @param data：网络获取到的资源
     */
    transcodePixelMap(data) {
        if (ResponseCode.ResponseCode.OK === data.responseCode) {
            let imageData = data.result;
            // 通过ArrayBuffer创建图片源实例。
            let imageSource = image.createImageSource(imageData);
            class tmp {
                constructor() {
                    this.height = 100;
                    this.width = 100;
                }
            }
            ;
            let options = {
                'alphaType': 0,
                'editable': false,
                'pixelFormat': 3,
                'scaleMode': 1,
                'size': { height: 100, width: 100 }
            }; // 创建图片大小
            // 通过属性创建PixelMap
            imageSource.createPixelMap(options).then((pixelMap) => {
                this.image = pixelMap;
                this.isShow = true;
            });
        }
    }
    /**
     * 保存ArrayBuffer到图库
     * @param buffer：图片ArrayBuffer
     * @returns
     */
    async saveImage(buffer) {
        let context = getContext(this); // 获取getPhotoAccessHelper需要的context
        let helper = photoAccessHelper.getPhotoAccessHelper(context); // 获取相册管理模块的实例
        let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg'); // 指定待创建的文件类型、后缀和创建选项，创建图片或视频资源
        let file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        await fs.write(file.fd, buffer);
        await fs.close(file.fd);
    }
    /**
     * 保存ArrayBuffer到用户选择的路径
     * @param buffer：图片ArrayBuffer
     * @returns
     */
    async pickerSave(buffer) {
        const photoSaveOptions = new picker.PhotoSaveOptions(); // 创建文件管理器保存选项实例
        photoSaveOptions.newFileNames = ['PhotoViewPicker ' + new Date().getTime() + '.jpg']; // 保存文件名（可选）
        const photoViewPicker = new picker.PhotoViewPicker;
        photoViewPicker.save(photoSaveOptions)
            .then(async (photoSvaeResult) => {
            console.info('PhotoViewPicker.save successfully,photoSvaeResult uri:' + JSON.stringify(photoSvaeResult));
            let uri = photoSvaeResult[0];
            let file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
            await fs.write(file.fd, buffer);
            await fs.close(file.fd);
            promptAction.showToast({
                message: { "id": 218103814, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" },
                duration: 2000
            });
        });
    }
    async aboutToAppear() {
        let context = getContext(this);
        let atManager = abilityAccessCtrl.createAtManager();
        await atManager.requestPermissionsFromUser(context, PERMISSIONS);
        this.getPicture();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("feature/picturemanager/src/main/ets/components/SaveNetWorkPictures.ets(140:5)");
            Column.width('100%');
            Column.height('50%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("feature/picturemanager/src/main/ets/components/SaveNetWorkPictures.ets(141:7)");
            Column.backgroundColor({ "id": 218103869, "type": 10001, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" });
            Column.borderRadius({ "id": 218103837, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" });
            Column.padding({ "id": 218103836, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" });
            Column.margin({ "id": 218103835, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create({ "id": 218103821, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" });
            Text.debugLine("feature/picturemanager/src/main/ets/components/SaveNetWorkPictures.ets(142:9)");
            Text.fontSize({ "id": 218103843, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" });
            Text.fontWeight(FontWeight.Medium);
            Text.margin({ bottom: { "id": 218103839, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" } });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create({ "id": 218103812, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" });
            Text.debugLine("feature/picturemanager/src/main/ets/components/SaveNetWorkPictures.ets(146:9)");
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Image.create(this.image);
            Image.debugLine("feature/picturemanager/src/main/ets/components/SaveNetWorkPictures.ets(153:7)");
            Image.objectFit(ImageFit.Contain);
            Image.width('50%');
            Image.height('50%');
        }, Image);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.isShow) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        SaveButton.create();
                        SaveButton.debugLine("feature/picturemanager/src/main/ets/components/SaveNetWorkPictures.ets(158:9)");
                        SaveButton.onClick(async () => {
                            if (this.imageBuffer !== undefined) {
                                await this.saveImage(ObservedObject.GetRawObject(this.imageBuffer));
                                promptAction.showToast({
                                    message: { "id": 218103814, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" },
                                    duration: 2000
                                });
                            }
                        });
                    }, SaveButton);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel({ "id": 218103818, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" });
                        Button.debugLine("feature/picturemanager/src/main/ets/components/SaveNetWorkPictures.ets(168:9)");
                        Button.margin({ top: { "id": 218103839, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" } });
                        Button.onClick(async () => {
                            if (this.imageBuffer !== undefined) {
                                this.pickerSave(ObservedObject.GetRawObject(this.imageBuffer));
                            }
                        });
                    }, Button);
                    Button.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
//# sourceMappingURL=SaveNetWorkPictures.js.map