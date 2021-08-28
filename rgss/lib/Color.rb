=begin
Color
RGBA カラーのクラス。各要素は浮動小数点数 (Float) で管理されます。

スーパークラスObject 
クラスメソッドColor.new(red, green, blue[, alpha]) 
Color オブジェクトを生成します。 alpha を省略した場合は 255 になります。

メソッドset(red, green, blue[, alpha]) 
全要素をまとめて設定します。

プロパティred 
赤の値 (0 ～ 255) です。範囲外の値は自動で修正されます。

green 
緑の値 (0 ～ 255) です。範囲外の値は自動で修正されます。

blue 
青の値 (0 ～ 255) です。範囲外の値は自動で修正されます。

alpha 
アルファの値 (0 ～ 255) です。範囲外の値は自動で修正されます。
=end

class Color
  attr_accessor :red, :green, :blue, :alpha

  def initialize(red, green, blue, alpha = 255)
    set(red, green, blue, alpha)
  end

  def set(red, green, blue, alpha = 255)
    @red = red
    @green = green
    @blue = blue
    @alpha = alpha
  end

  def self._load(array)
    obj = self.allocate
    obj.marshal_load(array)
    obj
  end

  def to_css_color
    r = sprintf("%02x", @red)
    g = sprintf("%02x", @green)
    b = sprintf("%02x", @blue)
    "rgba(#{@red}, #{@green}, #{@blue}, #{@alpha / 255.0})"
  end

  def marshal_load(bin)
    double_ary = bin.unpack("d*")
    @red = double_ary[0]
    @green = double_ary[1]
    @blue = double_ary[2]
    @alpha = double_ary[3]
  end

  def rpg_hash_dump
    {
      "class_name" => "Color",
      "@red" => @red,
      "@green" => @green,
      "@blue" => @blue,
      "@alpha" => @alpha,
    }
  end

  def rpg_hash_load(hash)
    @red = hash["@red"]
    @green = hash["@green"]
    @blue = hash["@blue"]
    @alpha = hash["@alpha"]
  end
end
