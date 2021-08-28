#==============================================================================
# ■ Arrow_Enemy
#------------------------------------------------------------------------------
# 　エネミーを選択させるためのアローカーソルです。このクラスは Arrow_Base クラ
# スを継承します。
#==============================================================================

class Arrow_Enemy < Arrow_Base
  #--------------------------------------------------------------------------
  # ● カーソルが指しているエネミーの取得
  #--------------------------------------------------------------------------
  def enemy
    return $game_troop.enemies[@index]
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    # 存在しないエネミーを指していたら飛ばす
    $game_troop.enemies.size.times do
      break if self.enemy.exist?
      @index += 1
      @index %= $game_troop.enemies.size
    end
    # カーソル右
    if Input.repeat?(Input::RIGHT)
      $game_system.se_play($data_system.cursor_se)
      $game_troop.enemies.size.times do
        @index += 1
        @index %= $game_troop.enemies.size
        break if self.enemy.exist?
      end
    end
    # カーソル左
    if Input.repeat?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      $game_troop.enemies.size.times do
        @index += $game_troop.enemies.size - 1
        @index %= $game_troop.enemies.size
        break if self.enemy.exist?
      end
    end
    # スプライトの座標を設定
    if self.enemy != nil
      self.x = self.enemy.screen_x
      self.y = self.enemy.screen_y
    end
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    # ヘルプウィンドウにエネミーの名前とステートを表示
    @help_window.set_enemy(self.enemy)
  end
end
