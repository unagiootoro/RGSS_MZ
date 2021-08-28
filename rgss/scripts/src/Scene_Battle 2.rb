#==============================================================================
# ■ Scene_Battle (分割定義 2)
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # ● プレバトルフェーズ開始
  #--------------------------------------------------------------------------
  def start_phase1
    # フェーズ 1 に移行
    @phase = 1
    # パーティ全員のアクションをクリア
    $game_party.clear_actions
    # バトルイベントをセットアップ
    setup_battle_event
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (プレバトルフェーズ)
  #--------------------------------------------------------------------------
  def update_phase1
    # 勝敗判定
    if judge
      # 勝利または敗北の場合 : メソッド終了
      return
    end
    # パーティコマンドフェーズ開始
    start_phase2
  end
  #--------------------------------------------------------------------------
  # ● パーティコマンドフェーズ開始
  #--------------------------------------------------------------------------
  def start_phase2
    # フェーズ 2 に移行
    @phase = 2
    # アクターを非選択状態に設定
    @actor_index = -1
    @active_battler = nil
    # パーティコマンドウィンドウを有効化
    @party_command_window.active = true
    @party_command_window.visible = true
    # アクターコマンドウィンドウを無効化
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # メインフェーズフラグをクリア
    $game_temp.battle_main_phase = false
    # パーティ全員のアクションをクリア
    $game_party.clear_actions
    # コマンド入力不可能な場合
    unless $game_party.inputable?
      # メインフェーズ開始
      start_phase4
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (パーティコマンドフェーズ)
  #--------------------------------------------------------------------------
  def update_phase2
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # パーティコマンドウィンドウのカーソル位置で分岐
      case @party_command_window.index
      when 0  # 戦う
        # 決定 SE を演奏
        $game_system.se_play($data_system.decision_se)
        # アクターコマンドフェーズ開始
        start_phase3
      when 1  # 逃げる
        # 逃走可能ではない場合
        if $game_temp.battle_can_escape == false
          # ブザー SE を演奏
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # 決定 SE を演奏
        $game_system.se_play($data_system.decision_se)
        # 逃走処理
        update_phase2_escape
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (パーティコマンドフェーズ : 逃げる)
  #--------------------------------------------------------------------------
  def update_phase2_escape
    # エネミーの素早さ平均値を計算
    enemies_agi = 0
    enemies_number = 0
    for enemy in $game_troop.enemies
      if enemy.exist?
        enemies_agi += enemy.agi
        enemies_number += 1
      end
    end
    if enemies_number > 0
      enemies_agi /= enemies_number
    end
    # アクターの素早さ平均値を計算
    actors_agi = 0
    actors_number = 0
    for actor in $game_party.actors
      if actor.exist?
        actors_agi += actor.agi
        actors_number += 1
      end
    end
    if actors_number > 0
      actors_agi /= actors_number
    end
    # 逃走成功判定
    success = rand(100) < 50 * actors_agi / enemies_agi
    # 逃走成功の場合
    if success
      # 逃走 SE を演奏
      $game_system.se_play($data_system.escape_se)
      # バトル開始前の BGM に戻す
      $game_system.bgm_play($game_temp.map_bgm)
      # バトル終了
      battle_end(1)
    # 逃走失敗の場合
    else
      # パーティ全員のアクションをクリア
      $game_party.clear_actions
      # メインフェーズ開始
      start_phase4
    end
  end
  #--------------------------------------------------------------------------
  # ● アフターバトルフェーズ開始
  #--------------------------------------------------------------------------
  def start_phase5
    # フェーズ 5 に移行
    @phase = 5
    # バトル終了 ME を演奏
    $game_system.me_play($game_system.battle_end_me)
    # バトル開始前の BGM に戻す
    $game_system.bgm_play($game_temp.map_bgm)
    # EXP、ゴールド、トレジャーを初期化
    exp = 0
    gold = 0
    treasures = []
    # ループ
    for enemy in $game_troop.enemies
      # エネミーが隠れ状態でない場合
      unless enemy.hidden
        # 獲得 EXP、ゴールドを追加
        exp += enemy.exp
        gold += enemy.gold
        # トレジャー出現判定
        if rand(100) < enemy.treasure_prob
          if enemy.item_id > 0
            treasures.push($data_items[enemy.item_id])
          end
          if enemy.weapon_id > 0
            treasures.push($data_weapons[enemy.weapon_id])
          end
          if enemy.armor_id > 0
            treasures.push($data_armors[enemy.armor_id])
          end
        end
      end
    end
    # トレジャーの数を 6 個までに限定
    treasures = treasures[0..5]
    # EXP 獲得
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      if actor.cant_get_exp? == false
        last_level = actor.level
        actor.exp += exp
        if actor.level > last_level
          @status_window.level_up(i)
        end
      end
    end
    # ゴールド獲得
    $game_party.gain_gold(gold)
    # トレジャー獲得
    for item in treasures
      case item
      when RPG::Item
        $game_party.gain_item(item.id, 1)
      when RPG::Weapon
        $game_party.gain_weapon(item.id, 1)
      when RPG::Armor
        $game_party.gain_armor(item.id, 1)
      end
    end
    # バトルリザルトウィンドウを作成
    @result_window = Window_BattleResult.new(exp, gold, treasures)
    # ウェイトカウントを設定
    @phase5_wait_count = 100
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (アフターバトルフェーズ)
  #--------------------------------------------------------------------------
  def update_phase5
    # ウェイトカウントが 0 より大きい場合
    if @phase5_wait_count > 0
      # ウェイトカウントを減らす
      @phase5_wait_count -= 1
      # ウェイトカウントが 0 になった場合
      if @phase5_wait_count == 0
        # リザルトウィンドウを表示
        @result_window.visible = true
        # メインフェーズフラグをクリア
        $game_temp.battle_main_phase = false
        # ステータスウィンドウをリフレッシュ
        @status_window.refresh
      end
      return
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # バトル終了
      battle_end(0)
    end
  end
end
