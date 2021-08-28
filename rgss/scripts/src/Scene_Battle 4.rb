#==============================================================================
# ■ Scene_Battle (分割定義 4)
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # ● メインフェーズ開始
  #--------------------------------------------------------------------------
  def start_phase4
    # フェーズ 4 に移行
    @phase = 4
    # ターン数カウント
    $game_temp.battle_turn += 1
    # バトルイベントの全ページを検索
    for index in 0...$data_troops[@troop_id].pages.size
      # イベントページを取得
      page = $data_troops[@troop_id].pages[index]
      # このページのスパンが [ターン] の場合
      if page.span == 1
        # 実行済みフラグをクリア
        $game_temp.battle_event_flags[index] = false
      end
    end
    # アクターを非選択状態に設定
    @actor_index = -1
    @active_battler = nil
    # パーティコマンドウィンドウを有効化
    @party_command_window.active = false
    @party_command_window.visible = false
    # アクターコマンドウィンドウを無効化
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # メインフェーズフラグをセット
    $game_temp.battle_main_phase = true
    # エネミーアクション作成
    for enemy in $game_troop.enemies
      enemy.make_action
    end
    # 行動順序作成
    make_action_orders
    # ステップ 1 に移行
    @phase4_step = 1
  end
  #--------------------------------------------------------------------------
  # ● 行動順序作成
  #--------------------------------------------------------------------------
  def make_action_orders
    # 配列 @action_battlers を初期化
    @action_battlers = []
    # エネミーを配列 @action_battlers に追加
    for enemy in $game_troop.enemies
      @action_battlers.push(enemy)
    end
    # アクターを配列 @action_battlers に追加
    for actor in $game_party.actors
      @action_battlers.push(actor)
    end
    # 全員のアクションスピードを決定
    for battler in @action_battlers
      battler.make_action_speed
    end
    # アクションスピードの大きい順に並び替え
    @action_battlers.sort! {|a,b|
      b.current_action.speed - a.current_action.speed }
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (メインフェーズ)
  #--------------------------------------------------------------------------
  def update_phase4
    case @phase4_step
    when 1
      update_phase4_step1
    when 2
      update_phase4_step2
    when 3
      update_phase4_step3
    when 4
      update_phase4_step4
    when 5
      update_phase4_step5
    when 6
      update_phase4_step6
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (メインフェーズ ステップ 1 : アクション準備)
  #--------------------------------------------------------------------------
  def update_phase4_step1
    # ヘルプウィンドウを隠す
    @help_window.visible = false
    # 勝敗判定
    if judge
      # 勝利または敗北の場合 : メソッド終了
      return
    end
    # アクションを強制されているバトラーが存在しない場合
    if $game_temp.forcing_battler == nil
      # バトルイベントをセットアップ
      setup_battle_event
      # バトルイベント実行中の場合
      if $game_system.battle_interpreter.running?
        return
      end
    end
    # アクションを強制されているバトラーが存在する場合
    if $game_temp.forcing_battler != nil
      # 先頭に追加または移動
      @action_battlers.delete($game_temp.forcing_battler)
      @action_battlers.unshift($game_temp.forcing_battler)
    end
    # 未行動バトラーが存在しない場合 (全員行動した)
    if @action_battlers.size == 0
      # パーティコマンドフェーズ開始
      start_phase2
      return
    end
    # アニメーション ID およびコモンイベント ID を初期化
    @animation1_id = 0
    @animation2_id = 0
    @common_event_id = 0
    # 未行動バトラー配列の先頭からシフト
    @active_battler = @action_battlers.shift
    # すでに戦闘から外されている場合
    if @active_battler.index == nil
      return
    end
    # スリップダメージ
    if @active_battler.hp > 0 and @active_battler.slip_damage?
      @active_battler.slip_damage_effect
      @active_battler.damage_pop = true
    end
    # ステート自然解除
    @active_battler.remove_states_auto
    # ステータスウィンドウをリフレッシュ
    @status_window.refresh
    # ステップ 2 に移行
    @phase4_step = 2
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (メインフェーズ ステップ 2 : アクション開始)
  #--------------------------------------------------------------------------
  def update_phase4_step2
    # 強制アクションでなければ
    unless @active_battler.current_action.forcing
      # 制約が [敵を通常攻撃する] か [味方を通常攻撃する] の場合
      if @active_battler.restriction == 2 or @active_battler.restriction == 3
        # アクションに攻撃を設定
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 0
      end
      # 制約が [行動できない] の場合
      if @active_battler.restriction == 4
        # アクション強制対象のバトラーをクリア
        $game_temp.forcing_battler = nil
        # ステップ 1 に移行
        @phase4_step = 1
        return
      end
    end
    # 対象バトラーをクリア
    @target_battlers = []
    # アクションの種別で分岐
    case @active_battler.current_action.kind
    when 0  # 基本
      make_basic_action_result
    when 1  # スキル
      make_skill_action_result
    when 2  # アイテム
      make_item_action_result
    end
    # ステップ 3 に移行
    if @phase4_step == 2
      @phase4_step = 3
    end
  end
  #--------------------------------------------------------------------------
  # ● 基本アクション 結果作成
  #--------------------------------------------------------------------------
  def make_basic_action_result
    # 攻撃の場合
    if @active_battler.current_action.basic == 0
      # アニメーション ID を設定
      @animation1_id = @active_battler.animation1_id
      @animation2_id = @active_battler.animation2_id
      # 行動側バトラーがエネミーの場合
      if @active_battler.is_a?(Game_Enemy)
        if @active_battler.restriction == 3
          target = $game_troop.random_target_enemy
        elsif @active_battler.restriction == 2
          target = $game_party.random_target_actor
        else
          index = @active_battler.current_action.target_index
          target = $game_party.smooth_target_actor(index)
        end
      end
      # 行動側バトラーがアクターの場合
      if @active_battler.is_a?(Game_Actor)
        if @active_battler.restriction == 3
          target = $game_party.random_target_actor
        elsif @active_battler.restriction == 2
          target = $game_troop.random_target_enemy
        else
          index = @active_battler.current_action.target_index
          target = $game_troop.smooth_target_enemy(index)
        end
      end
      # 対象側バトラーの配列を設定
      @target_battlers = [target]
      # 通常攻撃の効果を適用
      for target in @target_battlers
        target.attack_effect(@active_battler)
      end
      return
    end
    # 防御の場合
    if @active_battler.current_action.basic == 1
      # ヘルプウィンドウに "防御" を表示
      @help_window.set_text($data_system.words.guard, 1)
      return
    end
    # 逃げるの場合
    if @active_battler.is_a?(Game_Enemy) and
       @active_battler.current_action.basic == 2
      # ヘルプウィンドウに "逃げる" を表示
      @help_window.set_text("逃げる", 1)
      # 逃げる
      @active_battler.escape
      return
    end
    # 何もしないの場合
    if @active_battler.current_action.basic == 3
      # アクション強制対象のバトラーをクリア
      $game_temp.forcing_battler = nil
      # ステップ 1 に移行
      @phase4_step = 1
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● スキルまたはアイテムの対象側バトラー設定
  #     scope : スキルまたはアイテムの効果範囲
  #--------------------------------------------------------------------------
  def set_target_battlers(scope)
    # 行動側バトラーがエネミーの場合
    if @active_battler.is_a?(Game_Enemy)
      # 効果範囲で分岐
      case scope
      when 1  # 敵単体
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_party.smooth_target_actor(index))
      when 2  # 敵全体
        for actor in $game_party.actors
          if actor.exist?
            @target_battlers.push(actor)
          end
        end
      when 3  # 味方単体
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_troop.smooth_target_enemy(index))
      when 4  # 味方全体
        for enemy in $game_troop.enemies
          if enemy.exist?
            @target_battlers.push(enemy)
          end
        end
      when 5  # 味方単体 (HP 0) 
        index = @active_battler.current_action.target_index
        enemy = $game_troop.enemies[index]
        if enemy != nil and enemy.hp0?
          @target_battlers.push(enemy)
        end
      when 6  # 味方全体 (HP 0) 
        for enemy in $game_troop.enemies
          if enemy != nil and enemy.hp0?
            @target_battlers.push(enemy)
          end
        end
      when 7  # 使用者
        @target_battlers.push(@active_battler)
      end
    end
    # 行動側バトラーがアクターの場合
    if @active_battler.is_a?(Game_Actor)
      # 効果範囲で分岐
      case scope
      when 1  # 敵単体
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_troop.smooth_target_enemy(index))
      when 2  # 敵全体
        for enemy in $game_troop.enemies
          if enemy.exist?
            @target_battlers.push(enemy)
          end
        end
      when 3  # 味方単体
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_party.smooth_target_actor(index))
      when 4  # 味方全体
        for actor in $game_party.actors
          if actor.exist?
            @target_battlers.push(actor)
          end
        end
      when 5  # 味方単体 (HP 0) 
        index = @active_battler.current_action.target_index
        actor = $game_party.actors[index]
        if actor != nil and actor.hp0?
          @target_battlers.push(actor)
        end
      when 6  # 味方全体 (HP 0) 
        for actor in $game_party.actors
          if actor != nil and actor.hp0?
            @target_battlers.push(actor)
          end
        end
      when 7  # 使用者
        @target_battlers.push(@active_battler)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● スキルアクション 結果作成
  #--------------------------------------------------------------------------
  def make_skill_action_result
    # スキルを取得
    @skill = $data_skills[@active_battler.current_action.skill_id]
    # 強制アクションでなければ
    unless @active_battler.current_action.forcing
      # SP 切れなどで使用できなくなった場合
      unless @active_battler.skill_can_use?(@skill.id)
        # アクション強制対象のバトラーをクリア
        $game_temp.forcing_battler = nil
        # ステップ 1 に移行
        @phase4_step = 1
        return
      end
    end
    # SP 消費
    @active_battler.sp -= @skill.sp_cost
    # ステータスウィンドウをリフレッシュ
    @status_window.refresh
    # ヘルプウィンドウにスキル名を表示
    @help_window.set_text(@skill.name, 1)
    # アニメーション ID を設定
    @animation1_id = @skill.animation1_id
    @animation2_id = @skill.animation2_id
    # コモンイベント ID を設定
    @common_event_id = @skill.common_event_id
    # 対象側バトラーを設定
    set_target_battlers(@skill.scope)
    # スキルの効果を適用
    for target in @target_battlers
      target.skill_effect(@active_battler, @skill)
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテムアクション 結果作成
  #--------------------------------------------------------------------------
  def make_item_action_result
    # アイテムを取得
    @item = $data_items[@active_battler.current_action.item_id]
    # アイテム切れなどで使用できなくなった場合
    unless $game_party.item_can_use?(@item.id)
      # ステップ 1 に移行
      @phase4_step = 1
      return
    end
    # 消耗品の場合
    if @item.consumable
      # 使用したアイテムを 1 減らす
      $game_party.lose_item(@item.id, 1)
    end
    # ヘルプウィンドウにアイテム名を表示
    @help_window.set_text(@item.name, 1)
    # アニメーション ID を設定
    @animation1_id = @item.animation1_id
    @animation2_id = @item.animation2_id
    # コモンイベント ID を設定
    @common_event_id = @item.common_event_id
    # 対象を決定
    index = @active_battler.current_action.target_index
    target = $game_party.smooth_target_actor(index)
    # 対象側バトラーを設定
    set_target_battlers(@item.scope)
    # アイテムの効果を適用
    for target in @target_battlers
      target.item_effect(@item)
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (メインフェーズ ステップ 3 : 行動側アニメーション)
  #--------------------------------------------------------------------------
  def update_phase4_step3
    # 行動側アニメーション (ID が 0 の場合は白フラッシュ)
    if @animation1_id == 0
      @active_battler.white_flash = true
    else
      @active_battler.animation_id = @animation1_id
      @active_battler.animation_hit = true
    end
    # ステップ 4 に移行
    @phase4_step = 4
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (メインフェーズ ステップ 4 : 対象側アニメーション)
  #--------------------------------------------------------------------------
  def update_phase4_step4
    # 対象側アニメーション
    for target in @target_battlers
      target.animation_id = @animation2_id
      target.animation_hit = (target.damage != "Miss")
    end
    # アニメーションの長さにかかわらず、最低 8 フレーム待つ
    @wait_count = 8
    # ステップ 5 に移行
    @phase4_step = 5
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (メインフェーズ ステップ 5 : ダメージ表示)
  #--------------------------------------------------------------------------
  def update_phase4_step5
    # ヘルプウィンドウを隠す
    @help_window.visible = false
    # ステータスウィンドウをリフレッシュ
    @status_window.refresh
    # ダメージ表示
    for target in @target_battlers
      if target.damage != nil
        target.damage_pop = true
      end
    end
    # ステップ 6 に移行
    @phase4_step = 6
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (メインフェーズ ステップ 6 : リフレッシュ)
  #--------------------------------------------------------------------------
  def update_phase4_step6
    # アクション強制対象のバトラーをクリア
    $game_temp.forcing_battler = nil
    # コモンイベント ID が有効の場合
    if @common_event_id > 0
      # イベントをセットアップ
      common_event = $data_common_events[@common_event_id]
      $game_system.battle_interpreter.setup(common_event.list, 0)
    end
    # ステップ 1 に移行
    @phase4_step = 1
  end
end
