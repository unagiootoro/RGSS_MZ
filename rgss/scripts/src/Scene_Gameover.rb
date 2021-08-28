#==============================================================================
# ■ Scene_Gameover
#------------------------------------------------------------------------------
# 　ゲームオーバー画面の処理を行うクラスです。
#==============================================================================

class Scene_Gameover
  #--------------------------------------------------------------------------
  # ● メイン処理
  #--------------------------------------------------------------------------
  def main
    # ゲームオーバーグラフィックを作成
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.gameover($data_system.gameover_name)
    # BGM、BGS を停止
    $game_system.bgm_play(nil)
    $game_system.bgs_play(nil)
    # ゲームオーバー ME を演奏
    $game_system.me_play($data_system.gameover_me)
    # トランジション実行
    Graphics.transition(120)
    # メインループ
    loop do
      # ゲーム画面を更新
      Graphics.update
      # 入力情報を更新
      Input.update
      # フレーム更新
      update
      # 画面が切り替わったらループを中断
      if $scene != self
        break
      end
    end
    # トランジション準備
    Graphics.freeze
    # ゲームオーバーグラフィックを解放
    @sprite.bitmap.dispose
    @sprite.dispose
    # トランジション実行
    Graphics.transition(40)
    # トランジション準備
    Graphics.freeze
    # 戦闘テストの場合
    if $BTEST
      $scene = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # タイトル画面に切り替え
      $scene = Scene_Title.new
    end
  end
end
