# Hangman

# A hangman game played against the computer on the command line.  Features
# game saving/loading functionality.

require 'yaml'

class Hangman

  def initialize
    @guesses_left = 10
    @secret_word = ""
    @blanks = []
    @missed_letters = []
    @already_guessed = []
    @guess = ""
  end

  def start_game
    Dir.mkdir("save") unless Dir.exists? "save"
    puts ""
    puts "Welcome to Hangman!"
    puts ""
    game_choice
    puts ""
    puts "Try to guess the secret word. You have #{@guesses_left} guesses."
    get_word
    puts @secret_word
    create_blanks
    take_turn
  end

  protected

  def take_turn
    until @guesses_left == 0 || @blanks.eql?(@secret_word)
      display_board
      get_guess
      check_guess
      if @guesses_left == 0
        puts "You have run out of guesses. The secret word was '#{@secret_word}'. Game Over."
        play_again?
      elsif @blanks.eql?(@secret_word)
        puts "You have correctly guessed the secret word! It was '#{@secret_word}'."
        play_again?
      end
    end
  end

  private

  def game_choice
    print "Would you like to load a saved game? (Please enter 'y' if you would). "
    choice = gets.chomp
    if choice.include? "y"
      load_game
    end
  end

  def play_again?
    print "Do you want to play again? "
    entry = gets.downcase
    if entry.include? "y"
      puts ""
      game = Hangman.new
      game.start_game
    end
  end

  def get_word
    dictionary_file = '5desk.txt'
    dictionary = File.readlines(dictionary_file)
    until @secret_word.length > 5 && @secret_word.length < 12
      @secret_word = dictionary.sample.rstrip.downcase
    end
    @secret_word
  end

  def create_blanks
    @blanks = "_" * @secret_word.length
  end

  def display_board
    puts "Type 'save' to save and quit your game."
    puts "Guesses left: #{@guesses_left}    Incorrect letters: #{@missed_letters}"
    puts @blanks.scan(/./).join(" ")
    puts ""
  end

  def get_guess
    @guess = ""
    until @guess.match(/^[a-z]$/) && !@already_guessed.include?(@guess)
      print "Please enter a letter. "
      @guess = gets.chomp.downcase
      if @guess == 'save'
        save_game
      elsif @already_guessed.include?(@guess)
        puts "You have already guessed that letter. Please try again."
      elsif !@guess.match(/^[a-z]$/)
        puts "That is not a valid guess. Please enter a single letter."
      end
    end
    @guess
  end

  def check_guess
    @already_guessed.push(@guess)
    if @secret_word.include?(@guess)
      @secret_word.split("").each_with_index do |letter, index|
        if letter == @guess
          @blanks[index] = letter
        end
      end
    else
      @guesses_left -= 1
      @missed_letters.push(@guess)
    end
    @blanks
  end

  def save_game
    Dir.chdir("save")
    File.open("save.txt", 'w') { |file| file.write(YAML::dump(self))}
    puts "Game Saved!"
    Dir.chdir("..")
    exit
  end

  def load_game
    Dir.chdir("save")
    if File.exist?("save.txt")
      game = YAML::load(File.read("save.txt"))
      puts "Game Loaded!"
      puts ""
      Dir.chdir("..")
      game.take_turn
    else
      puts "You have no saved games."
      Dir.chdir("..")
    end
  end
end

game = Hangman.new
game.start_game
