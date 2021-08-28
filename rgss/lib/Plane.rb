=begin
Plane
プレーンのクラス。プレーンは、ビットマップのパターンを画面全体に並べて表示する特殊なスプライトで、パノラマやフォグを表示するために使います。

スーパークラスObject 
クラスメソッドPlane.new([viewport]) 
Plane オブジェクトを生成します。必要に応じてビューポート (Viewport) を指定します。

メソッドdispose 
プレーンを解放します。すでに解放されている場合は何も行いません。

disposed? 
プレーンがすでに解放されている場合に真を返します。

viewport 
生成時に指定されたビューポート (Viewport) を取得します。

プロパティbitmap 
プレーンとして使用するビットマップ (Bitmap) への参照です。

visible 
プレーンの可視状態です。真のとき可視になります。

z 
スプライトの Z 座標です。この値が大きいものほど手前に表示されます。Z 座標が同一の場合は、後に生成されたオブジェクトほど手前に表示されます。

ox 
プレーンの転送元原点の X 座標です。この値を変化させることによってスクロールを行います。

oy 
プレーンの転送元原点の Y 座標です。この値を変化させることによってスクロールを行います。

zoom_x 
プレーンの X 方向拡大率です。1.0 で等倍になります。

zoom_y 
プレーンの Y 方向拡大率です。1.0 で等倍になります。

opacity 
プレーンの不透明度です。0 ～ 255 の範囲で指定します。範囲外の値は自動で修正されます。

blend_type 
プレーンの合成方法 (0:通常、1:加算、2:減算) です。

color 
プレーンにブレンドする色 (Color) です。ブレンドの割合にはアルファ値が使用されます。

tone 
プレーンの色調 (Tone) です。

=end

class Plane
  attr_reader :bitmap
  attr_reader :visible
  attr_reader :z
  attr_reader :ox
  attr_reader :oy
  attr_reader :opacity
  attr_accessor :bitmap, :visible, :z, :ox, :oy, :zoom_x, :zoom_y, :blend_type, :color, :tone

  def initialize(viewport = nil)
    @viewport = viewport
    if viewport
      @sprite_id = RGSSEnv.sprite_new(viewport.viewport_id, true)
    else
      @sprite_id = RGSSEnv.sprite_new(-1, true)
    end
    @disposed = false
    @bitmap = nil
    @ox = 0
    @oy = 0
    @src_rect = Rect.new(0, 0, 0, 0)
  end

  def dispose
    @disposed = true
    Graphics._remove_sprite(self)
    if @viewport
      RGSSEnv.sprite_delete(@sprite_id, @viewport.viewport_id)
    else
      RGSSEnv.sprite_delete(@sprite_id, -1)
    end
  end

  def disposed?
    @disposed
  end

  def viewport
    @viewport
  end

  def bitmap=(bitmap)
    @bitmap = bitmap
    if bitmap
      @src_rect.set(0, 0, bitmap.width, bitmap.height)
      RGSSEnv.sprite_set_bitmap(@sprite_id, bitmap.bitmap_id)
    else
      RGSSEnv.sprite_set_bitmap(@sprite_id, -1)
    end
  end

  def ox=(ox)
    RGSSEnv.sprite_set_x(@sprite_id, -@ox)
    @ox = ox
  end

  def oy=(oy)
    RGSSEnv.sprite_set_y(@sprite_id, -@oy)
    @oy = oy
  end

  def z=(z)
    RGSSEnv.sprite_set_z(@sprite_id, z)
    @z = z
  end

  def visible=(visible)
    RGSSEnv.sprite_set_visible(@sprite_id, visible)
    @visible = visible
  end

  def opacity=(opacity)
    opacity = 255 if opacity > 255
    opacity = 0 if opacity < 0
    RGSSEnv.sprite_set_opacity(@sprite_id, opacity)
    @opacity = opacity
  end

  def _update_by_system
    RGSSEnv.sprite_update(@sprite_id)
    RGSSEnv.sprite_set_frame(@sprite_id, @src_rect.x, @src_rect.y, @src_rect.width, @src_rect.height)
    @bitmap._update_by_system if @bitmap
  end
end
