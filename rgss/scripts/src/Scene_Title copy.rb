#==============================================================================
# ■ Scene_Title
#------------------------------------------------------------------------------
# 　タイトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Title
  #--------------------------------------------------------------------------
  # ● メイン処理
  #--------------------------------------------------------------------------
  def main
    # 戦闘テストの場合
    if $BTEST
      battle_test
      return
    end
    # データベースをロード
    $data_actors        = load_data("Data/Actors.rxdata")
    $data_classes       = load_data("Data/Classes.rxdata")
    $data_skills        = load_data("Data/Skills.rxdata")
    $data_items         = load_data("Data/Items.rxdata")
    $data_weapons       = load_data("Data/Weapons.rxdata")
    $data_armors        = load_data("Data/Armors.rxdata")
    $data_enemies       = load_data("Data/Enemies.rxdata")
    $data_troops        = load_data("Data/Troops.rxdata")
    $data_states        = load_data("Data/States.rxdata")
    $data_animations    = load_data("Data/Animations.rxdata")
    $data_tilesets      = load_data("Data/Tilesets.rxdata")
    $data_common_events = load_data("Data/CommonEvents.rxdata")
    $data_system        = load_data("Data/System.rxdata")
    # システムオブジェクトを作成
    $game_system = Game_System.new
    # タイトルグラフィックを作成
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.title($data_system.title_name)
    # コマンドウィンドウを作成
    s1 = "ニューゲーム"
    s2 = "コンティニュー"
    s3 = "シャットダウン"
    @command_window = Window_Command.new(192, [s1, s2, s3])
    @command_window.back_opacity = 160
    @command_window.x = 320 - @command_window.width / 2
    @command_window.y = 288
    # コンティニュー有効判定
    # セーブファイルがひとつでも存在するかどうかを調べる
    # 有効なら @continue_enabled を true、無効なら false にする
    @continue_enabled = false
    for i in 0..3
      if FileTest.exist?("Save#{i+1}.rxdata")
        @continue_enabled = true
      end
    end
    # コンティニューが有効な場合、カーソルをコンティニューに合わせる
    # 無効な場合、コンティニューの文字をグレー表示にする
    if @continue_enabled
      @command_window.index = 1
    else
      @command_window.disable_item(1)
    end
    # タイトル BGM を演奏
    $game_system.bgm_play($data_system.title_bgm)
    # ME、BGS の演奏を停止
    Audio.me_stop
    Audio.bgs_stop
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
    # コマンドウィンドウを解放
    @command_window.dispose
    # タイトルグラフィックを解放
    @sprite.bitmap.dispose
    @sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # コマンドウィンドウを更新
    @command_window.update
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # コマンドウィンドウのカーソル位置で分岐
      case @command_window.index
      when 0  # ニューゲーム
        command_new_game
      when 1  # コンティニュー
        command_continue
      when 2  # シャットダウン
        command_shutdown
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● コマンド : ニューゲーム
  #--------------------------------------------------------------------------
  def command_new_game
    # 決定 SE を演奏
    $game_system.se_play($data_system.decision_se)
    # BGM を停止
    Audio.bgm_stop
    # プレイ時間計測用のフレームカウントをリセット
    Graphics.frame_count = 0
    # 各種ゲームオブジェクトを作成
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_screen        = Game_Screen.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    # 初期パーティをセットアップ
    $game_party.setup_starting_members
    # 初期位置のマップをセットアップ
    $game_map.setup($data_system.start_map_id)
    # プレイヤーを初期位置に移動
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    # プレイヤーをリフレッシュ
    $game_player.refresh
    # マップに設定されている BGM と BGS の自動切り替えを実行
    $game_map.autoplay
    # マップを更新 (並列イベント実行)
    $game_map.update
    # マップ画面に切り替え
    $scene = Scene_Map.new
  end
  #--------------------------------------------------------------------------
  # ● コマンド : コンティニュー
  #--------------------------------------------------------------------------
  def command_continue
    # コンティニューが無効の場合
    unless @continue_enabled
      # ブザー SE を演奏
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # 決定 SE を演奏
    $game_system.se_play($data_system.decision_se)
    # ロード画面に切り替え
    $scene = Scene_Load.new
  end
  #--------------------------------------------------------------------------
  # ● コマンド : シャットダウン
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
  # ● 戦闘テスト
  #--------------------------------------------------------------------------
  def battle_test
    # データベース (戦闘テスト用) をロード
    $data_actors        = load_data("Data/BT_Actors.rxdata")
    $data_classes       = load_data("Data/BT_Classes.rxdata")
    $data_skills        = load_data("Data/BT_Skills.rxdata")
    $data_items         = load_data("Data/BT_Items.rxdata")
    $data_weapons       = load_data("Data/BT_Weapons.rxdata")
    $data_armors        = load_data("Data/BT_Armors.rxdata")
    $data_enemies       = load_data("Data/BT_Enemies.rxdata")
    $data_troops        = load_data("Data/BT_Troops.rxdata")
    $data_states        = load_data("Data/BT_States.rxdata")
    $data_animations    = load_data("Data/BT_Animations.rxdata")
    $data_tilesets      = load_data("Data/BT_Tilesets.rxdata")
    $data_common_events = load_data("Data/BT_CommonEvents.rxdata")
    $data_system        = load_data("Data/BT_System.rxdata")
    # プレイ時間計測用のフレームカウントをリセット
    Graphics.frame_count = 0
    # 各種ゲームオブジェクトを作成
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_screen        = Game_Screen.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    # 戦闘テスト用のパーティをセットアップ
    $game_party.setup_battle_test_members
    # トループ ID、逃走可能フラグ、バトルバックを設定
    $game_temp.battle_troop_id = $data_system.test_troop_id
    $game_temp.battle_can_escape = true
    $game_map.battleback_name = $data_system.battleback_name
    # バトル開始 SE を演奏
    $game_system.se_play($data_system.battle_start_se)
    # バトル BGM を演奏
    $game_system.bgm_play($game_system.battle_bgm)
    # バトル画面に切り替え
    $scene = Scene_Battle.new
  end
end
