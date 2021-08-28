#==============================================================================
# ■ Scene_Equip
#------------------------------------------------------------------------------
# 　装備画面の処理を行うクラスです。
#==============================================================================

class Scene_Equip
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     actor_index : アクターインデックス
  #     equip_index : 装備インデックス
  #--------------------------------------------------------------------------
  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
    @equip_index = equip_index
  end
  #--------------------------------------------------------------------------
  # ● メイン処理
  #--------------------------------------------------------------------------
  def main
    # アクターを取得
    @actor = $game_party.actors[@actor_index]
    # ウィンドウを作成
    @help_window = Window_Help.new
    @left_window = Window_EquipLeft.new(@actor)
    @right_window = Window_EquipRight.new(@actor)
    @item_window1 = Window_EquipItem.new(@actor, 0)
    @item_window2 = Window_EquipItem.new(@actor, 1)
    @item_window3 = Window_EquipItem.new(@actor, 2)
    @item_window4 = Window_EquipItem.new(@actor, 3)
    @item_window5 = Window_EquipItem.new(@actor, 4)
    # ヘルプウィンドウを関連付け
    @right_window.help_window = @help_window
    @item_window1.help_window = @help_window
    @item_window2.help_window = @help_window
    @item_window3.help_window = @help_window
    @item_window4.help_window = @help_window
    @item_window5.help_window = @help_window
    # カーソル位置を設定
    @right_window.index = @equip_index
    refresh
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
    @left_window.dispose
    @right_window.dispose
    @item_window1.dispose
    @item_window2.dispose
    @item_window3.dispose
    @item_window4.dispose
    @item_window5.dispose
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    # アイテムウィンドウの可視状態設定
    @item_window1.visible = (@right_window.index == 0)
    @item_window2.visible = (@right_window.index == 1)
    @item_window3.visible = (@right_window.index == 2)
    @item_window4.visible = (@right_window.index == 3)
    @item_window5.visible = (@right_window.index == 4)
    # 現在装備中のアイテムを取得
    item1 = @right_window.item
    # 現在のアイテムウィンドウを @item_window に設定
    case @right_window.index
    when 0
      @item_window = @item_window1
    when 1
      @item_window = @item_window2
    when 2
      @item_window = @item_window3
    when 3
      @item_window = @item_window4
    when 4
      @item_window = @item_window5
    end
    # ライトウィンドウがアクティブの場合
    if @right_window.active
      # 装備変更後のパラメータを消去
      @left_window.set_new_parameters(nil, nil, nil)
    end
    # アイテムウィンドウがアクティブの場合
    if @item_window.active
      # 現在選択中のアイテムを取得
      item2 = @item_window.item
      # 装備を変更
      last_hp = @actor.hp
      last_sp = @actor.sp
      @actor.equip(@right_window.index, item2 == nil ? 0 : item2.id)
      # 装備変更後のパラメータを取得
      new_atk = @actor.atk
      new_pdef = @actor.pdef
      new_mdef = @actor.mdef
      # 装備を戻す
      @actor.equip(@right_window.index, item1 == nil ? 0 : item1.id)
      @actor.hp = last_hp
      @actor.sp = last_sp
      # レフトウィンドウに描画
      @left_window.set_new_parameters(new_atk, new_pdef, new_mdef)
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # ウィンドウを更新
    @left_window.update
    @right_window.update
    @item_window.update
    refresh
    # ライトウィンドウがアクティブの場合: update_right を呼ぶ
    if @right_window.active
      update_right
      return
    end
    # アイテムウィンドウがアクティブの場合: update_item を呼ぶ
    if @item_window.active
      update_item
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (ライトウィンドウがアクティブの場合)
  #--------------------------------------------------------------------------
  def update_right
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # キャンセル SE を演奏
      $game_system.se_play($data_system.cancel_se)
      # メニュー画面に切り替え
      $scene = Scene_Menu.new(2)
      return
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # 装備固定の場合
      if @actor.equip_fix?(@right_window.index)
        # ブザー SE を演奏
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 決定 SE を演奏
      $game_system.se_play($data_system.decision_se)
      # アイテムウィンドウをアクティブ化
      @right_window.active = false
      @item_window.active = true
      @item_window.index = 0
      return
    end
    # R ボタンが押された場合
    if Input.trigger?(Input::R)
      # カーソル SE を演奏
      $game_system.se_play($data_system.cursor_se)
      # 次のアクターへ
      @actor_index += 1
      @actor_index %= $game_party.actors.size
      # 別の装備画面に切り替え
      $scene = Scene_Equip.new(@actor_index, @right_window.index)
      return
    end
    # L ボタンが押された場合
    if Input.trigger?(Input::L)
      # カーソル SE を演奏
      $game_system.se_play($data_system.cursor_se)
      # 前のアクターへ
      @actor_index += $game_party.actors.size - 1
      @actor_index %= $game_party.actors.size
      # 別の装備画面に切り替え
      $scene = Scene_Equip.new(@actor_index, @right_window.index)
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
      # ライトウィンドウをアクティブ化
      @right_window.active = true
      @item_window.active = false
      @item_window.index = -1
      return
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # 装備 SE を演奏
      $game_system.se_play($data_system.equip_se)
      # アイテムウィンドウで現在選択されているデータを取得
      item = @item_window.item
      # 装備を変更
      @actor.equip(@right_window.index, item == nil ? 0 : item.id)
      # ライトウィンドウをアクティブ化
      @right_window.active = true
      @item_window.active = false
      @item_window.index = -1
      # ライトウィンドウ、アイテムウィンドウの内容を再作成
      @right_window.refresh
      @item_window.refresh
      return
    end
  end
end
