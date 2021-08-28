module RPG
  class MoveCommand
    include MarshalConvertor

    def initialize(code = 0, parameters = [])
      @code = code
      @parameters = parameters
    end
    attr_accessor :code
    attr_accessor :parameters
  end
end
