module MarshalConvertor; end

class Hash
  def to_h(&block)
    if block
      self.map(&block).to_h
    else
      self
    end
  end
end

module MarshalConvertor
  def rpg_hash_dump
    hash = {}
    hash["class_name"] = self.class.name
    instance_variables.each do |ivar|
      obj = instance_variable_get(ivar)
      if obj.respond_to?(:rpg_hash_dump)
        hash2 = obj.rpg_hash_dump
        hash[ivar] = hash2
      elsif obj.is_a?(String)
        hash[ivar] = str_encode(obj)
      elsif obj.is_a?(Array)
        hash[ivar] = obj.map do |val|
          if val.is_a?(String)
            val = str_encode(val)
          elsif val.respond_to?(:rpg_hash_dump)
            val.rpg_hash_dump
          else
            val
          end
        end
      elsif obj.is_a?(Hash)
        hash[ivar] = obj.to_h do |key, val|
          if val.is_a?(String)
            [key, str_encode(val)]
          elsif val.respond_to?(:rpg_hash_dump)
            [key, val.rpg_hash_dump]
          else
            [key, val]
          end
        end
      else
        hash[ivar] = obj
      end
    end
    hash
  end

  def rpg_hash_load(hash)
    hash.each do |ivar, obj|
      next unless ivar.to_s[0] == "@"
      if obj.is_a?(Hash) && obj["class_name"]
        cls = Kernel.const_get(obj["class_name"])
        obj2 = cls.allocate
        obj2.rpg_hash_load(obj)
        instance_variable_set(ivar, obj2)
      elsif obj.is_a?(Hash)
        hash2 = obj.to_h do |key, val|
          if key =~ /^\d+$/
            key = key.to_i
          end
          if val.is_a?(Hash) && val["class_name"]
            cls = Kernel.const_get(val["class_name"])
            obj2 = cls.allocate
            obj2.rpg_hash_load(val)
            [key, obj2]
          else
            [key, val]
          end
        end
        instance_variable_set(ivar, hash2)
      elsif obj.is_a?(Array)
        ary = obj.map do |val|
          if val.is_a?(Hash) && val["class_name"]
            cls = Kernel.const_get(val["class_name"])
            obj2 = cls.allocate
            obj2.rpg_hash_load(val)
            obj2
          else
            val
          end
        end
        instance_variable_set(ivar, ary)
      else
        instance_variable_set(ivar, obj)
      end
    end
  end

  def str_encode(str)
    begin
      str = str.encode("UTF-8")
    rescue
      str = str.force_encoding("UTF-8")
      str = str.gsub('\\', "")
      str = str.gsub('"', "")
    end
    str
  end
end
