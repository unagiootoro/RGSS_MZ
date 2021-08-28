#==============================================================================
# ■ Sprite_Picture
#------------------------------------------------------------------------------
# 　ピクチャ表示用のスプライトです。Game_Picture クラスのインスタンスを監視し、
# スプライトの状態を自動的に変化させます。
#==============================================================================

class Sprite_Picture < Sprite
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     viewport : ビューポート
  #     picture  : ピクチャ (Game_Picture)
  #--------------------------------------------------------------------------
  def initialize(viewport, picture)
    super(viewport)
    @picture = picture
    update
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
    # ピクチャのファイル名が現在のものと異なる場合
    if @picture_name != @picture.name
      # ファイル名をインスタンス変数に記憶
      @picture_name = @picture.name
      # ファイル名が空でない場合
      if @picture_name != ""
        # ピクチャグラフィックを取得
        self.bitmap = RPG::Cache.picture(@picture_name)
      end
    end
    # ファイル名が空の場合
    if @picture_name == ""
      # スプライトを不可視に設定
      self.visible = false
      return
    end
    # スプライトを可視に設定
    self.visible = true
    # 転送元原点を設定
    if @picture.origin == 0
      self.ox = 0
      self.oy = 0
    else
      self.ox = self.bitmap.width / 2
      self.oy = self.bitmap.height / 2
    end
    # スプライトの座標を設定
    self.x = @picture.x
    self.y = @picture.y
    self.z = @picture.number
    # 拡大率、不透明度、ブレンド方法を設定
    self.zoom_x = @picture.zoom_x / 100.0
    self.zoom_y = @picture.zoom_y / 100.0
    self.opacity = @picture.opacity
    self.blend_type = @picture.blend_type
    # 回転角度、色調を設定
    self.angle = @picture.angle
    self.tone = @picture.tone
  end
end
