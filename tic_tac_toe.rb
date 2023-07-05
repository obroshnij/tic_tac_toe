require 'io/console'
require 'colorize'
require './lib/tic_tac_toe'

SIG_BREAK = "\u0003" # ctrl + c
SIG_RETURN = "\r" # return

game = TicTacToe.new # initialize a new game

loop do
  game.render # re-render the board after iteration

  break if game.finished?

  # since it's a bit cumbersome to read one character at at time from input when user is using arrow keys
  # we would instead use this trick
  option = $stdin.raw { |io| io.readpartial(100) }

  break if option == SIG_BREAK

  if option == SIG_RETURN # user commited a move
    game.commit_move
    next
  end

  game.make_move(option) # user moves the cursor
end

