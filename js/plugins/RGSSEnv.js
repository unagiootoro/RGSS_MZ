(() => {
"use strict";

let $runtimeInitialized = false;

const midiPlayer = new MIDIPlayer();

AudioManager._path = "Audio/";

AudioManager.playBgm = function(bgm, pos) {
    if (this.isCurrentBgm(bgm)) {
        this.updateBgmParameters(bgm);
    } else {
        this.stopBgm();
        if (bgm.name) {
            this._bgmBuffer = this.createBuffer("BGM/", bgm.name);
            this.updateBgmParameters(bgm);
            if (!this._meBuffer) {
                this._bgmBuffer.play(true, pos || 0);
            }
        }
    }
    this.updateCurrentBgm(bgm, pos);
};

AudioManager.playBgs = function(bgs, pos) {
    if (this.isCurrentBgs(bgs)) {
        this.updateBgsParameters(bgs);
    } else {
        this.stopBgs();
        if (bgs.name) {
            this._bgsBuffer = this.createBuffer("BGS/", bgs.name);
            this.updateBgsParameters(bgs);
            this._bgsBuffer.play(true, pos || 0);
        }
    }
    this.updateCurrentBgs(bgs, pos);
};

AudioManager.playMe = function(me) {
    this.stopMe();
    if (me.name) {
        if (this._bgmBuffer && this._currentBgm) {
            this._currentBgm.pos = this._bgmBuffer.seek();
            this._bgmBuffer.stop();
        }
        this._meBuffer = this.createBuffer("ME/", me.name);
        this.updateMeParameters(me);
        this._meBuffer.play(false);
        this._meBuffer.addStopListener(this.stopMe.bind(this));
    }
};

AudioManager.playSe = function(se) {
    if (se.name) {
        // [Note] Do not play the same sound in the same frame.
        const latestBuffers = this._seBuffers.filter(
            buffer => buffer.frameCount === Graphics.frameCount
        );
        if (latestBuffers.find(buffer => buffer.name === se.name)) {
            return;
        }
        const buffer = this.createBuffer("SE/", se.name);
        this.updateSeParameters(buffer, se);
        buffer.play(false);
        this._seBuffers.push(buffer);
        this.cleanupSe();
    }
};



Module.onRuntimeInitialized = () => {
    Module._init_rgss();
    $runtimeInitialized = true;
}

const keyTable = {
    9: "tab",
    13: "ok",
    16: "shift",
    17: "control",
    18: "control",
    27: "escape",
    32: "ok",
    33: "pageup",
    34: "pagedown",
    37: "left",
    38: "up",
    39: "right",
    40: "down",
    45: "escape",
    81: "pageup",
    87: "pagedown",
    88: "escape",
    90: "ok",
    96: "escape",
    98: "down",
    100: "left",
    102: "right",
    104: "up",
    120: "debug",
}

const RGSSProcess = {
    process_Graphics_check_updated(param) {
        if (this._graphicsUpdated) {
            this._graphicsUpdated = false;
            return 1;
        }
        return 0;
    },

    process_Bitmap_new(param) {
        let bitmap;
        if (param.file_name) {
            bitmap = ImageManager.loadBitmapFromUrl(param.file_name);
        } else {
            bitmap = new Bitmap(param.width, param.height);
        }
        this._objectTable[this._objectTableIndex] = bitmap;
        const id = this._objectTableIndex;
        this._objectTableIndex++;
        return id;
    },

    process_Bitmap_check_created(param) {
        const bitmap = this._objectTable[param.bitmap_id];
        if (!bitmap || !(bitmap instanceof Bitmap)) {
            throw new Error(`bitmap is not createed. id: ${param.bitmap_id}`);
        }
        if (bitmap.isReady()) return 1;
        return 0;
    },

    process_Bitmap_delete(param) {
        delete this._objectTable[param.bitmap_id];
    },

    process_Bitmap_get_width(param) {
        const bitmap = this._objectTable[param.bitmap_id];
        return bitmap.width;
    },

    process_Bitmap_get_height(param) {
        const bitmap = this._objectTable[param.bitmap_id];
        return bitmap.height;
    },

    process_Bitmap_draw_text(param) {
        const bitmap = this._objectTable[param.bitmap_id];
        bitmap.drawText(param.text, param.x, param.y, param.width, param.height, param.align);
    },

    process_Bitmap_measure_text_width(param) {
        const bitmap = this._objectTable[param.bitmap_id];
        const width = bitmap.measureTextWidth(param.text);
        return width;
    },

    process_Bitmap_set_font(param) {
        const bitmap = this._objectTable[param.bitmap_id];
        bitmap.fontFace = param.face;
        bitmap.fontSize = Math.floor(param.size * 0.65);
        bitmap.fontBold = param.bold;
        bitmap.fontItalic = param.italic;
        bitmap.textColor = param.color;
    },

    process_Bitmap_clear(param) {
        const bitmap = this._objectTable[param.bitmap_id];
        bitmap.clear();
    },

    process_Bitmap_blt(param) {
        const bitmap = this._objectTable[param.bitmap_id];
        const srcBitmap = this._objectTable[param.src_bitmap_id];
        bitmap.blt(srcBitmap, param.sx, param.sy, param.sw, param.sh, param.dx, param.dy, param.dw, param.dh);
    },

    process_Bitmap_fill_rect(param) {
        const bitmap = this._objectTable[param.bitmap_id];
        bitmap.fillRect(param.x, param.y, param.width, param.height, param.color);
    },

    process_Sprite_new(param) {
        let sprite;
        if (param.is_tiling) {
            sprite = new TilingSprite();
        } else {
            sprite = new Sprite();
        }
        this._objectTable[this._objectTableIndex] = sprite;
        const id = this._objectTableIndex;
        this._objectTableIndex++;
        if (param.viewport_id === -1) {
            this._baseSprite.addChild(sprite);
        } else {
            const viewport = this._objectTable[param.viewport_id];
            viewport.addChild(sprite);
        }
        return id;
    },

    process_Sprite_delete(param) {
        const sprite = this._objectTable[param.sprite_id];
        if (param.viewport_id === -1) {
            this._baseSprite.removeChild(sprite);
        } else {
            const viewport = this._objectTable[param.viewport_id];
            viewport.removeChild(sprite);
        }
        delete this._objectTable[param.sprite_id];
    },

    process_Sprite_update(param) {
        const sprite = this._objectTable[param.sprite_id];
        sprite.update();
    },

    process_Sprite_set_bitmap(param) {
        const sprite = this._objectTable[param.sprite_id];
        if (param.bitmap_id === -1) {
            sprite.bitmap = null;
        } else {
            const bitmap = this._objectTable[param.bitmap_id];
            sprite.bitmap = bitmap;
        }
    },

    process_Sprite_set_x(param) {
        const sprite = this._objectTable[param.sprite_id];
        sprite.x = param.x;
    },

    process_Sprite_set_y(param) {
        const sprite = this._objectTable[param.sprite_id];
        sprite.y = param.y;
    },

    process_Sprite_set_z(param) {
        const sprite = this._objectTable[param.sprite_id];
        sprite.zIndex = param.z;
        this._baseSprite.sortChildren();
    },

    process_Sprite_set_frame(param) {
        const sprite = this._objectTable[param.sprite_id];
        sprite.setFrame(param.x, param.y, param.width, param.height);
    },

    process_Sprite_set_visible(param) {
        const sprite = this._objectTable[param.sprite_id];
        sprite.visible = param.visible;
    },

    process_Sprite_set_opacity(param) {
        const sprite = this._objectTable[param.sprite_id];
        sprite.opacity = param.opacity;
    },

    // process_Window_new(param) {
    //     const window = new Window_Base(new Rectangle(0, 0, 0, 0));
    //     window.openness = 255;
    //     this._objectTable[this._objectTableIndex] = window;
    //     const id = this._objectTableIndex;
    //     this._objectTableIndex++;
    //     if (param.viewport_id === -1) {
    //         this._baseSprite.addChild(window);
    //     } else {
    //         const viewport = this._objectTable[param.viewport_id];
    //         viewport.addChild(window);
    //     }
    //     return id;
    // },

    process_Window_new(param) {
        const backWindow = new Window_Base(new Rectangle(0, 0, 0, 0));
        const topSprite = new Sprite();
        topSprite.x = backWindow.padding;
        topSprite.y = backWindow.padding;
        backWindow.topSprite = topSprite;
        backWindow.addChild(topSprite);

        backWindow.openness = 255;
        this._objectTable[this._objectTableIndex] = backWindow;
        const id = this._objectTableIndex;
        this._objectTableIndex++;
        if (param.viewport_id === -1) {
            this._baseSprite.addChild(backWindow);
        } else {
            const viewport = this._objectTable[param.viewport_id];
            viewport.addChild(backWindow);
        }
        return id;
    },

    process_Window_delete(param) {
        const window = this._objectTable[param.window_id];
        if (param.viewport_id === -1) {
            this._baseSprite.removeChild(window);
        } else {
            const viewport = this._objectTable[param.viewport_id];
            viewport.removeChild(window);
        }
        delete this._objectTable[param.window_id];
    },

    process_Window_update(param) {
        const window = this._objectTable[param.window_id];
        window.update();
    },

    // process_Window_get_bitmap(param) {
    //     const window = this._objectTable[param.window_id];
    //     let index = -1;
    //     for (const key in this._objectTable) {
    //         if (this._objectTable[key] === window.contents) {
    //             index = key;
    //             break;
    //         }
    //     }
    //     if (index === -1) {
    //         this._objectTable[this._objectTableIndex] = window.contents;
    //         index = this._objectTableIndex;
    //         this._objectTableIndex++;
    //     }
    //     return index;
    // },

    process_Window_get_bitmap(param) {
        const window = this._objectTable[param.window_id];
        let index = -1;
        if (window.topSprite.bitmap) {
            for (const key in this._objectTable) {
                if (this._objectTable[key] === window.topSprite.bitmap) {
                    index = key;
                    break;
                }
            }
        }
        if (index === -1) {
            const width = window.width - window.padding * 2;
            const height = window.height - window.padding * 2;
            const bitmap = new Bitmap(width, height);
            window.topSprite.bitmap = bitmap;
            this._objectTable[this._objectTableIndex] = bitmap;
            index = this._objectTableIndex;
            this._objectTableIndex++;
        }
        return index;
    },

    // process_Window_set_bitmap(param) {
    //     const window = this._objectTable[param.window_id];
    //     const bitmap = this._objectTable[param.bitmap_id];
    //     window.contents = bitmap;
    // },

    process_Window_set_bitmap(param) {
        const window = this._objectTable[param.window_id];
        const bitmap = this._objectTable[param.bitmap_id];
        window.topSprite.bitmap = bitmap;
    },

    process_Window_set_x(param) {
        const window = this._objectTable[param.window_id];
        window.x = param.x;
    },

    process_Window_set_y(param) {
        const window = this._objectTable[param.window_id];
        window.y = param.y;
    },

    process_Window_set_z(param) {
        const window = this._objectTable[param.window_id];
        window.zIndex = param.z;
        window.topSprite.zIndex = param.z + 2;
        this._baseSprite.sortChildren();
    },

    process_Window_set_width(param) {
        const window = this._objectTable[param.window_id];
        window.width = param.width;
    },

    process_Window_set_height(param) {
        const window = this._objectTable[param.window_id];
        window.height = param.height;
    },

    process_Window_set_visible(param) {
        const window = this._objectTable[param.window_id];
        window.visible = param.visible;
    },

    process_Window_set_cursor_rect(param) {
        const window = this._objectTable[param.window_id];
        window.setCursorRect(param.x, param.y, param.width, param.height);
    },

    process_Window_set_opacity(param) {
        const window = this._objectTable[param.window_id];
        window.opacity = param.opacity;
    },

    process_Window_set_contents_opacity(param) {
        const window = this._objectTable[param.window_id];
        window.topSprite.opacity = param.opacity;
    },

    process_Viewport_new(param) {
        const container = new PIXI.Container();
        container.sortableChildren = true;
        this._baseSprite.addChild(container);
        this._objectTable[this._objectTableIndex] = container;
        const id = this._objectTableIndex;
        this._objectTableIndex++;
        return id;
    },

    process_Viewport_delete(param) {
        const container = this._objectTable[param.viewport_id];
        this._baseSprite.removeChild(container);
        delete this._objectTable[param.viewport_id];
    },

    process_Viewport_update(param) {
        const container = this._objectTable[param.viewport_id];
    },

    process_Viewport_set_z(param) {
        const container = this._objectTable[param.viewport_id];
        container.zIndex = param.z;
        this._baseSprite.sortChildren();
    },

    process_Tilemap_new(param) {
        const tilemap = new XPTilemap();
        this._objectTable[this._objectTableIndex] = tilemap;
        const id = this._objectTableIndex;
        this._objectTableIndex++;
        if (param.viewport_id === -1) {
            for (const sprite of tilemap.sprites()) {
                this._baseSprite.addChild(sprite);
            }
        } else {
            const viewport = this._objectTable[param.viewport_id];
            for (const sprite of tilemap.sprites()) {
                viewport.addChild(sprite);
            }
        }
        return id;
    },

    process_Tilemap_delete(param) {
        const tilemap = this._objectTable[param.tilemap_id];
        if (param.viewport_id === -1) {
            for (const sprite of tilemap.sprites()) {
                this._baseSprite.removeChild(sprite);
            }
        } else {
            const viewport = this._objectTable[param.viewport_id];
            for (const sprite of tilemap.sprites()) {
                viewport.removeChild(sprite);
            }
        }
        delete this._objectTable[param.tilemap_id];
    },

    process_Tilemap_update(param) {
        const tilemap = this._objectTable[param.tilemap_id];
        tilemap.update();
    },

    process_Tilemap_set_origin(param) {
        const tilemap = this._objectTable[param.tilemap_id];
        tilemap.origin.x = param.ox;
        tilemap.origin.y = param.oy;
    },

    process_Tilemap_set_tileset(param) {
        const tilemap = this._objectTable[param.tilemap_id];
        const tileset = this._objectTable[param.bitmap_id];
        tilemap.setTileset(tileset);
    },

    process_Tilemap_set_autotile(param) {
        const tilemap = this._objectTable[param.tilemap_id];
        if (param.bitmap_id === -1) {
            tilemap.setAutotile(param.index, null);
        } else {
            const autotile = this._objectTable[param.bitmap_id];
            tilemap.setAutotile(param.index, autotile);
        }
    },

    process_Tilemap_set_map_data(param) {
        const tilemap = this._objectTable[param.tilemap_id];
        const mapData = param.map_data;
        tilemap.setMapData(mapData, param.width, param.height);
    },

    process_Tilemap_set_priorities(param) {
        const tilemap = this._objectTable[param.tilemap_id];
        const priorities = param.priorities;
        tilemap.setPriorities(priorities);
    },

    process_Input_is_pressed(param) {
        const keyName = keyTable[param.keycode];
        if (Input.isPressed(keyName)) {
            return 1;
        }
        return 0;
    },

    process_Input_is_triggered(param) {
        const keyName = keyTable[param.keycode];
        if (Input.isTriggered(keyName)) {
            return 1;
        }
        return 0;
    },

    process_Input_is_repeated(param) {
        const keyName = keyTable[param.keycode];
        if (Input.isRepeated(keyName)) {
            return 1;
        }
        return 0;
    },

    process_Input_dir4(param) {
        return Input.dir4;
    },

    process_Input_dir8(param) {
        return Input.dir8;
    },

    process_Audio_MidiBgmPlay(param) {
        midiPlayer.load(param.name);
        midiPlayer.loopPlay();
    },

    process_Audio_MidiBgmStop(param) {
        midiPlayer.pause();
    },

    process_Audio_MidiMePlay(param) {
        midiPlayer.load(param.name);
        midiPlayer.play();
    },

    process_Audio_OggBgmPlay(param) {
        const bgm = {
            name: param.name.replace("Audio/BGM/", ""),
            pan: 0,
            pitch: param.pitch,
            volume: param.volume,
        }
        AudioManager.playBgm(bgm);
    },

    process_Audio_OggBgmStop(param) {
        AudioManager.stopBgm();
    },

    process_Audio_OggBgmFadeOut(param) {
        AudioManager.fadeOutBgm(param.duration);
    },

    process_Audio_OggBgsPlay(param) {
        const bgs = {
            name: param.name.replace("Audio/BGS/", ""),
            pan: 0,
            pitch: param.pitch,
            volume: param.volume,
        }
        AudioManager.playBgs(bgs);
    },

    process_Audio_OggBgsStop(param) {
        AudioManager.stopBgs();
    },

    process_Audio_OggBgsFadeOut(param) {
        AudioManager.fadeOutBgs(param.duration);
    },

    process_Audio_OggMePlay(param) {
        const me = {
            name: param.name.replace("Audio/ME/", ""),
            pan: 0,
            pitch: param.pitch,
            volume: param.volume,
        }
        AudioManager.playMe(me);
    },

    process_Audio_OggMeStop(param) {
        AudioManager.stopMe();
    },

    process_Audio_OggMeFadeOut(param) {
        AudioManager.fadeOutMe(param.duration);
    },

    process_Audio_OggSePlay(param) {
        const se = {
            name: param.name.replace("Audio/SE/", ""),
            pan: 0,
            pitch: param.pitch,
            volume: param.volume,
        }
        AudioManager.playSe(se);
    },

    process_Audio_OggSeStop(param) {
        AudioManager.stopSe(param.duration);
    },

    process_Audio_OggSeFadeOut(param) {
        AudioManager.fadeOutSe(param.duration);
    },
};

class Scene_RGSSEnv extends Scene_Base {
    create() {
        super.create();
        this._frameCount = 0;
        this._baseSprite = new Sprite();
        this._baseSprite.sortableChildren = true;
        this.addChild(this._baseSprite);
        this._objectTable = {};
        this._objectTableIndex = 0;
        this._sharedBuffer = null;
        // this.initServer();
    }

    initWorker() {
        this._worker = new Worker("rgss/rgss.js");
        this._worker.addEventListener("message", this.recvMessage.bind(this));
    }

    initServer() {
        const http = require("http");
        this._server = http.createServer();
        this._server.on("request", (req, res) => {
            console.log("request");
            res.writeHead(200, { "Content-Type": "text/plain"});
            if (req.method === "POST") {
                let data = "";
                req.on("data", (chunk) => { data += chunk }).on("end", () => {
                    const result = this.serverPost(data);
                    res.write(result.toString());
                    res.end();
                });
            } else {
                res.write("");
                res.end();
            }
        });
        this._server.listen(7000);
    }

    serverPost(data) {
        let result = 0;
        try {
            const params = JSON.parse(data);
            if (params.type === "debug_log") {
                console.log(params.obj);
            } else if (params.type === "file_read_start") {
    
            } else if (params.type === "file_read") {
    
            } else {
                result = this.doProcess(params.type, params.obj);
            }
        } catch(e) {
            console.error(e);
        }
        return result;
    }

    recvMessage(e) {
        const type = e.data[0];
        this._sharedBuffer = e.data[1];
        const obj = e.data[2];
        if (type === "debug_log") {
            console.log(obj);
        } else if (type === "file_read_start") {
            const fs = require("fs");
            const fileData = fs.readFileSync(obj);
            this._file = fileData.toString();
            const bufferView = new Int32Array(this._sharedBuffer);
            bufferView[1] = this._file.length;
            bufferView[0] = 1;
        } else if (type === "file_read") {
            const sharedBuffer2 = obj;
            const bufferView = new Int32Array(this._sharedBuffer);
            const bufferView2 = new Uint32Array(sharedBuffer2);
            for (let i = 0; i < this._file.length; i++) {
                bufferView2[i] = this._file.codePointAt(i);
            }
            this._file = null;
            bufferView[0] = 1;
        } else {
            this.recvData(type, obj);
        }
    }

    update() {
        super.update();
        this._processCount = 0;
        if ($runtimeInitialized) {
            const result = Module._update_rgss();
            if (result === 1) {
                throw new Error("failed rgss.");
            }
        }
        this._frameCount++;
        this._graphicsUpdated = true;
        // console.log(this._processCount);
    }

    recvData(type, obj) {
        const bufferView = new Int32Array(this._sharedBuffer);
        const result = this.doProcess(type, obj);
        bufferView[1] = result;
        bufferView[0] = 1;
    }

    doProcess(type, obj) {
        this._processCount++;
        const funcname = "process_" + type;
        if (!this[funcname]) {
            throw new Error(`${funcname} is not found.`)
        }
        const result = this[funcname](obj);
        return result == null ? 0 : result;
    }
}

Object.assign(Scene_RGSSEnv.prototype, RGSSProcess);

Scene_Boot.prototype.startNormalGame = function() {
    this.checkPlayerLocation();
    DataManager.setupNewGame();
    SceneManager.goto(Scene_RGSSEnv);
    Window_TitleCommand.initCommandPosition();
};

})();
