# Farkle class represents the dice game Farkle
class Farkle
  # Player class contains all the player information
  class Player
    attr_reader   :p_id
    attr_accessor :p_score

    def initialize(p_id)
      @p_id    = p_id
      @p_score = 0
    end
  end

  # Dice class emulates dice and die rolling
  class Dice
    attr_reader :d_num

    def initialize(d_num)
      @d_num = d_num
    end
    
    def roll
      Random.new_seed
      Array.new(@d_num) { rand(6) + 1 }
    end
  end

  # Game class contains the main game logic
  class Game
  end

  # ConsoleMessenger class outputs messages to console
  class ConsoleMessenger
  end
end
