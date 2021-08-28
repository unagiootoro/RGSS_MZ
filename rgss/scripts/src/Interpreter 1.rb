#==============================================================================
# ■ Interpreter (分割定義 1)
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_System クラ
# スや Game_Event クラスの内部で使用されます。
#==============================================================================

class Interpreter
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     depth : ネストの深さ
  #     main  : メインフラグ
  #--------------------------------------------------------------------------
  def initialize(depth = 0, main = false)
    @depth = depth
    @main = main
    # 深さは 100 レベルまで
    if depth > 100
      print("コモンイベントの呼び出しが上限を超えました。")
      exit
    end
    # インタプリタの内部状態をクリア
    clear
  end
  #--------------------------------------------------------------------------
  # ● クリア
  #--------------------------------------------------------------------------
  def clear
    @map_id = 0                       # 起動時のマップ ID
    @event_id = 0                     # イベント ID
    @message_waiting = false          # メッセージ終了待機中
    @move_route_waiting = false       # 移動完了待機中
    @button_input_variable_id = 0     # ボタン入力 変数 ID
    @wait_count = 0                   # ウェイトカウント
    @child_interpreter = nil          # 子インタプリタ
    @branch = {}                      # 分岐データ
  end
  #--------------------------------------------------------------------------
  # ● イベントのセットアップ
  #     list     : 実行内容
  #     event_id : イベント ID
  #--------------------------------------------------------------------------
  def setup(list, event_id)
    # インタプリタの内部状態をクリア
    clear
    # マップ ID を記憶
    @map_id = $game_map.map_id
    # イベント ID を記憶
    @event_id = event_id
    # 実行内容を記憶
    @list = list
    # インデックスを初期化
    @index = 0
    # 分岐データ用のハッシュをクリア
    @branch.clear
  end
  #--------------------------------------------------------------------------
  # ● 実行中判定
  #--------------------------------------------------------------------------
  def running?
    return @list != nil
  end
  #--------------------------------------------------------------------------
  # ● 起動中イベントのセットアップ
  #--------------------------------------------------------------------------
  def setup_starting_event
    # 必要ならマップをリフレッシュ
    if $game_map.need_refresh
      $game_map.refresh
    end
    # コモンイベントの呼び出しが予約されている場合
    if $game_temp.common_event_id > 0
      # イベントをセットアップ
      setup($data_common_events[$game_temp.common_event_id].list, 0)
      # 予約を解除
      $game_temp.common_event_id = 0
      return
    end
    # ループ (マップイベント)
    for event in $game_map.events.values
      # 起動中のイベントが見つかった場合
      if event.starting
        # 自動実行でなければ
        if event.trigger < 3
          # 起動中フラグをクリア
          event.clear_starting
          # ロック
          event.lock
        end
        # イベントをセットアップ
        setup(event.list, event.id)
        return
      end
    end
    # ループ (コモンイベント)
    for common_event in $data_common_events.compact
      # トリガーが自動実行かつ条件スイッチが ON の場合
      if common_event.trigger == 1 and
         $game_switches[common_event.switch_id] == true
        # イベントをセットアップ
        setup(common_event.list, 0)
        return
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # ループカウントを初期化
    @loop_count = 0
    # ループ
    loop do
      # ループカウントに 1 加算
      @loop_count += 1
      # イベントコマンド 100 個を実行した場合
      if @loop_count > 100
        # フリーズ防止のため、Graphics.update を呼ぶ
        Graphics.update
        @loop_count = 0
      end
      # マップがイベント起動時と異なる場合
      if $game_map.map_id != @map_id
        # イベント ID を 0 にする
        @event_id = 0
      end
      # 子インタプリタが存在する場合
      if @child_interpreter != nil
        # 子インタプリタを更新
        @child_interpreter.update
        # 子インタプリタの実行が終わった場合
        unless @child_interpreter.running?
          # 子インタプリタを消去
          @child_interpreter = nil
        end
        # 子インタプリタがまだ存在する場合
        if @child_interpreter != nil
          return
        end
      end
      # メッセージ終了待機中の場合
      if @message_waiting
        return
      end
      # 移動完了待機中の場合
      if @move_route_waiting
        # プレイヤーが移動ルート強制中の場合
        if $game_player.move_route_forcing
          return
        end
        # ループ (マップイベント)
        for event in $game_map.events.values
          # このイベントが移動ルート強制中の場合
          if event.move_route_forcing
            return
          end
        end
        # 移動完了待機中フラグをクリア
        @move_route_waiting = false
      end
      # ボタン入力待機中の場合
      if @button_input_variable_id > 0
        # ボタン入力の処理を実行
        input_button
        return
      end
      # ウェイト中の場合
      if @wait_count > 0
        # ウェイトカウントを減らす
        @wait_count -= 1
        return
      end
      # アクションを強制されているバトラーが存在する場合
      if $game_temp.forcing_battler != nil
        return
      end
      # 各種画面の呼び出しフラグがセットされている場合
      if $game_temp.battle_calling or
         $game_temp.shop_calling or
         $game_temp.name_calling or
         $game_temp.menu_calling or
         $game_temp.save_calling or
         $game_temp.gameover
        return
      end
      # 実行内容リストが空の場合
      if @list == nil
        # メインのマップイベントの場合
        if @main
          # 起動中のイベントをセットアップ
          setup_starting_event
        end
        # 何もセットアップされなかった場合
        if @list == nil
          return
        end
      end
      # イベントコマンドの実行を試み、戻り値が false の場合
      if execute_command == false
        return
      end
      # インデックスを進める
      @index += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● ボタン入力
  #--------------------------------------------------------------------------
  def input_button
    # 押されたボタンを判定
    n = 0
    for i in 1..18
      if Input.trigger?(i)
        n = i
      end
    end
    # ボタンが押された場合
    if n > 0
      # 変数の値を変更
      $game_variables[@button_input_variable_id] = n
      $game_map.need_refresh = true
      # ボタン入力を終了
      @button_input_variable_id = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 選択肢のセットアップ
  #--------------------------------------------------------------------------
  def setup_choices(parameters)
    # choice_max に選択肢の項目数を設定
    $game_temp.choice_max = parameters[0].size
    # message_text に選択肢を設定
    for text in parameters[0]
      $game_temp.message_text += text + "\n"
    end
    # キャンセルの場合の処理を設定
    $game_temp.choice_cancel_type = parameters[1]
    # コールバックを設定
    current_indent = @list[@index].indent
    $game_temp.choice_proc = Proc.new { |n| @branch[current_indent] = n }
  end
  #--------------------------------------------------------------------------
  # ● アクター用イテレータ (パーティ全体を考慮)
  #     parameter : 1 以上なら ID、0 なら全体
  #--------------------------------------------------------------------------
  def iterate_actor(parameter)
    # パーティ全体の場合
    if parameter == 0
      # パーティ全体分ループ
      for actor in $game_party.actors
        # ブロックを評価
        yield actor
      end
    # アクター単体の場合
    else
      # アクターを取得
      actor = $game_actors[parameter]
      # ブロックを評価
      yield actor if actor != nil
    end
  end
  #--------------------------------------------------------------------------
  # ● エネミー用イテレータ (トループ全体を考慮)
  #     parameter : 0 以上ならインデックス、-1 なら全体
  #--------------------------------------------------------------------------
  def iterate_enemy(parameter)
    # トループ全体の場合
    if parameter == -1
      # トループ全体分ループ
      for enemy in $game_troop.enemies
        # ブロックを評価
        yield enemy
      end
    # エネミー単体の場合
    else
      # エネミーを取得
      enemy = $game_troop.enemies[parameter]
      # ブロックを評価
      yield enemy if enemy != nil
    end
  end
  #--------------------------------------------------------------------------
  # ● バトラー用イテレータ (トループ全体、パーティ全体を考慮)
  #     parameter1 : 0 ならエネミー、1 ならアクター
  #     parameter2 : 0 以上ならインデックス、-1 なら全体
  #--------------------------------------------------------------------------
  def iterate_battler(parameter1, parameter2)
    # エネミーの場合
    if parameter1 == 0
      # エネミーのイテレータを呼び出す
      iterate_enemy(parameter2) do |enemy|
        yield enemy
      end
    # アクターの場合
    else
      # パーティ全体の場合
      if parameter2 == -1
        # パーティ全体分ループ
        for actor in $game_party.actors
          # ブロックを評価
          yield actor
        end
      # アクター単体 (N 人目) の場合
      else
        # アクターを取得
        actor = $game_party.actors[parameter2]
        # ブロックを評価
        yield actor if actor != nil
      end
    end
  end
end
