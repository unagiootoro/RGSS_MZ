#==============================================================================
# ■ Scene_File
#------------------------------------------------------------------------------
# 　セーブ画面およびロード画面のスーパークラスです。
#==============================================================================

class Scene_File
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     help_text : ヘルプウィンドウに表示する文字列
  #--------------------------------------------------------------------------
  def initialize(help_text)
    @help_text = help_text
  end
  #--------------------------------------------------------------------------
  # ● メイン処理
  #--------------------------------------------------------------------------
  def main
    # ヘルプウィンドウを作成
    @help_window = Window_Help.new
    @help_window.set_text(@help_text)
    # セーブファイルウィンドウを作成
    @savefile_windows = []
    for i in 0..3
      @savefile_windows.push(Window_SaveFile.new(i, make_filename(i)))
    end
    # 最後に操作したファイルを選択
    @file_index = $game_temp.last_file_index
    @savefile_windows[@file_index].selected = true
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
    @help_window.dispose
    for i in @savefile_windows
      i.dispose
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # ウィンドウを更新
    @help_window.update
    for i in @savefile_windows
      i.update
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # メソッド on_decision (継承先で定義) を呼ぶ
      on_decision(make_filename(@file_index))
      $game_temp.last_file_index = @file_index
      return
    end
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # メソッド on_cancel (継承先で定義) を呼ぶ
      on_cancel
      return
    end
    # 方向ボタンの下が押された場合
    if Input.repeat?(Input::DOWN)
      # 方向ボタンの下の押下状態がリピートでない場合か、
      # またはカーソル位置が 3 より前の場合
      if Input.trigger?(Input::DOWN) or @file_index < 3
        # カーソル SE を演奏
        $game_system.se_play($data_system.cursor_se)
        # カーソルを下に移動
        @savefile_windows[@file_index].selected = false
        @file_index = (@file_index + 1) % 4
        @savefile_windows[@file_index].selected = true
        return
      end
    end
    # 方向ボタンの上が押された場合
    if Input.repeat?(Input::UP)
      # 方向ボタンの上の押下状態がリピートでない場合か、
      # またはカーソル位置が 0 より後ろの場合
      if Input.trigger?(Input::UP) or @file_index > 0
        # カーソル SE を演奏
        $game_system.se_play($data_system.cursor_se)
        # カーソルを上に移動
        @savefile_windows[@file_index].selected = false
        @file_index = (@file_index + 3) % 4
        @savefile_windows[@file_index].selected = true
        return
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● ファイル名の作成
  #     file_index : セーブファイルのインデックス (0～3)
  #--------------------------------------------------------------------------
  def make_filename(file_index)
    return "Save#{file_index + 1}.rxdata"
  end
end
