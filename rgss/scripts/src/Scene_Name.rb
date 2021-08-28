#==============================================================================
# ■ Scene_Name
#------------------------------------------------------------------------------
# 　名前入力画面の処理を行うクラスです。
#==============================================================================

class Scene_Name
  #--------------------------------------------------------------------------
  # ● メイン処理
  #--------------------------------------------------------------------------
  def main
    # アクターを取得
    @actor = $game_actors[$game_temp.name_actor_id]
    # ウィンドウを作成
    @edit_window = Window_NameEdit.new(@actor, $game_temp.name_max_char)
    @input_window = Window_NameInput.new
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
    @edit_window.dispose
    @input_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # ウィンドウを更新
    @edit_window.update
    @input_window.update
    # B ボタンが押された場合
    if Input.repeat?(Input::B)
      # カーソル位置が 0 の場合
      if @edit_window.index == 0
        return
      end
      # キャンセル SE を演奏
      $game_system.se_play($data_system.cancel_se)
      # 文字を削除
      @edit_window.back
      return
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # カーソル位置が [決定] の場合
      if @input_window.character == nil
        # 名前が空の場合
        if @edit_window.name == ""
          # デフォルトの名前に戻す
          @edit_window.restore_default
          # 名前が空の場合
          if @edit_window.name == ""
            # ブザー SE を演奏
            $game_system.se_play($data_system.buzzer_se)
            return
          end
          # 決定 SE を演奏
          $game_system.se_play($data_system.decision_se)
          return
        end
        # アクターの名前を変更
        @actor.name = @edit_window.name
        # 決定 SE を演奏
        $game_system.se_play($data_system.decision_se)
        # マップ画面に切り替え
        $scene = Scene_Map.new
        return
      end
      # カーソル位置が最大の場合
      if @edit_window.index == $game_temp.name_max_char
        # ブザー SE を演奏
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 文字が空の場合
      if @input_window.character == ""
        # ブザー SE を演奏
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 決定 SE を演奏
      $game_system.se_play($data_system.decision_se)
      # 文字を追加
      @edit_window.add(@input_window.character)
      return
    end
  end
end
