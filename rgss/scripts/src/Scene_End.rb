#==============================================================================
# ■ Scene_End
#------------------------------------------------------------------------------
# 　ゲーム終了画面の処理を行うクラスです。
#==============================================================================

class Scene_End
  #--------------------------------------------------------------------------
  # ● メイン処理
  #--------------------------------------------------------------------------
  def main
    # コマンドウィンドウを作成
    s1 = "タイトルへ"
    s2 = "シャットダウン"
    s3 = "やめる"
    @command_window = Window_Command.new(192, [s1, s2, s3])
    @command_window.x = 320 - @command_window.width / 2
    @command_window.y = 240 - @command_window.height / 2
    # トランジション実行
    Graphics.transition
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
    # ウィンドウを解放
    @command_window.dispose
    # タイトル画面に切り替え中の場合
    if $scene.is_a?(Scene_Title)
      # 画面をフェードアウト
      Graphics.transition
      Graphics.freeze
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # コマンドウィンドウを更新
    @command_window.update
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # キャンセル SE を演奏
      $game_system.se_play($data_system.cancel_se)
      # メニュー画面に切り替え
      $scene = Scene_Menu.new(5)
      return
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # コマンドウィンドウのカーソル位置で分岐
      case @command_window.index
      when 0  # タイトルへ
        command_to_title
      when 1  # シャットダウン
        command_shutdown
      when 2  # やめる
        command_cancel
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● コマンド [タイトルへ] 選択時の処理
  #--------------------------------------------------------------------------
  def command_to_title
    # 決定 SE を演奏
    $game_system.se_play($data_system.decision_se)
    # BGM、BGS、ME をフェードアウト
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    # タイトル画面に切り替え
    $scene = Scene_Title.new
  end
  #--------------------------------------------------------------------------
  # ● コマンド [シャットダウン] 選択時の処理
  #--------------------------------------------------------------------------
  def command_shutdown
    # 決定 SE を演奏
    $game_system.se_play($data_system.decision_se)
    # BGM、BGS、ME をフェードアウト
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    # シャットダウン
    $scene = nil
  end
  #--------------------------------------------------------------------------
  # ● コマンド [やめる] 選択時の処理
  #--------------------------------------------------------------------------
  def command_cancel
    # 決定 SE を演奏
    $game_system.se_play($data_system.decision_se)
    # メニュー画面に切り替え
    $scene = Scene_Menu.new(5)
  end
end
