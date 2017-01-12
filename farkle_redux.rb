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
    attr_reader   :win_score
    attr_reader   :d_num
    attr_accessor :players

    def initialize(p_num, d_num, win_score)
      @players   = Array.new(p_num) { |n| Player.new(n + 1) }
      @win_score = win_score
      @d_num = d_num
      play
    end

    def play
      until game_finished?
        do_rounds
      end
    end

    def game_finished?
    end

    def do_rounds
      players.each do |player|
        next if turn_finished?(player)
      end
    end

    def turn_finished?(player)
      roll_result = Dice.new(@d_num).roll
      farkled?(roll_result) ? first_roll?(roll_result) : gained(roll_result)
    end

    def farkled?(roll_result)
      roll_hash(roll_result).each { |k, v| break false unless scored?(k, v.size) }
    end

    def scored?(k, v)
      (v % 3).zero? || k == 1 || k == 5
    end

    def roll_hash(roll_result)
      roll_result.group_by { |i| i }
    end

    def first_roll?(roll_result)
    end

    def gained(roll_result)
    end
  end

  # ConsoleMessenger class outputs messages to console
  class ConsoleMessenger
    def initialize; end
  end
end
