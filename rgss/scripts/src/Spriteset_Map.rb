#==============================================================================
# ■ Spriteset_Map
#------------------------------------------------------------------------------
# 　マップ画面のスプライトやタイルマップなどをまとめたクラスです。このクラスは
# Scene_Map クラスの内部で使用されます。
#==============================================================================

class Spriteset_Map
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    # ビューポートを作成
    @viewport1 = Viewport.new(0, 0, 640, 480)
    @viewport2 = Viewport.new(0, 0, 640, 480)
    @viewport3 = Viewport.new(0, 0, 640, 480)
    @viewport2.z = 200
    @viewport3.z = 5000
    # タイルマップを作成
    @tilemap = Tilemap.new(@viewport1)
    @tilemap.tileset = RPG::Cache.tileset($game_map.tileset_name)
    for i in 0..6
      autotile_name = $game_map.autotile_names[i]
      @tilemap.autotiles[i] = RPG::Cache.autotile(autotile_name)
    end
    @tilemap.map_data = $game_map.data
    @tilemap.priorities = $game_map.priorities
    # パノラマプレーンを作成
    @panorama = Plane.new(@viewport1)
    @panorama.z = -1000
    # フォグプレーンを作成
    @fog = Plane.new(@viewport1)
    @fog.z = 3000
    # キャラクタースプライトを作成
    @character_sprites = []
    for i in $game_map.events.keys.sort
      sprite = Sprite_Character.new(@viewport1, $game_map.events[i])
      @character_sprites.push(sprite)
    end
    @character_sprites.push(Sprite_Character.new(@viewport1, $game_player))
    # 天候を作成
    @weather = RPG::Weather.new(@viewport1)
    # ピクチャを作成
    @picture_sprites = []
    for i in 1..50
      @picture_sprites.push(Sprite_Picture.new(@viewport2,
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
    # タイルマップを解放
    @tilemap.tileset.dispose
    for i in 0..6
      @tilemap.autotiles[i].dispose
    end
    @tilemap.dispose
    # パノラマプレーンを解放
    @panorama.dispose
    # フォグプレーンを解放
    @fog.dispose
    # キャラクタースプライトを解放
    for sprite in @character_sprites
      sprite.dispose
    end
    # 天候を解放
    @weather.dispose
    # ピクチャを解放
    for sprite in @picture_sprites
      sprite.dispose
    end
    # タイマースプライトを解放
    @timer_sprite.dispose
    # ビューポートを解放
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # パノラマが現在のものと異なる場合
    if @panorama_name != $game_map.panorama_name or
       @panorama_hue != $game_map.panorama_hue
      @panorama_name = $game_map.panorama_name
      @panorama_hue = $game_map.panorama_hue
      if @panorama.bitmap != nil
        @panorama.bitmap.dispose
        @panorama.bitmap = nil
      end
      if @panorama_name != ""
        @panorama.bitmap = RPG::Cache.panorama(@panorama_name, @panorama_hue)
      end
      Graphics.frame_reset
    end
    # フォグが現在のものと異なる場合
    if @fog_name != $game_map.fog_name or @fog_hue != $game_map.fog_hue
      @fog_name = $game_map.fog_name
      @fog_hue = $game_map.fog_hue
      if @fog.bitmap != nil
        @fog.bitmap.dispose
        @fog.bitmap = nil
      end
      if @fog_name != ""
        @fog.bitmap = RPG::Cache.fog(@fog_name, @fog_hue)
      end
      Graphics.frame_reset
    end
    # タイルマップを更新
    @tilemap.ox = $game_map.display_x / 4
    @tilemap.oy = $game_map.display_y / 4
    @tilemap.update
    # パノラマプレーンを更新
    @panorama.ox = $game_map.display_x / 8
    @panorama.oy = $game_map.display_y / 8
    # フォグプレーンを更新
    @fog.zoom_x = $game_map.fog_zoom / 100.0
    @fog.zoom_y = $game_map.fog_zoom / 100.0
    @fog.opacity = $game_map.fog_opacity
    @fog.blend_type = $game_map.fog_blend_type
    @fog.ox = $game_map.display_x / 4 + $game_map.fog_ox
    @fog.oy = $game_map.display_y / 4 + $game_map.fog_oy
    @fog.tone = $game_map.fog_tone
    # キャラクタースプライトを更新
    for sprite in @character_sprites
      sprite.update
    end
    # 天候グラフィックを更新
    @weather.type = $game_screen.weather_type
    @weather.max = $game_screen.weather_max
    @weather.ox = $game_map.display_x / 4
    @weather.oy = $game_map.display_y / 4
    @weather.update
    # ピクチャを更新
    for sprite in @picture_sprites
      sprite.update
    end
    # タイマースプライトを更新
    @timer_sprite.update
    # 画面の色調とシェイク位置を設定
    @viewport1.tone = $game_screen.tone
    @viewport1.ox = $game_screen.shake
    # 画面のフラッシュ色を設定
    @viewport3.color = $game_screen.flash_color
    # ビューポートを更新
    @viewport1.update
    @viewport3.update
  end
end
