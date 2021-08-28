=begin
Window
ゲーム内のウィンドウのクラス。内部的には複数のスプライトで構成されています。

スーパークラスObject 
クラスメソッドWindow.new([viewport]) 
Window オブジェクトを生成します。必要に応じてビューポート (Viewport) を指定します。

メソッドviewport 
生成時に指定されたビューポート (Viewport) を取得します。

dispose 
ウィンドウを解放します。すでに解放されている場合は何も行いません。

disposed? 
ウィンドウがすでに解放されている場合に真を返します。

update 
カーソルの点滅、ポーズサインのアニメーションを進めます。このメソッドは、原則として 1 フレームに 1 回呼び出します。

プロパティwindowskin 
ウィンドウスキンとして使用するビットマップ (Bitmap) への参照です。

contents 
ウィンドウ内容として表示するビットマップ (Bitmap) への参照です。

stretch 
壁紙の表示方法です。真のとき「拡大して表示」、偽のとき「並べて表示」になります。初期値は true です。

cursor_rect 
カーソルの矩形 (Rect) です。ウィンドウの左上隅を (-16, -16) とした相対座標で指定します。

active 
カーソルの点滅状態です。真のとき点滅します。

visible 
ウィンドウの可視状態です。真のとき可視になります。

pause 
ポーズサインの可視状態です。ポーズサインとは、メッセージウィンドウのボタン入力待ち状態を表わす記号のことです。真のとき可視になります。

x 
ウィンドウの X 座標です。

y 
ウィンドウの Y 座標です。

width 
ウィンドウの幅です。

height 
ウィンドウの高さです。

z 
ウィンドウ背景の Z 座標です。この値が大きいものほど手前に表示されます。Z 座標が同一の場合は、後に生成されたオブジェクトほど手前に表示されます。ウィンドウ内容の Z 座標は、ウィンドウ背景の Z 座標に 2 を加算した値になります。

ox 
ウィンドウ内容の転送元原点の X 座標です。この値を変化させることによってスクロールを行います。

oy 
ウィンドウ内容の転送元原点の Y 座標です。この値を変化させることによってスクロールを行います。

opacity 
ウィンドウの不透明度 (0 ～ 255) です。範囲外の値は自動で修正されます。

back_opacity 
ウィンドウ背景の不透明度 (0 ～ 255) です。範囲外の値は自動で修正されます。

contents_opacity 
ウィンドウ内容の不透明度 (0 ～ 255) です。範囲外の値は自動で修正されます。
=end

class Window
  attr_accessor :windowskin
  attr_accessor :stretch
  attr_accessor :cursor_rect
  attr_accessor :active
  attr_reader :visible
  attr_accessor :pause
  attr_reader :x
  attr_reader :y
  attr_reader :width
  attr_reader :height
  attr_reader :z
  attr_reader :ox
  attr_reader :oy
  attr_reader :opacity
  attr_reader :back_opacity
  attr_reader :contents_opacity

  def initialize(viewport = nil)
    @viewport = viewport
    if viewport
      @window_id = RGSSEnv.window_new(viewport.viewport_id)
    else
      @window_id = RGSSEnv.window_new(-1)
    end
    @disposed = false
    @x = 0
    @y = 0
    @z = 0
    @width = 0
    @height = 0
    @cursor_rect = Rect.new(0, 0, 0, 0)
    @ox = 0
    @oy = 0
    @active = true
    @bitmap = nil
    self.visible = true
    @stretch = true
    @pause = false
    self.opacity = 255
    self.back_opacity = 255
    self.contents_opacity = 255
  end

  def x=(x)
    RGSSEnv.window_set_x(@window_id, x - @ox)
    @x = x
  end

  def y=(y)
    RGSSEnv.window_set_y(@window_id, y - @oy)
    @y = y
  end

  def z=(z)
    RGSSEnv.window_set_z(@window_id, z)
    @z = z
  end

  def ox=(ox)
    RGSSEnv.window_set_x(@window_id, @x - ox)
    @ox = ox
  end

  def oy=(y)
    RGSSEnv.window_set_y(@window_id, @y - oy)
    @oy = oy
  end

  def width=(width)
    RGSSEnv.window_set_width(@window_id, width)
    @width = width
  end

  def height=(height)
    RGSSEnv.window_set_height(@window_id, height)
    @height = height
  end

  def contents
    @bitmap
  end

  def contents=(bitmap)
    if bitmap
      RGSSEnv.window_set_bitmap(@window_id, bitmap.bitmap_id)
    else
      RGSSEnv.window_set_bitmap(@window_id, -1)
    end
    @bitmap = bitmap
  end

  def visible=(visible)
    RGSSEnv.window_set_visible(@window_id, visible)
    @visible = visible
  end

  def dispose
    @disposed = true
    if @viewport
      RGSSEnv.window_delete(@window_id, @viewport.viewport_id)
    else
      RGSSEnv.window_delete(@window_id, -1)
    end
  end

  def disposed?
    @disposed
  end

  def update
    RGSSEnv.window_update(@window_id)
    x = @cursor_rect.x
    y = @cursor_rect.y
    width = @cursor_rect.width
    height = @cursor_rect.height
    RGSSEnv.window_set_cursor_rect(@window_id, x, y, width, height)
  end

  def opacity=(opacity)
    opacity = 255 if opacity > 255
    opacity = 0 if opacity < 0
    RGSSEnv.window_set_opacity(@window_id, opacity)
    @opacity = opacity
  end

  def back_opacity=(back_opacity)
    back_opacity = 255 if back_opacity > 255
    back_opacity = 0 if back_opacity < 0
    @back_opacity = back_opacity
  end

  def contents_opacity=(contents_opacity)
    contents_opacity = 255 if contents_opacity > 255
    contents_opacity = 0 if contents_opacity < 0
    RGSSEnv.window_set_contents_opacity(@window_id, contents_opacity)
    @contents_opacity = contents_opacity
  end
end
