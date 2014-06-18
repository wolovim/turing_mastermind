require './lib/game_repl'
require './lib/code_generator'
require './lib/code_matcher'
require './lib/guess_builder'
require './lib/code_matcher'
require 'colored'
require 'pry'

class Game
  attr_reader :time_start, :guess, :correct_letter, :counter, :guesses, :code_word

  def initialize
    @guess = ""
    @correct_letter = []
    @counter = 20
    @guesses = []
    # @code_word
  end

##################( Gameplay )##################
  def play
    generate_a_code
    @time_start = Time.now
    while @code_word.secret_code != @matched_position && @counter >= 0
      print_im_thinking
      build_a_guess # until guess_is_valid?
      match_a_guess
      print_guess_results
    end
    print_game_over_scenarios
  end

##################( Gameplay Methods )##################
  def generate_a_code
    validate_user_diff
    gen = CodeGenerator.new(@diff)
    @code_word = gen.generate_code
  end

  def validate_user_diff
    @diff = GameREPL.new.validate_difficulty
  end

  def build_a_guess
    # validate_guess_input
    @guess = GuessBuilder.new(gets.chomp.downcase).make_guess #pass in @g
    until guess_is_valid?
      puts "Your guess must be #{@code_word.code_length} letters. Try again.\n".red
      @guess = GuessBuilder.new(gets.chomp.downcase).make_guess #pass in @g
    end
    @guesses << @guess.string_guess
  end

  def guess_is_valid?
    @guess.formatted_guess.length == @code_word.code_length
  end

  def validate_guess_input
    @g = GameREPL.new.validate_guess
  end

  def match_a_guess
    matcher = CodeMatcher.new(@guess.formatted_guess, @code_word.secret_code)
    @matched_letter = matcher.count_correct_letter
    @matched_position = matcher.count_correct_position
  end

##################( Gameplay Assets )##################
  def print_im_thinking
    border
    print "
  I'm thinking of a #{@code_word.secret_code.count} letter combination. What is it?
  There may be duplicate letters. #{diff_choice}" # => change for diff lvls
    border_bottom
  end

  def border
    print "
=======================================================".blue
  end

  def border_bottom
    puts "
=======================================================".blue
  end

  def diff_choice
    case @diff
    when "easy"
      "Choices: RGBY"
    when "medium"
      "Choices: RGBYW"
    when "hard"
      "Choices: RGBYWP"
    end
  end

  def print_guess_results
    puts "You guessed #{@matched_letter.count} out of #{@code_word.secret_code.count} correct letters!"
    puts "Letters in the correct position: #{@matched_position.count}"
    puts "(#{@counter} turns remaining)".red
    puts "Your guesses: #{@guesses}"
    @counter -= 1
  end

  def print_game_over_scenarios
    @time_end = Time.now
    # Game lost:
    if @counter < 0
      puts "\nAw too bad. You used all your turns up in #{converts_time}. The correct answer was #{@code_word.secret_code}. Try again!".red
    # Game won:
    elsif @matched_position == @code_word.secret_code
      puts "\nCongratulations! You won with #{guess_count} guesses in #{converts_time}! The winning combination was #{@code_word.secret_code}.".red
    # Testing: did a game end with any other conditions?
    else
      puts "How did you escape?"
    end
  end

  def converts_time
    total_time = @time_end - @time_start
    @minutes = total_time.to_i / 60
    @seconds = total_time.to_i % 60
    "#{@minutes} minutes and #{@seconds} seconds"
  end

  def guess_count
    @guesses.count
  end

end

if __FILE__ == $0
  GameREPL.new.start
end
