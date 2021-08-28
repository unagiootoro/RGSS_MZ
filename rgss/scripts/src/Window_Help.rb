#==============================================================================
# ■ Window_Help
#------------------------------------------------------------------------------
# 　スキルやアイテムの説明、アクターのステータスなどを表示するウィンドウです。
#==============================================================================

class Window_Help < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, 640, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
  end
  #--------------------------------------------------------------------------
  # ● テキスト設定
  #     text  : ウィンドウに表示する文字列
  #     align : アラインメント (0..左揃え、1..中央揃え、2..右揃え)
  #--------------------------------------------------------------------------
  def set_text(text, align = 0)
    # テキストとアラインメントの少なくとも一方が前回と違っている場合
    if text != @text or align != @align
      # テキストを再描画
      self.contents.clear
      self.contents.font.color = normal_color
      self.contents.draw_text(4, 0, self.width - 40, 32, text, align)
      @text = text
      @align = align
      @actor = nil
    end
    self.visible = true
  end
  #--------------------------------------------------------------------------
  # ● アクター設定
  #     actor : ステータスを表示するアクター
  #--------------------------------------------------------------------------
  def set_actor(actor)
    if actor != @actor
      self.contents.clear
      draw_actor_name(actor, 4, 0)
      draw_actor_state(actor, 140, 0)
      draw_actor_hp(actor, 284, 0)
      draw_actor_sp(actor, 460, 0)
      @actor = actor
      @text = nil
      self.visible = true
    end
  end
  #--------------------------------------------------------------------------
  # ● エネミー設定
  #     enemy : 名前とステートを表示するエネミー
  #--------------------------------------------------------------------------
  def set_enemy(enemy)
    text = enemy.name
    state_text = make_battler_state_text(enemy, 112, false)
    if state_text != ""
      text += "  " + state_text
    end
    set_text(text, 1)
  end
end
