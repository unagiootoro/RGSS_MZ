#==============================================================================
# ■ Window_ShopStatus
#------------------------------------------------------------------------------
# 　ショップ画面で、アイテムの所持数やアクターの装備を表示するウィンドウです。
#==============================================================================

class Window_ShopStatus < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(368, 128, 272, 352)
    self.contents = Bitmap.new(width - 32, height - 32)
    @item = nil
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    if @item == nil
      return
    end
    case @item
    when RPG::Item
      number = $game_party.item_number(@item.id)
    when RPG::Weapon
      number = $game_party.weapon_number(@item.id)
    when RPG::Armor
      number = $game_party.armor_number(@item.id)
    end
    self.contents.font.color = system_color
    self.contents.draw_text(4, 0, 200, 32, "持っている数")
    self.contents.font.color = normal_color
    self.contents.draw_text(204, 0, 32, 32, number.to_s, 2)
    if @item.is_a?(RPG::Item)
      return
    end
    # 装備品追加情報
    for i in 0...$game_party.actors.size
      # アクターを取得
      actor = $game_party.actors[i]
      # 装備可能なら通常文字色に、不可能なら無効文字色に設定
      if actor.equippable?(@item)
        self.contents.font.color = normal_color
      else
        self.contents.font.color = disabled_color
      end
      # アクターの名前を描画
      self.contents.draw_text(4, 64 + 64 * i, 120, 32, actor.name)
      # 現在の装備品を取得
      if @item.is_a?(RPG::Weapon)
        item1 = $data_weapons[actor.weapon_id]
      elsif @item.kind == 0
        item1 = $data_armors[actor.armor1_id]
      elsif @item.kind == 1
        item1 = $data_armors[actor.armor2_id]
      elsif @item.kind == 2
        item1 = $data_armors[actor.armor3_id]
      else
        item1 = $data_armors[actor.armor4_id]
      end
      # 装備可能な場合
      if actor.equippable?(@item)
        # 武器の場合
        if @item.is_a?(RPG::Weapon)
          atk1 = item1 != nil ? item1.atk : 0
          atk2 = @item != nil ? @item.atk : 0
          change = atk2 - atk1
        end
        # 防具の場合
        if @item.is_a?(RPG::Armor)
          pdef1 = item1 != nil ? item1.pdef : 0
          mdef1 = item1 != nil ? item1.mdef : 0
          pdef2 = @item != nil ? @item.pdef : 0
          mdef2 = @item != nil ? @item.mdef : 0
          change = pdef2 - pdef1 + mdef2 - mdef1
        end
        # パラメータの変化値を描画
        self.contents.draw_text(124, 64 + 64 * i, 112, 32,
          sprintf("%+d", change), 2)
      end
      # アイテムを描画
      if item1 != nil
        x = 4
        y = 64 + 64 * i + 32
        bitmap = RPG::Cache.icon(item1.icon_name)
        opacity = self.contents.font.color == normal_color ? 255 : 128
        self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24), opacity)
        self.contents.draw_text(x + 28, y, 212, 32, item1.name)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテムの設定
  #     item : 新しいアイテム
  #--------------------------------------------------------------------------
  def item=(item)
    if @item != item
      @item = item
      refresh
    end
  end
end
