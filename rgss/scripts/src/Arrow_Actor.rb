#==============================================================================
# ■ Arrow_Actor
#------------------------------------------------------------------------------
# 　アクターを選択させるためのアローカーソルです。このクラスは Arrow_Base クラ
# スを継承します。
#==============================================================================

class Arrow_Actor < Arrow_Base
  #--------------------------------------------------------------------------
  # ● カーソルが指しているアクターの取得
  #--------------------------------------------------------------------------
  def actor
    return $game_party.actors[@index]
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    # カーソル右
    if Input.repeat?(Input::RIGHT)
      $game_system.se_play($data_system.cursor_se)
      @index += 1
      @index %= $game_party.actors.size
    end
    # カーソル左
    if Input.repeat?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      @index += $game_party.actors.size - 1
      @index %= $game_party.actors.size
    end
    # スプライトの座標を設定
    if self.actor != nil
      self.x = self.actor.screen_x
      self.y = self.actor.screen_y
    end
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    # ヘルプウィンドウにアクターのステータスを表示
    @help_window.set_actor(self.actor)
  end
end
