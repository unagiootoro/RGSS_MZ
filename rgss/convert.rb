$: << __dir__

require "json"
require "marshal_convertor"

require "lib/Table"
require "lib/Color"
require "lib/Tone"
require "lib/rpg/Actor"
require "lib/rpg/Animation"
require "lib/rpg/AnimationFrame"
require "lib/rpg/AnimationTiming"
require "lib/rpg/Armor"
require "lib/rpg/AudioFile"
require "lib/rpg/Class"
require "lib/rpg/ClassLearning"
require "lib/rpg/CommonEvent"
require "lib/rpg/Enemy"
require "lib/rpg/EnemyAction"
require "lib/rpg/Event"
require "lib/rpg/EventCommand"
require "lib/rpg/EventPage"
require "lib/rpg/EventPageCondition"
require "lib/rpg/EventPageGraphic"
require "lib/rpg/Item"
require "lib/rpg/Map"
require "lib/rpg/MapInfo"
require "lib/rpg/MoveCommand"
require "lib/rpg/MoveRoute"
require "lib/rpg/Skill"
require "lib/rpg/State"
require "lib/rpg/System"
require "lib/rpg/SystemTestBattler"
require "lib/rpg/SystemWords"
require "lib/rpg/Tileset"
require "lib/rpg/Troop"
require "lib/rpg/TroopMember"
require "lib/rpg/TroopPage"
require "lib/rpg/TroopPageCondition"
require "lib/rpg/Weapon"

Dir.mkdir("converted") unless Dir.exist?("converted")
Dir["Data/*.rxdata"].each do |fname|
  type = fname.match("Data/(.+)\.rxdata")[1]
  next if type == "Scripts"
  next if type == "Shops"
  file = File.read(fname)
  obj = Marshal.load(file)

  if obj.is_a?(Array)
    hash = obj.map { |val| val.respond_to?(:rpg_hash_dump) ? val.rpg_hash_dump : val }
  elsif obj.is_a?(Hash)
    hash = obj.to_h { |key, val| [key, val.respond_to?(:rpg_hash_dump) ? val.rpg_hash_dump : val] }
  else
    hash = obj.rpg_hash_dump
  end

  file3 = JSON.dump(hash)
  
  File.binwrite("converted/#{type}.json", file3)
end
