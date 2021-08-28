#==============================================================================
# ■ Scene_Save
#------------------------------------------------------------------------------
# 　セーブ画面の処理を行うクラスです。
#==============================================================================

class Scene_Save < Scene_File
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super("どのファイルにセーブしますか？")
  end
  #--------------------------------------------------------------------------
  # ● 決定時の処理
  #--------------------------------------------------------------------------
  def on_decision(filename)
    # セーブ SE を演奏
    $game_system.se_play($data_system.save_se)
    # セーブデータの書き込み
    file = File.open(filename, "wb")
    write_save_data(file)
    file.close
    # イベントから呼び出されている場合
    if $game_temp.save_calling
      # セーブ呼び出しフラグをクリア
      $game_temp.save_calling = false
      # マップ画面に切り替え
      $scene = Scene_Map.new
      return
    end
    # メニュー画面に切り替え
    $scene = Scene_Menu.new(4)
  end
  #--------------------------------------------------------------------------
  # ● キャンセル時の処理
  #--------------------------------------------------------------------------
  def on_cancel
    # キャンセル SE を演奏
    $game_system.se_play($data_system.cancel_se)
    # イベントから呼び出されている場合
    if $game_temp.save_calling
      # セーブ呼び出しフラグをクリア
      $game_temp.save_calling = false
      # マップ画面に切り替え
      $scene = Scene_Map.new
      return
    end
    # メニュー画面に切り替え
    $scene = Scene_Menu.new(4)
  end
  #--------------------------------------------------------------------------
  # ● セーブデータの書き込み
  #     file : 書き込み用ファイルオブジェクト (オープン済み)
  #--------------------------------------------------------------------------
  def write_save_data(file)
    # セーブファイル描画用のキャラクターデータを作成
    characters = []
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      characters.push([actor.character_name, actor.character_hue])
    end
    # セーブファイル描画用のキャラクターデータを書き込む
    Marshal.dump(characters, file)
    # プレイ時間計測用のフレームカウントを書き込む
    Marshal.dump(Graphics.frame_count, file)
    # セーブ回数を 1 増やす
    $game_system.save_count += 1
    # マジックナンバーを保存する
    # (エディタで保存するたびにランダムな値に書き換えられる)
    $game_system.magic_number = $data_system.magic_number
    # 各種ゲームオブジェクトを書き込む
    Marshal.dump($game_system, file)
    Marshal.dump($game_switches, file)
    Marshal.dump($game_variables, file)
    Marshal.dump($game_self_switches, file)
    Marshal.dump($game_screen, file)
    Marshal.dump($game_actors, file)
    Marshal.dump($game_party, file)
    Marshal.dump($game_troop, file)
    Marshal.dump($game_map, file)
    Marshal.dump($game_player, file)
  end
end
