#==============================================================================
# ■ Window_ShopBuy
#------------------------------------------------------------------------------
# 　ショップ画面で、購入できる商品の一覧を表示するウィンドウです。
#==============================================================================

class Window_ShopBuy < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     shop_goods : 商品
  #--------------------------------------------------------------------------
  def initialize(shop_goods)
    super(0, 128, 368, 352)
    @shop_goods = shop_goods
    refresh
    self.index = 0
  end
  #--------------------------------------------------------------------------
  # ● アイテムの取得
  #--------------------------------------------------------------------------
  def item
    return @data[self.index]
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data = []
    for goods_item in @shop_goods
      case goods_item[0]
      when 0
        item = $data_items[goods_item[1]]
      when 1
        item = $data_weapons[goods_item[1]]
      when 2
        item = $data_armors[goods_item[1]]
      end
      if item != nil
        @data.push(item)
      end
    end
    # 項目数が 0 でなければビットマップを作成し、全項目を描画
    @item_max = @data.size
    if @item_max > 0
      self.contents = Bitmap.new(width - 32, row_max * 32)
      for i in 0...@item_max
        draw_item(i)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #     index : 項目番号
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    # アイテムの所持数を取得
    case item
    when RPG::Item
      number = $game_party.item_number(item.id)
    when RPG::Weapon
      number = $game_party.weapon_number(item.id)
    when RPG::Armor
      number = $game_party.armor_number(item.id)
    end
    # 価格が所持金以下、かつ所持数が 99 でなければ通常文字色に、
    # そうでなければ無効文字色に設定
    if item.price <= $game_party.gold and number < 99
      self.contents.font.color = normal_color
    else
      self.contents.font.color = disabled_color
    end
    x = 4
    y = index * 32
    rect = Rect.new(x, y, self.width - 32, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    bitmap = RPG::Cache.icon(item.icon_name)
    opacity = self.contents.font.color == normal_color ? 255 : 128
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24), opacity)
    self.contents.draw_text(x + 28, y, 212, 32, item.name, 0)
    self.contents.draw_text(x + 240, y, 88, 32, item.price.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(self.item == nil ? "" : self.item.description)
  end
end
