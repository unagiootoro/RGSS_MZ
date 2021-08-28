=begin
Bitmap
ビットマップのクラス。ビットマップは、いわゆる画像そのものを表わします。

画面にビットマップを表示するためにはスプライト (Sprite) などを使う必要があります。

スーパークラスObject 
クラスメソッドBitmap.new(filename) 
filename で指定した画像ファイルを読み込み、Bitmap オブジェクトを生成します。

RGSS-RTP、暗号化アーカイブに含まれるファイルも自動的に探します。拡張子は省略可能です。

Bitmap.new(width, height) 
指定したサイズの Bitmap オブジェクトを生成します。

メソッドdispose 
ビットマップを解放します。すでに解放されている場合は何も行いません。

disposed? 
ビットマップがすでに解放されている場合に真を返します。

width 
ビットマップの幅を取得します。

height 
ビットマップの高さを取得します。

rect 
ビットマップの矩形 (Rect) を取得します。

blt(x, y, src_bitmap, src_rect[, opacity]) 
src_bitmap の矩形 src_rect (Rect) から、このビットマップの座標 (x, y) にブロック転送を行います。

opacity には不透明度を 0 ～ 255 の範囲で指定できます。

stretch_blt(dest_rect, src_bitmap, src_rect[, opacity]) 
src_bitmap の矩形 src_rect (Rect) から、このビットマップの矩形 dest_rect (Rect) にブロック転送を行います。

opacity には不透明度を 0 ～ 255 の範囲で指定できます。

fill_rect(x, y, width, height, color) 
fill_rect(rect, color) 
このビットマップの矩形 (x, y, width, height) または rect (Rect) を color (Color) で塗り潰します。

clear 
ビットマップ全体をクリアします。

get_pixel(x, y) 
点 (x, y) の色 (Color) を取得します。

set_pixel(x, y, color) 
点 (x, y) の色を color (Color) に設定します。

hue_change(hue) 
色相を変換します。hue は色相 (360 度系) の変位を指定します。

この処理には時間がかかります。また、変換誤差のため、何度も変換を繰り返すと色が失われます。

draw_text(x, y, width, height, str[, align]) 
draw_text(rect, str[, align]) 
このビットマップの矩形 (x, y, width, height) または rect (Rect) に文字列 str を描画します。

テキストの長さが矩形の幅を超える場合は、幅を 60% まで自動的に縮小して描画します。

水平方向はデフォルトで左揃えですが、align に 1 を指定すると中央揃え、2 を指定すると右揃えになります。垂直方向は常に中央揃えです。

この処理には時間がかかるため、1 フレームごとに文字列を再描画するような使い方は推奨されません。

text_size(str) 
draw_text メソッドで文字列 str を描画したときの矩形 (Rect) を取得します。ただし、イタリックの場合の傾き分は含みません。

プロパティfont 
draw_text メソッドで文字列の描画に使用するフォント (Font) です。

=end

class Bitmap
  attr_reader :bitmap_id
  attr_reader :width
  attr_reader :height
  attr_reader :font

  def initialize(*args)
    if args.length == 1 && args[0].is_a?(Integer)
      initialize_1(*args)
    elsif args.length == 1 && args[0].is_a?(String)
      initialize_2(*args)
    elsif args.length == 2
      initialize_3(*args)
    else
      raise TypeError, "constructor is invalid."
    end
    loop_count = 0
    while true
      break if RGSSEnv.bitmap_check_created(@bitmap_id) == 1
      loop_count += 1
      raise "endless loop error." if loop_count > 1000
      Fiber.yield
    end
    @disposed = false
    @width = RGSSEnv.bitmap_get_width(@bitmap_id)
    @height = RGSSEnv.bitmap_get_height(@bitmap_id)
    self.font = Font.new
  end

  def initialize_1(bitmap_id)
    @bitmap_id = bitmap_id
  end

  def initialize_2(filename)
    file_path = _find_full_filename(filename)
    @bitmap_id = RGSSEnv.bitmap_new(file_path, 0, 0)
  end

  def initialize_3(width, height)
    @bitmap_id = RGSSEnv.bitmap_new(nil, width, height)
  end

  def _find_full_filename(filename)
    match_data = filename.match(/(.+)\/(.+)$/)
    target_dname = match_data[1]
    target_fname = match_data[2]
    file_path = GRAPHICS_FILE_LIST.find do |path|
      match_data = path.match(/(.+)\/(.+)\..+$/)
      dname = match_data[1]
      fname = match_data[2]
      fname_no_ext = fname.gsub(/\..+/, "")
      if match_data
        if fname_no_ext.upcase == target_fname.upcase && dname.upcase == target_dname.upcase
          next true
        end
      end
      false
    end
    raise "#{filename} is not found." unless file_path
    file_path
  end

  def dispose
    RGSSEnv.bitmap_delete(@bitmap_id)
    @disposed = true
  end

  def disposed?
    @disposed
  end

  def rect
    Rect.new(0, 0, @width, @height)
  end

  def blt(x, y, src_bitmap, src_rect, opacity = nil)
    sx = src_rect.x
    sy = src_rect.y
    sw = src_rect.width
    sh = src_rect.height
    dx = x
    dy = y
    dw = sw
    dh = sh
    RGSSEnv.bitmap_blt(@bitmap_id, src_bitmap.bitmap_id, sx, sy, sw, sh, x, y, sw, sh)
  end

  def stretch_blt(dest_rect, src_bitmap, src_rect, opacity = nil)
    sx = src_rect.x
    sy = src_rect.y
    sw = src_rect.width
    sh = src_rect.height
    dx = dest_rect.x
    dy = dest_rect.y
    dw = dest_rect.width
    dh = dest_rect.height
    RGSSEnv.bitmap_blt(@bitmap_id, src_bitmap.bitmap_id, sx, sy, sw, sh, dx, dy, dw, dh)
  end

  def fill_rect(*args)
    if args.length == 5
      fill_rect_1(*args)
    elsif args.length == 2
      fill_rect_2(*args)
    end
  end

  def fill_rect_1(x, y, width, height, color)
    RGSSEnv.bitmap_fill_rect(@bitmap_id, x, y, width, height, color.to_css_color)
  end

  def fill_rect_2(rect, color)
    fill_rect_1(rect.x, rect.y, rect.width, rect.height, color)
  end

  def clear
    RGSSEnv.bitmap_clear(@bitmap_id)
  end

  def get_pixel(x, y)

  end

  def set_pixel(x, y, color)

  end

  def hue_change(hue)

  end

  def draw_text(*args)
    if args.length == 5 || args.length == 6
      draw_text_1(*args)
    elsif args.length == 2 || args.length == 3
      draw_text_2(*args)
    else
      raise ArgumentError, "invalid args."
    end
  end

  def draw_text_1(x, y, width, height, str, align = 0)
    case align
    when 0
      str_align = "left"
    when 1
      str_align = "center"
    when 2
      str_align = "right"
    else
      raise TypeError, "align: #{align} is invalid."
    end
    RGSSEnv.bitmap_draw_text(@bitmap_id, str, x, y, width, height, str_align)
  end

  def draw_text_2(rect, str, align = 0)
    draw_text_1(rect.x, rect.y, rect.width, rect.height, str, align)
  end

  def text_size(str)
    width = RGSSEnv.bitmap_measure_text_width(@bitmap_id, str)
    Rect.new(0, 0, width, 32)
  end

  def font=(font)
    RGSSEnv.bitmap_set_font(@bitmap_id, font.name, font.size, font.bold, font.italic, font.color.to_css_color)
    @font = font
  end

  def _update_by_system
    if @font.need_update
      RGSSEnv.bitmap_set_font(@bitmap_id, @font.name, @font.size, @font.bold, @font.italic, @font.color.to_css_color)
    end
  end
end
