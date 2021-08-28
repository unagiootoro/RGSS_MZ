#==============================================================================
# ■ Window_EquipItem
#------------------------------------------------------------------------------
# 　装備画面で、装備変更の候補となるアイテムの一覧を表示するウィンドウです。
#==============================================================================

class Window_EquipItem < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     actor      : アクター
  #     equip_type : 装備部位 (0～3)
  #--------------------------------------------------------------------------
  def initialize(actor, equip_type)
    super(0, 256, 640, 224)
    @actor = actor
    @equip_type = equip_type
    @column_max = 2
    refresh
    self.active = false
    self.index = -1
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
    # 装備可能な武器を追加
    if @equip_type == 0
      weapon_set = $data_classes[@actor.class_id].weapon_set
      for i in 1...$data_weapons.size
        if $game_party.weapon_number(i) > 0 and weapon_set.include?(i)
          @data.push($data_weapons[i])
        end
      end
    end
    # 装備可能な防具を追加
    if @equip_type != 0
      armor_set = $data_classes[@actor.class_id].armor_set
      for i in 1...$data_armors.size
        if $game_party.armor_number(i) > 0 and armor_set.include?(i)
          if $data_armors[i].kind == @equip_type-1
            @data.push($data_armors[i])
          end
        end
      end
    end
    # 空白を追加
    @data.push(nil)
    # ビットマップを作成し、全項目を描画
    @item_max = @data.size
    self.contents = Bitmap.new(width - 32, row_max * 32)
    for i in 0...@item_max-1
      draw_item(i)
    end
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #     index : 項目番号
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    x = 4 + index % 2 * (288 + 32)
    y = index / 2 * 32
    case item
    when RPG::Weapon
      number = $game_party.weapon_number(item.id)
    when RPG::Armor
      number = $game_party.armor_number(item.id)
    end
    bitmap = RPG::Cache.icon(item.icon_name)
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24))
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 28, y, 212, 32, item.name, 0)
    self.contents.draw_text(x + 240, y, 16, 32, ":", 1)
    self.contents.draw_text(x + 256, y, 24, 32, number.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(self.item == nil ? "" : self.item.description)
  end
end
