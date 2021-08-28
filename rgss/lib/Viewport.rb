=begin
Viewport
ビューポートのクラス。画面の一部にスプライトを表示し、他の部分にはみ出さないようにしたい場合に使用します。

スーパークラスObject 
クラスメソッドViewport.new(x, y, width, height) 
Viewport.new(rect) 
Viewport オブジェクトを生成します。

メソッドdispose 
ビューポートを解放します。すでに解放されている場合は何も行いません。

disposed? 
ビューポートがすでに解放されている場合に真を返します。

flash(color, duration) 
ビューポートのフラッシュを開始します。duration はフラッシュにかけるフレーム数です。

color に nil を指定した場合は、フラッシュの時間分ビューポート自体を消去します。

update 
ビューポートのフラッシュを進めます。このメソッドは、原則として 1 フレームに 1 回呼び出します。

フラッシュの必要がない場合は呼び出さなくても構いません。

プロパティrect 
ビューポートとして設定する矩形 (Rect) です。

visible 
ビューポートの可視状態です。真のとき可視になります。

z 
ビューポートの Z 座標です。この値が大きいものほど手前に表示されます。Z 座標が同一の場合は、後に生成されたオブジェクトほど手前に表示されます。

ox 
ビューポートの転送元原点の X 座標です。この値を変化させることによって画面のシェイクなどを行います。

oy 
ビューポートの転送元原点の Y 座標です。この値を変化させることによって画面のシェイクなどを行います。

color 
ビューポートにブレンドする色 (Color) です。ブレンドの割合にはアルファ値が使用されます。

flash によってブレンドされる色とは別に管理されます。

tone 
ビューポートの色調 (Tone) です。

=end

class Viewport
  attr_reader :viewport_id
  attr_accessor :rect
  attr_accessor :visible
  attr_reader :z
  attr_accessor :ox
  attr_accessor :oy
  attr_accessor :color
  attr_accessor :tone

  def initialize(*args)
    if args.length == 4
      initialize_1(*args)
    elsif args.length == 1
      initialize_2(*args)
    else
      raise ArgumentError, "invalid args."
    end
    @viewport_id = RGSSEnv.viewport_new
    @disposed = false
  end

  def initialize_1(x, y, width, height)
    @rect = Rect.new(x, y, width, height)
  end

  def initialize_2(rect)
    initialize_1(rect.x, rect.y, rect.width, rect.height)
  end

  def dispose
    @disposed = true
    RGSSEnv.viewport_delete(@viewport_id)
  end

  def disposed?
    @disposed
  end

  def z=(z)
    RGSSEnv.viewport_set_z(@viewport_id, z)
    @z = z
  end

  def flash(color, duration)

  end

  def update
    RGSSEnv.viewport_update(@viewport_id)
  end
end
