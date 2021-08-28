#==============================================================================
# ■ Game_Player
#------------------------------------------------------------------------------
# 　プレイヤーを扱うクラスです。イベントの起動判定や、マップのスクロールなどの
# 機能を持っています。このクラスのインスタンスは $game_player で参照されます。
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ● 定数
  #--------------------------------------------------------------------------
  CENTER_X = (320 - 16) * 4   # 画面中央の X 座標 * 4
  CENTER_Y = (240 - 16) * 4   # 画面中央の Y 座標 * 4
  #--------------------------------------------------------------------------
  # ● 通行可能判定
  #     x : X 座標
  #     y : Y 座標
  #     d : 方向 (0,2,4,6,8)  ※ 0 = 全方向通行不可の場合を判定 (ジャンプ用)
  #--------------------------------------------------------------------------
  def passable?(x, y, d)
    # 新しい座標を求める
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    # 座標がマップ外の場合
    unless $game_map.valid?(new_x, new_y)
      # 通行不可
      return false
    end
    # デバッグモードが ON かつ CTRL キーが押されている場合
    if $DEBUG and Input.press?(Input::CTRL)
      # 通行可
      return true
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● 画面中央に来るようにマップの表示位置を設定
  #--------------------------------------------------------------------------
  def center(x, y)
    max_x = ($game_map.width - 20) * 128
    max_y = ($game_map.height - 15) * 128
    $game_map.display_x = [0, [x * 128 - CENTER_X, max_x].min].max
    $game_map.display_y = [0, [y * 128 - CENTER_Y, max_y].min].max
  end
  #--------------------------------------------------------------------------
  # ● 指定位置に移動
  #     x : X 座標
  #     y : Y 座標
  #--------------------------------------------------------------------------
  def moveto(x, y)
    super
    # センタリング
    center(x, y)
    # エンカウント カウントを作成
    make_encounter_count
  end
  #--------------------------------------------------------------------------
  # ● 歩数増加
  #--------------------------------------------------------------------------
  def increase_steps
    super
    # 移動ルート強制中ではない場合
    unless @move_route_forcing
      # 歩数増加
      $game_party.increase_steps
      # 歩数が偶数の場合
      if $game_party.steps % 2 == 0
        # スリップダメージチェック
        $game_party.check_map_slip_damage
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● エンカウント カウント取得
  #--------------------------------------------------------------------------
  def encounter_count
    return @encounter_count
  end
  #--------------------------------------------------------------------------
  # ● エンカウント カウント作成
  #--------------------------------------------------------------------------
  def make_encounter_count
    # サイコロを 2 個振るイメージ
    if $game_map.map_id != 0
      n = $game_map.encounter_step
      @encounter_count = rand(n) + rand(n) + 1
    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    # パーティ人数が 0 人の場合
    if $game_party.actors.size == 0
      # キャラクターのファイル名と色相をクリア
      @character_name = ""
      @character_hue = 0
      # メソッド終了
      return
    end
    # 先頭のアクターを取得
    actor = $game_party.actors[0]
    # キャラクターのファイル名と色相を設定
    @character_name = actor.character_name
    @character_hue = actor.character_hue
    # 不透明度と合成方法を初期化
    @opacity = 255
    @blend_type = 0
  end
  #--------------------------------------------------------------------------
  # ● 同位置のイベント起動判定
  #--------------------------------------------------------------------------
  def check_event_trigger_here(triggers)
    result = false
    # イベント実行中の場合
    if $game_system.map_interpreter.running?
      return result
    end
    # 全イベントのループ
    for event in $game_map.events.values
      # イベントの座標とトリガーが一致した場合
      if event.x == @x and event.y == @y and triggers.include?(event.trigger)
        # ジャンプ中以外で、起動判定が同位置のイベントなら
        if not event.jumping? and event.over_trigger?
          event.start
          result = true
        end
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # ● 正面のイベント起動判定
  #--------------------------------------------------------------------------
  def check_event_trigger_there(triggers)
    result = false
    # イベント実行中の場合
    if $game_system.map_interpreter.running?
      return result
    end
    # 正面の座標を計算
    new_x = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    new_y = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    # 全イベントのループ
    for event in $game_map.events.values
      # イベントの座標とトリガーが一致した場合
      if event.x == new_x and event.y == new_y and
         triggers.include?(event.trigger)
        # ジャンプ中以外で、起動判定が正面のイベントなら
        if not event.jumping? and not event.over_trigger?
          event.start
          result = true
        end
      end
    end
    # 該当するイベントが見つからなかった場合
    if result == false
      # 正面のタイルがカウンターなら
      if $game_map.counter?(new_x, new_y)
        # 1 タイル奥の座標を計算
        new_x += (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
        new_y += (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
        # 全イベントのループ
        for event in $game_map.events.values
          # イベントの座標とトリガーが一致した場合
          if event.x == new_x and event.y == new_y and
             triggers.include?(event.trigger)
            # ジャンプ中以外で、起動判定が正面のイベントなら
            if not event.jumping? and not event.over_trigger?
              event.start
              result = true
            end
          end
        end
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # ● 接触イベントの起動判定
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    result = false
    # イベント実行中の場合
    if $game_system.map_interpreter.running?
      return result
    end
    # 全イベントのループ
    for event in $game_map.events.values
      # イベントの座標とトリガーが一致した場合
      if event.x == x and event.y == y and [1,2].include?(event.trigger)
        # ジャンプ中以外で、起動判定が正面のイベントなら
        if not event.jumping? and not event.over_trigger?
          event.start
          result = true
        end
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # ローカル変数に移動中かどうかを記憶
    last_moving = moving?
    # 移動中、イベント実行中、移動ルート強制中、
    # メッセージウィンドウ表示中のいずれでもない場合
    unless moving? or $game_system.map_interpreter.running? or
           @move_route_forcing or $game_temp.message_window_showing
      # 方向ボタンが押されていれば、その方向へプレイヤーを移動
      case Input.dir4
      when 2
        move_down
      when 4
        move_left
      when 6
        move_right
      when 8
        move_up
      end
    end
    # ローカル変数に座標を記憶
    last_real_x = @real_x
    last_real_y = @real_y
    super
    # キャラクターが下に移動し、かつ画面上の位置が中央より下の場合
    if @real_y > last_real_y and @real_y - $game_map.display_y > CENTER_Y
      # マップを下にスクロール
      $game_map.scroll_down(@real_y - last_real_y)
    end
    # キャラクターが左に移動し、かつ画面上の位置が中央より左の場合
    if @real_x < last_real_x and @real_x - $game_map.display_x < CENTER_X
      # マップを左にスクロール
      $game_map.scroll_left(last_real_x - @real_x)
    end
    # キャラクターが右に移動し、かつ画面上の位置が中央より右の場合
    if @real_x > last_real_x and @real_x - $game_map.display_x > CENTER_X
      # マップを右にスクロール
      $game_map.scroll_right(@real_x - last_real_x)
    end
    # キャラクターが上に移動し、かつ画面上の位置が中央より上の場合
    if @real_y < last_real_y and @real_y - $game_map.display_y < CENTER_Y
      # マップを上にスクロール
      $game_map.scroll_up(last_real_y - @real_y)
    end
    # 移動中ではない場合
    unless moving?
      # 前回プレイヤーが移動中だった場合
      if last_moving
        # 同位置のイベントとの接触によるイベント起動判定
        result = check_event_trigger_here([1,2])
        # 起動したイベントがない場合
        if result == false
          # デバッグモードが ON かつ CTRL キーが押されている場合を除き
          unless $DEBUG and Input.press?(Input::CTRL)
            # エンカウント カウントダウン
            if @encounter_count > 0
              @encounter_count -= 1
            end
          end
        end
      end
      # C ボタンが押された場合
      if Input.trigger?(Input::C)
        # 同位置および正面のイベント起動判定
        check_event_trigger_here([0])
        check_event_trigger_there([0,1,2])
      end
    end
  end
end
