#==============================================================================
# ■ Game_Event
#------------------------------------------------------------------------------
# 　イベントを扱うクラスです。条件判定によるイベントページ切り替えや、並列処理
# イベント実行などの機能を持っており、Game_Map クラスの内部で使用されます。
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :trigger                  # トリガー
  attr_reader   :list                     # 実行内容
  attr_reader   :starting                 # 起動中フラグ
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     map_id : マップ ID
  #     event  : イベント (RPG::Event)
  #--------------------------------------------------------------------------
  def initialize(map_id, event)
    super()
    @map_id = map_id
    @event = event
    @id = @event.id
    @erased = false
    @starting = false
    @through = true
    # 初期位置に移動
    moveto(@event.x, @event.y)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 起動中フラグのクリア
  #--------------------------------------------------------------------------
  def clear_starting
    @starting = false
  end
  #--------------------------------------------------------------------------
  # ● オーバートリガー判定 (同位置を起動条件とするか否か)
  #--------------------------------------------------------------------------
  def over_trigger?
    # グラフィックがキャラクターで、すり抜け状態ではない場合
    if @character_name != "" and not @through
      # 起動判定は正面
      return false
    end
    # マップ上でこの位置が通行不可能な場合
    unless $game_map.passable?(@x, @y, 0)
      # 起動判定は正面
      return false
    end
    # 起動判定は同位置
    return true
  end
  #--------------------------------------------------------------------------
  # ● イベント起動
  #--------------------------------------------------------------------------
  def start
    # 実行内容が空でない場合
    if @list.size > 1
      @starting = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 一時消去
  #--------------------------------------------------------------------------
  def erase
    @erased = true
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    # ローカル変数 new_page を初期化
    new_page = nil
    # 一時消去されていない場合
    unless @erased
      # 番号の大きいイベントページから順に調べる
      for page in @event.pages.reverse
        # イベント条件を c で参照可能に
        c = page.condition
        # スイッチ 1 条件確認
        if c.switch1_valid
          if $game_switches[c.switch1_id] == false
            next
          end
        end
        # スイッチ 2 条件確認
        if c.switch2_valid
          if $game_switches[c.switch2_id] == false
            next
          end
        end
        # 変数 条件確認
        if c.variable_valid
          if $game_variables[c.variable_id] < c.variable_value
            next
          end
        end
        # セルフスイッチ 条件確認
        if c.self_switch_valid
          key = [@map_id, @event.id, c.self_switch_ch]
          if $game_self_switches[key] != true
            next
          end
        end
        # ローカル変数 new_page を設定
        new_page = page
        # ループを抜ける
        break
      end
    end
    # 前回と同じイベントページの場合
    if new_page == @page
      # メソッド終了
      return
    end
    # @page に現在のイベントページを設定
    @page = new_page
    # 起動中フラグをクリア
    clear_starting
    # 条件を満たすページがない場合
    if @page == nil
      # 各インスタンス変数を設定
      @tile_id = 0
      @character_name = ""
      @character_hue = 0
      @move_type = 0
      @through = true
      @trigger = nil
      @list = nil
      @interpreter = nil
      # メソッド終了
      return
    end
    # 各インスタンス変数を設定
    @tile_id = @page.graphic.tile_id
    @character_name = @page.graphic.character_name
    @character_hue = @page.graphic.character_hue
    if @original_direction != @page.graphic.direction
      @direction = @page.graphic.direction
      @original_direction = @direction
      @prelock_direction = 0
    end
    if @original_pattern != @page.graphic.pattern
      @pattern = @page.graphic.pattern
      @original_pattern = @pattern
    end
    @opacity = @page.graphic.opacity
    @blend_type = @page.graphic.blend_type
    @move_type = @page.move_type
    @move_speed = @page.move_speed
    @move_frequency = @page.move_frequency
    @move_route = @page.move_route
    @move_route_index = 0
    @move_route_forcing = false
    @walk_anime = @page.walk_anime
    @step_anime = @page.step_anime
    @direction_fix = @page.direction_fix
    @through = @page.through
    @always_on_top = @page.always_on_top
    @trigger = @page.trigger
    @list = @page.list
    @interpreter = nil
    # トリガーが [並列処理] の場合
    if @trigger == 4
      # 並列処理用インタプリタを作成
      @interpreter = Interpreter.new
    end
    # 自動イベントの起動判定
    check_event_trigger_auto
  end
  #--------------------------------------------------------------------------
  # ● 接触イベントの起動判定
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    # イベント実行中の場合
    if $game_system.map_interpreter.running?
      return
    end
    # トリガーが [イベントから接触] かつプレイヤーの座標と一致した場合
    if @trigger == 2 and x == $game_player.x and y == $game_player.y
      # ジャンプ中以外で、起動判定が正面のイベントなら
      if not jumping? and not over_trigger?
        start
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 自動イベントの起動判定
  #--------------------------------------------------------------------------
  def check_event_trigger_auto
    # トリガーが [イベントから接触] かつプレイヤーの座標と一致した場合
    if @trigger == 2 and @x == $game_player.x and @y == $game_player.y
      # ジャンプ中以外で、起動判定が同位置のイベントなら
      if not jumping? and over_trigger?
        start
      end
    end
    # トリガーが [自動実行] の場合
    if @trigger == 3
      start
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    # 自動イベントの起動判定
    check_event_trigger_auto
    # 並列処理が有効の場合
    if @interpreter != nil
      # 実行中でない場合
      unless @interpreter.running?
        # イベントをセットアップ
        @interpreter.setup(@list, @event.id)
      end
      # インタプリタを更新
      @interpreter.update
    end
  end
end
