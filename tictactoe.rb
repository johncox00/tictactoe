class GameOverError < StandardError; end
class IllegalMoveError < StandardError; end

class Board
  attr_accessor :board
  def initialize(p1, p2)
    @players = [p1, p2]
    @board = [
      [' ', ' ', ' '],
      [' ', ' ', ' '],
      [' ', ' ', ' ']
    ]
  end

  def show_board
    puts @board.map{|r| r.join('|')}.join("\n-----\n")
    puts ''
  end

  def rows
    @board
  end

  def cols
    [].tap do |a|
      (0..2).each do |x|
        a << [@board[0][x], @board[1][x], @board[2][x]]
      end
    end
  end

  def diags
    [
      [@board[0][0], @board[1][1], @board[2][2]],
      [@board[0][2], @board[1][1], @board[2][0]]
    ]
  end

  def make_move(player, x, y)
    raise GameOverError.new if !@board.flatten.uniq.include?(' ')
    raise IllegalMoveError.new("Cannot move to (#{x}, #{y})") if !legal_move?(x, y)
    @board[x][y] = player.letter
    w = winner
    if w
      puts "WINNER: #{w.letter}"
      show_board
    end
    return w
  end

  def legal_move?(x, y)
    x >= 0 && x < 3 && y >=0 && y < 3 && @board[x][y].blank?
  end

  def winner
    [rows, cols, diags].each do |c|
      there = check_collection(c)
      return there if there
    end
    nil
  end

  def check_collection(collection)
    collection.each do |c|
      there = all_for_one(c)
      return player_of(there) if there
    end
    nil
  end

  def player_of(letter)
    @players.select{|p| p.letter == letter}.first
  end

  def all_for_one(row_col_diag)
    return 'x' if row_col_diag.join('') == 'xxx'
    return 'o' if row_col_diag.join('') == 'ooo'
    false
  end
end

class Player
  attr_accessor :letter
  def initialize(l)
    raise 'Letter must be "x" or "o".' unless ['x', 'o'].include?(l)
    @letter = l
  end

  def choose_move(board)
    if board.board.flatten.uniq == [' ']
      return board.make_move(self, rand(3), rand(3))
    else
      opps_letter = ['x', 'y'].select{|i| i != letter}.first

      [
        [' ', opps_letter, opps_letter],  # do any r, c, d have 2 of the other player's letter and a blank?
        [' ', letter, letter],            # do any rows, cols, diags have 2 of my letter and a blank?
        [' ', ' ', letter]                # do any r, c, d have 1 of my letter and 2 blanks?
      ].each do |condition|
        puts "considering condition #{condition}"
        puts "rows"
        board.rows.each_with_index do |r, i|
          return board.make_move(self, i, r.index(' ')) if should_move?(r, condition)
        end
        puts "columns"
        board.cols.each_with_index do |c, i|
          return board.make_move(self, c.index(' '), i) if should_move?(c, condition)
        end
        puts "diagonals"
        board.diags.each_with_index do |d, i|
          if should_move?(d, condition)
            index = d.index(' ')
            ys = i == 0 ? [0, 1, 2] : [2, 1, 0]
            y = ys[index]
            x = i
            return board.make_move(self, x, y)
          end
        end
      end
      puts "first blank"
      first_blank = board.board.flatten.index(' ') || 0
      return board.make_move(self, first_blank / 3, first_blank % 3)
    end
  end

  def should_move?(collection, condition)
    collection.sort == condition
  end
end

class Game
  def initialize
    @player1 = Player.new('x')
    @player2 = Player.new('o')
    @board = Board.new(@player1, @player2)
  end

  def play
    players = [@player1, @player2]
    cur_player = rand(2)
    start = Time.now
    loop do
      break if Time.now > start + 10.seconds
      puts "#{players[cur_player].letter}'s move...'"
      players[cur_player].choose_move(@board)
      @board.show_board
      cur_player = cur_player == 0 ? 1 : 0
    end
  rescue GameOverError
  end
end
