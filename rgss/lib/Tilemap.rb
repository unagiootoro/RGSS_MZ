=begin
Tilemap
タイルマップを管理するクラス。タイルマップは 2D ゲームのマップ表示に特化した概念で、内部的には複数のスプライトで構成されています。

スーパークラスObject 
クラスメソッドTilemap.new([viewport]) 
Tilemap オブジェクトを生成します。必要に応じてビューポート (Viewport) を指定します。

メソッドdispose 
タイルマップを解放します。すでに解放されている場合は何も行いません。

disposed? 
タイルマップがすでに解放されている場合に真を返します。

viewport 
生成時に指定されたビューポート (Viewport) を取得します。

update 
オートタイルのアニメーションなどを進めます。このメソッドは、原則として 1 フレームに 1 回呼び出します。

プロパティtileset 
タイルセットとして使用するビットマップ (Bitmap) への参照です。

autotiles[index] 
番号 index (0 ～ 6) のオートタイルとして使用するビットマップ (Bitmap) への参照です。

map_data 
マップデータ (Table) への参照です。横サイズ * 縦サイズ * 3 の 3 次元配列を設定します。

flash_data 
シミュレーションゲームの移動範囲の表示などに使用する、フラッシュデータ (Table) への参照です。横サイズ * 縦サイズの 2 次元配列を設定します。必ずマップデータと同じサイズでなければなりません。各要素は、タイルのフラッシュ色を RGB 各 4 ビットで表わします。たとえば 0xf84 の場合は、RGB(15,8,4) の色でフラッシュします。

priorities 
プライオリティテーブル (Table) への参照です。タイル ID に対応した要素を持つ 1 次元配列を設定します。

visible 
タイルマップの可視状態です。真のとき可視になります。

ox 
タイルマップの転送元原点の X 座標です。この値を変化させることによってスクロールを行います。

oy 
タイルマップの転送元原点の Y 座標です。この値を変化させることによってスクロールを行います。

備考タイルマップを構成する各スプライトの Z 座標は特定の値に固定されています。

プライオリティ 0 のタイルの Z 座標は必ず 0 になります。 
画面の上端に位置するプライオリティ 1 のタイルの Z 座標は 64 となります。 
プライオリティが 1 増えるかタイル 1 個分下に行くごとに、Z 座標は 32 ずつ増加します。 
タイルマップが縦にスクロールすると、Z 座標もそれに合わせて変化します。 
マップ上に表示させるキャラクターの Z 座標は、これを前提として決定しなければなりません。
=end

class Tilemap
  attr_reader :tileset
  attr_reader :map_data
  attr_accessor :flash_data
  attr_reader :priorities
  attr_accessor :visible
  attr_accessor :ox
  attr_accessor :oy

  def initialize(viewport)
    @viewport = viewport
    if viewport
      @tilemap_id = RGSSEnv.tilemap_new(viewport.viewport_id)
    else
      @tilemap_id = RGSSEnv.tilemap_new(-1)
    end
    @autotiles = Array.new(7)
    @disposed = false
    @map_data = nil
    @ox = 0
    @oy = 0
    @update_autotiles = false
  end

  def dispose
    @disposed = true
    if @viewport
      RGSSEnv.tilemap_delete(@tilemap_id, @viewport.viewport_id)
    else
      RGSSEnv.tilemap_delete(@tilemap_id, -1)
    end
  end

  def disposed?
    @disposed
  end

  def viewport
    @viewport
  end

  def update
    RGSSEnv.tilemap_set_origin(@tilemap_id, @ox, @oy)
    if @update_autotiles
      @autotiles.each.with_index do |autotile, i|
        if autotile
          RGSSEnv.tilemap_set_autotile(@tilemap_id, i, autotile.bitmap_id)
        else
          RGSSEnv.tilemap_set_autotile(@tilemap_id, i, -1)
        end
      end
      @update_autotiles = false
    end
    RGSSEnv.tilemap_update(@tilemap_id)
  end

  def tileset=(tileset)
    if tileset
      RGSSEnv.tilemap_set_tileset(@tilemap_id, tileset.bitmap_id)
    else
      RGSSEnv.tilemap_set_tileset(@tilesetid, -1)
    end
    @tileset = tileset
  end

  def autotiles
    @update_autotiles = true
    @autotiles
  end

  def map_data=(map_data)
    RGSSEnv.tilemap_set_map_data(@tilemap_id, map_data.array, map_data.xsize, map_data.ysize)
    @map_data = map_data
  end

  def priorities=(priorities)
    RGSSEnv.tilemap_set_priorities(@tilemap_id, priorities.array, priorities.array.length)
    @priorities = priorities
  end
end
