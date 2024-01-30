import picker from '@ohos:file.picker';
export class SelectPictures extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__uris = new ObservedPropertyObjectPU([], this, "uris");
        this.setInitiallyProvidedValue(params);
    }
    setInitiallyProvidedValue(params) {
        if (params.uris !== undefined) {
            this.uris = params.uris;
        }
    }
    updateStateVars(params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__uris.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__uris.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    get uris() {
        return this.__uris.get();
    }
    set uris(newValue) {
        this.__uris.set(newValue);
    }
    // 接口采用promise异步返回形式，传入可选参数DocumentSelectOptions对象，返回选择文件的uri数组。
    async getFileAssetsFromType() {
        const photoSelectOptions = new picker.PhotoSelectOptions(); // 创建图片-音频类型文件-预览的图库选项实例
        // 选择媒体文件类型和选择媒体文件的最大数目
        photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE; // 选择媒体文件类型为Image
        photoSelectOptions.maxSelectNumber = 5; // 选择媒体文件的最大数目
        // TODO：知识点：创建图库选择器实例，调用photoViewPicker.select()接口拉起图库界面进行文件选择，文件选择成功后，返回photoSelectResult结果集。
        const photoViewPicker = new picker.PhotoViewPicker();
        photoViewPicker.select(photoSelectOptions)
            .then((photoSelectResult) => {
            this.uris = photoSelectResult.photoUris;
        })
            .catch((err) => {
            console.log('Invoke photoViewPicker.select failed, code is ${err.code},message is ${err.message}');
        });
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("feature/picturemanager/src/main/ets/components/SelectPictures.ets(48:5)");
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("feature/picturemanager/src/main/ets/components/SelectPictures.ets(49:7)");
            Column.backgroundColor({ "id": 218103869, "type": 10001, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" });
            Column.borderRadius({ "id": 218103837, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" });
            Column.padding({ "id": 218103836, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" });
            Column.margin({ "id": 218103835, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create({ "id": 218103810, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" });
            Text.debugLine("feature/picturemanager/src/main/ets/components/SelectPictures.ets(50:9)");
            Text.fontSize({ "id": 218103843, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" });
            Text.fontWeight(FontWeight.Medium);
            Text.margin({ bottom: { "id": 218103839, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" } });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create({ "id": 218103822, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" });
            Text.debugLine("feature/picturemanager/src/main/ets/components/SelectPictures.ets(54:9)");
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel({ "id": 218103810, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" });
            Button.debugLine("feature/picturemanager/src/main/ets/components/SelectPictures.ets(61:7)");
            Button.fontSize({ "id": 218103843, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" });
            Button.fontWeight(FontWeight.Medium);
            Button.onClick(() => {
                // TODO：知识点：通过调用getFileAssetsFromType()中的photoViewPicker.select()拉起图库界面进行图片选择。
                this.getFileAssetsFromType();
            });
            Button.width('30%');
            Button.margin({ "id": 218103835, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "picturemanager" });
        }, Button);
        Button.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
//# sourceMappingURL=SelectPictures.js.map