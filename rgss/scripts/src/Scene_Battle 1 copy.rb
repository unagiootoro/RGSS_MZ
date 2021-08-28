#==============================================================================
# ■ Scene_Battle (分割定義 1)
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # ● メイン処理
  #--------------------------------------------------------------------------
  def main
    # 戦闘用の各種一時データを初期化
    $game_temp.in_battle = true
    $game_temp.battle_turn = 0
    $game_temp.battle_event_flags.clear
    $game_temp.battle_abort = false
    $game_temp.battle_main_phase = false
    $game_temp.battleback_name = $game_map.battleback_name
    $game_temp.forcing_battler = nil
    # バトルイベント用インタプリタを初期化
    $game_system.battle_interpreter.setup(nil, 0)
    # トループを準備
    @troop_id = $game_temp.battle_troop_id
    $game_troop.setup(@troop_id)
    # アクターコマンドウィンドウを作成
    s1 = $data_system.words.attack
    s2 = $data_system.words.skill
    s3 = $data_system.words.guard
    s4 = $data_system.words.item
    @actor_command_window = Window_Command.new(160, [s1, s2, s3, s4])
    @actor_command_window.y = 160
    @actor_command_window.back_opacity = 160
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # その他のウィンドウを作成
    @party_command_window = Window_PartyCommand.new
    @help_window = Window_Help.new
    @help_window.back_opacity = 160
    @help_window.visible = false
    @status_window = Window_BattleStatus.new
    @message_window = Window_Message.new
    # スプライトセットを作成
    @spriteset = Spriteset_Battle.new
    # ウェイトカウントを初期化
    @wait_count = 0
    # トランジション実行
    if $data_system.battle_transition == ""
      Graphics.transition(20)
    else
      Graphics.transition(40, "Graphics/Transitions/" +
        $data_system.battle_transition)
    end
    # プレバトルフェーズ開始
    start_phase1
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
    @actor_command_window.dispose
    @party_command_window.dispose
    @help_window.dispose
    @status_window.dispose
    @message_window.dispose
    if @skill_window != nil
      @skill_window.dispose
    end
    if @item_window != nil
      @item_window.dispose
    end
    if @result_window != nil
      @result_window.dispose
    end
    # スプライトセットを解放
    @spriteset.dispose
    # タイトル画面に切り替え中の場合
    if $scene.is_a?(Scene_Title)
      # 画面をフェードアウト
      Graphics.transition
      Graphics.freeze
    end
    # 戦闘テストからゲームオーバー画面以外に切り替え中の場合
    if $BTEST and not $scene.is_a?(Scene_Gameover)
      $scene = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 勝敗判定
  #--------------------------------------------------------------------------
  def judge
    # 全滅判定が真、またはパーティ人数が 0 人の場合
    if $game_party.all_dead? or $game_party.actors.size == 0
      # 敗北可能の場合
      if $game_temp.battle_can_lose
        # バトル開始前の BGM に戻す
        $game_system.bgm_play($game_temp.map_bgm)
        # バトル終了
        battle_end(2)
        # true を返す
        return true
      end
      # ゲームオーバーフラグをセット
      $game_temp.gameover = true
      # true を返す
      return true
    end
    # エネミーが 1 体でも存在すれば false を返す
    for enemy in $game_troop.enemies
      if enemy.exist?
        return false
      end
    end
    # アフターバトルフェーズ開始 (勝利)
    start_phase5
    # true を返す
    return true
  end
  #--------------------------------------------------------------------------
  # ● バトル終了
  #     result : 結果 (0:勝利 1:敗北 2:逃走)
  #--------------------------------------------------------------------------
  def battle_end(result)
    # 戦闘中フラグをクリア
    $game_temp.in_battle = false
    # パーティ全員のアクションをクリア
    $game_party.clear_actions
    # バトル用ステートを解除
    for actor in $game_party.actors
      actor.remove_states_battle
    end
    # エネミーをクリア
    $game_troop.enemies.clear
    # バトル コールバックを呼ぶ
    if $game_temp.battle_proc != nil
      $game_temp.battle_proc.call(result)
      $game_temp.battle_proc = nil
    end
    # マップ画面に切り替え
    $scene = Scene_Map.new
  end
  #--------------------------------------------------------------------------
  # ● バトルイベントのセットアップ
  #--------------------------------------------------------------------------
  def setup_battle_event
    # バトルイベント実行中の場合
    if $game_system.battle_interpreter.running?
      return
    end
    # バトルイベントの全ページを検索
    for index in 0...$data_troops[@troop_id].pages.size
      # イベントページを取得
      page = $data_troops[@troop_id].pages[index]
      # イベント条件を c で参照可能に
      c = page.condition
      # 何も条件が指定されていない場合は次のページへ
      unless c.turn_valid or c.enemy_valid or
             c.actor_valid or c.switch_valid
        next
      end
      # 実行済みの場合は次のページへ
      if $game_temp.battle_event_flags[index]
        next
      end
      # ターン 条件確認
      if c.turn_valid
        n = $game_temp.battle_turn
        a = c.turn_a
        b = c.turn_b
        if (b == 0 and n != a) or
           (b > 0 and (n < 1 or n < a or n % b != a % b))
          next
        end
      end
      # エネミー 条件確認
      if c.enemy_valid
        enemy = $game_troop.enemies[c.enemy_index]
        if enemy == nil or enemy.hp * 100.0 / enemy.maxhp > c.enemy_hp
          next
        end
      end
      # アクター 条件確認
      if c.actor_valid
        actor = $game_actors[c.actor_id]
        if actor == nil or actor.hp * 100.0 / actor.maxhp > c.actor_hp
          next
        end
      end
      # スイッチ 条件確認
      if c.switch_valid
        if $game_switches[c.switch_id] == false
          next
        end
      end
      # イベントをセットアップ
      $game_system.battle_interpreter.setup(page.list, 0)
      # このページのスパンが [バトル] か [ターン] の場合
      if page.span <= 1
        # 実行済みフラグをセット
        $game_temp.battle_event_flags[index] = true
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # バトルイベント実行中の場合
    if $game_system.battle_interpreter.running?
      # インタプリタを更新
      $game_system.battle_interpreter.update
      # アクションを強制されているバトラーが存在しない場合
      if $game_temp.forcing_battler == nil
        # バトルイベントの実行が終わった場合
        unless $game_system.battle_interpreter.running?
          # 戦闘継続の場合、バトルイベントのセットアップを再実行
          unless judge
            setup_battle_event
          end
        end
        # アフターバトルフェーズでなければ
        if @phase != 5
          # ステータスウィンドウをリフレッシュ
          @status_window.refresh
        end
      end
    end
    # システム (タイマー)、画面を更新
    $game_system.update
    $game_screen.update
    # タイマーが 0 になった場合
    if $game_system.timer_working and $game_system.timer == 0
      # バトル中断
      $game_temp.battle_abort = true
    end
    # ウィンドウを更新
    @help_window.update
    @party_command_window.update
    @actor_command_window.update
    @status_window.update
    @message_window.update
    # スプライトセットを更新
    @spriteset.update
    # トランジション処理中の場合
    if $game_temp.transition_processing
      # トランジション処理中フラグをクリア
      $game_temp.transition_processing = false
      # トランジション実行
      if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(40, "Graphics/Transitions/" +
          $game_temp.transition_name)
      end
    end
    # メッセージウィンドウ表示中の場合
    if $game_temp.message_window_showing
      return
    end
    # エフェクト表示中の場合
    if @spriteset.effect?
      return
    end
    # ゲームオーバーの場合
    if $game_temp.gameover
      # ゲームオーバー画面に切り替え
      $scene = Scene_Gameover.new
      return
    end
    # タイトル画面に戻す場合
    if $game_temp.to_title
      # タイトル画面に切り替え
      $scene = Scene_Title.new
      return
    end
    # バトル中断の場合
    if $game_temp.battle_abort
      # バトル開始前の BGM に戻す
      $game_system.bgm_play($game_temp.map_bgm)
      # バトル終了
      battle_end(1)
      return
    end
    # ウェイト中の場合
    if @wait_count > 0
      # ウェイトカウントを減らす
      @wait_count -= 1
      return
    end
    # アクションを強制されているバトラーが存在せず、
    # かつバトルイベントが実行中の場合
    if $game_temp.forcing_battler == nil and
       $game_system.battle_interpreter.running?
      return
    end
    # フェーズによって分岐
    case @phase
    when 1  # プレバトルフェーズ
      update_phase1
    when 2  # パーティコマンドフェーズ
      update_phase2
    when 3  # アクターコマンドフェーズ
      update_phase3
    when 4  # メインフェーズ
      update_phase4
    when 5  # アフターバトルフェーズ
      update_phase5
    end
  end
end
