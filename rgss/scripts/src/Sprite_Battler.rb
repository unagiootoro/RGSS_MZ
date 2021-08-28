#==============================================================================
# ■ Sprite_Battler
#------------------------------------------------------------------------------
# 　バトラー表示用のスプライトです。Game_Battler クラスのインスタンスを監視し、
# スプライトの状態を自動的に変化させます。
#==============================================================================

class Sprite_Battler < RPG::Sprite
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :battler                  # バトラー
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     viewport : ビューポート
  #     battler  : バトラー (Game_Battler)
  #--------------------------------------------------------------------------
  def initialize(viewport, battler = nil)
    super(viewport)
    @battler = battler
    @battler_visible = false
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    if self.bitmap != nil
      self.bitmap.dispose
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    # バトラーが nil の場合
    if @battler == nil
      self.bitmap = nil
      loop_animation(nil)
      return
    end
    # ファイル名か色相が現在のものと異なる場合
    if @battler.battler_name != @battler_name or
       @battler.battler_hue != @battler_hue
      # ビットマップを取得、設定
      @battler_name = @battler.battler_name
      @battler_hue = @battler.battler_hue
      self.bitmap = RPG::Cache.battler(@battler_name, @battler_hue)
      @width = bitmap.width
      @height = bitmap.height
      self.ox = @width / 2
      self.oy = @height
      # 戦闘不能または隠れ状態なら不透明度を 0 にする
      if @battler.dead? or @battler.hidden
        self.opacity = 0
      end
    end
    # アニメーション ID が現在のものと異なる場合
    if @battler.damage == nil and
       @battler.state_animation_id != @state_animation_id
      @state_animation_id = @battler.state_animation_id
      loop_animation($data_animations[@state_animation_id])
    end
    # 表示されるべきアクターの場合
    if @battler.is_a?(Game_Actor) and @battler_visible
      # メインフェーズでないときは不透明度をやや下げる
      if $game_temp.battle_main_phase
        self.opacity += 3 if self.opacity < 255
      else
        self.opacity -= 3 if self.opacity > 207
      end
    end
    # 明滅
    if @battler.blink
      blink_on
    else
      blink_off
    end
    # 不可視の場合
    unless @battler_visible
      # 出現
      if not @battler.hidden and not @battler.dead? and
         (@battler.damage == nil or @battler.damage_pop)
        appear
        @battler_visible = true
      end
    end
    # 可視の場合
    if @battler_visible
      # 逃走
      if @battler.hidden
        $game_system.se_play($data_system.escape_se)
        escape
        @battler_visible = false
      end
      # 白フラッシュ
      if @battler.white_flash
        whiten
        @battler.white_flash = false
      end
      # アニメーション
      if @battler.animation_id != 0
        animation = $data_animations[@battler.animation_id]
        animation(animation, @battler.animation_hit)
        @battler.animation_id = 0
      end
      # ダメージ
      if @battler.damage_pop
        damage(@battler.damage, @battler.critical)
        @battler.damage = nil
        @battler.critical = false
        @battler.damage_pop = false
      end
      # コラプス
      if @battler.damage == nil and @battler.dead?
        if @battler.is_a?(Game_Enemy)
          $game_system.se_play($data_system.enemy_collapse_se)
        else
          $game_system.se_play($data_system.actor_collapse_se)
        end
        collapse
        @battler_visible = false
      end
    end
    # スプライトの座標を設定
    self.x = @battler.screen_x
    self.y = @battler.screen_y
    self.z = @battler.screen_z
  end
end
