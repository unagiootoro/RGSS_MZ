(() => {
"use strict";

class XPTilemap {
    constructor() {
        this.origin = new Point();
        this._tileWidth = 32;
        this._tileHeight = 32;
        this.animationCount = 0;
        this.animationFrame = 0;
        this._lastAnimationFrame = 0;
        this._mapData = null;
        this._width = 0;
        this._height = 0;
        this._bitmap = null;
        this._needUpdate = false;
        this._tileset = null;
        this._autotiles = new Array(7);
        // this._sprite = new Sprite();
        this._sprites = new Array(3 * 17 * 22);
        for (let z = 0; z < 3; z++) {
            for (let y = 0; y < 17; y++) {
                for (let x = 0; x < 22; x++) {
                    const sprite = new Sprite();
                    sprite.bitmap = new Bitmap(this._tileWidth, this._tileHeight);
                    const i = z * 17 * 22 + y * 22 + x;
                    this._sprites[i] = sprite;
                }
            }
        }
    }

    sprites() {
        // return [this._sprite];
        return this._sprites;
    }

    update() {
        let xBegin = Math.floor(this.origin.x / this._tileWidth);
        let yBegin = Math.floor(this.origin.y / this._tileHeight);
        const baseX = xBegin * this._tileWidth - this.origin.x;
        const baseY = yBegin * this._tileHeight - this.origin.y;
        // this._sprite.x = baseX;
        // this._sprite.y = baseY;
        for (let z = 0; z < 3; z++) {
            for (let y = 0; y < 17; y++) {
                for (let x = 0; x < 22; x++) {
                    const i = z * 17 * 22 + y * 22 + x;
                    const sprite = this._sprites[i];
                    sprite.bitmap.clear();
                    sprite.x = baseX + x * this._tileWidth;
                    sprite.y = baseY + y * this._tileHeight;
                    const posX = xBegin + x;
                    const posY = yBegin + y;
                    const i2 = z * this._height * this._width + posY * this._width + posX;
                    const tileId = this._mapData[i2];
                    const pri = this._priorities[tileId];
                    if (pri > 0) {
                        // sprite.zIndex = ((posY + 1) + pri) * 32 - Math.floor(this.origin.y / this._tileHeight) * this._tileHeight;
                        sprite.zIndex = ((y + 1) + pri) * 32 + z * 0.1;
                    } else {
                        sprite.zIndex = 0 + z * 0.1;
                    }
                }
            }
        }
        SceneManager._scene._baseSprite.sortChildren();
        this.animationCount++;
        this.renderMapData();
    }

    renderMapData() {
        // if (!this._needUpdate) return;
        // if (!this._bitmap) return;
        // this._bitmap.clear();
        for (let layerIndex = 0; layerIndex < 3; layerIndex++) {
            this.renderLayer(layerIndex);
        }
        this._needUpdate = false;
    }

    renderLayer(layerIndex) {
        let xBegin = Math.floor(this.origin.x / this._tileWidth);
        let yBegin = Math.floor(this.origin.y / this._tileHeight);
        let xEnd = 22;
        let yEnd = 17;
        const animationFrame = Math.floor((this.animationCount % 120) / 30);
        for (let y = 0; y < yEnd; y++) {
            for (let x = 0; x < xEnd; x++) {
                const posX = xBegin + x;
                const posY = yBegin + y;
                if (posX >= 0 && posY >= 0) {
                    const i = layerIndex * this._height * this._width + posY * this._width + posX;
                    const tileId = this._mapData[i];
                    const dx = x * this._tileWidth;
                    const dy = y * this._tileHeight;
                    if (tileId >= 384) {
                        if (this._tileset) {
                            const index = tileId - 384;
                            const sx = (tileId % 8) * this._tileWidth;
                            const sy = Math.floor(index / 8) * this._tileHeight;
                            this.addRect(this._tileset, sx, sy, this._tileWidth, this._tileHeight, dx, dy, layerIndex);
                        }
                    } else if (tileId >= 48) {
                        const autotileIndex = Math.floor((tileId - 48) / 48);
                        const autotile = this._autotiles[autotileIndex];
                        if (autotile) {
                            for (let i = 0; i < 4; i++) {
                                const index = tileId % 48;
                                const ix = XPTilemap.AUTOTILE_ID_TABLE[index][i][0];
                                const iy = Math.floor(XPTilemap.AUTOTILE_ID_TABLE[index][i][1]);
                                let sx = ix * this._tileWidth / 2;
                                const maxAnimationFrame = Math.floor(autotile.width / (this._tileWidth * 3));
                                if (animationFrame < maxAnimationFrame) {
                                    sx += animationFrame * (this._tileWidth * 3);
                                }
                                let sy = iy * this._tileHeight / 2;
                                const dx2 = dx + (i % 2) * (this._tileWidth / 2);   // 1 or 3 => dst x + 16
                                const dy2 = dy + Math.floor(i / 2) * (this._tileHeight / 2); // 2 or 3 => dst y + 16
                                this.addRect(autotile, sx, sy, this._tileWidth / 2, this._tileHeight / 2, dx2, dy2, layerIndex);
                            }
                        }
                    }
                    
                }
            }
        }
    }

    addRect(tileset, sx, sy, tw, th, dx, dy, layerIndex) {
        // this._bitmap.blt(tileset, sx, sy, tw, th, dx, dy);
        const x = Math.floor(dx / this._tileWidth);
        const y = Math.floor(dy / this._tileHeight);
        const dx2 = dx - x * this._tileWidth;
        const dy2 = dy - y * this._tileHeight;
        const i = layerIndex * 17 * 22 + y * 22 + x;
        const sprite = this._sprites[i];
        sprite.bitmap.blt(tileset, sx, sy, tw, th, dx2, dy2);
    }

    setMapData(mapData, width, height) {
        this._mapData = mapData;
        this._width = width;
        this._height = height;
        // if (this._bitmap) {
        //     this._bitmap.destroy();
        // }
        // this._bitmap = new Bitmap(22 * this._tileWidth, 17 * this._tileHeight);
        // this._sprite.bitmap = this._bitmap;
        this._needUpdate = true;
    }

    setPriorities(priorities) {
        this._priorities = priorities;
    }

    autotile(index) {
        return this._autotiles[index];
    }

    setAutotile(index, autotile) {
        this._needUpdate = true;
        this._autotiles[index] = autotile;
    }

    setTileset(tileset) {
        this._tileset = tileset;
    }

    tileset() {
        return this._tileset;
    }
}

XPTilemap.AUTOTILE_ID_TABLE = [
    [[2, 4], [3, 4], [2, 5], [3, 5]],
    [[4, 0], [3, 4], [2, 5], [3, 5]],
    [[2, 4], [5, 0], [2, 5], [3, 5]],
    [[4, 0], [5, 0], [2, 5], [3, 5]],
    [[2, 4], [3, 4], [2, 5], [5, 1]],
    [[4, 0], [3, 4], [2, 5], [5, 1]],
    [[2, 4], [5, 0], [2, 5], [5, 1]],
    [[4, 0], [5, 0], [2, 5], [5, 1]],
    [[2, 4], [3, 4], [4, 1], [3, 5]],
    [[4, 0], [3, 4], [4, 1], [3, 5]],
    [[2, 4], [5, 0], [4, 1], [3, 5]],
    [[4, 0], [5, 0], [4, 1], [3, 5]],
    [[2, 4], [3, 4], [4, 1], [5, 1]],
    [[4, 0], [3, 4], [4, 1], [5, 1]],
    [[2, 4], [5, 0], [4, 1], [5, 1]],
    [[4, 0], [5, 0], [4, 1], [5, 1]],
    [[0, 4], [1, 4], [0, 5], [1, 5]],
    [[0, 4], [5, 0], [0, 5], [1, 5]],
    [[0, 4], [1, 4], [0, 5], [5, 1]],
    [[0, 4], [5, 0], [0, 5], [5, 1]],
    [[2, 2], [3, 2], [2, 3], [3, 3]],
    [[2, 2], [3, 2], [2, 3], [5, 1]],
    [[2, 2], [3, 2], [4, 1], [3, 3]],
    [[2, 2], [3, 2], [4, 1], [5, 1]],
    [[4, 4], [5, 4], [4, 5], [5, 5]],
    [[4, 4], [5, 4], [4, 1], [5, 5]],
    [[4, 0], [5, 4], [4, 5], [5, 5]],
    [[4, 0], [5, 4], [4, 1], [5, 5]],
    [[2, 6], [3, 6], [2, 7], [3, 7]],
    [[4, 0], [3, 6], [2, 7], [3, 7]],
    [[2, 6], [5, 0], [2, 7], [3, 7]],
    [[4, 0], [5, 0], [2, 7], [3, 7]],
    [[0, 4], [5, 4], [0, 5], [5, 5]],
    [[2, 2], [3, 2], [2, 7], [3, 7]],
    [[0, 2], [1, 2], [0, 3], [1, 3]],
    [[0, 2], [1, 2], [0, 3], [5, 1]],
    [[4, 2], [5, 2], [4, 3], [5, 3]],
    [[4, 2], [5, 2], [4, 1], [5, 3]],
    [[4, 6], [5, 6], [4, 7], [5, 7]],
    [[4, 0], [5, 6], [4, 7], [5, 7]],
    [[0, 6], [1, 6], [0, 7], [1, 7]],
    [[0, 6], [5, 0], [0, 7], [1, 7]],
    [[0, 2], [5, 2], [0, 3], [5, 3]],
    [[0, 2], [1, 2], [0, 7], [1, 7]],
    [[0, 6], [5, 6], [0, 7], [5, 7]],
    [[4, 2], [5, 2], [4, 7], [5, 7]],
    [[0, 2], [5, 2], [0, 7], [5, 7]],
    [[0, 0], [1, 0], [0, 1], [1, 1]]
];

window.XPTilemap = XPTilemap;

})();
