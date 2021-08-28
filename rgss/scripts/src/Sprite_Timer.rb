#==============================================================================
# ■ Sprite_Timer
#------------------------------------------------------------------------------
# 　タイマー表示用のスプライトです。$game_system を監視し、スプライトの状態を
# 自動的に変化させます。
#==============================================================================

class Sprite_Timer < Sprite
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super
    self.bitmap = Bitmap.new(88, 48)
    self.bitmap.font.name = "Arial"
    self.bitmap.font.size = 32
    self.x = 640 - self.bitmap.width
    self.y = 0
    self.z = 500
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
    # タイマー作動中なら可視に設定
    self.visible = $game_system.timer_working
    # タイマーを再描画する必要がある場合
    if $game_system.timer / Graphics.frame_rate != @total_sec
      # ウィンドウ内容をクリア
      self.bitmap.clear
      # トータル秒数を計算
      @total_sec = $game_system.timer / Graphics.frame_rate
      # タイマー表示用の文字列を作成
      min = @total_sec / 60
      sec = @total_sec % 60
      text = sprintf("%02d:%02d", min, sec)
      # タイマーを描画
      self.bitmap.font.color.set(255, 255, 255)
      self.bitmap.draw_text(self.bitmap.rect, text, 1)
    end
  end
end
