#==============================================================================
# ■ Scene_Battle (分割定義 3)
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # ● アクターコマンドフェーズ開始
  #--------------------------------------------------------------------------
  def start_phase3
    # フェーズ 3 に移行
    @phase = 3
    # アクターを非選択状態に設定
    @actor_index = -1
    @active_battler = nil
    # 次のアクターのコマンド入力へ
    phase3_next_actor
  end
  #--------------------------------------------------------------------------
  # ● 次のアクターのコマンド入力へ
  #--------------------------------------------------------------------------
  def phase3_next_actor
    # ループ
    begin
      # アクターの明滅エフェクト OFF
      if @active_battler != nil
        @active_battler.blink = false
      end
      # 最後のアクターの場合
      if @actor_index == $game_party.actors.size-1
        # メインフェーズ開始
        start_phase4
        return
      end
      # アクターのインデックスを進める
      @actor_index += 1
      @active_battler = $game_party.actors[@actor_index]
      @active_battler.blink = true
    # アクターがコマンド入力を受け付けない状態ならもう一度
    end until @active_battler.inputable?
    # アクターコマンドウィンドウをセットアップ
    phase3_setup_command_window
  end
  #--------------------------------------------------------------------------
  # ● 前のアクターのコマンド入力へ
  #--------------------------------------------------------------------------
  def phase3_prior_actor
    # ループ
    begin
      # アクターの明滅エフェクト OFF
      if @active_battler != nil
        @active_battler.blink = false
      end
      # 最初のアクターの場合
      if @actor_index == 0
        # パーティコマンドフェーズ開始
        start_phase2
        return
      end
      # アクターのインデックスを戻す
      @actor_index -= 1
      @active_battler = $game_party.actors[@actor_index]
      @active_battler.blink = true
    # アクターがコマンド入力を受け付けない状態ならもう一度
    end until @active_battler.inputable?
    # アクターコマンドウィンドウをセットアップ
    phase3_setup_command_window
  end
  #--------------------------------------------------------------------------
  # ● アクターコマンドウィンドウのセットアップ
  #--------------------------------------------------------------------------
  def phase3_setup_command_window
    # パーティコマンドウィンドウを無効化
    @party_command_window.active = false
    @party_command_window.visible = false
    # アクターコマンドウィンドウを有効化
    @actor_command_window.active = true
    @actor_command_window.visible = true
    # アクターコマンドウィンドウの位置を設定
    @actor_command_window.x = @actor_index * 160
    # インデックスを 0 に設定
    @actor_command_window.index = 0
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (アクターコマンドフェーズ)
  #--------------------------------------------------------------------------
  def update_phase3
    # エネミーアローが有効の場合
    if @enemy_arrow != nil
      update_phase3_enemy_select
    # アクターアローが有効の場合
    elsif @actor_arrow != nil
      update_phase3_actor_select
    # スキルウィンドウが有効の場合
    elsif @skill_window != nil
      update_phase3_skill_select
    # アイテムウィンドウが有効の場合
    elsif @item_window != nil
      update_phase3_item_select
    # アクターコマンドウィンドウが有効の場合
    elsif @actor_command_window.active
      update_phase3_basic_command
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (アクターコマンドフェーズ : 基本コマンド)
  #--------------------------------------------------------------------------
  def update_phase3_basic_command
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # キャンセル SE を演奏
      $game_system.se_play($data_system.cancel_se)
      # 前のアクターのコマンド入力へ
      phase3_prior_actor
      return
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # アクターコマンドウィンドウのカーソル位置で分岐
      case @actor_command_window.index
      when 0  # 攻撃
        # 決定 SE を演奏
        $game_system.se_play($data_system.decision_se)
        # アクションを設定
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 0
        # エネミーの選択を開始
        start_enemy_select
      when 1  # スキル
        # 決定 SE を演奏
        $game_system.se_play($data_system.decision_se)
        # アクションを設定
        @active_battler.current_action.kind = 1
        # スキルの選択を開始
        start_skill_select
      when 2  # 防御
        # 決定 SE を演奏
        $game_system.se_play($data_system.decision_se)
        # アクションを設定
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 1
        # 次のアクターのコマンド入力へ
        phase3_next_actor
      when 3  # アイテム
        # 決定 SE を演奏
        $game_system.se_play($data_system.decision_se)
        # アクションを設定
        @active_battler.current_action.kind = 2
        # アイテムの選択を開始
        start_item_select
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (アクターコマンドフェーズ : スキル選択)
  #--------------------------------------------------------------------------
  def update_phase3_skill_select
    # スキルウィンドウを可視状態にする
    @skill_window.visible = true
    # スキルウィンドウを更新
    @skill_window.update
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # キャンセル SE を演奏
      $game_system.se_play($data_system.cancel_se)
      # スキルの選択を終了
      end_skill_select
      return
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # スキルウィンドウで現在選択されているデータを取得
      @skill = @skill_window.skill
      # 使用できない場合
      if @skill == nil or not @active_battler.skill_can_use?(@skill.id)
        # ブザー SE を演奏
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 決定 SE を演奏
      $game_system.se_play($data_system.decision_se)
      # アクションを設定
      @active_battler.current_action.skill_id = @skill.id
      # スキルウィンドウを不可視状態にする
      @skill_window.visible = false
      # 効果範囲が敵単体の場合
      if @skill.scope == 1
        # エネミーの選択を開始
        start_enemy_select
      # 効果範囲が味方単体の場合
      elsif @skill.scope == 3 or @skill.scope == 5
        # アクターの選択を開始
        start_actor_select
      # 効果範囲が単体ではない場合
      else
        # スキルの選択を終了
        end_skill_select
        # 次のアクターのコマンド入力へ
        phase3_next_actor
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (アクターコマンドフェーズ : アイテム選択)
  #--------------------------------------------------------------------------
  def update_phase3_item_select
    # アイテムウィンドウを可視状態にする
    @item_window.visible = true
    # アイテムウィンドウを更新
    @item_window.update
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # キャンセル SE を演奏
      $game_system.se_play($data_system.cancel_se)
      # アイテムの選択を終了
      end_item_select
      return
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # アイテムウィンドウで現在選択されているデータを取得
      @item = @item_window.item
      # 使用できない場合
      unless $game_party.item_can_use?(@item.id)
        # ブザー SE を演奏
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 決定 SE を演奏
      $game_system.se_play($data_system.decision_se)
      # アクションを設定
      @active_battler.current_action.item_id = @item.id
      # アイテムウィンドウを不可視状態にする
      @item_window.visible = false
      # 効果範囲が敵単体の場合
      if @item.scope == 1
        # エネミーの選択を開始
        start_enemy_select
      # 効果範囲が味方単体の場合
      elsif @item.scope == 3 or @item.scope == 5
        # アクターの選択を開始
        start_actor_select
      # 効果範囲が単体ではない場合
      else
        # アイテムの選択を終了
        end_item_select
        # 次のアクターのコマンド入力へ
        phase3_next_actor
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (アクターコマンドフェーズ : エネミー選択)
  #--------------------------------------------------------------------------
  def update_phase3_enemy_select
    # エネミーアローを更新
    @enemy_arrow.update
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # キャンセル SE を演奏
      $game_system.se_play($data_system.cancel_se)
      # エネミーの選択を終了
      end_enemy_select
      return
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # 決定 SE を演奏
      $game_system.se_play($data_system.decision_se)
      # アクションを設定
      @active_battler.current_action.target_index = @enemy_arrow.index
      # エネミーの選択を終了
      end_enemy_select
      # スキルウィンドウ表示中の場合
      if @skill_window != nil
        # スキルの選択を終了
        end_skill_select
      end
      # アイテムウィンドウ表示中の場合
      if @item_window != nil
        # アイテムの選択を終了
        end_item_select
      end
      # 次のアクターのコマンド入力へ
      phase3_next_actor
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (アクターコマンドフェーズ : アクター選択)
  #--------------------------------------------------------------------------
  def update_phase3_actor_select
    # アクターアローを更新
    @actor_arrow.update
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # キャンセル SE を演奏
      $game_system.se_play($data_system.cancel_se)
      # アクターの選択を終了
      end_actor_select
      return
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # 決定 SE を演奏
      $game_system.se_play($data_system.decision_se)
      # アクションを設定
      @active_battler.current_action.target_index = @actor_arrow.index
      # アクターの選択を終了
      end_actor_select
      # スキルウィンドウ表示中の場合
      if @skill_window != nil
        # スキルの選択を終了
        end_skill_select
      end
      # アイテムウィンドウ表示中の場合
      if @item_window != nil
        # アイテムの選択を終了
        end_item_select
      end
      # 次のアクターのコマンド入力へ
      phase3_next_actor
    end
  end
  #--------------------------------------------------------------------------
  # ● エネミー選択開始
  #--------------------------------------------------------------------------
  def start_enemy_select
    # エネミーアローを作成
    @enemy_arrow = Arrow_Enemy.new(@spriteset.viewport1)
    # ヘルプウィンドウを関連付け
    @enemy_arrow.help_window = @help_window
    # アクターコマンドウィンドウを無効化
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  #--------------------------------------------------------------------------
  # ● エネミー選択終了
  #--------------------------------------------------------------------------
  def end_enemy_select
    # エネミーアローを解放
    @enemy_arrow.dispose
    @enemy_arrow = nil
    # コマンドが [戦う] の場合
    if @actor_command_window.index == 0
      # アクターコマンドウィンドウを有効化
      @actor_command_window.active = true
      @actor_command_window.visible = true
      # ヘルプウィンドウを隠す
      @help_window.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # ● アクター選択開始
  #--------------------------------------------------------------------------
  def start_actor_select
    # アクターアローを作成
    @actor_arrow = Arrow_Actor.new(@spriteset.viewport2)
    @actor_arrow.index = @actor_index
    # ヘルプウィンドウを関連付け
    @actor_arrow.help_window = @help_window
    # アクターコマンドウィンドウを無効化
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  #--------------------------------------------------------------------------
  # ● アクター選択終了
  #--------------------------------------------------------------------------
  def end_actor_select
    # アクターアローを解放
    @actor_arrow.dispose
    @actor_arrow = nil
  end
  #--------------------------------------------------------------------------
  # ● スキル選択開始
  #--------------------------------------------------------------------------
  def start_skill_select
    # スキルウィンドウを作成
    @skill_window = Window_Skill.new(@active_battler)
    # ヘルプウィンドウを関連付け
    @skill_window.help_window = @help_window
    # アクターコマンドウィンドウを無効化
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  #--------------------------------------------------------------------------
  # ● スキル選択終了
  #--------------------------------------------------------------------------
  def end_skill_select
    # スキルウィンドウを解放
    @skill_window.dispose
    @skill_window = nil
    # ヘルプウィンドウを隠す
    @help_window.visible = false
    # アクターコマンドウィンドウを有効化
    @actor_command_window.active = true
    @actor_command_window.visible = true
  end
  #--------------------------------------------------------------------------
  # ● アイテム選択開始
  #--------------------------------------------------------------------------
  def start_item_select
    # アイテムウィンドウを作成
    @item_window = Window_Item.new
    # ヘルプウィンドウを関連付け
    @item_window.help_window = @help_window
    # アクターコマンドウィンドウを無効化
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  #--------------------------------------------------------------------------
  # ● アイテム選択終了
  #--------------------------------------------------------------------------
  def end_item_select
    # アイテムウィンドウを解放
    @item_window.dispose
    @item_window = nil
    # ヘルプウィンドウを隠す
    @help_window.visible = false
    # アクターコマンドウィンドウを有効化
    @actor_command_window.active = true
    @actor_command_window.visible = true
  end
end
