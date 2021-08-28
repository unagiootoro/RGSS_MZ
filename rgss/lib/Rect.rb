=begin
Rect
四角形のクラス。

スーパークラスObject 
クラスメソッドRect.new(x, y, width, height) 
Rect オブジェクトを生成します。

メソッドset(x, y, width, height) 
各要素をまとめて設定します。

プロパティx 
四角形の左上隅の X 座標です。

y 
四角形の左上隅の Y 座標です。

width 
四角形の幅です。

height 
四角形の高さです。

=end

class Rect
  attr_accessor :x, :y, :width, :height

  def initialize(x, y, width, height)
    set(x, y, width, height)
  end

  def set(x, y, width, height)
    @x = x
    @y = y
    @width = width
    @height = height
  end

  def empty
    @x = 0
    @y = 0
    @width = 0
    @height = 0
  end
end
