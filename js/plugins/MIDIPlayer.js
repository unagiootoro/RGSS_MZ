(() => {
"use strict";

class MIDIPlayer {
    constructor() {
        this._player = new Timidity();
        this._loop = false;
        this.initCallbacks();
    }

    initCallbacks() {
        this._player.on("ended", () => {
            if (this._loop) {
                this._player.seek(0);
                this._player.play();
            }
        });
    }

    load(fileName) {
        this._player.load(fileName);
    }

    play() {
        this._loop = false;
        this._player.play();
    }

    loopPlay() {
        this._loop = true;
        this._player.play();
    }

    pause() {
        this._loop = false;
        this._player.pause();
    }

    update() {

    }
}

window.MIDIPlayer = MIDIPlayer;

})();
