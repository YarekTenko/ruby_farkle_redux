# Farkle class represents the dice game Farkle
class Farkle
  # Player class contains all the player information
  class Player
    attr_reader   :id
    attr_accessor :score
    attr_accessor :inter_score

    def initialize(id)
      @id          = id
      @score       = 0
      @inter_score = 0
    end
  end

  # Dice class emulates dice and die rolling
  class Dice
    attr_accessor :d_num
    attr_accessor :first_roll

    def initialize(d_num)
      @d_num = d_num
      @first_roll = true
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
      leading_players.size == 1 ? GAME_FINISHED : GAME_CONTINUES 
    end

    def leading_players
      @players.group_by { |p| p.score >= win_score }.max.last
    end

    def do_rounds
      players.each do |player|
        next if turn_finished?(player)
      end
    end

    def turn_finished?(player)
      dice = Dice.new(@d_num)
      farkled?(result) ? lost(player) : gained(player, result, dice)
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

    def lost(player)
      player.score = player.inter_score
    end

    def gained(player, result, dice)
      dice.first_roll ? hot_dice(player, result) : keep_rolling(player)
    end

    def hot_dice(player, result, dice)
      hd = roll_hash(result).map { |k, v| scored?(k, v.size) }.all?
      hd ? calc_result(player, result, dice) : keep_rolling
    end

    def calc_result(player, result)
      player.score += calc_roll_score(result)
    end

    def calc_roll_score(result)
      result.map do |roll|
        case roll
        when 1
          set_of_three?(result, roll) ?        800 : 100
        when 5
          set_of_three?(result, roll) ?        500 : 50
        else
          set_of_three?(result, roll) ? roll * 100 : 0
        end
      end.sum
    end

    def set_of_three?(result, roll)
      roll_hash(result)[roll].size % 3
    end

    def keep_rolling
      (@d_num -= 1).zero? ? TURN_OVER : bank_or_continue
    end

    def bank_or_continue
    end
  end

  # ConsoleMessenger class outputs messages to console
  class ConsoleMessenger
    def initialize; end
  end

  TURN_OVER      = true
  GAME_FINISHED  = true
  GAME_CONTINUES = false
end
