mergeInto(LibraryManager.library, {
    rgss_send_message: function(ptrMessage) {
        const message = UTF8ToString(ptrMessage);
        let result = 0;
        try {
            const params = JSON.parse(message);
            if (params.type === "debug_log") {
                console.log(params.obj);
            } else if (params.type === "file_read_start") {
    
            } else if (params.type === "file_read") {

            } else {
                result = SceneManager._scene.doProcess(params.type, params.obj);
            }
        } catch(e) {
            console.error(e);
        }
        return result;
    },

    rgss_file_read: function(ptrFileName, ptrBuf, ptrBufSize) {
        const fs = require("fs");
        const fileName = UTF8ToString(ptrFileName);
        const fileData = fs.readFileSync(fileName);
        const file = fileData.toString();
        const utf8str = unescape(encodeURIComponent(file));
        setValue(ptrBufSize, utf8str.length, "i32");
        for (let i = 0; i < utf8str.length; i++) {
            setValue(ptrBuf + i, utf8str.charCodeAt(i), "i8");
        }
    },

    rgss_file_write: function(ptrFileName, ptrBuf, bufSize) {
        const fs = require("fs");
        const fileName = UTF8ToString(ptrFileName);
        let utf8buf = "";
        for (let i = 0; i < bufSize; i++) {
            const code = getValue(ptrBuf + i, utf8str.charCodeAt(i), "i8");
            utf8buf += String.fromCharCode(code);
        }
        const data = decodeURIComponent(escape(utf8buf));
        fs.writeFileSync(fileName, data);
    },


    // Bitmap
    rgssenv_bitmap_new: function(ptr_file_name, width, height) {
        let file_name = null;
        if (ptr_file_name !== 0) {
            file_name = UTF8ToString(ptr_file_name);
        }
        const obj = { file_name, width, height };
        return SceneManager._scene.doProcess("Bitmap_new", obj);
    },

    rgssenv_bitmap_check_created: function(bitmap_id) {
        const obj = { bitmap_id };
        return SceneManager._scene.doProcess("Bitmap_check_created", obj);
    },

    rgssenv_bitmap_delete: function(bitmap_id) {
        const obj = { bitmap_id };
        return SceneManager._scene.doProcess("Bitmap_delete", obj);
    },

    rgssenv_bitmap_get_width: function(bitmap_id) {
        const obj = { bitmap_id };
        return SceneManager._scene.doProcess("Bitmap_get_width", obj);
    },

    rgssenv_bitmap_get_height: function(bitmap_id) {
        const obj = { bitmap_id };
        return SceneManager._scene.doProcess("Bitmap_get_height", obj);
    },

    rgssenv_bitmap_draw_text: function(bitmap_id, ptr_text, x, y, width, height, ptr_align) {
        const text = UTF8ToString(ptr_text);
        const align = UTF8ToString(ptr_align);
        const obj = { bitmap_id, text, x, y, width, height, align };
        return SceneManager._scene.doProcess("Bitmap_draw_text", obj);
    },

    rgssenv_bitmap_measure_text_width: function(bitmap_id, ptr_text) {
        const text = UTF8ToString(ptr_text);
        const obj = { bitmap_id, text };
        return SceneManager._scene.doProcess("Bitmap_measure_text_width", obj);
    },

    rgssenv_bitmap_set_font: function(bitmap_id, ptr_face, size, int_bold, int_italic, ptr_color) {
        const face = UTF8ToString(ptr_face);
        const bold = int_bold === 0 ? false : true;
        const italic = int_italic === 0 ? false : true;
        const color = UTF8ToString(ptr_color);
        const obj = { bitmap_id, face, size, bold, italic, color };
        return SceneManager._scene.doProcess("Bitmap_set_font", obj);
    },

    rgssenv_bitmap_clear: function(bitmap_id) {
        const obj = { bitmap_id };
        return SceneManager._scene.doProcess("Bitmap_clear", obj);
    },

    rgssenv_bitmap_blt: function(bitmap_id, src_bitmap_id, sx, sy, sw, sh, dx, dy, dw, dh) {
        const obj = { bitmap_id, src_bitmap_id, sx, sy, sw, sh, dx, dy, dw, dh };
        return SceneManager._scene.doProcess("Bitmap_blt", obj);
    },

    rgssenv_bitmap_fill_rect: function(bitmap_id, x, y, width, height, ptr_color) {
        const color = UTF8ToString(ptr_color);
        const obj = { bitmap_id, x, y, width, height, color };
        return SceneManager._scene.doProcess("Bitmap_fill_rect", obj);
    },


    // Sprite
    rgssenv_sprite_new: function(viewport_id, int_is_tiling) {
        const is_tiling = int_is_tiling === 0 ? false : true;
        const obj = { viewport_id, is_tiling };
        return SceneManager._scene.doProcess("Sprite_new", obj);
    },

    rgssenv_sprite_delete: function(sprite_id, viewport_id) {
        const obj = { sprite_id, viewport_id };
        return SceneManager._scene.doProcess("Sprite_delete", obj);
    },

    rgssenv_sprite_update: function(sprite_id) {
        const obj = { sprite_id };
        return SceneManager._scene.doProcess("Sprite_update", obj);
    },

    rgssenv_sprite_set_bitmap: function(sprite_id, bitmap_id) {
        const obj = { sprite_id, bitmap_id };
        return SceneManager._scene.doProcess("Sprite_set_bitmap", obj);
    },

    rgssenv_sprite_set_x: function(sprite_id, x) {
        const obj = { sprite_id, x };
        return SceneManager._scene.doProcess("Sprite_set_x", obj);
    },

    rgssenv_sprite_set_y: function(sprite_id, y) {
        const obj = { sprite_id, y };
        return SceneManager._scene.doProcess("Sprite_set_y", obj);
    },

    rgssenv_sprite_set_z: function(sprite_id, z) {
        const obj = { sprite_id, z };
        return SceneManager._scene.doProcess("Sprite_set_z", obj);
    },

    rgssenv_sprite_set_frame: function(sprite_id, x, y, width, height) {
        const obj = { sprite_id, x, y, width, height };
        return SceneManager._scene.doProcess("Sprite_set_frame", obj);
    },

    rgssenv_sprite_set_visible: function(sprite_id, intVisible) {
        const visible = intVisible === 0 ? false : true;
        const obj = { sprite_id, visible  };
        return SceneManager._scene.doProcess("Sprite_set_visible", obj);
    },

    rgssenv_sprite_set_opacity: function(sprite_id, opacity) {
        const obj = { sprite_id, opacity };
        return SceneManager._scene.doProcess("Sprite_set_opacity", obj);
    },


    // Window
    rgssenv_window_new: function(viewport_id) {
        const obj = { viewport_id };
        return SceneManager._scene.doProcess("Window_new", obj);
    },

    rgssenv_window_delete: function(window_id, viewport_id) {
        const obj = { window_id, viewport_id };
        return SceneManager._scene.doProcess("Window_delete", obj);
    },

    rgssenv_window_update: function(window_id) {
        const obj = { window_id };
        return SceneManager._scene.doProcess("Window_update", obj);
    },

    rgssenv_window_get_bitmap: function(window_id) {
        const obj = { window_id };
        return SceneManager._scene.doProcess("Window_get_bitmap", obj);
    },

    rgssenv_window_set_bitmap: function(window_id, bitmap_id) {
        const obj = { window_id, bitmap_id };
        return SceneManager._scene.doProcess("Window_set_bitmap", obj);
    },

    rgssenv_window_set_x: function(window_id, x) {
        const obj = { window_id, x };
        return SceneManager._scene.doProcess("Window_set_x", obj);
    },

    rgssenv_window_set_y: function(window_id, y) {
        const obj = { window_id, y };
        return SceneManager._scene.doProcess("Window_set_y", obj);
    },

    rgssenv_window_set_z: function(window_id, z) {
        const obj = { window_id, z };
        return SceneManager._scene.doProcess("Window_set_z", obj);
    },

    rgssenv_window_set_width: function(window_id, width) {
        const obj = { window_id, width };
        return SceneManager._scene.doProcess("Window_set_width", obj);
    },

    rgssenv_window_set_height: function(window_id, height) {
        const obj = { window_id, height };
        return SceneManager._scene.doProcess("Window_set_height", obj);
    },

    rgssenv_window_set_visible: function(window_id, int_visible) {
        const visible = int_visible === 0 ? false : true;
        const obj = { window_id, visible };
        return SceneManager._scene.doProcess("Window_set_visible", obj);
    },

    rgssenv_window_set_cursor_rect: function(window_id, x, y, width, height) {
        const obj = { window_id, x, y, width, height };
        return SceneManager._scene.doProcess("Window_set_cursor_rect", obj);
    },

    rgssenv_window_set_opacity: function(window_id, opacity) {
        const obj = { window_id, opacity };
        return SceneManager._scene.doProcess("Window_set_opacity", obj);
    },

    rgssenv_window_set_contents_opacity: function(window_id, opacity) {
        const obj = { window_id, opacity };
        return SceneManager._scene.doProcess("Window_set_contents_opacity", obj);
    },

    rgssenv_viewport_new: function() {
        return SceneManager._scene.doProcess("Viewport_new", null);
    },

    rgssenv_viewport_delete: function(viewport_id) {
        const obj = { viewport_id };
        return SceneManager._scene.doProcess("Viewport_delete", obj);
    },

    rgssenv_viewport_update: function(viewport_id) {
        const obj = { viewport_id };
        return SceneManager._scene.doProcess("Viewport_update", obj);
    },

    rgssenv_viewport_set_z: function(viewport_id, z) {
        const obj = { viewport_id, z };
        return SceneManager._scene.doProcess("Viewport_set_z", obj);
    },

    rgssenv_tilemap_new: function(viewport_id) {
        const obj = { viewport_id };
        return SceneManager._scene.doProcess("Tilemap_new", obj);
    },

    rgssenv_tilemap_delete: function(tilemap_id, viewport_id) {
        const obj = { tilemap_id, viewport_id };
        return SceneManager._scene.doProcess("Tilemap_delete", obj);
    },

    rgssenv_tilemap_update: function(tilemap_id) {
        const obj = { tilemap_id };
        return SceneManager._scene.doProcess("Tilemap_update", obj);
    },

    rgssenv_tilemap_set_origin: function(tilemap_id, ox, oy) {
        const obj = { tilemap_id, ox, oy };
        return SceneManager._scene.doProcess("Tilemap_set_origin", obj);
    },

    rgssenv_tilemap_set_tileset: function(tilemap_id, bitmap_id) {
        const obj = { tilemap_id, bitmap_id };
        return SceneManager._scene.doProcess("Tilemap_set_tileset", obj);
    },

    rgssenv_tilemap_set_autotile: function(tilemap_id, index, bitmap_id) {
        const obj = { tilemap_id, index, bitmap_id };
        return SceneManager._scene.doProcess("Tilemap_set_autotile", obj);
    },

    rgssenv_tilemap_set_map_data: function(tilemap_id, ptr_map_data, map_data_size, width, height) {
        const map_data = new Int16Array(map_data_size);
        for (let i = 0; i < map_data_size; i++) {
            map_data[i] = getValue(ptr_map_data + i * 2, "i16");
        }
        const obj = { tilemap_id, map_data, width, height };
        return SceneManager._scene.doProcess("Tilemap_set_map_data", obj);
    },

    rgssenv_tilemap_set_priorities: function(tilemap_id, ptr_priorities, priorities_size) {
        const priorities = new Int16Array(priorities_size);
        for (let i = 0; i < priorities_size; i++) {
            priorities[i] = getValue(ptr_priorities + i * 2, "i16");
        }
        const obj = { tilemap_id, priorities };
        return SceneManager._scene.doProcess("Tilemap_set_priorities", obj);
    },


    // Input
    rgssenv_input_is_pressed: function(keycode) {
        const obj = { keycode };
        return SceneManager._scene.doProcess("Input_is_pressed", obj);
    },

    rgssenv_input_is_triggered: function(keycode) {
        const obj = { keycode };
        return SceneManager._scene.doProcess("Input_is_triggered", obj);
    },

    rgssenv_input_is_repeated: function(keycode) {
        const obj = { keycode };
        return SceneManager._scene.doProcess("Input_is_repeated", obj);
    },

    rgssenv_input_dir4: function() {
        return SceneManager._scene.doProcess("Input_dir4", null);
    },

    rgssenv_input_dir8: function() {
        return SceneManager._scene.doProcess("Input_dir8", null);
    },


    // Audio
    rgssenv_audio_midi_bgm_play: function(ptr_name, pitch, volume) {
        const name = UTF8ToString(ptr_name);
        const obj = { name, pitch, volume };
        return SceneManager._scene.doProcess("Audio_MidiBgmPlay", obj);
    },

    rgssenv_audio_midi_bgm_stop: function() {
        return SceneManager._scene.doProcess("Audio_MidiBgmStop", null);
    },

    rgssenv_audio_midi_bgm_fade_out: function(duration) {
        const obj = { duration };
        // return SceneManager._scene.doProcess("Audio_MidiBgmFadeOut", obj);
    },

    rgssenv_audio_midi_me_play: function(ptr_name, pitch, volume) {
        const name = UTF8ToString(ptr_name);
        const obj = { name, pitch, volume };
        return SceneManager._scene.doProcess("Audio_MidiMePlay", obj);
    },

    rgssenv_audio_midi_me_stop: function() {
        // return SceneManager._scene.doProcess("Audio_MidiMeStop", null);
    },

    rgssenv_audio_midi_me_fade_out: function(duration) {
        const obj = { duration };
        // return SceneManager._scene.doProcess("Audio_MidiMeFadeOut", obj);
    },

    rgssenv_audio_ogg_bgm_play: function(ptr_name, pitch, volume) {
        const name = UTF8ToString(ptr_name);
        const obj = { name, pitch, volume };
        return SceneManager._scene.doProcess("Audio_OggBgmPlay", obj);
    },

    rgssenv_audio_ogg_bgm_stop: function() {
        return SceneManager._scene.doProcess("Audio_OggBgmStop", null);
    },

    rgssenv_audio_ogg_bgm_fade_out: function(duration) {
        const obj = { duration };
        return SceneManager._scene.doProcess("Audio_OggBgmFadeOut", obj);
    },

    rgssenv_audio_ogg_bgs_play: function(ptr_name, pitch, volume) {
        const name = UTF8ToString(ptr_name);
        const obj = { name, pitch, volume };
        return SceneManager._scene.doProcess("Audio_OggBgsPlay", obj);
    },

    rgssenv_audio_ogg_bgs_stop: function() {
        return SceneManager._scene.doProcess("Audio_OggBgsStop", null);
    },

    rgssenv_audio_ogg_bgs_fade_out: function(duration) {
        const obj = { duration };
        return SceneManager._scene.doProcess("Audio_OggBgsFadeOut", obj);
    },

    rgssenv_audio_ogg_me_play: function(ptr_name, pitch, volume) {
        const name = UTF8ToString(ptr_name);
        const obj = { name, pitch, volume };
        return SceneManager._scene.doProcess("Audio_OggMePlay", obj);
    },

    rgssenv_audio_ogg_me_stop: function() {
        return SceneManager._scene.doProcess("Audio_OggMeStop", null);
    },

    rgssenv_audio_ogg_me_fade_out: function(duration) {
        const obj = { duration };
        return SceneManager._scene.doProcess("Audio_OggMeFadeOut", obj);
    },

    rgssenv_audio_ogg_se_play: function(ptr_name, pitch, volume) {
        const name = UTF8ToString(ptr_name);
        const obj = { name, pitch, volume };
        return SceneManager._scene.doProcess("Audio_OggSePlay", obj);
    },

    rgssenv_audio_ogg_se_stop: function() {
        return SceneManager._scene.doProcess("Audio_OggSeStop", null);
    },

    rgssenv_audio_ogg_se_fade_out: function(duration) {
        const obj = { duration };
        return SceneManager._scene.doProcess("Audio_OggSeFadeOut", obj);
    },
});
