#==============================================================================
# ■ Scene_Skill
#------------------------------------------------------------------------------
# 　スキル画面の処理を行うクラスです。
#==============================================================================

class Scene_Skill
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     actor_index : アクターインデックス
  #--------------------------------------------------------------------------
  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
  end
  #--------------------------------------------------------------------------
  # ● メイン処理
  #--------------------------------------------------------------------------
  def main
    # アクターを取得
    @actor = $game_party.actors[@actor_index]
    # ヘルプウィンドウ、ステータスウィンドウ、スキルウィンドウを作成
    @help_window = Window_Help.new
    @status_window = Window_SkillStatus.new(@actor)
    @skill_window = Window_Skill.new(@actor)
    # ヘルプウィンドウを関連付け
    @skill_window.help_window = @help_window
    # ターゲットウィンドウを作成 (不可視・非アクティブに設定)
    @target_window = Window_Target.new
    @target_window.visible = false
    @target_window.active = false
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
    # ウィンドウを解放
    @help_window.dispose
    @status_window.dispose
    @skill_window.dispose
    @target_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # ウィンドウを更新
    @help_window.update
    @status_window.update
    @skill_window.update
    @target_window.update
    # スキルウィンドウがアクティブの場合: update_skill を呼ぶ
    if @skill_window.active
      update_skill
      return
    end
    # ターゲットウィンドウがアクティブの場合: update_target を呼ぶ
    if @target_window.active
      update_target
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (スキルウィンドウがアクティブの場合)
  #--------------------------------------------------------------------------
  def update_skill
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # キャンセル SE を演奏
      $game_system.se_play($data_system.cancel_se)
      # メニュー画面に切り替え
      $scene = Scene_Menu.new(1)
      return
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # スキルウィンドウで現在選択されているデータを取得
      @skill = @skill_window.skill
      # 使用できない場合
      if @skill == nil or not @actor.skill_can_use?(@skill.id)
        # ブザー SE を演奏
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 決定 SE を演奏
      $game_system.se_play($data_system.decision_se)
      # 効果範囲が味方の場合
      if @skill.scope >= 3
        # ターゲットウィンドウをアクティブ化
        @skill_window.active = false
        @target_window.x = (@skill_window.index + 1) % 2 * 304
        @target_window.visible = true
        @target_window.active = true
        # 効果範囲 (単体/全体) に応じてカーソル位置を設定
        if @skill.scope == 4 || @skill.scope == 6
          @target_window.index = -1
        elsif @skill.scope == 7
          @target_window.index = @actor_index - 10
        else
          @target_window.index = 0
        end
      # 効果範囲が味方以外の場合
      else
        # コモンイベント ID が有効の場合
        if @skill.common_event_id > 0
          # コモンイベント呼び出し予約
          $game_temp.common_event_id = @skill.common_event_id
          # スキルの使用時 SE を演奏
          $game_system.se_play(@skill.menu_se)
          # SP 消費
          @actor.sp -= @skill.sp_cost
          # 各ウィンドウの内容を再作成
          @status_window.refresh
          @skill_window.refresh
          @target_window.refresh
          # マップ画面に切り替え
          $scene = Scene_Map.new
          return
        end
      end
      return
    end
    # R ボタンが押された場合
    if Input.trigger?(Input::R)
      # カーソル SE を演奏
      $game_system.se_play($data_system.cursor_se)
      # 次のアクターへ
      @actor_index += 1
      @actor_index %= $game_party.actors.size
      # 別のスキル画面に切り替え
      $scene = Scene_Skill.new(@actor_index)
      return
    end
    # L ボタンが押された場合
    if Input.trigger?(Input::L)
      # カーソル SE を演奏
      $game_system.se_play($data_system.cursor_se)
      # 前のアクターへ
      @actor_index += $game_party.actors.size - 1
      @actor_index %= $game_party.actors.size
      # 別のスキル画面に切り替え
      $scene = Scene_Skill.new(@actor_index)
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (ターゲットウィンドウがアクティブの場合)
  #--------------------------------------------------------------------------
  def update_target
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # キャンセル SE を演奏
      $game_system.se_play($data_system.cancel_se)
      # ターゲットウィンドウを消去
      @skill_window.active = true
      @target_window.visible = false
      @target_window.active = false
      return
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # SP 切れなどで使用できなくなった場合
      unless @actor.skill_can_use?(@skill.id)
        # ブザー SE を演奏
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # ターゲットが全体の場合
      if @target_window.index == -1
        # パーティ全体にスキルの使用効果を適用
        used = false
        for i in $game_party.actors
          used |= i.skill_effect(@actor, @skill)
        end
      end
      # ターゲットが使用者の場合
      if @target_window.index <= -2
        # ターゲットのアクターにスキルの使用効果を適用
        target = $game_party.actors[@target_window.index + 10]
        used = target.skill_effect(@actor, @skill)
      end
      # ターゲットが単体の場合
      if @target_window.index >= 0
        # ターゲットのアクターにスキルの使用効果を適用
        target = $game_party.actors[@target_window.index]
        used = target.skill_effect(@actor, @skill)
      end
      # スキルを使った場合
      if used
        # スキルの使用時 SE を演奏
        $game_system.se_play(@skill.menu_se)
        # SP 消費
        @actor.sp -= @skill.sp_cost
        # 各ウィンドウの内容を再作成
        @status_window.refresh
        @skill_window.refresh
        @target_window.refresh
        # 全滅の場合
        if $game_party.all_dead?
          # ゲームオーバー画面に切り替え
          $scene = Scene_Gameover.new
          return
        end
        # コモンイベント ID が有効の場合
        if @skill.common_event_id > 0
          # コモンイベント呼び出し予約
          $game_temp.common_event_id = @skill.common_event_id
          # マップ画面に切り替え
          $scene = Scene_Map.new
          return
        end
      end
      # スキルを使わなかった場合
      unless used
        # ブザー SE を演奏
        $game_system.se_play($data_system.buzzer_se)
      end
      return
    end
  end
end
