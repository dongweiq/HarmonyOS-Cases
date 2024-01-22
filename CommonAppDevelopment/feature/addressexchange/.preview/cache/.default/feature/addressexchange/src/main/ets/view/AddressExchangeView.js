import curves from '@native:ohos.curves';
export class AddressExchangeView extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined) {
        super(parent, __localStorage, elmtId);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__rotateAngle = new ObservedPropertySimplePU(0, this, "rotateAngle");
        this.__translateX = new ObservedPropertySimplePU(0, this, "translateX");
        this.__swap = new ObservedPropertySimplePU(false, this, "swap");
        this.rowWidth = 300;
        this.distance = this.rowWidth * 0.6;
        this.columnSpace = 40;
        this.zeroTranslate = 0;
        this.rotateAddAngle = 180;
        this.contentBackgroundColor = 0x888888;
        this.setInitiallyProvidedValue(params);
    }
    setInitiallyProvidedValue(params) {
        if (params.rotateAngle !== undefined) {
            this.rotateAngle = params.rotateAngle;
        }
        if (params.translateX !== undefined) {
            this.translateX = params.translateX;
        }
        if (params.swap !== undefined) {
            this.swap = params.swap;
        }
        if (params.rowWidth !== undefined) {
            this.rowWidth = params.rowWidth;
        }
        if (params.distance !== undefined) {
            this.distance = params.distance;
        }
        if (params.columnSpace !== undefined) {
            this.columnSpace = params.columnSpace;
        }
        if (params.zeroTranslate !== undefined) {
            this.zeroTranslate = params.zeroTranslate;
        }
        if (params.rotateAddAngle !== undefined) {
            this.rotateAddAngle = params.rotateAddAngle;
        }
        if (params.contentBackgroundColor !== undefined) {
            this.contentBackgroundColor = params.contentBackgroundColor;
        }
    }
    updateStateVars(params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__rotateAngle.purgeDependencyOnElmtId(rmElmtId);
        this.__translateX.purgeDependencyOnElmtId(rmElmtId);
        this.__swap.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__rotateAngle.aboutToBeDeleted();
        this.__translateX.aboutToBeDeleted();
        this.__swap.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    get rotateAngle() {
        return this.__rotateAngle.get();
    }
    set rotateAngle(newValue) {
        this.__rotateAngle.set(newValue);
    }
    get translateX() {
        return this.__translateX.get();
    }
    set translateX(newValue) {
        this.__translateX.set(newValue);
    }
    get swap() {
        return this.__swap.get();
    }
    set swap(newValue) {
        this.__swap.set(newValue);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: this.columnSpace });
            Column.debugLine("feature/addressexchange/src/main/ets/view/AddressExchangeView.ets(19:5)");
            Column.justifyContent(FlexAlign.Start);
            Column.width({ "id": 16777218, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "addressexchange" });
            Column.height({ "id": 16777218, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "addressexchange" });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create({ "id": 16777217, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "addressexchange" });
            Text.debugLine("feature/addressexchange/src/main/ets/view/AddressExchangeView.ets(20:7)");
            Text.margin({ top: { "id": 16777216, "type": 10007, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "addressexchange" } });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create({ "id": 16777230, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "addressexchange" });
            Text.debugLine("feature/addressexchange/src/main/ets/view/AddressExchangeView.ets(23:7)");
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("feature/addressexchange/src/main/ets/view/AddressExchangeView.ets(25:7)");
            Row.width(this.rowWidth);
            Row.justifyContent(FlexAlign.SpaceBetween);
            Row.height({ "id": 16777229, "type": 10007, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "addressexchange" });
            Row.backgroundColor(this.contentBackgroundColor);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create({ "id": 16777220, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "addressexchange" });
            Text.debugLine("feature/addressexchange/src/main/ets/view/AddressExchangeView.ets(26:9)");
            Text.translate({ x: this.translateX });
            Text.width({ "id": 16777223, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "addressexchange" });
            Text.fontSize({ "id": 16777224, "type": 10007, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "addressexchange" });
            Text.textAlign(this.swap ? TextAlign.End : TextAlign.Start);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create();
            Stack.debugLine("feature/addressexchange/src/main/ets/view/AddressExchangeView.ets(32:9)");
            Stack.width({ "id": 16777228, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "addressexchange" });
            Stack.onClick(() => {
                this.swap = !this.swap;
                // TODO 知识点：动画效果，修改偏移量，修改旋转角度，实现效果
                Context.animateTo({ curve: curves.springMotion() }, () => {
                    if (this.swap) {
                        this.translateX = this.distance;
                    }
                    else {
                        this.translateX = this.zeroTranslate;
                    }
                });
                this.rotateAngle += this.rotateAddAngle;
            });
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Image.create({ "id": 16777222, "type": 20000, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "addressexchange" });
            Image.debugLine("feature/addressexchange/src/main/ets/view/AddressExchangeView.ets(33:11)");
            Image.size({
                height: { "id": 16777226, "type": 10007, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "addressexchange" },
                width: { "id": 16777226, "type": 10007, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "addressexchange" }
            });
        }, Image);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Image.create({ "id": 16777225, "type": 20000, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "addressexchange" });
            Image.debugLine("feature/addressexchange/src/main/ets/view/AddressExchangeView.ets(38:11)");
            Context.animation({
                curve: Curve.EaseOut,
                playMode: PlayMode.Normal,
            });
            Image.size({
                height: { "id": 16777227, "type": 10007, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "addressexchange" },
                width: { "id": 16777227, "type": 10007, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "addressexchange" }
            });
            Image.rotate({ angle: this.rotateAngle });
            Context.animation(null);
        }, Image);
        Stack.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create({ "id": 16777221, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "addressexchange" });
            Text.debugLine("feature/addressexchange/src/main/ets/view/AddressExchangeView.ets(63:9)");
            Text.translate({ x: -this.translateX });
            Text.width({ "id": 16777223, "type": 10003, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "addressexchange" });
            Text.fontSize({ "id": 16777224, "type": 10007, params: [], "bundleName": "com.north.commonappdevelopment", "moduleName": "addressexchange" });
            Text.textAlign(this.swap ? TextAlign.Start : TextAlign.End);
        }, Text);
        Text.pop();
        Row.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
//# sourceMappingURL=AddressExchangeView.js.map