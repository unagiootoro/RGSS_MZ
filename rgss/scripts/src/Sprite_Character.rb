#==============================================================================
# ■ Sprite_Character
#------------------------------------------------------------------------------
# 　キャラクター表示用のスプライトです。Game_Character クラスのインスタンスを
# 監視し、スプライトの状態を自動的に変化させます。
#==============================================================================

class Sprite_Character < RPG::Sprite
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :character                # キャラクター
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     viewport  : ビューポート
  #     character : キャラクター (Game_Character)
  #--------------------------------------------------------------------------
  def initialize(viewport, character = nil)
    super(viewport)
    @character = character
    update
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    # タイル ID、ファイル名、色相のどれかが現在のものと異なる場合
    if @tile_id != @character.tile_id or
       @character_name != @character.character_name or
       @character_hue != @character.character_hue
      # タイル ID とファイル名、色相を記憶
      @tile_id = @character.tile_id
      @character_name = @character.character_name
      @character_hue = @character.character_hue
      # タイル ID が有効な値の場合
      if @tile_id >= 384
        self.bitmap = RPG::Cache.tile($game_map.tileset_name,
          @tile_id, @character.character_hue)
        self.src_rect.set(0, 0, 32, 32)
        self.ox = 16
        self.oy = 32
      # タイル ID が無効な値の場合
      else
        self.bitmap = RPG::Cache.character(@character.character_name,
          @character.character_hue)
        @cw = bitmap.width / 4
        @ch = bitmap.height / 4
        self.ox = @cw / 2
        self.oy = @ch
      end
    end
    # 可視状態を設定
    self.visible = (not @character.transparent)
    # グラフィックがキャラクターの場合
    if @tile_id == 0
      # 転送元の矩形を設定
      sx = @character.pattern * @cw
      sy = (@character.direction - 2) / 2 * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
    # スプライトの座標を設定
    self.x = @character.screen_x
    self.y = @character.screen_y
    self.z = @character.screen_z(@ch)
    # 不透明度、合成方法、茂み深さを設定
    self.opacity = @character.opacity
    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    # アニメーション
    if @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      animation(animation, true)
      @character.animation_id = 0
    end
  end
end
