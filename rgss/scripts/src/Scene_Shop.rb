#==============================================================================
# ■ Scene_Shop
#------------------------------------------------------------------------------
# 　ショップ画面の処理を行うクラスです。
#==============================================================================

class Scene_Shop
  #--------------------------------------------------------------------------
  # ● メイン処理
  #--------------------------------------------------------------------------
  def main
    # ヘルプウィンドウを作成
    @help_window = Window_Help.new
    # コマンドウィンドウを作成
    @command_window = Window_ShopCommand.new
    # ゴールドウィンドウを作成
    @gold_window = Window_Gold.new
    @gold_window.x = 480
    @gold_window.y = 64
    # ダミーウィンドウを作成
    @dummy_window = Window_Base.new(0, 128, 640, 352)
    # 購入ウィンドウを作成
    @buy_window = Window_ShopBuy.new($game_temp.shop_goods)
    @buy_window.active = false
    @buy_window.visible = false
    @buy_window.help_window = @help_window
    # 売却ウィンドウを作成
    @sell_window = Window_ShopSell.new
    @sell_window.active = false
    @sell_window.visible = false
    @sell_window.help_window = @help_window
    # 個数入力ウィンドウを作成
    @number_window = Window_ShopNumber.new
    @number_window.active = false
    @number_window.visible = false
    # ステータスウィンドウを作成
    @status_window = Window_ShopStatus.new
    @status_window.visible = false
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
    @command_window.dispose
    @gold_window.dispose
    @dummy_window.dispose
    @buy_window.dispose
    @sell_window.dispose
    @number_window.dispose
    @status_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # ウィンドウを更新
    @help_window.update
    @command_window.update
    @gold_window.update
    @dummy_window.update
    @buy_window.update
    @sell_window.update
    @number_window.update
    @status_window.update
    # コマンドウィンドウがアクティブの場合: update_command を呼ぶ
    if @command_window.active
      update_command
      return
    end
    # 購入ウィンドウがアクティブの場合: update_buy を呼ぶ
    if @buy_window.active
      update_buy
      return
    end
    # 売却ウィンドウがアクティブの場合: update_sell を呼ぶ
    if @sell_window.active
      update_sell
      return
    end
    # 個数入力ウィンドウがアクティブの場合: update_number を呼ぶ
    if @number_window.active
      update_number
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (コマンドウィンドウがアクティブの場合)
  #--------------------------------------------------------------------------
  def update_command
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # キャンセル SE を演奏
      $game_system.se_play($data_system.cancel_se)
      # マップ画面に切り替え
      $scene = Scene_Map.new
      return
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # コマンドウィンドウのカーソル位置で分岐
      case @command_window.index
      when 0  # 購入する
        # 決定 SE を演奏
        $game_system.se_play($data_system.decision_se)
        # ウィンドウの状態を購入モードへ
        @command_window.active = false
        @dummy_window.visible = false
        @buy_window.active = true
        @buy_window.visible = true
        @buy_window.refresh
        @status_window.visible = true
      when 1  # 売却する
        # 決定 SE を演奏
        $game_system.se_play($data_system.decision_se)
        # ウィンドウの状態を売却モードへ
        @command_window.active = false
        @dummy_window.visible = false
        @sell_window.active = true
        @sell_window.visible = true
        @sell_window.refresh
      when 2  # やめる
        # 決定 SE を演奏
        $game_system.se_play($data_system.decision_se)
        # マップ画面に切り替え
        $scene = Scene_Map.new
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (購入ウィンドウがアクティブの場合)
  #--------------------------------------------------------------------------
  def update_buy
    # ステータスウィンドウのアイテムを設定
    @status_window.item = @buy_window.item
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # キャンセル SE を演奏
      $game_system.se_play($data_system.cancel_se)
      # ウィンドウの状態を初期モードへ
      @command_window.active = true
      @dummy_window.visible = true
      @buy_window.active = false
      @buy_window.visible = false
      @status_window.visible = false
      @status_window.item = nil
      # ヘルプテキストを消去
      @help_window.set_text("")
      return
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # アイテムを取得
      @item = @buy_window.item
      # アイテムが無効の場合、または価格が所持金より上の場合
      if @item == nil or @item.price > $game_party.gold
        # ブザー SE を演奏
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # アイテムの所持数を取得
      case @item
      when RPG::Item
        number = $game_party.item_number(@item.id)
      when RPG::Weapon
        number = $game_party.weapon_number(@item.id)
      when RPG::Armor
        number = $game_party.armor_number(@item.id)
      end
      # すでに 99 個所持している場合
      if number == 99
        # ブザー SE を演奏
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 決定 SE を演奏
      $game_system.se_play($data_system.decision_se)
      # 最大購入可能個数を計算
      max = @item.price == 0 ? 99 : $game_party.gold / @item.price
      max = [max, 99 - number].min
      # ウィンドウの状態を個数入力モードへ
      @buy_window.active = false
      @buy_window.visible = false
      @number_window.set(@item, max, @item.price)
      @number_window.active = true
      @number_window.visible = true
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (売却ウィンドウがアクティブの場合)
  #--------------------------------------------------------------------------
  def update_sell
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # キャンセル SE を演奏
      $game_system.se_play($data_system.cancel_se)
      # ウィンドウの状態を初期モードへ
      @command_window.active = true
      @dummy_window.visible = true
      @sell_window.active = false
      @sell_window.visible = false
      @status_window.item = nil
      # ヘルプテキストを消去
      @help_window.set_text("")
      return
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # アイテムを取得
      @item = @sell_window.item
      # ステータスウィンドウのアイテムを設定
      @status_window.item = @item
      # アイテムが無効の場合、または価格が 0 (売却不可) の場合
      if @item == nil or @item.price == 0
        # ブザー SE を演奏
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 決定 SE を演奏
      $game_system.se_play($data_system.decision_se)
      # アイテムの所持数を取得
      case @item
      when RPG::Item
        number = $game_party.item_number(@item.id)
      when RPG::Weapon
        number = $game_party.weapon_number(@item.id)
      when RPG::Armor
        number = $game_party.armor_number(@item.id)
      end
      # 最大売却個数 = アイテムの所持数
      max = number
      # ウィンドウの状態を個数入力モードへ
      @sell_window.active = false
      @sell_window.visible = false
      @number_window.set(@item, max, @item.price / 2)
      @number_window.active = true
      @number_window.visible = true
      @status_window.visible = true
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (個数入力ウィンドウがアクティブの場合)
  #--------------------------------------------------------------------------
  def update_number
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # キャンセル SE を演奏
      $game_system.se_play($data_system.cancel_se)
      # 個数入力ウィンドウを非アクティブ・不可視に設定
      @number_window.active = false
      @number_window.visible = false
      # コマンドウィンドウのカーソル位置で分岐
      case @command_window.index
      when 0  # 購入する
        # ウィンドウの状態を購入モードへ
        @buy_window.active = true
        @buy_window.visible = true
      when 1  # 売却する
        # ウィンドウの状態を売却モードへ
        @sell_window.active = true
        @sell_window.visible = true
        @status_window.visible = false
      end
      return
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # ショップ SE を演奏
      $game_system.se_play($data_system.shop_se)
      # 個数入力ウィンドウを非アクティブ・不可視に設定
      @number_window.active = false
      @number_window.visible = false
      # コマンドウィンドウのカーソル位置で分岐
      case @command_window.index
      when 0  # 購入する
        # 購入処理
        $game_party.lose_gold(@number_window.number * @item.price)
        case @item
        when RPG::Item
          $game_party.gain_item(@item.id, @number_window.number)
        when RPG::Weapon
          $game_party.gain_weapon(@item.id, @number_window.number)
        when RPG::Armor
          $game_party.gain_armor(@item.id, @number_window.number)
        end
        # 各ウィンドウをリフレッシュ
        @gold_window.refresh
        @buy_window.refresh
        @status_window.refresh
        # ウィンドウの状態を購入モードへ
        @buy_window.active = true
        @buy_window.visible = true
      when 1  # 売却する
        # 売却処理
        $game_party.gain_gold(@number_window.number * (@item.price / 2))
        case @item
        when RPG::Item
          $game_party.lose_item(@item.id, @number_window.number)
        when RPG::Weapon
          $game_party.lose_weapon(@item.id, @number_window.number)
        when RPG::Armor
          $game_party.lose_armor(@item.id, @number_window.number)
        end
        # 各ウィンドウをリフレッシュ
        @gold_window.refresh
        @sell_window.refresh
        @status_window.refresh
        # ウィンドウの状態を売却モードへ
        @sell_window.active = true
        @sell_window.visible = true
        @status_window.visible = false
      end
      return
    end
  end
end
