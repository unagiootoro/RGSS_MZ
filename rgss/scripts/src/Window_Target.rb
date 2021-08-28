#==============================================================================
# ■ Window_Target
#------------------------------------------------------------------------------
# 　アイテム画面とスキル画面で、使用対象のアクターを選択するウィンドウです。
#==============================================================================

class Window_Target < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, 336, 480)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.z += 10
    @item_max = $game_party.actors.size
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    for i in 0...$game_party.actors.size
      x = 4
      y = i * 116
      actor = $game_party.actors[i]
      draw_actor_name(actor, x, y)
      draw_actor_class(actor, x + 144, y)
      draw_actor_level(actor, x + 8, y + 32)
      draw_actor_state(actor, x + 8, y + 64)
      draw_actor_hp(actor, x + 152, y + 32)
      draw_actor_sp(actor, x + 152, y + 64)
    end
  end
  #--------------------------------------------------------------------------
  # ● カーソルの矩形更新
  #--------------------------------------------------------------------------
  def update_cursor_rect
    # カーソル位置 -1 は全選択、-2 以下は単独選択 (使用者自身)
    if @index <= -2
      self.cursor_rect.set(0, (@index + 10) * 116, self.width - 32, 96)
    elsif @index == -1
      self.cursor_rect.set(0, 0, self.width - 32, @item_max * 116 - 20)
    else
      self.cursor_rect.set(0, @index * 116, self.width - 32, 96)
    end
  end
end
