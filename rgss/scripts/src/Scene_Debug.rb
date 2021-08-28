#==============================================================================
# ■ Scene_Debug
#------------------------------------------------------------------------------
# 　デバッグ画面の処理を行うクラスです。
#==============================================================================

class Scene_Debug
  #--------------------------------------------------------------------------
  # ● メイン処理
  #--------------------------------------------------------------------------
  def main
    # ウィンドウを作成
    @left_window = Window_DebugLeft.new
    @right_window = Window_DebugRight.new
    @help_window = Window_Base.new(192, 352, 448, 128)
    @help_window.contents = Bitmap.new(406, 96)
    # 前回選択されていた項目を復帰
    @left_window.top_row = $game_temp.debug_top_row
    @left_window.index = $game_temp.debug_index
    @right_window.mode = @left_window.mode
    @right_window.top_id = @left_window.top_id
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
    # マップをリフレッシュ
    $game_map.refresh
    # トランジション準備
    Graphics.freeze
    # ウィンドウを解放
    @left_window.dispose
    @right_window.dispose
    @help_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # ウィンドウを更新
    @right_window.mode = @left_window.mode
    @right_window.top_id = @left_window.top_id
    @left_window.update
    @right_window.update
    # 選択中の項目を記憶
    $game_temp.debug_top_row = @left_window.top_row
    $game_temp.debug_index = @left_window.index
    # レフトウィンドウがアクティブの場合: update_left を呼ぶ
    if @left_window.active
      update_left
      return
    end
    # ライトウィンドウがアクティブの場合: update_right を呼ぶ
    if @right_window.active
      update_right
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (レフトウィンドウがアクティブの場合)
  #--------------------------------------------------------------------------
  def update_left
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # キャンセル SE を演奏
      $game_system.se_play($data_system.cancel_se)
      # マップ画面に切り替え
      $scene = Scene_Map.new
      return
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # 決定 SE を演奏
      $game_system.se_play($data_system.decision_se)
      # ヘルプを表示
      if @left_window.mode == 0
        text1 = "C (Enter) : ON / OFF"
        @help_window.contents.draw_text(4, 0, 406, 32, text1)
      else
        text1 = "← : -1   → : +1"
        text2 = "L (Pageup) : -10"
        text3 = "R (Pagedown) : +10"
        @help_window.contents.draw_text(4, 0, 406, 32, text1)
        @help_window.contents.draw_text(4, 32, 406, 32, text2)
        @help_window.contents.draw_text(4, 64, 406, 32, text3)
      end
      # ライトウィンドウをアクティブ化
      @left_window.active = false
      @right_window.active = true
      @right_window.index = 0
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (ライトウィンドウがアクティブの場合)
  #--------------------------------------------------------------------------
  def update_right
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # キャンセル SE を演奏
      $game_system.se_play($data_system.cancel_se)
      # レフトウィンドウをアクティブ化
      @left_window.active = true
      @right_window.active = false
      @right_window.index = -1
      # ヘルプを消去
      @help_window.contents.clear
      return
    end
    # 選択されているスイッチ / 変数の ID を取得
    current_id = @right_window.top_id + @right_window.index
    # スイッチの場合
    if @right_window.mode == 0
      # C ボタンが押された場合
      if Input.trigger?(Input::C)
        # 決定 SE を演奏
        $game_system.se_play($data_system.decision_se)
        # ON / OFF を反転
        $game_switches[current_id] = (not $game_switches[current_id])
        @right_window.refresh
        return
      end
    end
    # 変数の場合
    if @right_window.mode == 1
      # 右ボタンが押された場合
      if Input.repeat?(Input::RIGHT)
        # カーソル SE を演奏
        $game_system.se_play($data_system.cursor_se)
        # 変数を 1 増やす
        $game_variables[current_id] += 1
        # 上限チェック
        if $game_variables[current_id] > 99999999
          $game_variables[current_id] = 99999999
        end
        @right_window.refresh
        return
      end
      # 左ボタンが押された場合
      if Input.repeat?(Input::LEFT)
        # カーソル SE を演奏
        $game_system.se_play($data_system.cursor_se)
        # 変数を 1 減らす
        $game_variables[current_id] -= 1
        # 下限チェック
        if $game_variables[current_id] < -99999999
          $game_variables[current_id] = -99999999
        end
        @right_window.refresh
        return
      end
      # R ボタンが押された場合
      if Input.repeat?(Input::R)
        # カーソル SE を演奏
        $game_system.se_play($data_system.cursor_se)
        # 変数を 10 増やす
        $game_variables[current_id] += 10
        # 上限チェック
        if $game_variables[current_id] > 99999999
          $game_variables[current_id] = 99999999
        end
        @right_window.refresh
        return
      end
      # L ボタンが押された場合
      if Input.repeat?(Input::L)
        # カーソル SE を演奏
        $game_system.se_play($data_system.cursor_se)
        # 変数を 10 減らす
        $game_variables[current_id] -= 10
        # 下限チェック
        if $game_variables[current_id] < -99999999
          $game_variables[current_id] = -99999999
        end
        @right_window.refresh
        return
      end
    end
  end
end
