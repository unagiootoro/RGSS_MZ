=begin
Font
フォントのクラス。フォントは Bitmap クラスのプロパティです。

スーパークラスObject 
クラスメソッドFont.new([name[, size]]) 
Font オブジェクトを生成します。

Font.exist?(name) 
指定された名前のフォントがシステムに存在するとき真を返します。

プロパティname 
フォント名です。初期値は "ＭＳ Ｐゴシック" です。

文字列の配列を設定すると、希望順に複数指定することができます。

font.name = ["HGP行書体", "ＭＳ Ｐゴシック"]

上の例の場合、第一希望の "HGP行書体" がシステムに存在しなければ、第二希望の "ＭＳ Ｐゴシック" が使用されることになります。

size 
フォントのサイズです。初期値は 22 です。

bold 
ボールドフラグです。初期値は false です。

italic 
イタリックフラグです。初期値は false です。

color 
フォントの色 (Color) です。アルファ値も有効です。初期値は (255,255,255,255) です。

クラスプロパティdefault_name 
default_size 
default_bold 
default_italic 
default_color 
Font オブジェクトが新しく作成されたときに各要素に設定されるデフォルト値を変更できます。

Font.default_name = "ＭＳ Ｐ明朝"
Font.default_bold = true

=end

class Font
  class << self
    attr_accessor :default_name , :default_size, :default_bold, :default_italic, :default_color
  end

  # @default_name = "mplus-1m-regular.woff"
  @default_name = "ＭＳ Ｐゴシック"
  @default_size = 32
  @default_bold = false
  @default_italic = false
  @default_color = Color.new(255, 255, 255, 255)

  attr_reader :name, :size, :bold, :italic, :color
  attr_reader :need_update

  def self.exist?(name)
    true
  end

  def initialize(name = Font.default_name, size = Font.default_size)
    @name = name
    @size = size
    @bold = Font.default_bold
    @italic = Font.default_italic
    @color = Font.default_color
    @need_update = false
  end

  def name=(name)
    @name = name
    @need_update = true
  end

  def size=(size)
    @size = size
    @need_update = true
  end

  def bold=(bold)
    @bold = bold
    @need_update = true
  end

  def italic=(italic)
    @italic = italic
    @need_update = true
  end

  def color=(color)
    @name = name
    @need_update = true
  end
end
