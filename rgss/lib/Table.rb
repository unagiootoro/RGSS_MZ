=begin
Table
多次元配列のクラス。各要素は符号付き 2 バイト型、すなわち -32,768 から 32,767 の範囲の整数となります。

大量のデータを扱う場合、Ruby の Array クラスでは実行効率が悪くなるため、このクラスが用意されています。

スーパークラスObject 
クラスメソッドTable.new(xsize[, ysize[, zsize]]) 
Table オブジェクトを生成します。多次元配列の各次元のサイズを指定します。生成できる配列は 1 ～ 3 次元です。要素数が 0 の配列を生成することも可能です。

メソッドresize(xsize[, ysize[, zsize]]) 
配列のサイズを変更します。変更前のデータは保持されます。

xsize 
ysize 
zsize 
配列の各次元のサイズを取得します。

プロパティself[x] 
self[x, y] 
self[x, y, z] 
配列の要素にアクセスします。生成した配列の次元数と同じ数の引数をとります。指定された要素が存在しないときには nil を返します。

=end

class Table
  attr_reader :array
  attr_reader :xsize, :ysize, :zsize

  def initialize(xsize, ysize = 1, zsize = 1)
    resize(xsize, ysize, zsize)
    @array = Array.new(zsize * ysize * xsize, 0)
  end

  def resize(xsize, ysize = 1, zsize = 1)
    @xsize = xsize
    @ysize = ysize
    @zsize = zsize
  end

  def [](x, y = 0, z = 0)
    return nil if x >= @xsize || y >= @ysize || z >= @zsize
    i = _calc_index(x, y, z)
    @array[i]
  end

  def []=(x, y = 0, z = 0, val)
    i = _calc_index(x, y, z)
    @array[i] = val
  end

  def _calc_index(x, y, z)
    z * @ysize * @xsize + y * @xsize + x
  end

  def self._load(array)
    obj = self.allocate
    obj.marshal_load(array)
    obj
  end

  def marshal_load(bin)
    ary = bin.unpack("I5S*")
    dim, xsize, ysize, zsize, size = *ary[0..4]
    @dim = dim
    @size = size
    @xsize = xsize
    @ysize = ysize
    @zsize = zsize
    @array = ary[5..-1]
  end

  def rpg_hash_dump
    {
      "class_name" => "Table",
      "@array" => @array,
      "@xsize" => @xsize,
      "@ysize" => @ysize,
      "@zsize" => @zsize,
    }
  end

  def rpg_hash_load(hash)
    @array = hash["@array"]
    @xsize = hash["@xsize"]
    @ysize = hash["@ysize"]
    @zsize = hash["@zsize"]
  end
end
