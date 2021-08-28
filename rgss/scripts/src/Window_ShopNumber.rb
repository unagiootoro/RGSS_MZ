#==============================================================================
# ■ Window_ShopNumber
#------------------------------------------------------------------------------
# 　ショップ画面で、購入または売却するアイテムの個数を入力するウィンドウです。
#==============================================================================

class Window_ShopNumber < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 128, 368, 352)
    self.contents = Bitmap.new(width - 32, height - 32)
    @item = nil
    @max = 1
    @price = 0
    @number = 1
  end
  #--------------------------------------------------------------------------
  # ● アイテム、最大個数、価格の設定
  #--------------------------------------------------------------------------
  def set(item, max, price)
    @item = item
    @max = max
    @price = price
    @number = 1
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 入力された個数の設定
  #--------------------------------------------------------------------------
  def number
    return @number
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    draw_item_name(@item, 4, 96)
    self.contents.font.color = normal_color
    self.contents.draw_text(272, 96, 32, 32, "×")
    self.contents.draw_text(308, 96, 24, 32, @number.to_s, 2)
    self.cursor_rect.set(304, 96, 32, 32)
    # 合計価格と通貨単位を描画
    domination = $data_system.words.gold
    cx = contents.text_size(domination).width
    total_price = @price * @number
    self.contents.font.color = normal_color
    self.contents.draw_text(4, 160, 328-cx-2, 32, total_price.to_s, 2)
    self.contents.font.color = system_color
    self.contents.draw_text(332-cx, 160, cx, 32, domination, 2)
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    if self.active
      # カーソル右 (+1)
      if Input.repeat?(Input::RIGHT) and @number < @max
        $game_system.se_play($data_system.cursor_se)
        @number += 1
        refresh
      end
      # カーソル左 (-1)
      if Input.repeat?(Input::LEFT) and @number > 1
        $game_system.se_play($data_system.cursor_se)
        @number -= 1
        refresh
      end
      # カーソル上 (+10)
      if Input.repeat?(Input::UP) and @number < @max
        $game_system.se_play($data_system.cursor_se)
        @number = [@number + 10, @max].min
        refresh
      end
      # カーソル下 (-10)
      if Input.repeat?(Input::DOWN) and @number > 1
        $game_system.se_play($data_system.cursor_se)
        @number = [@number - 10, 1].max
        refresh
      end
    end
  end
end
