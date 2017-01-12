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
    attr_accessor :d_num
    attr_accessor :first_roll?

    def initialize(d_num)
      @d_num = d_num
      @first_roll? = true
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
      do_rounds until game_finished?
    end

    def game_finished?
      true
    end

    def do_rounds
      players.each do |player|
        next if turn_finished?(player)
      end
    end

    def turn_finished?(player)
      dice = Dice.new(@d_num)
      farkled?(result) ? first_roll?(dice) : gained(player, result, dice)
    end

    def farkled?(result)
      roll_hash(result).each { |k, v| break false unless scored?(k, v.size) }
    end

    def scored?(k, v)
      (v % 3).zero? || k == 1 || k == 5
    end

    def roll_hash(result)
      result.group_by { |i| i }
    end

    def first_roll?(dice)
      dice.first_roll? = false
    end

    def gained(player, result, dice)
      dice.first_roll? ? hot_dice? : keep_rolling?
    end

    def hot_dice?
    end

    def keep_rolling?
    end
  end

  # ConsoleMessenger class outputs messages to console
  class ConsoleMessenger
    def initialize; end
  end
end
