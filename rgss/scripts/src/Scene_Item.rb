#==============================================================================
# ■ Scene_Item
#------------------------------------------------------------------------------
# 　アイテム画面の処理を行うクラスです。
#==============================================================================

class Scene_Item
  #--------------------------------------------------------------------------
  # ● メイン処理
  #--------------------------------------------------------------------------
  def main
    # ヘルプウィンドウ、アイテムウィンドウを作成
    @help_window = Window_Help.new
    @item_window = Window_Item.new
    # ヘルプウィンドウを関連付け
    @item_window.help_window = @help_window
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
    @item_window.dispose
    @target_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # ウィンドウを更新
    @help_window.update
    @item_window.update
    @target_window.update
    # アイテムウィンドウがアクティブの場合: update_item を呼ぶ
    if @item_window.active
      update_item
      return
    end
    # ターゲットウィンドウがアクティブの場合: update_target を呼ぶ
    if @target_window.active
      update_target
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (アイテムウィンドウがアクティブの場合)
  #--------------------------------------------------------------------------
  def update_item
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # キャンセル SE を演奏
      $game_system.se_play($data_system.cancel_se)
      # メニュー画面に切り替え
      $scene = Scene_Menu.new(0)
      return
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # アイテムウィンドウで現在選択されているデータを取得
      @item = @item_window.item
      # 使用アイテムではない場合
      unless @item.is_a?(RPG::Item)
        # ブザー SE を演奏
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 使用できない場合
      unless $game_party.item_can_use?(@item.id)
        # ブザー SE を演奏
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 決定 SE を演奏
      $game_system.se_play($data_system.decision_se)
      # 効果範囲が味方の場合
      if @item.scope >= 3
        # ターゲットウィンドウをアクティブ化
        @item_window.active = false
        @target_window.x = (@item_window.index + 1) % 2 * 304
        @target_window.visible = true
        @target_window.active = true
        # 効果範囲 (単体/全体) に応じてカーソル位置を設定
        if @item.scope == 4 || @item.scope == 6
          @target_window.index = -1
        else
          @target_window.index = 0
        end
      # 効果範囲が味方以外の場合
      else
        # コモンイベント ID が有効の場合
        if @item.common_event_id > 0
          # コモンイベント呼び出し予約
          $game_temp.common_event_id = @item.common_event_id
          # アイテムの使用時 SE を演奏
          $game_system.se_play(@item.menu_se)
          # 消耗品の場合
          if @item.consumable
            # 使用したアイテムを 1 減らす
            $game_party.lose_item(@item.id, 1)
            # アイテムウィンドウの項目を再描画
            @item_window.draw_item(@item_window.index)
          end
          # マップ画面に切り替え
          $scene = Scene_Map.new
          return
        end
      end
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
      # アイテム切れなどで使用できなくなった場合
      unless $game_party.item_can_use?(@item.id)
        # アイテムウィンドウの内容を再作成
        @item_window.refresh
      end
      # ターゲットウィンドウを消去
      @item_window.active = true
      @target_window.visible = false
      @target_window.active = false
      return
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # アイテムを使い切った場合
      if $game_party.item_number(@item.id) == 0
        # ブザー SE を演奏
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # ターゲットが全体の場合
      if @target_window.index == -1
        # パーティ全体にアイテムの使用効果を適用
        used = false
        for i in $game_party.actors
          used |= i.item_effect(@item)
        end
      end
      # ターゲットが単体の場合
      if @target_window.index >= 0
        # ターゲットのアクターにアイテムの使用効果を適用
        target = $game_party.actors[@target_window.index]
        used = target.item_effect(@item)
      end
      # アイテムを使った場合
      if used
        # アイテムの使用時 SE を演奏
        $game_system.se_play(@item.menu_se)
        # 消耗品の場合
        if @item.consumable
          # 使用したアイテムを 1 減らす
          $game_party.lose_item(@item.id, 1)
          # アイテムウィンドウの項目を再描画
          @item_window.draw_item(@item_window.index)
        end
        # ターゲットウィンドウの内容を再作成
        @target_window.refresh
        # 全滅の場合
        if $game_party.all_dead?
          # ゲームオーバー画面に切り替え
          $scene = Scene_Gameover.new
          return
        end
        # コモンイベント ID が有効の場合
        if @item.common_event_id > 0
          # コモンイベント呼び出し予約
          $game_temp.common_event_id = @item.common_event_id
          # マップ画面に切り替え
          $scene = Scene_Map.new
          return
        end
      end
      # アイテムを使わなかった場合
      unless used
        # ブザー SE を演奏
        $game_system.se_play($data_system.buzzer_se)
      end
      return
    end
  end
end
