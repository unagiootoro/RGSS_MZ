#include <mruby.h>
#include <mruby/string.h>
#include <mruby/irep.h>
#include <mruby/array.h>
#include "main.h"
#include <stdio.h>
#include <stdlib.h>
#include "marshal.h"

static mrb_state* mrb;

static void dump_error(mrb_state *mrb) {
  mrb_print_error(mrb);
  mrb->exc = 0;
}

#ifdef __EMSCRIPTEN__
static mrb_value mrb_rgss_send_message(mrb_state *mrb, mrb_value self);
static mrb_value mrb_rgss_file_read(mrb_state *mrb, mrb_value self);
static mrb_value mrb_rgssenv_bitmap_draw_text(mrb_state *mrb, mrb_value self);

static mrb_value mrb_rgssenv_sprite_update(mrb_state *mrb, mrb_value self);
#endif

#ifdef __EMSCRIPTEN__
static mrb_value mrb_rgss_send_message(mrb_state *mrb, mrb_value self) {
  mrb_value mrb_message;
  mrb_get_args(mrb, "o", &mrb_message);
  const char* message = mrb_str_to_cstr(mrb, mrb_message);
  int res = rgss_send_message(message);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgss_file_read(mrb_state *mrb, mrb_value self) {
  mrb_value mrb_file_name, mrb_buf;
  mrb_get_args(mrb, "oo", &mrb_file_name, &mrb_buf);
  const char* file_name = mrb_str_to_cstr(mrb, mrb_file_name);
  int buf_size = 0;
  char* buf = RSTRING_PTR(mrb_buf);
  rgss_file_read(file_name, buf, &buf_size);
  return mrb_fixnum_value(buf_size);
}

static mrb_value mrb_rgss_file_write(mrb_state *mrb, mrb_value self) {
  mrb_value mrb_file_name, mrb_buf;
  mrb_int buf_size;
  mrb_get_args(mrb, "ooi", &mrb_file_name, &mrb_buf, &buf_size);
  const char* file_name = mrb_str_to_cstr(mrb, mrb_file_name);
  char* buf = RSTRING_PTR(mrb_buf);
  rgss_file_write(file_name, buf, buf_size);
  return mrb_fixnum_value(0);
}



// Bitmap
static mrb_value mrb_rgssenv_bitmap_new(mrb_state *mrb, mrb_value self) {
  mrb_value mrb_file_name;
  mrb_int width, height;
  const char* file_name;
  mrb_get_args(mrb, "oii", &mrb_file_name, &width, &height);
  if (mrb_nil_p(mrb_file_name)) {
    file_name = NULL;
  } else {
    file_name = mrb_str_to_cstr(mrb, mrb_file_name);
  }
  int res = rgssenv_bitmap_new(file_name, width, height);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_bitmap_check_created(mrb_state *mrb, mrb_value self) {
  mrb_int bitmap_id;
  mrb_get_args(mrb, "i", &bitmap_id);
  int res = rgssenv_bitmap_check_created(bitmap_id);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_bitmap_delete(mrb_state *mrb, mrb_value self) {
  mrb_int bitmap_id;
  mrb_get_args(mrb, "i", &bitmap_id);
  int res = rgssenv_bitmap_delete(bitmap_id);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_bitmap_get_width(mrb_state *mrb, mrb_value self) {
  mrb_int bitmap_id;
  mrb_get_args(mrb, "i", &bitmap_id);
  int res = rgssenv_bitmap_get_width(bitmap_id);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_bitmap_get_height(mrb_state *mrb, mrb_value self) {
  mrb_int bitmap_id;
  mrb_get_args(mrb, "i", &bitmap_id);
  int res = rgssenv_bitmap_get_height(bitmap_id);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_bitmap_draw_text(mrb_state *mrb, mrb_value self) {
  int bitmap_id;
  mrb_value mrb_text;
  const char* text;
  int x, y, width, height;
  mrb_value mrb_align;
  const char* align;
  mrb_get_args(mrb, "ioiiiio", &bitmap_id, &mrb_text, &x, &y, &width, &height, &mrb_align);
  text = mrb_str_to_cstr(mrb, mrb_text);
  align = mrb_str_to_cstr(mrb, mrb_align);
  int res = rgssenv_bitmap_draw_text(bitmap_id, text, x, y, width, height, align);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_bitmap_measure_text_width(mrb_state *mrb, mrb_value self) {
  mrb_int bitmap_id;
  mrb_value mrb_text;
  const char* text;
  mrb_get_args(mrb, "io", &bitmap_id, &mrb_text);
  text = mrb_str_to_cstr(mrb, mrb_text);
  int res = rgssenv_bitmap_measure_text_width(bitmap_id, text);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_bitmap_set_font(mrb_state *mrb, mrb_value self) {
  mrb_value mrb_face;
  mrb_value mrb_bold;
  mrb_value mrb_italic;
  mrb_value mrb_color;
  mrb_int bitmap_id;
  const char* face;
  mrb_int size;
  int bold;
  int italic;
  const char* color;

  mrb_get_args(mrb, "ioiooo", &bitmap_id, &mrb_face, &size, &mrb_bold, &mrb_italic, &mrb_color);
  face = mrb_str_to_cstr(mrb, mrb_face);
  bold = mrb_true_p(mrb_bold) ? 1 : 0;
  italic = mrb_true_p(mrb_italic) ? 1 : 0;
  color = mrb_str_to_cstr(mrb, mrb_color);

  int res = rgssenv_bitmap_set_font(bitmap_id, face, size, bold, italic, color);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_bitmap_clear(mrb_state *mrb, mrb_value self) {
  mrb_int bitmap_id;
  mrb_get_args(mrb, "i", &bitmap_id);
  int res = rgssenv_bitmap_clear(bitmap_id);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_bitmap_blt(mrb_state *mrb, mrb_value self) {
  mrb_int bitmap_id;
  mrb_int src_bitmap_id;
  int sx, sy, sw, sh;
  int dx, dy, dw, dh;
  mrb_get_args(mrb, "iiiiiiiiii", &bitmap_id, &src_bitmap_id, &sx, &sy, &sw, &sh, &dx, &dy, &dw, &dh);
  int res = rgssenv_bitmap_blt(bitmap_id, src_bitmap_id, sx, sy, sw, sh, dx, dy, dw, dh);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_bitmap_fill_rect(mrb_state *mrb, mrb_value self) {
  mrb_int bitmap_id;
  int x, y, width, height;
  mrb_value mrb_color;
  const char* color;
  mrb_get_args(mrb, "iiiiio", &bitmap_id, &x, &y, &width, &height, &mrb_color);
  color = mrb_str_to_cstr(mrb, mrb_color);
  int res = rgssenv_bitmap_fill_rect(bitmap_id, x, y, width, height, color);
  return mrb_fixnum_value(res);
}


// Sprite
static mrb_value mrb_rgssenv_sprite_new(mrb_state *mrb, mrb_value self) {
  int viewport_id;
  mrb_value mrb_is_tiling;
  int is_tiling;
  mrb_get_args(mrb, "io", &viewport_id, &is_tiling);
  is_tiling = mrb_true_p(mrb_is_tiling) ? 1 : 0;
  int res = rgssenv_sprite_new(viewport_id, is_tiling);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_sprite_delete(mrb_state *mrb, mrb_value self) {
  int sprite_id;
  int viewport_id;
  mrb_get_args(mrb, "ii", &sprite_id, &viewport_id);
  int res = rgssenv_sprite_delete(sprite_id, viewport_id);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_sprite_update(mrb_state *mrb, mrb_value self) {
  int sprite_id;
  mrb_get_args(mrb, "i", &sprite_id);
  int res = rgssenv_sprite_update(sprite_id);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_sprite_set_bitmap(mrb_state *mrb, mrb_value self) {
  int sprite_id;
  int bitmap_id;
  mrb_get_args(mrb, "ii", &sprite_id, &bitmap_id);
  int res = rgssenv_sprite_set_bitmap(sprite_id, bitmap_id);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_sprite_set_x(mrb_state *mrb, mrb_value self) {
  int sprite_id;
  int x;
  mrb_get_args(mrb, "ii", &sprite_id, &x);
  int res = rgssenv_sprite_set_x(sprite_id, x);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_sprite_set_y(mrb_state *mrb, mrb_value self) {
  int sprite_id;
  int y;
  mrb_get_args(mrb, "ii", &sprite_id, &y);
  int res = rgssenv_sprite_set_y(sprite_id, y);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_sprite_set_z(mrb_state *mrb, mrb_value self) {
  int sprite_id;
  int z;
  mrb_get_args(mrb, "ii", &sprite_id, &z);
  int res = rgssenv_sprite_set_z(sprite_id, z);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_sprite_set_frame(mrb_state *mrb, mrb_value self) {
  int sprite_id;
  int x, y, width, height;
  mrb_get_args(mrb, "iiiii", &sprite_id, &x, &y, &width, &height);
  int res = rgssenv_sprite_set_frame(sprite_id, x, y, width, height);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_sprite_set_visible(mrb_state *mrb, mrb_value self) {
  int sprite_id;
  mrb_value mrb_visible;
  int visible;
  mrb_get_args(mrb, "io", &sprite_id, &mrb_visible);
  visible = mrb_true_p(mrb_visible) ? 1 : 0;
  int res = rgssenv_sprite_set_visible(sprite_id, visible);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_sprite_set_opacity(mrb_state *mrb, mrb_value self) {
  int sprite_id;
  int opacity;
  mrb_get_args(mrb, "ii", &sprite_id, &opacity);
  int res = rgssenv_sprite_set_opacity(sprite_id, opacity);
  return mrb_fixnum_value(res);
}


// Window
static mrb_value mrb_rgssenv_window_new(mrb_state *mrb, mrb_value self) {
  mrb_int viewport_id;
  mrb_get_args(mrb, "i", &viewport_id);
  int res = rgssenv_window_new(viewport_id);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_window_delete(mrb_state *mrb, mrb_value self) {
  mrb_int window_id;
  mrb_int viewport_id;
  mrb_get_args(mrb, "ii", &window_id, &viewport_id);
  int res = rgssenv_window_delete(window_id, viewport_id);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_window_update(mrb_state *mrb, mrb_value self) {
  mrb_int window_id;
  mrb_get_args(mrb, "i", &window_id);
  int res = rgssenv_window_update(window_id);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_window_get_bitmap(mrb_state *mrb, mrb_value self) {
  mrb_int window_id;
  mrb_get_args(mrb, "i", &window_id);
  int res = rgssenv_window_get_bitmap(window_id);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_window_set_bitmap(mrb_state *mrb, mrb_value self) {
  mrb_int window_id;
  mrb_int bitmap_id;
  mrb_get_args(mrb, "ii", &window_id, &bitmap_id);
  int res = rgssenv_window_set_bitmap(window_id, bitmap_id);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_window_set_x(mrb_state *mrb, mrb_value self) {
  mrb_int window_id;
  mrb_int x;
  mrb_get_args(mrb, "ii", &window_id, &x);
  int res = rgssenv_window_set_x(window_id, x);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_window_set_y(mrb_state *mrb, mrb_value self) {
  mrb_int window_id;
  mrb_int y;
  mrb_get_args(mrb, "ii", &window_id, &y);
  int res = rgssenv_window_set_y(window_id, y);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_window_set_z(mrb_state *mrb, mrb_value self) {
  mrb_int window_id;
  mrb_int z;
  mrb_get_args(mrb, "ii", &window_id, &z);
  int res = rgssenv_window_set_z(window_id, z);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_window_set_width(mrb_state *mrb, mrb_value self) {
  mrb_int window_id;
  mrb_int width;
  mrb_get_args(mrb, "ii", &window_id, &width);
  int res = rgssenv_window_set_width(window_id, width);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_window_set_height(mrb_state *mrb, mrb_value self) {
  mrb_int window_id;
  mrb_int height;
  mrb_get_args(mrb, "ii", &window_id, &height);
  int res = rgssenv_window_set_height(window_id, height);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_window_set_visible(mrb_state *mrb, mrb_value self) {
  mrb_int window_id;
  mrb_value mrb_visible;
  int visible;
  mrb_get_args(mrb, "io", &window_id, &mrb_visible);
  visible = mrb_true_p(mrb_visible) ? 1 : 0;
  int res = rgssenv_window_set_visible(window_id, visible);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_window_set_cursor_rect(mrb_state *mrb, mrb_value self) {
  mrb_int window_id;
  mrb_int x, y, width, height;
  mrb_get_args(mrb, "iiiii", &window_id, &x, &y, &width, &height);
  int res = rgssenv_window_set_cursor_rect(window_id, x, y, width, height);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_window_set_opacity(mrb_state *mrb, mrb_value self) {
  mrb_int window_id;
  mrb_int opacity;
  mrb_get_args(mrb, "ii", &window_id, &opacity);
  int res = rgssenv_window_set_opacity(window_id, opacity);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_window_set_contents_opacity(mrb_state *mrb, mrb_value self) {
  mrb_int window_id;
  mrb_int opacity;
  mrb_get_args(mrb, "ii", &window_id, &opacity);
  int res = rgssenv_window_set_contents_opacity(window_id, opacity);
  return mrb_fixnum_value(res);
}


// Viewport
static mrb_value mrb_rgssenv_viewport_new(mrb_state *mrb, mrb_value self) {
  int res = rgssenv_viewport_new();
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_viewport_delete(mrb_state *mrb, mrb_value self) {
  mrb_int viewport_id;
  mrb_get_args(mrb, "i", &viewport_id);
  int res = rgssenv_viewport_delete(viewport_id);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_viewport_update(mrb_state *mrb, mrb_value self) {
  mrb_int viewport_id;
  mrb_get_args(mrb, "i", &viewport_id);
  int res = rgssenv_viewport_update(viewport_id);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_viewport_set_z(mrb_state *mrb, mrb_value self) {
  mrb_int viewport_id;
  mrb_int z;
  mrb_get_args(mrb, "ii", &viewport_id, &z);
  int res = rgssenv_viewport_set_z(viewport_id, z);
  return mrb_fixnum_value(res);
}


// Tilemap
static mrb_value mrb_rgssenv_tilemap_new(mrb_state *mrb, mrb_value self) {
  mrb_int viewport_id;
  mrb_get_args(mrb, "i", &viewport_id);
  int res = rgssenv_tilemap_new(viewport_id);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_tilemap_delete(mrb_state *mrb, mrb_value self) {
  mrb_int tilemap_id;
  mrb_int viewport_id;
  mrb_get_args(mrb, "ii", &tilemap_id, &viewport_id);
  int res = rgssenv_tilemap_delete(tilemap_id, viewport_id);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_tilemap_update(mrb_state *mrb, mrb_value self) {
  mrb_int tilemap_id;
  mrb_get_args(mrb, "i", &tilemap_id);
  int res = rgssenv_tilemap_update(tilemap_id);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_tilemap_set_origin(mrb_state *mrb, mrb_value self) {
  mrb_int tilemap_id;
  mrb_int ox, oy;
  mrb_get_args(mrb, "iii", &tilemap_id, &ox, &oy);
  int res = rgssenv_tilemap_set_origin(tilemap_id, ox, oy);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_tilemap_set_tileset(mrb_state *mrb, mrb_value self) {
  mrb_int tilemap_id;
  mrb_int bitmap_id;
  mrb_get_args(mrb, "ii", &tilemap_id, &bitmap_id);
  int res = rgssenv_tilemap_set_tileset(tilemap_id, bitmap_id);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_tilemap_set_autotile(mrb_state *mrb, mrb_value self) {
  mrb_int tilemap_id;
  mrb_int index;
  mrb_int bitmap_id;
  mrb_get_args(mrb, "iii", &tilemap_id, &index, &bitmap_id);
  int res = rgssenv_tilemap_set_autotile(tilemap_id, index, bitmap_id);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_tilemap_set_map_data(mrb_state *mrb, mrb_value self) {
  mrb_int tilemap_id;
  mrb_value mrb_map_data;
  mrb_value mrb_val;
  short* map_data;
  int i;
  int size;
  mrb_int width, height;
  mrb_get_args(mrb, "ioii", &tilemap_id, &mrb_map_data, &width, &height);

  size = width * height * 3;
  map_data = (short*)malloc(size * sizeof(short));
  for (i = 0; i < size; i++) {
    mrb_val = mrb_ary_entry(mrb_map_data, i);
    map_data[i] = (short)mrb_fixnum(mrb_val);
  }

  int res = rgssenv_tilemap_set_map_data(tilemap_id, (const short*)map_data, size, width, height);
  free(map_data);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_tilemap_set_priorities(mrb_state *mrb, mrb_value self) {
  mrb_int tilemap_id;
  mrb_value mrb_priorities;
  mrb_value mrb_val;
  short* priorities;
  int i;
  mrb_int size;
  mrb_get_args(mrb, "ioi", &tilemap_id, &mrb_priorities, &size);

  priorities = (short*)malloc(size * sizeof(short));
  for (i = 0; i < size; i++) {
    mrb_val = mrb_ary_entry(mrb_priorities, i);
    priorities[i] = (short)mrb_fixnum(mrb_val);
  }

  int res = rgssenv_tilemap_set_priorities(tilemap_id, (const short*)priorities, size);
  free(priorities);
  return mrb_fixnum_value(res);
}


// Input
static mrb_value mrb_rgssenv_input_is_pressed(mrb_state *mrb, mrb_value self) {
  mrb_int keycode;
  mrb_get_args(mrb, "i", &keycode);
  int res = rgssenv_input_is_pressed(keycode);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_input_is_triggered(mrb_state *mrb, mrb_value self) {
  mrb_int keycode;
  mrb_get_args(mrb, "i", &keycode);
  int res = rgssenv_input_is_triggered(keycode);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_input_is_repeated(mrb_state *mrb, mrb_value self) {
  mrb_int keycode;
  mrb_get_args(mrb, "i", &keycode);
  int res = rgssenv_input_is_repeated(keycode);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_input_dir4(mrb_state *mrb, mrb_value self) {
  int res = rgssenv_input_dir4();
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_input_dir8(mrb_state *mrb, mrb_value self) {
  int res = rgssenv_input_dir8();
  return mrb_fixnum_value(res);
}


// Audio
static mrb_value mrb_rgssenv_audio_midi_bgm_play(mrb_state *mrb, mrb_value self) {
  mrb_value mrb_name;
  mrb_int pitch, volume;
  const char* name;
  mrb_get_args(mrb, "oii", &mrb_name, &pitch, &volume);
  name = mrb_str_to_cstr(mrb, mrb_name);
  int res = rgssenv_audio_midi_bgm_play(name, pitch, volume);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_audio_midi_bgm_stop(mrb_state *mrb, mrb_value self) {
  int res = rgssenv_audio_midi_bgm_stop();
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_audio_midi_bgm_fade_out(mrb_state *mrb, mrb_value self) {
  mrb_int duration;
  mrb_get_args(mrb, "i", &duration);
  int res = rgssenv_audio_midi_bgm_fade_out(duration);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_audio_midi_me_play(mrb_state *mrb, mrb_value self) {
  mrb_value mrb_name;
  mrb_int pitch, volume;
  const char* name;
  mrb_get_args(mrb, "oii", &mrb_name, &pitch, &volume);
  name = mrb_str_to_cstr(mrb, mrb_name);
  int res = rgssenv_audio_midi_me_play(name, pitch, volume);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_audio_midi_me_stop(mrb_state *mrb, mrb_value self) {
  int res = rgssenv_audio_midi_bgm_stop();
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_audio_midi_me_fade_out(mrb_state *mrb, mrb_value self) {
  mrb_int duration;
  mrb_get_args(mrb, "i", &duration);
  int res = rgssenv_audio_midi_bgm_fade_out(duration);
  return mrb_fixnum_value(res);
}



static mrb_value mrb_rgssenv_audio_ogg_bgm_play(mrb_state *mrb, mrb_value self) {
  mrb_value mrb_name;
  mrb_int pitch, volume;
  const char* name;
  mrb_get_args(mrb, "oii", &mrb_name, &pitch, &volume);
  name = mrb_str_to_cstr(mrb, mrb_name);
  int res = rgssenv_audio_ogg_bgm_play(name, pitch, volume);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_audio_ogg_bgm_stop(mrb_state *mrb, mrb_value self) {
  int res = rgssenv_audio_ogg_bgm_stop();
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_audio_ogg_bgm_fade_out(mrb_state *mrb, mrb_value self) {
  mrb_int duration;
  mrb_get_args(mrb, "i", &duration);
  int res = rgssenv_audio_ogg_bgm_fade_out(duration);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_audio_ogg_bgs_play(mrb_state *mrb, mrb_value self) {
  mrb_value mrb_name;
  mrb_int pitch, volume;
  const char* name;
  mrb_get_args(mrb, "oii", &mrb_name, &pitch, &volume);
  name = mrb_str_to_cstr(mrb, mrb_name);
  int res = rgssenv_audio_ogg_bgs_play(name, pitch, volume);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_audio_ogg_bgs_stop(mrb_state *mrb, mrb_value self) {
  int res = rgssenv_audio_ogg_bgs_stop();
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_audio_ogg_bgs_fade_out(mrb_state *mrb, mrb_value self) {
  mrb_int duration;
  mrb_get_args(mrb, "i", &duration);
  int res = rgssenv_audio_ogg_bgs_fade_out(duration);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_audio_ogg_me_play(mrb_state *mrb, mrb_value self) {
  mrb_value mrb_name;
  mrb_int pitch, volume;
  const char* name;
  mrb_get_args(mrb, "oii", &mrb_name, &pitch, &volume);
  name = mrb_str_to_cstr(mrb, mrb_name);
  int res = rgssenv_audio_ogg_me_play(name, pitch, volume);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_audio_ogg_me_stop(mrb_state *mrb, mrb_value self) {
  int res = rgssenv_audio_ogg_bgm_stop();
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_audio_ogg_me_fade_out(mrb_state *mrb, mrb_value self) {
  mrb_int duration;
  mrb_get_args(mrb, "i", &duration);
  int res = rgssenv_audio_ogg_me_fade_out(duration);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_audio_ogg_se_play(mrb_state *mrb, mrb_value self) {
  mrb_value mrb_name;
  mrb_int pitch, volume;
  const char* name;
  mrb_get_args(mrb, "oii", &mrb_name, &pitch, &volume);
  name = mrb_str_to_cstr(mrb, mrb_name);
  int res = rgssenv_audio_ogg_se_play(name, pitch, volume);
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_audio_ogg_se_stop(mrb_state *mrb, mrb_value self) {
  int res = rgssenv_audio_ogg_bgm_stop();
  return mrb_fixnum_value(res);
}

static mrb_value mrb_rgssenv_audio_ogg_se_fade_out(mrb_state *mrb, mrb_value self) {
  mrb_int duration;
  mrb_get_args(mrb, "i", &duration);
  int res = rgssenv_audio_ogg_se_fade_out(duration);
  return mrb_fixnum_value(res);
}


#else
int main() {
  init_rgss();
  while (1) {
    update_rgss();
  }
  mrb_close(mrb);
  return 0;
}
#endif


int init_rgss(void) {
  mrb = mrb_open();
  mrb_load_irep(mrb, mfull);
  // mrb_mruby_marshal_gem_init(mrb);

#ifdef __EMSCRIPTEN__
  struct RClass *rgss_env = mrb_define_module(mrb, "RGSSEnv");
  mrb_define_class_method(mrb, rgss_env, "rgss_send_message", mrb_rgss_send_message, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "rgss_file_read", mrb_rgss_file_read, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, rgss_env, "rgss_file_write", mrb_rgss_file_write, MRB_ARGS_REQ(3));

  mrb_define_class_method(mrb, rgss_env, "sprite_new", mrb_rgssenv_sprite_new, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, rgss_env, "sprite_delete", mrb_rgssenv_sprite_delete, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, rgss_env, "sprite_update", mrb_rgssenv_sprite_update, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "sprite_set_bitmap", mrb_rgssenv_sprite_set_bitmap, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, rgss_env, "sprite_set_x", mrb_rgssenv_sprite_set_x, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, rgss_env, "sprite_set_y", mrb_rgssenv_sprite_set_y, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, rgss_env, "sprite_set_z", mrb_rgssenv_sprite_set_z, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, rgss_env, "sprite_set_frame", mrb_rgssenv_sprite_set_frame, MRB_ARGS_REQ(5));
  mrb_define_class_method(mrb, rgss_env, "sprite_set_visible", mrb_rgssenv_sprite_set_visible, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, rgss_env, "sprite_set_opacity", mrb_rgssenv_sprite_set_opacity, MRB_ARGS_REQ(2));

  mrb_define_class_method(mrb, rgss_env, "bitmap_new", mrb_rgssenv_bitmap_new, MRB_ARGS_REQ(3));
  mrb_define_class_method(mrb, rgss_env, "bitmap_check_created", mrb_rgssenv_bitmap_check_created, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "bitmap_delete", mrb_rgssenv_bitmap_delete, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "bitmap_get_width", mrb_rgssenv_bitmap_get_width, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "bitmap_get_height", mrb_rgssenv_bitmap_get_height, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "bitmap_draw_text", mrb_rgssenv_bitmap_draw_text, MRB_ARGS_REQ(7));
  mrb_define_class_method(mrb, rgss_env, "bitmap_measure_text_width", mrb_rgssenv_bitmap_measure_text_width, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, rgss_env, "bitmap_set_font", mrb_rgssenv_bitmap_set_font, MRB_ARGS_REQ(6));
  mrb_define_class_method(mrb, rgss_env, "bitmap_clear", mrb_rgssenv_bitmap_clear, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "bitmap_blt", mrb_rgssenv_bitmap_blt, MRB_ARGS_REQ(10));
  mrb_define_class_method(mrb, rgss_env, "bitmap_fill_rect", mrb_rgssenv_bitmap_fill_rect, MRB_ARGS_REQ(6));

  mrb_define_class_method(mrb, rgss_env, "window_new", mrb_rgssenv_window_new, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "window_delete", mrb_rgssenv_window_delete, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, rgss_env, "window_update", mrb_rgssenv_window_update, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "window_get_bitmap", mrb_rgssenv_window_get_bitmap, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "window_set_bitmap", mrb_rgssenv_window_set_bitmap, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, rgss_env, "window_set_x", mrb_rgssenv_window_set_x, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, rgss_env, "window_set_y", mrb_rgssenv_window_set_y, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, rgss_env, "window_set_z", mrb_rgssenv_window_set_z, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, rgss_env, "window_set_width", mrb_rgssenv_window_set_width, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, rgss_env, "window_set_height", mrb_rgssenv_window_set_height, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, rgss_env, "window_set_visible", mrb_rgssenv_window_set_visible, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, rgss_env, "window_set_cursor_rect", mrb_rgssenv_window_set_cursor_rect, MRB_ARGS_REQ(5));
  mrb_define_class_method(mrb, rgss_env, "window_set_opacity", mrb_rgssenv_window_set_opacity, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, rgss_env, "window_set_contents_opacity", mrb_rgssenv_window_set_contents_opacity, MRB_ARGS_REQ(2));

  mrb_define_class_method(mrb, rgss_env, "viewport_new", mrb_rgssenv_viewport_new, MRB_ARGS_NONE());
  mrb_define_class_method(mrb, rgss_env, "viewport_delete", mrb_rgssenv_viewport_delete, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "viewport_update", mrb_rgssenv_viewport_update, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "viewport_set_z", mrb_rgssenv_viewport_set_z, MRB_ARGS_REQ(2));

  mrb_define_class_method(mrb, rgss_env, "tilemap_new", mrb_rgssenv_tilemap_new, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "tilemap_delete", mrb_rgssenv_tilemap_delete, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, rgss_env, "tilemap_update", mrb_rgssenv_tilemap_update, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "tilemap_set_origin", mrb_rgssenv_tilemap_set_origin, MRB_ARGS_REQ(3));
  mrb_define_class_method(mrb, rgss_env, "tilemap_set_tileset", mrb_rgssenv_tilemap_set_tileset, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, rgss_env, "tilemap_set_autotile", mrb_rgssenv_tilemap_set_autotile, MRB_ARGS_REQ(3));
  mrb_define_class_method(mrb, rgss_env, "tilemap_set_map_data", mrb_rgssenv_tilemap_set_map_data, MRB_ARGS_REQ(4));
  mrb_define_class_method(mrb, rgss_env, "tilemap_set_priorities", mrb_rgssenv_tilemap_set_priorities, MRB_ARGS_REQ(2));

  mrb_define_class_method(mrb, rgss_env, "input_is_pressed", mrb_rgssenv_input_is_pressed, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "input_is_triggered", mrb_rgssenv_input_is_triggered, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "input_is_repeated", mrb_rgssenv_input_is_repeated, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "input_dir4", mrb_rgssenv_input_dir4, MRB_ARGS_NONE());
  mrb_define_class_method(mrb, rgss_env, "input_dir8", mrb_rgssenv_input_dir8, MRB_ARGS_NONE());

  mrb_define_class_method(mrb, rgss_env, "audio_midi_bgm_play", mrb_rgssenv_audio_midi_bgm_play, MRB_ARGS_REQ(3));
  mrb_define_class_method(mrb, rgss_env, "audio_midi_bgm_stop", mrb_rgssenv_audio_ogg_bgm_stop, MRB_ARGS_NONE());
  mrb_define_class_method(mrb, rgss_env, "audio_midi_bgm_fade_out", mrb_rgssenv_audio_midi_bgm_fade_out, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "audio_midi_me_play", mrb_rgssenv_audio_midi_me_play, MRB_ARGS_REQ(3));
  mrb_define_class_method(mrb, rgss_env, "audio_midi_me_stop", mrb_rgssenv_audio_midi_me_stop, MRB_ARGS_NONE());
  mrb_define_class_method(mrb, rgss_env, "audio_midi_me_fade_out", mrb_rgssenv_audio_midi_me_fade_out, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "audio_ogg_bgm_play", mrb_rgssenv_audio_ogg_bgm_play, MRB_ARGS_REQ(3));
  mrb_define_class_method(mrb, rgss_env, "audio_ogg_bgm_stop", mrb_rgssenv_audio_ogg_bgm_stop, MRB_ARGS_NONE());
  mrb_define_class_method(mrb, rgss_env, "audio_ogg_bgm_fade_out", mrb_rgssenv_audio_ogg_bgm_fade_out, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "audio_ogg_bgs_play", mrb_rgssenv_audio_ogg_bgs_play, MRB_ARGS_REQ(3));
  mrb_define_class_method(mrb, rgss_env, "audio_ogg_bgs_stop", mrb_rgssenv_audio_ogg_bgs_stop, MRB_ARGS_NONE());
  mrb_define_class_method(mrb, rgss_env, "audio_ogg_bgs_fade_out", mrb_rgssenv_audio_ogg_bgs_fade_out, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "audio_ogg_me_play", mrb_rgssenv_audio_ogg_me_play, MRB_ARGS_REQ(3));
  mrb_define_class_method(mrb, rgss_env, "audio_ogg_me_stop", mrb_rgssenv_audio_ogg_me_stop, MRB_ARGS_NONE());
  mrb_define_class_method(mrb, rgss_env, "audio_ogg_me_fade_out", mrb_rgssenv_audio_ogg_me_fade_out, MRB_ARGS_REQ(1));
  mrb_define_class_method(mrb, rgss_env, "audio_ogg_se_play", mrb_rgssenv_audio_ogg_se_play, MRB_ARGS_REQ(3));
  mrb_define_class_method(mrb, rgss_env, "audio_ogg_se_stop", mrb_rgssenv_audio_ogg_se_stop, MRB_ARGS_NONE());
  mrb_define_class_method(mrb, rgss_env, "audio_ogg_se_fade_out", mrb_rgssenv_audio_ogg_se_fade_out, MRB_ARGS_REQ(1));

#endif

  struct RClass* rgss_main = mrb_module_get(mrb, "RGSSMain");
  mrb_value mrb_rgss_main = mrb_obj_value(rgss_main);
  mrb_funcall(mrb, mrb_rgss_main, "init_rgss", 0);
  return 0;
}

int update_rgss(void) {
  int error_flag = 0;
  struct RClass* rgss_main = mrb_module_get(mrb, "RGSSMain");
  mrb_value mrb_rgss_main = mrb_obj_value(rgss_main);

  int arena = mrb_gc_arena_save(mrb);
  mrb_funcall(mrb, mrb_rgss_main, "update_rgss", 0);
  if (mrb->exc) {
    dump_error(mrb);
    error_flag = 1;
  }
  mrb_gc_arena_restore(mrb, arena);
  return error_flag;
}
