#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　アクターを扱うクラスです。このクラスは Game_Actors クラス ($game_actors)
# の内部で使用され、Game_Party クラス ($game_party) からも参照されます。
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :name                     # 名前
  attr_reader   :character_name           # キャラクター ファイル名
  attr_reader   :character_hue            # キャラクター 色相
  attr_reader   :class_id                 # クラス ID
  attr_reader   :weapon_id                # 武器 ID
  attr_reader   :armor1_id                # 盾 ID
  attr_reader   :armor2_id                # 頭防具 ID
  attr_reader   :armor3_id                # 体防具 ID
  attr_reader   :armor4_id                # 装飾品 ID
  attr_reader   :level                    # レベル
  attr_reader   :exp                      # EXP
  attr_reader   :skills                   # スキル
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     actor_id : アクター ID
  #--------------------------------------------------------------------------
  def initialize(actor_id)
    super()
    setup(actor_id)
  end
  #--------------------------------------------------------------------------
  # ● セットアップ
  #     actor_id : アクター ID
  #--------------------------------------------------------------------------
  def setup(actor_id)
    actor = $data_actors[actor_id]
    @actor_id = actor_id
    @name = actor.name
    @character_name = actor.character_name
    @character_hue = actor.character_hue
    @battler_name = actor.battler_name
    @battler_hue = actor.battler_hue
    @class_id = actor.class_id
    @weapon_id = actor.weapon_id
    @armor1_id = actor.armor1_id
    @armor2_id = actor.armor2_id
    @armor3_id = actor.armor3_id
    @armor4_id = actor.armor4_id
    @level = actor.initial_level
    @exp_list = Array.new(101)
    make_exp_list
    @exp = @exp_list[@level]
    @skills = []
    @hp = maxhp
    @sp = maxsp
    @states = []
    @states_turn = {}
    @maxhp_plus = 0
    @maxsp_plus = 0
    @str_plus = 0
    @dex_plus = 0
    @agi_plus = 0
    @int_plus = 0
    # スキル習得
    for i in 1..@level
      for j in $data_classes[@class_id].learnings
        if j.level == i
          learn_skill(j.skill_id)
        end
      end
    end
    # オートステートを更新
    update_auto_state(nil, $data_armors[@armor1_id])
    update_auto_state(nil, $data_armors[@armor2_id])
    update_auto_state(nil, $data_armors[@armor3_id])
    update_auto_state(nil, $data_armors[@armor4_id])
  end
  #--------------------------------------------------------------------------
  # ● アクター ID 取得
  #--------------------------------------------------------------------------
  def id
    return @actor_id
  end
  #--------------------------------------------------------------------------
  # ● インデックス取得
  #--------------------------------------------------------------------------
  def index
    return $game_party.actors.index(self)
  end
  #--------------------------------------------------------------------------
  # ● EXP 計算
  #--------------------------------------------------------------------------
  def make_exp_list
    actor = $data_actors[@actor_id]
    @exp_list[1] = 0
    pow_i = 2.4 + actor.exp_inflation / 100.0
    for i in 2..100
      if i > actor.final_level
        @exp_list[i] = 0
      else
        n = actor.exp_basis * ((i + 3) ** pow_i) / (5 ** pow_i)
        @exp_list[i] = @exp_list[i-1] + Integer(n)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 属性補正値の取得
  #     element_id : 属性 ID
  #--------------------------------------------------------------------------
  def element_rate(element_id)
    # 属性有効度に対応する数値を取得
    table = [0,200,150,100,50,0,-100]
    result = table[$data_classes[@class_id].element_ranks[element_id]]
    # 防具でこの属性が防御されている場合は半減
    for i in [@armor1_id, @armor2_id, @armor3_id, @armor4_id]
      armor = $data_armors[i]
      if armor != nil and armor.guard_element_set.include?(element_id)
        result /= 2
      end
    end
    # ステートでこの属性が防御されている場合は半減
    for i in @states
      if $data_states[i].guard_element_set.include?(element_id)
        result /= 2
      end
    end
    # メソッド終了
    return result
  end
  #--------------------------------------------------------------------------
  # ● ステート有効度の取得
  #--------------------------------------------------------------------------
  def state_ranks
    return $data_classes[@class_id].state_ranks
  end
  #--------------------------------------------------------------------------
  # ● ステート防御判定
  #     state_id : ステート ID
  #--------------------------------------------------------------------------
  def state_guard?(state_id)
    for i in [@armor1_id, @armor2_id, @armor3_id, @armor4_id]
      armor = $data_armors[i]
      if armor != nil
        if armor.guard_state_set.include?(state_id)
          return true
        end
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃の属性取得
  #--------------------------------------------------------------------------
  def element_set
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.element_set : []
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃のステート変化 (+) 取得
  #--------------------------------------------------------------------------
  def plus_state_set
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.plus_state_set : []
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃のステート変化 (-) 取得
  #--------------------------------------------------------------------------
  def minus_state_set
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.minus_state_set : []
  end
  #--------------------------------------------------------------------------
  # ● MaxHP の取得
  #--------------------------------------------------------------------------
  def maxhp
    n = [[base_maxhp + @maxhp_plus, 1].max, 9999].min
    for i in @states
      n *= $data_states[i].maxhp_rate / 100.0
    end
    n = [[Integer(n), 1].max, 9999].min
    return n
  end
  #--------------------------------------------------------------------------
  # ● 基本 MaxHP の取得
  #--------------------------------------------------------------------------
  def base_maxhp
    return $data_actors[@actor_id].parameters[0, @level]
  end
  #--------------------------------------------------------------------------
  # ● 基本 MaxSP の取得
  #--------------------------------------------------------------------------
  def base_maxsp
    return $data_actors[@actor_id].parameters[1, @level]
  end
  #--------------------------------------------------------------------------
  # ● 基本腕力の取得
  #--------------------------------------------------------------------------
  def base_str
    n = $data_actors[@actor_id].parameters[2, @level]
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    n += weapon != nil ? weapon.str_plus : 0
    n += armor1 != nil ? armor1.str_plus : 0
    n += armor2 != nil ? armor2.str_plus : 0
    n += armor3 != nil ? armor3.str_plus : 0
    n += armor4 != nil ? armor4.str_plus : 0
    return [[n, 1].max, 999].min
  end
  #--------------------------------------------------------------------------
  # ● 基本器用さの取得
  #--------------------------------------------------------------------------
  def base_dex
    n = $data_actors[@actor_id].parameters[3, @level]
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    n += weapon != nil ? weapon.dex_plus : 0
    n += armor1 != nil ? armor1.dex_plus : 0
    n += armor2 != nil ? armor2.dex_plus : 0
    n += armor3 != nil ? armor3.dex_plus : 0
    n += armor4 != nil ? armor4.dex_plus : 0
    return [[n, 1].max, 999].min
  end
  #--------------------------------------------------------------------------
  # ● 基本素早さの取得
  #--------------------------------------------------------------------------
  def base_agi
    n = $data_actors[@actor_id].parameters[4, @level]
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    n += weapon != nil ? weapon.agi_plus : 0
    n += armor1 != nil ? armor1.agi_plus : 0
    n += armor2 != nil ? armor2.agi_plus : 0
    n += armor3 != nil ? armor3.agi_plus : 0
    n += armor4 != nil ? armor4.agi_plus : 0
    return [[n, 1].max, 999].min
  end
  #--------------------------------------------------------------------------
  # ● 基本魔力の取得
  #--------------------------------------------------------------------------
  def base_int
    n = $data_actors[@actor_id].parameters[5, @level]
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    n += weapon != nil ? weapon.int_plus : 0
    n += armor1 != nil ? armor1.int_plus : 0
    n += armor2 != nil ? armor2.int_plus : 0
    n += armor3 != nil ? armor3.int_plus : 0
    n += armor4 != nil ? armor4.int_plus : 0
    return [[n, 1].max, 999].min
  end
  #--------------------------------------------------------------------------
  # ● 基本攻撃力の取得
  #--------------------------------------------------------------------------
  def base_atk
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.atk : 0
  end
  #--------------------------------------------------------------------------
  # ● 基本物理防御の取得
  #--------------------------------------------------------------------------
  def base_pdef
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    pdef1 = weapon != nil ? weapon.pdef : 0
    pdef2 = armor1 != nil ? armor1.pdef : 0
    pdef3 = armor2 != nil ? armor2.pdef : 0
    pdef4 = armor3 != nil ? armor3.pdef : 0
    pdef5 = armor4 != nil ? armor4.pdef : 0
    return pdef1 + pdef2 + pdef3 + pdef4 + pdef5
  end
  #--------------------------------------------------------------------------
  # ● 基本魔法防御の取得
  #--------------------------------------------------------------------------
  def base_mdef
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    mdef1 = weapon != nil ? weapon.mdef : 0
    mdef2 = armor1 != nil ? armor1.mdef : 0
    mdef3 = armor2 != nil ? armor2.mdef : 0
    mdef4 = armor3 != nil ? armor3.mdef : 0
    mdef5 = armor4 != nil ? armor4.mdef : 0
    return mdef1 + mdef2 + mdef3 + mdef4 + mdef5
  end
  #--------------------------------------------------------------------------
  # ● 基本回避修正の取得
  #--------------------------------------------------------------------------
  def base_eva
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    eva1 = armor1 != nil ? armor1.eva : 0
    eva2 = armor2 != nil ? armor2.eva : 0
    eva3 = armor3 != nil ? armor3.eva : 0
    eva4 = armor4 != nil ? armor4.eva : 0
    return eva1 + eva2 + eva3 + eva4
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃 攻撃側アニメーション ID の取得
  #--------------------------------------------------------------------------
  def animation1_id
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.animation1_id : 0
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃 対象側アニメーション ID の取得
  #--------------------------------------------------------------------------
  def animation2_id
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.animation2_id : 0
  end
  #--------------------------------------------------------------------------
  # ● クラス名の取得
  #--------------------------------------------------------------------------
  def class_name
    return $data_classes[@class_id].name
  end
  #--------------------------------------------------------------------------
  # ● EXP の文字列取得
  #--------------------------------------------------------------------------
  def exp_s
    return @exp_list[@level+1] > 0 ? @exp.to_s : "-------"
  end
  #--------------------------------------------------------------------------
  # ● 次のレベルの EXP の文字列取得
  #--------------------------------------------------------------------------
  def next_exp_s
    return @exp_list[@level+1] > 0 ? @exp_list[@level+1].to_s : "-------"
  end
  #--------------------------------------------------------------------------
  # ● 次のレベルまでの EXP の文字列取得
  #--------------------------------------------------------------------------
  def next_rest_exp_s
    return @exp_list[@level+1] > 0 ?
      (@exp_list[@level+1] - @exp).to_s : "-------"
  end
  #--------------------------------------------------------------------------
  # ● オートステートの更新
  #     old_armor : 外した防具
  #     new_armor : 装備した防具
  #--------------------------------------------------------------------------
  def update_auto_state(old_armor, new_armor)
    # 外した防具のオートステートを強制解除
    if old_armor != nil and old_armor.auto_state_id != 0
      remove_state(old_armor.auto_state_id, true)
    end
    # 装備した防具のオートステートを強制付加
    if new_armor != nil and new_armor.auto_state_id != 0
      add_state(new_armor.auto_state_id, true)
    end
  end
  #--------------------------------------------------------------------------
  # ● 装備固定判定
  #     equip_type : 装備タイプ
  #--------------------------------------------------------------------------
  def equip_fix?(equip_type)
    case equip_type
    when 0  # 武器
      return $data_actors[@actor_id].weapon_fix
    when 1  # 盾
      return $data_actors[@actor_id].armor1_fix
    when 2  # 頭
      return $data_actors[@actor_id].armor2_fix
    when 3  # 身体
      return $data_actors[@actor_id].armor3_fix
    when 4  # 装飾品
      return $data_actors[@actor_id].armor4_fix
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 装備の変更
  #     equip_type : 装備タイプ
  #     id    : 武器 or 防具 ID  (0 なら装備解除)
  #--------------------------------------------------------------------------
  def equip(equip_type, id)
    case equip_type
    when 0  # 武器
      if id == 0 or $game_party.weapon_number(id) > 0
        $game_party.gain_weapon(@weapon_id, 1)
        @weapon_id = id
        $game_party.lose_weapon(id, 1)
      end
    when 1  # 盾
      if id == 0 or $game_party.armor_number(id) > 0
        update_auto_state($data_armors[@armor1_id], $data_armors[id])
        $game_party.gain_armor(@armor1_id, 1)
        @armor1_id = id
        $game_party.lose_armor(id, 1)
      end
    when 2  # 頭
      if id == 0 or $game_party.armor_number(id) > 0
        update_auto_state($data_armors[@armor2_id], $data_armors[id])
        $game_party.gain_armor(@armor2_id, 1)
        @armor2_id = id
        $game_party.lose_armor(id, 1)
      end
    when 3  # 身体
      if id == 0 or $game_party.armor_number(id) > 0
        update_auto_state($data_armors[@armor3_id], $data_armors[id])
        $game_party.gain_armor(@armor3_id, 1)
        @armor3_id = id
        $game_party.lose_armor(id, 1)
      end
    when 4  # 装飾品
      if id == 0 or $game_party.armor_number(id) > 0
        update_auto_state($data_armors[@armor4_id], $data_armors[id])
        $game_party.gain_armor(@armor4_id, 1)
        @armor4_id = id
        $game_party.lose_armor(id, 1)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 装備可能判定
  #     item : アイテム
  #--------------------------------------------------------------------------
  def equippable?(item)
    # 武器の場合
    if item.is_a?(RPG::Weapon)
      # 現在のクラスの装備可能な武器に含まれている場合
      if $data_classes[@class_id].weapon_set.include?(item.id)
        return true
      end
    end
    # 防具の場合
    if item.is_a?(RPG::Armor)
      # 現在のクラスの装備可能な防具に含まれている場合
      if $data_classes[@class_id].armor_set.include?(item.id)
        return true
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● EXP の変更
  #     exp : 新しい EXP
  #--------------------------------------------------------------------------
  def exp=(exp)
    @exp = [[exp, 9999999].min, 0].max
    # レベルアップ
    while @exp >= @exp_list[@level+1] and @exp_list[@level+1] > 0
      @level += 1
      # スキル習得
      for j in $data_classes[@class_id].learnings
        if j.level == @level
          learn_skill(j.skill_id)
        end
      end
    end
    # レベルダウン
    while @exp < @exp_list[@level]
      @level -= 1
    end
    # 現在の HP と SP が最大値を超えていたら修正
    @hp = [@hp, self.maxhp].min
    @sp = [@sp, self.maxsp].min
  end
  #--------------------------------------------------------------------------
  # ● レベルの変更
  #     level : 新しいレベル
  #--------------------------------------------------------------------------
  def level=(level)
    # 上下限チェック
    level = [[level, $data_actors[@actor_id].final_level].min, 1].max
    # EXP を変更
    self.exp = @exp_list[level]
  end
  #--------------------------------------------------------------------------
  # ● スキルを覚える
  #     skill_id : スキル ID
  #--------------------------------------------------------------------------
  def learn_skill(skill_id)
    if skill_id > 0 and not skill_learn?(skill_id)
      @skills.push(skill_id)
      @skills.sort!
    end
  end
  #--------------------------------------------------------------------------
  # ● スキルを忘れる
  #     skill_id : スキル ID
  #--------------------------------------------------------------------------
  def forget_skill(skill_id)
    @skills.delete(skill_id)
  end
  #--------------------------------------------------------------------------
  # ● スキルの習得済み判定
  #     skill_id : スキル ID
  #--------------------------------------------------------------------------
  def skill_learn?(skill_id)
    return @skills.include?(skill_id)
  end
  #--------------------------------------------------------------------------
  # ● スキルの使用可能判定
  #     skill_id : スキル ID
  #--------------------------------------------------------------------------
  def skill_can_use?(skill_id)
    if not skill_learn?(skill_id)
      return false
    end
    return super
  end
  #--------------------------------------------------------------------------
  # ● 名前の変更
  #     name : 新しい名前
  #--------------------------------------------------------------------------
  def name=(name)
    @name = name
  end
  #--------------------------------------------------------------------------
  # ● クラス ID の変更
  #     class_id : 新しいクラス ID
  #--------------------------------------------------------------------------
  def class_id=(class_id)
    if $data_classes[class_id] != nil
      @class_id = class_id
      # 装備できなくなったアイテムを外す
      unless equippable?($data_weapons[@weapon_id])
        equip(0, 0)
      end
      unless equippable?($data_armors[@armor1_id])
        equip(1, 0)
      end
      unless equippable?($data_armors[@armor2_id])
        equip(2, 0)
      end
      unless equippable?($data_armors[@armor3_id])
        equip(3, 0)
      end
      unless equippable?($data_armors[@armor4_id])
        equip(4, 0)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● グラフィックの変更
  #     character_name : 新しいキャラクター ファイル名
  #     character_hue  : 新しいキャラクター 色相
  #     battler_name   : 新しいバトラー ファイル名
  #     battler_hue    : 新しいバトラー 色相
  #--------------------------------------------------------------------------
  def set_graphic(character_name, character_hue, battler_name, battler_hue)
    @character_name = character_name
    @character_hue = character_hue
    @battler_name = battler_name
    @battler_hue = battler_hue
  end
  #--------------------------------------------------------------------------
  # ● バトル画面 X 座標の取得
  #--------------------------------------------------------------------------
  def screen_x
    # パーティ内の並び順から X 座標を計算して返す
    if self.index != nil
      return self.index * 160 + 80
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # ● バトル画面 Y 座標の取得
  #--------------------------------------------------------------------------
  def screen_y
    return 464
  end
  #--------------------------------------------------------------------------
  # ● バトル画面 Z 座標の取得
  #--------------------------------------------------------------------------
  def screen_z
    # パーティ内の並び順から Z 座標を計算して返す
    if self.index != nil
      return 4 - self.index
    else
      return 0
    end
  end
end
