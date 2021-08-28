#pragma once

extern const uint8_t mfull[];

extern "C" {
    extern int init_rgss(void);
    extern int update_rgss(void);
#ifdef __EMSCRIPTEN__
    extern int rgss_send_message(const char* message);
    extern void rgss_file_read(const char* file_name, char* ptrBuf, int* ptrBufSize);
    extern void rgss_file_write(const char* file_name, char* ptrBuf, int bufSize);

    extern int rgssenv_bitmap_new(const char* file_name, int width, int height);
    extern int rgssenv_bitmap_check_created(int bitmap_id);
    extern int rgssenv_bitmap_delete(int bitmap_id);
    extern int rgssenv_bitmap_get_width(int bitmap_id);
    extern int rgssenv_bitmap_get_height(int bitmap_id);
    extern int rgssenv_bitmap_draw_text(int bitmap_id, const char* text, int x, int y, int width, int height, const char* ptr_align);
    extern int rgssenv_bitmap_measure_text_width(int bitmap_id, const char* text);
    extern int rgssenv_bitmap_set_font(int bitmap_id, const char* face, int size, int bold, int italic, const char* color);
    extern int rgssenv_bitmap_clear(int bitmap_id);
    extern int rgssenv_bitmap_blt(int bitmap_id, int src_bitmap_id, int sx, int sy, int sw, int sh, int dx, int dy, int dw, int dh);
    extern int rgssenv_bitmap_fill_rect(int bitmap_id, int x, int y, int width, int height, const char* color);

    extern int rgssenv_sprite_new(int viewport_id, int is_tiling);
    extern int rgssenv_sprite_delete(int sprite_id, int viewport_id);
    extern int rgssenv_sprite_update(int sprite_id);
    extern int rgssenv_sprite_set_bitmap(int sprite_id, int bitmap_id);
    extern int rgssenv_sprite_set_x(int sprite_id, int x);
    extern int rgssenv_sprite_set_y(int sprite_id, int y);
    extern int rgssenv_sprite_set_z(int sprite_id, int z);
    extern int rgssenv_sprite_set_frame(int sprite_id, int x, int y, int width, int height);
    extern int rgssenv_sprite_set_visible(int sprite_id, int visible);
    extern int rgssenv_sprite_set_opacity(int sprite_id, int opacity);

    extern int rgssenv_window_new(int viewport_id);
    extern int rgssenv_window_delete(int window_id, int viewport_id);
    extern int rgssenv_window_update(int window_id);
    extern int rgssenv_window_get_bitmap(int window_id);
    extern int rgssenv_window_set_bitmap(int window_id, int bitmap_id);
    extern int rgssenv_window_set_x(int window_id, int x);
    extern int rgssenv_window_set_y(int window_id, int y);
    extern int rgssenv_window_set_z(int window_id, int z);
    extern int rgssenv_window_set_width(int window_id, int width);
    extern int rgssenv_window_set_height(int window_id, int height);
    extern int rgssenv_window_set_visible(int window_id, int visible);
    extern int rgssenv_window_set_cursor_rect(int window_id, int x, int y, int width, int height);
    extern int rgssenv_window_set_opacity(int window_id, int opacity);
    extern int rgssenv_window_set_contents_opacity(int window_id, int opacity);

    extern int rgssenv_viewport_new(void);
    extern int rgssenv_viewport_delete(int viewport_id);
    extern int rgssenv_viewport_update(int viewport_id);
    extern int rgssenv_viewport_set_z(int viewport_id, int z);

    extern int rgssenv_tilemap_new(int viewport_id);
    extern int rgssenv_tilemap_delete(int tilemap_id, int viewport_id);
    extern int rgssenv_tilemap_update(int tilemap_id);
    extern int rgssenv_tilemap_set_origin(int tilemap_id, int ox, int oy);
    extern int rgssenv_tilemap_set_tileset(int tilemap_id, int bitmap_id);
    extern int rgssenv_tilemap_set_autotile(int tilemap_id, int index, int bitmap_id);
    extern int rgssenv_tilemap_set_map_data(int tilemap_id, const short* map_data, int map_data_size, int width, int height);
    extern int rgssenv_tilemap_set_priorities(int tilemap_id, const short* priorities, int priorities_size);

    extern int rgssenv_input_is_pressed(int keycode);
    extern int rgssenv_input_is_triggered(int keycode);
    extern int rgssenv_input_is_repeated(int keycode);
    extern int rgssenv_input_dir4(void);
    extern int rgssenv_input_dir8(void);

    extern int rgssenv_audio_midi_bgm_play(const char* name, int pitch, int volume);
    extern int rgssenv_audio_midi_bgm_stop(void);
    extern int rgssenv_audio_midi_bgm_fade_out(int duration);
    extern int rgssenv_audio_midi_me_play(const char* name, int pitch, int volume);
    extern int rgssenv_audio_midi_me_stop(void);
    extern int rgssenv_audio_midi_me_fade_out(int duration);
    extern int rgssenv_audio_ogg_bgm_play(const char* name, int pitch, int volume);
    extern int rgssenv_audio_ogg_bgm_stop(void);
    extern int rgssenv_audio_ogg_bgm_fade_out(int duration);
    extern int rgssenv_audio_ogg_bgs_play(const char* name, int pitch, int volume);
    extern int rgssenv_audio_ogg_bgs_stop(void);
    extern int rgssenv_audio_ogg_bgs_fade_out(int duration);
    extern int rgssenv_audio_ogg_me_play(const char* name, int pitch, int volume);
    extern int rgssenv_audio_ogg_me_stop(void);
    extern int rgssenv_audio_ogg_me_fade_out(int duration);
    extern int rgssenv_audio_ogg_se_play(const char* name, int pitch, int volume);
    extern int rgssenv_audio_ogg_se_stop(void);
    extern int rgssenv_audio_ogg_se_fade_out(int duration);

#endif
}
