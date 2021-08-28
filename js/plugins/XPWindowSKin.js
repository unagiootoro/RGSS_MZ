/*:
@target MZ
@plugindesc XPウィンドウスキン v1.0.0
@author うなぎおおとろ
@url https://raw.githubusercontent.com/unagiootoro/RPGMZ/master/XPWindowSKin.js
@help
ツクールXPのウィンドウスキンに対応するプラグインです。

【使用方法】
このプラグインを導入し、プラグインコマンド「ChangeXPWindowSkin」を実行してください。

【ライセンス】
このプラグインは、MITライセンスの条件の下で利用可能です。


@param WindowSkinNames
@text ウィンドウスキンファイル一覧
@type file[]
@dir img/system
@desc
使用するウィンドウスキンを登録します。


@command ChangeXPWindowSkin
@text XPウィンドウスキン変更
@desc
指定したXPウィンドウスキン名に変更します。

@arg WindowSkinName
@text ウィンドウスキン名
@type file
@dir img/system
@desc
ウィンドウスキン名を指定します。


@command ResetWindowSkin
@text ウィンドウスキンリセット
@desc
デフォルトのMZウィンドウスキンに戻します。
*/


const XPWindowSKinPluginName = document.currentScript.src.match(/.+\/(.+)\.js/)[1];

(() => {
"use strict";

class XPWindowConfig {
    constructor() {
        // this._windowskinName = null;
        this._windowskinName = "001-Blue01";
    }

    enableXPWindow() {
        return !!this._windowskinName;
    }

    windowSkinName() {
        if (!this._windowskinName) throw new Error(`windowSkinName is null.`);
        return this._windowskinName;
    }

    setWindowSkinName(windowSkinName) {
        this._windowskinName = windowSkinName;
    }
}

const xpWindowConfig = new XPWindowConfig();

PluginManager.registerCommand(XPWindowSKinPluginName, "ChangeXPWindowSkin", args => {
    const windowSkinName = args.WindowSkinName;
    xpWindowConfig.setWindowSkinName(windowSkinName);
});

PluginManager.registerCommand(XPWindowSKinPluginName, "ResetWindowSkin", () => {
    xpWindowConfig.setWindowSkinName(null);
});


const _Window_initialize = Window.prototype.initialize;
Window.prototype.initialize = function() {
    _Window_initialize.call(this);
    if (xpWindowConfig.enableXPWindow()) {
        this._margin = 2;
    }
};

const _Window_createBackSprite = Window.prototype._createBackSprite;
Window.prototype._createBackSprite = function() {
    if (xpWindowConfig.enableXPWindow()) {
        this._createBackSpriteXP();
    } else {
        _Window_createBackSprite.call(this);
    }
};

Window.prototype._createBackSpriteXP = function() {
    this._backSprite = new Sprite();
    this._container.addChild(this._backSprite);
};

const _Window_refreshBack = Window.prototype._refreshBack;
Window.prototype._refreshBack = function() {
    if (xpWindowConfig.enableXPWindow()) {
        this._refreshBackXP();
    } else {
        _Window_refreshBack.call(this);
    }
};

Window.prototype._refreshBackXP = function() {
    const m = this._margin;
    const w = Math.max(0, this._width - m * 2);
    const h = Math.max(0, this._height - m * 2);
    const sprite = this._backSprite;
    sprite.bitmap = this._windowskin;
    sprite.setFrame(0, 0, 128, 128);
    sprite.move(m, m);
    sprite.scale.x = w / 128;
    sprite.scale.y = h / 128;
    sprite.setColorTone(this._colorTone);
};

const _Window_refreshFrame = Window.prototype._refreshFrame;
Window.prototype._refreshFrame = function() {
    if (xpWindowConfig.enableXPWindow()) {
        this._refreshFrameXP();
    } else {
        _Window_refreshFrame.call(this);
    }
};

Window.prototype._refreshFrameXP = function() {
    const drect = { x: 0, y: 0, width: this._width, height: this._height };
    const srect = { x: 128, y: 0, width: 64, height: 64 };
    const m = 16;
    for (const child of this._frameSprite.children) {
        child.bitmap = this._windowskin;
    }
    this._setRectPartsGeometry(this._frameSprite, srect, drect, m);
};

const _Window_refreshCursor = Window.prototype._refreshCursor;
Window.prototype._refreshCursor = function() {
    if (xpWindowConfig.enableXPWindow()) {
        this._refreshCursorXP();
    } else {
        _Window_refreshCursor.call(this);
    }
};

Window.prototype._refreshCursorXP = function() {
    const drect = this._cursorRect.clone();
    const srect = { x: 128, y: 64, width: 32, height: 32 };
    const m = 4;
    for (const child of this._cursorSprite.children) {
        child.bitmap = this._windowskin;
    }
    this._setRectPartsGeometry(this._cursorSprite, srect, drect, m);
};

const _Window_refreshArrows = Window.prototype._refreshArrows;
Window.prototype._refreshArrows = function() {
    if (xpWindowConfig.enableXPWindow()) {
        this._refreshArrowsXP();
    } else {
        _Window_refreshArrows.call(this);
    }
};

Window.prototype._refreshArrowsXP = function() {
    const w = this._width;
    const h = this._height;
    const p = 16;
    const q = p / 2;
    const sx = 128 + p;
    const sy = 0 + p;
    this._downArrowSprite.bitmap = this._windowskin;
    this._downArrowSprite.anchor.x = 0.5;
    this._downArrowSprite.anchor.y = 0.5;
    this._downArrowSprite.setFrame(sx + q, sy + q + p, p, q);
    this._downArrowSprite.move(w / 2, h - q);
    this._downArrowSprite.scale.x = 1.5;
    this._downArrowSprite.scale.y = 1.5;
    this._upArrowSprite.bitmap = this._windowskin;
    this._upArrowSprite.anchor.x = 0.5;
    this._upArrowSprite.anchor.y = 0.5;
    this._upArrowSprite.setFrame(sx + q, sy, p, q);
    this._upArrowSprite.move(w / 2, q);
    this._upArrowSprite.scale.x = 1.5;
    this._upArrowSprite.scale.y = 1.5;
};

const _Window_refreshPauseSign = Window.prototype._refreshPauseSign;
Window.prototype._refreshPauseSign = function() {
    if (xpWindowConfig.enableXPWindow()) {
        this._refreshPauseSignXP();
    } else {
        _Window_refreshPauseSign.call(this);
    }
};

Window.prototype._refreshPauseSignXP = function() {
    const sx = 160;
    const sy = 64;
    const p = 16;
    this._pauseSignSprite.bitmap = this._windowskin;
    this._pauseSignSprite.anchor.x = 0.5;
    this._pauseSignSprite.anchor.y = 1;
    this._pauseSignSprite.move(this._width / 2, this._height);
    this._pauseSignSprite.setFrame(sx, sy, p, p);
    this._pauseSignSprite.alpha = 0;
    this._pauseSignSprite.scale.x = 1.5;
    this._pauseSignSprite.scale.y = 1.5;
};

const _Window_updatePauseSign = Window.prototype._updatePauseSign;
Window.prototype._updatePauseSign = function() {
    if (xpWindowConfig.enableXPWindow()) {
        this._updatePauseSignXP();
    } else {
        _Window_updatePauseSign.call(this);
    }
};

Window.prototype._updatePauseSignXP = function() {
    const sprite = this._pauseSignSprite;
    const x = Math.floor(this._animationCount / 16) % 2;
    const y = Math.floor(this._animationCount / 16 / 2) % 2;
    const sx = 160;
    const sy = 64;
    const p = 16;
    if (!this.pause) {
        sprite.alpha = 0;
    } else if (sprite.alpha < 1) {
        sprite.alpha = Math.min(sprite.alpha + 0.1, 1);
    }
    sprite.setFrame(sx + x * p, sy + y * p, p, p);
    sprite.visible = this.isOpen();
};

const _Window_Selectable_drawItemBackground = Window_Selectable.prototype.drawItemBackground;
Window_Selectable.prototype.drawItemBackground = function(index) {
    if (!xpWindowConfig.enableXPWindow()) {
        _Window_Selectable_drawItemBackground.call(this, index);
    }
};

const _Window_Base_loadWindowskin = Window_Base.prototype.loadWindowskin;
Window_Base.prototype.loadWindowskin = function() {
    if (xpWindowConfig.enableXPWindow()) {
        this.windowskin = ImageManager.loadSystem(xpWindowConfig.windowSkinName());
    } else {
        _Window_Base_loadWindowskin.call(this);
    }
};

})();
