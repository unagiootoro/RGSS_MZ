#==============================================================================
# ■ Scene_Load
#------------------------------------------------------------------------------
# 　ロード画面の処理を行うクラスです。
#==============================================================================

class Scene_Load < Scene_File
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    # テンポラリオブジェクトを再作成
    $game_temp = Game_Temp.new
    # タイムスタンプが最新のファイルを選択
    $game_temp.last_file_index = 0
    latest_time = Time.at(0)
    for i in 0..3
      filename = make_filename(i)
      if FileTest.exist?(filename)
        file = File.open(filename, "r")
        if file.mtime > latest_time
          latest_time = file.mtime
          $game_temp.last_file_index = i
        end
        file.close
      end
    end
    super("どのファイルをロードしますか？")
  end
  #--------------------------------------------------------------------------
  # ● 決定時の処理
  #--------------------------------------------------------------------------
  def on_decision(filename)
    # ファイルが存在しない場合
    unless FileTest.exist?(filename)
      # ブザー SE を演奏
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # ロード SE を演奏
    $game_system.se_play($data_system.load_se)
    # セーブデータの書き込み
    file = File.open(filename, "rb")
    read_save_data(file)
    file.close
    # BGM、BGS を復帰
    $game_system.bgm_play($game_system.playing_bgm)
    $game_system.bgs_play($game_system.playing_bgs)
    # マップを更新 (並列イベント実行)
    $game_map.update
    # マップ画面に切り替え
    $scene = Scene_Map.new
  end
  #--------------------------------------------------------------------------
  # ● キャンセル時の処理
  #--------------------------------------------------------------------------
  def on_cancel
    # キャンセル SE を演奏
    $game_system.se_play($data_system.cancel_se)
    # タイトル画面に切り替え
    $scene = Scene_Title.new
  end
  #--------------------------------------------------------------------------
  # ● セーブデータの読み込み
  #     file : 読み込み用ファイルオブジェクト (オープン済み)
  #--------------------------------------------------------------------------
  def read_save_data(file)
    # セーブファイル描画用のキャラクターデータを読み込む
    characters = Marshal.load(file)
    # プレイ時間計測用のフレームカウントを読み込む
    Graphics.frame_count = Marshal.load(file)
    # 各種ゲームオブジェクトを読み込む
    $game_system        = Marshal.load(file)
    $game_switches      = Marshal.load(file)
    $game_variables     = Marshal.load(file)
    $game_self_switches = Marshal.load(file)
    $game_screen        = Marshal.load(file)
    $game_actors        = Marshal.load(file)
    $game_party         = Marshal.load(file)
    $game_troop         = Marshal.load(file)
    $game_map           = Marshal.load(file)
    $game_player        = Marshal.load(file)
    # マジックナンバーがセーブ時と異なる場合
    # (エディタで編集が加えられている場合)
    if $game_system.magic_number != $data_system.magic_number
      # マップをリロード
      $game_map.setup($game_map.map_id)
      $game_player.center($game_player.x, $game_player.y)
    end
    # パーティメンバーをリフレッシュ
    $game_party.refresh
  end
end
