# Farkle class represents the dice game Farkle
class Farkle
  # Player class contains all the player information
  class Player
    attr_reader   :id
    attr_accessor :score
    attr_accessor :inter_score
    attr_accessor :first_roll

    def initialize(id)
      @id          = id
      @score       = 0
      @inter_score = 0
      @first_roll  = true
    end
  end

  # Dice class emulates dice and die rolling
  class Dice
    attr_accessor :d_num

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
    attr_reader   :score_to_win
    attr_reader   :d_num
    attr_accessor :players
    attr_accessor :round

    def initialize(p_num, d_num, score_to_win)
      @players      = Array.new(p_num) { |n| Player.new(n + 1) }
      @score_to_win = score_to_win
      @d_num        = d_num
      @round        = 0
    end

    def game_finished?
      only_one = leading_players.size == 1
      winning_score = leading_players.first.score >= @score_to_win
      only_one && winning_score ? true : false
    end

    def leading_players
      @players.group_by(&:score).max.last
    end

    def roll_dice(d_num)
      Dice.new(d_num).roll
    end

    def farkled?(result)
      roll_hash(result).each { |k, v| break false if scored?(k, v.size) }
    end

    def scored?(k, v)
      (v % 3).zero? || k == 1 || k == 5
    end

    def roll_hash(result)
      result.group_by { |i| i }
    end

    def lost(player)
      player.score      = player.inter_score
      player.first_roll = true
    end

    def gained(player, result)
      calc_result(player, result) - player.inter_score
    end

    def hot_dice?(roll)
      roll_hash(roll).map { |k, v| scored?(k, v.size) }.all?
    end

    def calc_result(player, result)
      player.score += calc_roll_score(result)
    end

    def calc_roll_score(result)
      rh = Hash.new(0)
      result.map do |roll|
        rh[roll]    += 1
        set_of_three = (rh[roll] % 3).zero?
        add_score(roll, set_of_three)
      end.sum
    end

    def add_score(roll, set_of_three)
      case roll
      when 1
        set_of_three ?        800 : 100
      when 5
        set_of_three ?        400 : 50
      else
        set_of_three ? roll * 100 : 0
      end
    end

    def bank(player)
      player.inter_score = player.score
      player.first_roll  = true
    end
  end

  # ConsoleInterface class plays the game in console
  class ConsoleInterface
    def initialize(game)
      @g = game
    end

    def play
      notify_welcome
      do_rounds until @g.game_finished?
      notify_winner
    end

    def do_rounds
      notify_round
      @g.players.each do |player|
        notify_current_player(player)
        process_turn(player, @g.d_num)
        notify_turn_finished(player)
      end
    end

    def process_turn(player, d_num)
      notify_roll_result(roll = @g.roll_dice(d_num))
      @g.farkled?(roll) ? lost(player) : gained(player, roll)
    end

    def lost(player)
      @g.lost(player)
      notify_lost(player)
    end

    def gained(player, roll)
      notify_roll_score(roll)
      notify_gained(player, @g.gained(player, roll))
      hd = player.first_roll && @g.hot_dice?(roll)
      hd ? hot_dice(player) : continue(player, roll)
    end

    def hot_dice(player)
      puts '!HOT DICE!'
      puts 'Rolling again...'
      gets.chomp
      nr = @g.roll_dice(@g.d_num)
      notify_roll_result(nr)
      gained(player, nr)
    end

    def continue(player, roll)
      print 'Keep rolling? (y/n) >> '
      case gets.chomp.downcase
      when 'y'
        notify_continue(player)
        process_turn(player, roll.size - 1)
      else
        bank(player)
      end
    end

    def bank(player)
      @g.bank(player)
      notify_banked(player)
    end

    def notify_round
      puts '************************************'
      puts "Round #{@g.round += 1}"
    end

    def notify_roll_score(roll)
      puts "Gain from the roll   : #{@g.calc_roll_score(roll)}"
    end

    def notify_turn_finished(player)
      puts "Player #{player.id} finished his turn"
      puts '------------------------------------'
    end

    def notify_winner
      puts "\n$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
      puts "Player #{@g.leading_players.last.id} won!"
      puts "Final score          : #{@g.leading_players.last.score}"
    end

    def notify_current_player(player)
      puts '------------------------------------'
      puts "Player #{player.id} turn"
    end

    def notify_roll_result(roll)
      puts "You rolled           : #{roll}"
      gets.chomp
    end

    def notify_banked(player)
      puts "Player #{player.id} banked his score"
    end

    def notify_continue(player)
      puts "Player #{player.id} continues to roll with -1 die!"
      puts ''
    end

    def notify_lost(player)
      puts 'Woops, looks like you FARKLE\'d!'
      notify_score(player)
      gets.chomp
    end

    def notify_gained(player, gain)
      puts "Total gain this round: #{gain}"
      notify_score(player)
    end

    def notify_score(player)
      puts "Your current score is: #{player.score}"
    end

    def notify_welcome
      puts 'Welcome to Farkle'
      puts "Number of players: #{@g.players.size}"
      puts "Number of dice   : #{@g.d_num}"
      puts "Score to win     : #{@g.score_to_win}"
      gets.chomp
    end
  end

  def initialize(p_num, d_num, score_to_win)
    game = Game.new(p_num, d_num, score_to_win)
    @ci  = ConsoleInterface.new(game)
  end

  def play_in_console
    @ci.play
  end
end

farkle_game = Farkle.new(2, 5, 300)
farkle_game.play_in_console
