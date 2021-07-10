require 'csv'

def parse_dictionary(file)
  words = file.select { |word| word.length.between?(7, 14) }
  dic = words.map { |word| word[0..-3] }
end

def check_result(result, secret_word, guesses)
  secret_word.chars.each_with_index do |letter, index|
    guesses.chars.each do |guess|
      result[index] = guess if guess == letter
    end
  end
  result
end

def check_status(tries, result, secret_word)
  if tries >= 8
    puts 'You have run out of tries'
    return true
  elsif result == secret_word
    puts 'Congratulations, you win'
    return true
  end
  false
end

def validate_guess(guess)
  alpha = [*'a'..'z'].join
  if guess.size != 1
    puts 'Please enter only one alphabet'
    false
  elsif alpha.include?(guess) == false
    puts 'Please enter only alphabets'
    false
  else
    true
  end
end

def check_guesses(guess, guesses)
  if guesses.include? guess
    puts "You have already guessed #{guess}.  Try again"
    false
  else
    true
  end
end

def save_game(guesses, tries, result, secret_word)
  column_header = %w[guesses tries result secret_word]
  data = [guesses, tries, result, secret_word]
  save_file = 'save.csv'
  CSV.open(save_file, 'w',
           write_headers: true,
           headers: column_header) do |hdr|
    column_header = nil
    hdr << data
  end
  puts 'Game saved'
end

def load_saved_game
  contents = CSV.open(
    'save.csv', 'a+',
    headers: true,
    header_converters: :symbol
  )
end

filename = '5desk.txt'
file = File.open(filename, 'r')
dic = parse_dictionary(file)
secret_word = dic.sample.downcase
guess = ''
guesses = ''
result = '-' * secret_word.size
tries = 0
save = false

puts "\e[H\e[2J"
puts '[1] for new game, [2] for saved game'
game_choice = gets.chomp

if game_choice == '1'
  puts "\r\nThe word to guess has #{secret_word.size} letters:  #{result}"
else
  contents = load_saved_game
  contents.each do |row|
    guesses = row[:guesses]
    tries = row[:tries].to_i
    result = row[:result]
    secret_word = row[:secret_word]
  end
  puts "\r\nThe word to guess has #{secret_word.size} letters:  #{result}"
end

loop do
  break if check_status(tries, result, secret_word)

  puts "\r\nYour turn to guess one letter in the secret word. Press 1 to save game"
  puts "Attempts:#{tries}   Remaining Attempts:#{8 - tries}   Your guesses: #{guesses}"
  guess = gets.chomp.downcase

  if guess == '1'
    save_game(guesses, tries, result, secret_word)
    save = true
    break
  elsif validate_guess(guess) == false
    next
  end

  check_guesses(guess, guesses) ? guesses += guess : next

  puts "\e[H\e[2J"
  if secret_word.include? guess
    result = check_result(result, secret_word, guesses)
  else
    puts "\r\nGuess does not match any letters"
    tries += 1
  end

  puts "\r\nYour guess is #{result}"
end

puts "The word to guess is #{secret_word}" if save == false
