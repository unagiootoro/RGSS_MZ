#==============================================================================
# ■ Window_BattleStatus
#------------------------------------------------------------------------------
# 　バトル画面でパーティメンバーのステータスを表示するウィンドウです。
#==============================================================================

class Window_BattleStatus < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 320, 640, 160)
    self.contents = Bitmap.new(width - 32, height - 32)
    @level_up_flags = [false, false, false, false]
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    super
  end
  #--------------------------------------------------------------------------
  # ● レベルアップフラグの設定
  #     actor_index : アクターインデックス
  #--------------------------------------------------------------------------
  def level_up(actor_index)
    @level_up_flags[actor_index] = true
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @item_max = $game_party.actors.size
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      actor_x = i * 160 + 4
      draw_actor_name(actor, actor_x, 0)
      draw_actor_hp(actor, actor_x, 32, 120)
      draw_actor_sp(actor, actor_x, 64, 120)
      if @level_up_flags[i]
        self.contents.font.color = normal_color
        self.contents.draw_text(actor_x, 96, 120, 32, "LEVEL UP!")
      else
        draw_actor_state(actor, actor_x, 96)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    # メインフェーズのときは不透明度をやや下げる
    if $game_temp.battle_main_phase
      self.contents_opacity -= 4 if self.contents_opacity > 191
    else
      self.contents_opacity += 4 if self.contents_opacity < 255
    end
  end
end
