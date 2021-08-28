=begin
Tone
色調のクラス。各要素は浮動小数点数 (Float) で管理されます。

スーパークラスObject 
クラスメソッドTone.new(red, green, blue[, gray]) 
Tone オブジェクトを生成します。gray を省略した場合は 0 になります。

メソッドset(red, green, blue[, gray]) 
全要素をまとめて設定します。

プロパティred 
赤成分のカラーバランス調整値 (-255 ～ 255) です。範囲外の値は自動で修正されます。

green 
緑成分のカラーバランス調整値 (-255 ～ 255) です。範囲外の値は自動で修正されます。

blue 
青成分のカラーバランス調整値 (-255 ～ 255) です。範囲外の値は自動で修正されます。

gray 
グレースケール化フィルタの強さ (0 ～ 255) です。範囲外の値は自動で修正されます。

この値が 0 以外の場合、色成分のバランス調整だけの場合よりも余分に処理時間がかかります。

=end

class Tone
  attr_accessor :red, :green, :blue, :gray

  def self._load(array)
    obj = self.allocate
    obj.marshal_load(array)
    obj
  end

  def initialize(red, green, blue, gray = 0)
    set(red, green, blue, gray)
  end

  def set(red, green, blue, gray = 0)
    @red = red
    @green = green
    @blue = blue
    @gray = gray
  end

  def marshal_load(bin)
    double_ary = bin.unpack("d*")
    @red = double_ary[0]
    @green = double_ary[1]
    @blue = double_ary[2]
    @gray = double_ary[3]
  end

  def rpg_hash_dump
    {
      "class_name" => "Tone",
      "@red" => @red,
      "@green" => @green,
      "@blue" => @blue,
      "@gray" => @gray,
    }
  end

  def rpg_hash_load(hash)
    @red = hash["@red"]
    @green = hash["@green"]
    @blue = hash["@blue"]
    @gray = hash["@gray"]
  end
end
