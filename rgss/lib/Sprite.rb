=begin
Sprite
スプライトのクラス。スプライトは、ゲーム画面上にキャラクター等を表示するための基本概念です。

スーパークラスObject 
クラスメソッドSprite.new([viewport]) 
Sprite オブジェクトを生成します。必要に応じてビューポート (Viewport) を指定します。

メソッドdispose 
スプライトを解放します。すでに解放されている場合は何も行いません。

disposed? 
スプライトがすでに解放されている場合に真を返します。

viewport 
生成時に指定されたビューポート (Viewport) を取得します。

flash(color, duration) 
スプライトのフラッシュを開始します。duration はフラッシュにかけるフレーム数です。

color に nil を指定した場合は、フラッシュの時間分スプライト自体を消去します。

update 
スプライトのフラッシュを進めます。このメソッドは、原則として 1 フレームに 1 回呼び出します。

フラッシュの必要がない場合は呼び出さなくても構いません。

プロパティbitmap 
転送元とするビットマップ (Bitmap) への参照です。

src_rect 
ビットマップから転送される矩形 (Rect) です。

visible 
スプライトの可視状態です。真のとき可視になります。

x 
スプライトの X 座標です。

y 
スプライトの Y 座標です。

z 
スプライトの Z 座標です。この値が大きいものほど手前に表示されます。Z 座標が同一の場合は、後に生成されたオブジェクトほど手前に表示されます。

ox 
スプライトの転送元原点の X 座標です。

oy 
スプライトの転送元原点の Y 座標です。

zoom_x 
スプライトの X 方向拡大率です。1.0 で等倍になります。

zoom_y 
スプライトの Y 方向拡大率です。1.0 で等倍になります。

angle 
スプライトの回転角度です。反時計回りを正とする 360 度系で指定します。回転描画には時間がかかりますので、多用は避けてください。

mirror 
スプライトの左右反転フラグです。真のとき反転して描画されます。

bush_depth 
スプライトの茂み深さです。茂み深さとは、スプライトの下部を半透明で表示するドット数です。この効果により、キャラクターの足元が茂みなどに隠れているような表現を簡単に行うことができます。

opacity 
スプライトの不透明度です。0 ～ 255 の範囲で指定します。範囲外の値は自動で修正されます。

blend_type 
スプライトの合成方法 (0:通常、1:加算、2:減算) です。

color 
スプライトにブレンドする色 (Color) です。ブレンドの割合にはアルファ値が使用されます。

flash によってブレンドされる色とは別に管理されます。ただし、表示の際にはアルファ値の大きいほうの色が優先してブレンドされます。

tone 
スプライトの色調 (Tone) です

=end

class Sprite
  attr_reader :bitmap
  attr_reader :x
  attr_reader :y
  attr_accessor :src_rect
  attr_reader :visible
  attr_reader :z
  attr_reader :ox
  attr_reader :oy
  attr_accessor :zoom_x
  attr_accessor :zoom_y
  attr_accessor :angle
  attr_accessor :mirror
  attr_accessor :bush_depth
  attr_reader :opacity
  attr_accessor :blend_type
  attr_accessor :color
  attr_accessor :tone

  def initialize(viewport = nil)
    @viewport = viewport
    if viewport
      @sprite_id = RGSSEnv.sprite_new(viewport.viewport_id, false)
    else
      @sprite_id = RGSSEnv.sprite_new(-1, false)
    end
    Graphics._add_sprite(self)
    @bitmap = nil
    @x = 0
    @y = 0
    @ox = 0
    @oy = 0
    @src_rect = Rect.new(0, 0, 0, 0)
    @color = Color.new(0, 0, 0)
    @visible = true
  end

  def bitmap
    @bitmap
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

  def x=(x)
    RGSSEnv.sprite_set_x(@sprite_id, x - @ox)
    @x = x
  end

  def y=(y)
    RGSSEnv.sprite_set_y(@sprite_id, y - @oy)
    @y = y
  end

  def z=(z)
    RGSSEnv.sprite_set_z(@sprite_id, z)
    @z = z
  end

  def ox=(ox)
    RGSSEnv.sprite_set_x(@sprite_id, @x - ox)
    @ox = ox
  end

  def oy=(oy)
    RGSSEnv.sprite_set_y(@sprite_id, @y - oy)
    @oy = oy
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

  def flash(color, duration)

  end

  def update
  end

  def _update_by_system
    RGSSEnv.sprite_update(@sprite_id)
    RGSSEnv.sprite_set_frame(@sprite_id, @src_rect.x, @src_rect.y, @src_rect.width, @src_rect.height)
    @bitmap._update_by_system if @bitmap
  end
end
