module RPG
  class System
    include MarshalConvertor

    def initialize
      @magic_number = 0
      @party_members = [1]
      @elements = [nil, ""]
      @switches = [nil, ""]
      @variables = [nil, ""]
      @windowskin_name = ""
      @title_name = ""
      @gameover_name = ""
      @battle_transition = ""
      @title_bgm = RPG::AudioFile.new
      @battle_bgm = RPG::AudioFile.new
      @battle_end_me = RPG::AudioFile.new
      @gameover_me = RPG::AudioFile.new
      @cursor_se = RPG::AudioFile.new("", 80)
      @decision_se = RPG::AudioFile.new("", 80)
      @cancel_se = RPG::AudioFile.new("", 80)
      @buzzer_se = RPG::AudioFile.new("", 80)
      @equip_se = RPG::AudioFile.new("", 80)
      @shop_se = RPG::AudioFile.new("", 80)
      @save_se = RPG::AudioFile.new("", 80)
      @load_se = RPG::AudioFile.new("", 80)
      @battle_start_se = RPG::AudioFile.new("", 80)
      @escape_se = RPG::AudioFile.new("", 80)
      @actor_collapse_se = RPG::AudioFile.new("", 80)
      @enemy_collapse_se = RPG::AudioFile.new("", 80)
      @words = RPG::System::Words.new
      @test_battlers = []
      @test_troop_id = 1
      @start_map_id = 1
      @start_x = 0
      @start_y = 0
      @battleback_name = ""
      @battler_name = ""
      @battler_hue = 0
      @edit_map_id = 1
    end
    attr_accessor :magic_number
    attr_accessor :party_members
    attr_accessor :elements
    attr_accessor :switches
    attr_accessor :variables
    attr_accessor :windowskin_name
    attr_accessor :title_name
    attr_accessor :gameover_name
    attr_accessor :battle_transition
    attr_accessor :title_bgm
    attr_accessor :battle_bgm
    attr_accessor :battle_end_me
    attr_accessor :gameover_me
    attr_accessor :cursor_se
    attr_accessor :decision_se
    attr_accessor :cancel_se
    attr_accessor :buzzer_se
    attr_accessor :equip_se
    attr_accessor :shop_se
    attr_accessor :save_se
    attr_accessor :load_se
    attr_accessor :battle_start_se
    attr_accessor :escape_se
    attr_accessor :actor_collapse_se
    attr_accessor :enemy_collapse_se
    attr_accessor :words
    attr_accessor :test_battlers
    attr_accessor :test_troop_id
    attr_accessor :start_map_id
    attr_accessor :start_x
    attr_accessor :start_y
    attr_accessor :battleback_name
    attr_accessor :battler_name
    attr_accessor :battler_hue
    attr_accessor :edit_map_id
  end
end
