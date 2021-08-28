#==============================================================================
# ■ Spriteset_Battle
#------------------------------------------------------------------------------
# 　バトル画面のスプライトをまとめたクラスです。このクラスは Scene_Battle クラ
# スの内部で使用されます。
#==============================================================================

class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :viewport1                # エネミー側のビューポート
  attr_reader   :viewport2                # アクター側のビューポート
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    # ビューポートを作成
    @viewport1 = Viewport.new(0, 0, 640, 320)
    @viewport2 = Viewport.new(0, 0, 640, 480)
    @viewport3 = Viewport.new(0, 0, 640, 480)
    @viewport4 = Viewport.new(0, 0, 640, 480)
    @viewport2.z = 101
    @viewport3.z = 200
    @viewport4.z = 5000
    # バトルバックスプライトを作成
    @battleback_sprite = Sprite.new(@viewport1)
    # エネミースプライトを作成
    @enemy_sprites = []
    for enemy in $game_troop.enemies.reverse
      @enemy_sprites.push(Sprite_Battler.new(@viewport1, enemy))
    end
    # アクタースプライトを作成
    @actor_sprites = []
    @actor_sprites.push(Sprite_Battler.new(@viewport2))
    @actor_sprites.push(Sprite_Battler.new(@viewport2))
    @actor_sprites.push(Sprite_Battler.new(@viewport2))
    @actor_sprites.push(Sprite_Battler.new(@viewport2))
    # 天候を作成
    @weather = RPG::Weather.new(@viewport1)
    # ピクチャスプライトを作成
    @picture_sprites = []
    for i in 51..100
      @picture_sprites.push(Sprite_Picture.new(@viewport3,
        $game_screen.pictures[i]))
    end
    # タイマースプライトを作成
    @timer_sprite = Sprite_Timer.new
    # フレーム更新
    update
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    # バトルバックビットマップが存在していたら解放
    if @battleback_sprite.bitmap != nil
      @battleback_sprite.bitmap.dispose
    end
    # バトルバックスプライトを解放
    @battleback_sprite.dispose
    # エネミースプライト、アクタースプライトを解放
    for sprite in @enemy_sprites + @actor_sprites
      sprite.dispose
    end
    # 天候を解放
    @weather.dispose
    # ピクチャスプライトを解放
    for sprite in @picture_sprites
      sprite.dispose
    end
    # タイマースプライトを解放
    @timer_sprite.dispose
    # ビューポートを解放
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
    @viewport4.dispose
  end
  #--------------------------------------------------------------------------
  # ● エフェクト表示中判定
  #--------------------------------------------------------------------------
  def effect?
    # エフェクトが一つでも表示中なら true を返す
    for sprite in @enemy_sprites + @actor_sprites
      return true if sprite.effect?
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # アクタースプライトの内容を更新 (アクターの入れ替えに対応)
    @actor_sprites[0].battler = $game_party.actors[0]
    @actor_sprites[1].battler = $game_party.actors[1]
    @actor_sprites[2].battler = $game_party.actors[2]
    @actor_sprites[3].battler = $game_party.actors[3]
    # バトルバックのファイル名が現在のものと違う場合
    if @battleback_name != $game_temp.battleback_name
      @battleback_name = $game_temp.battleback_name
      if @battleback_sprite.bitmap != nil
        @battleback_sprite.bitmap.dispose
      end
      @battleback_sprite.bitmap = RPG::Cache.battleback(@battleback_name)
      @battleback_sprite.src_rect.set(0, 0, 640, 320)
    end
    # バトラースプライトを更新
    for sprite in @enemy_sprites + @actor_sprites
      sprite.update
    end
    # 天候グラフィックを更新
    @weather.type = $game_screen.weather_type
    @weather.max = $game_screen.weather_max
    @weather.update
    # ピクチャスプライトを更新
    for sprite in @picture_sprites
      sprite.update
    end
    # タイマースプライトを更新
    @timer_sprite.update
    # 画面の色調とシェイク位置を設定
    @viewport1.tone = $game_screen.tone
    @viewport1.ox = $game_screen.shake
    # 画面のフラッシュ色を設定
    @viewport4.color = $game_screen.flash_color
    # ビューポートを更新
    @viewport1.update
    @viewport2.update
    @viewport4.update
  end
end
