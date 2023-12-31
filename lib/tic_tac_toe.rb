require 'colorize'
require_relative './output'
require "byebug"

class TicTacToe
  PLAYER_X = "X"
  PLAYER_O = "O"

  # key signals as read from input
  RIGHT_ARROW = "\e[C"
  LEFT_ARROW = "\e[D"
  UP_ARROW = "\e[A"
  DOWN_ARROW = "\e[B"

  # list all possible winning combinations
  COMBINATIONS = [
    [[0, 0], [0, 1], [0, 2]], # top row
    [[1, 0], [1, 1], [1, 2]], # middle row
    [[2, 0], [2, 1], [2, 2]], # bottom row
    [[0, 0], [1, 0], [2, 0]], # left column
    [[0, 1], [1, 1], [2, 1]], # middle column
    [[0, 2], [1, 2], [2, 2]], # right column
    [[0, 0], [1, 1], [2, 2]], # diagonal from top left
    [[0, 2], [1, 1], [2, 0]]  # diagonal from top right
  ]

  attr_accessor :last_player_played, :winner

  def initialize
    @board = Array.new(3) { Array.new(3, ' ') } # empty board
    @cursor_x = 0 # initial cursor X
    @cursor_y = 0 # initial cursor Y
    set_cursor(@cursor_x, @cursor_y) # place cursor into those coords
  end

  # use this method to move cursor arround
  # accepts signals from keyboard
  def make_move(input)
    case input
    when RIGHT_ARROW
      set_cursor(@cursor_x + 1, @cursor_y)
    when LEFT_ARROW
      set_cursor(@cursor_x - 1, @cursor_y)
    when UP_ARROW
      set_cursor(@cursor_x, @cursor_y - 1)
    when DOWN_ARROW
      set_cursor(@cursor_x, @cursor_y + 1)
    else
      # skip, don't do anything, we have no idea how to handle that O_O
    end
  end

  # returns true if game is done!
  def finished?
    won? || draw?
  end

  # render to Output
  # as of now this is just terminal
  def render
    if won?
      Output.write "\n\n\t#{winner_text} \n\n"
    elsif draw?
      Output.write "\n\n\t#{draw_text}\n\n"
    else
      Output.write "Current player is: #{current_player} \n\r#{print_board}"
    end
  end

  def display_winner
    Output.write_new_line "\n\n\t#{winner_text} \n\n"
  end

  def commit_move
    commit_move_as_human

    display_winner if finished?

    make_move_as_ai

    display_winner if finished?
  end

  # commit current cursor position
  # If the cell is occupied - there is nothing we can unfortunately
  def commit_move_as_human
    return if cell_occupied?(@board[@cursor_y][@cursor_x])

    @board[@cursor_y][@cursor_x] = current_player
    @last_player_played = current_player
  end

  def make_move_as_ai
    is_cell_available = false

    random_x_id = nil
    random_y_id = nil

    while !is_cell_available
      random_y_id, random_x_id = next_ai_move_coords

      cell_value = @board[random_y_id][random_x_id]

      is_cell_available = !cell_occupied?(cell_value)
    end

    @board[random_y_id][random_x_id] = PLAYER_O
    @last_player_played = PLAYER_O
  end

  def selected_valid_ai_combinations
    COMBINATIONS.reject do |winning_combo|
      # [[0, 0], [0, 1], [0, 2]]
      winning_combo.any? do |y, x| # reject if cell is occupied by player X
        cell_occupied_by_player?(
          cell_value_by_coords(x, y), PLAYER_X
        )
      end
    end
  end

  def next_ai_move_coords
    combos = selected_valid_ai_combinations.group_by do |combo|
      # [[0, 0], [0, 1], [0, 2]]
      combo.count do |y, x|
        cell_occupied_by_player?(
          cell_value_by_coords(x, y), PLAYER_O
        )
      end
    end

    # 2 => [ [0, 0], [0, 1], [0, 2], [0, 0], [0, 1], [0, 2], ]

    max_combos = combos[combos.keys.max]

    combination = max_combos.sample
    next_combo = combination.find do |y, x|
      cell_value_by_coords(x, y) == ' '
    end

    next_combo
  end

  private

  # current player is always the one that is not the one who commited last move
  def current_player
    case @last_player_played
    when PLAYER_X
      PLAYER_O
    when PLAYER_O
      PLAYER_X
    else # at the beginning of the game it will be X
      PLAYER_X
    end
  end

  def print_cursor
    current_player.colorize(:red)
  end

  # check if the cell is not outside of the boundaries
  def can_move_to?(x, y)
    x <= 2 && x >= 0 && y >= 0 && y <= 2
  end

  def set_cursor(x, y)
    return unless can_move_to?(x, y)

    wipe_cursor # remove cursor from prev position

    @cursor_x = x
    @cursor_y = y
    @board[y][x] = "#{@board[y][x]}#{print_cursor}".squeeze.lstrip # move it to the next cell
  end

  def wipe_cursor
    @board[@cursor_y][@cursor_x].delete_suffix!(print_cursor)

    if @board[@cursor_y][@cursor_x].size == 0
      @board[@cursor_y][@cursor_x] = " "
    end

    @board[@cursor_y][@cursor_x].squeeze
  end

  def print_board
    buff = ""
    @board.each_with_index do |row, i|
      buff << " #{row.join(' | ')}\n\r"
      buff << "---+---+---\n\r" unless i == 2
    end
    buff
  end

  def draw?
    @board.flatten.none? { |cell| [' ', print_cursor].include? cell }
  end

  def won?
    COMBINATIONS.any? do |combo|
      combo.all? { |row, col| @board[row][col] == @last_player_played }
    end
  end

  def winner_text
    "#{@last_player_played.blue.on_red.blink} WOOON!\nCongratulations!".blue.on_red.blink
  end

  def draw_text
    "It's a DRAW. Good job!".blue.on_red.blink
  end

  def cell_value_by_coords(x, y)
    @board[y][x]
  end

  def cell_occupied?(val)
    val.start_with?(PLAYER_O) || val.start_with?(PLAYER_X)
  end

  def cell_occupied_by_player?(cell_val, player_alias)
    cell_val.start_with?(player_alias)
  end
end
