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
    attr_reader   :score_to_win
    attr_reader   :d_num
    attr_accessor :players

    def initialize(p_num, d_num, score_to_win)
      @players   = Array.new(p_num) { |n| Player.new(n + 1) }
      @score_to_win = score_to_win
      @d_num = d_num
    end

    def game_finished?
      leading_players.size == 1 ? GAME_FINISHED : GAME_CONTINUES
    end

    def leading_players
      @players.group_by { |p| p.score >= score_to_win }.max.last
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

    def roll_dice
      Dice.new(@d_num)
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

    def keep_rolling(player)
      (@d_num -= 1).zero? ? TURN_OVER : bank_or_roll?(decision, player)
    end

    def bank_or_roll?(decision, player)
      if decision == BANK
        player.inter_score = player.score
        TURN_OVER
      else
        ROLL
      end
    end
  end

  # ConsoleInterface class plays the game in console
  class ConsoleInterface
    def initialize(game)
      @g = game
    end

    def play
      notify_welcome
      gets.chomp
      do_rounds until @g.game_finished?
      notify_winner
    end

    def do_rounds
      @g.players.each do |player|
        roll = @g.roll_dice
        @g.farkled?(roll) ? notify_lost(player) : notify_gained(player, roll)
        # next if turn_finished?(player)
      end
    end

    def notify_winner; end

    def notify_lost(player)
    end

    def notify_gained(player, roll)
    end

    def notify_welcome
      puts 'Welcome to Farkle'
      puts "Number of players: #{@g.players.size}"
      puts "Number of dice   : #{@g.d_num}"
      puts "Score to win     : #{@g.score_to_win}"
    end
  end

  TURN_OVER      = true
  GAME_FINISHED  = true
  BANK           = true
  GAME_CONTINUES = false
  ROLL           = false

  def initialize(p_num, d_num, score_to_win)
    game = Game.new(p_num, d_num, score_to_win)
    @ci  = ConsoleInterface.new(game)
  end

  def play_in_console
    @ci.play
  end
end

farkle_game = Farkle.new(2, 5, 1000)
farkle_game.play_in_console
