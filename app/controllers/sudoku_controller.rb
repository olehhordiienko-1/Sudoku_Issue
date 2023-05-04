class SudokuController < ApplicationController
  def home
    @board = generate
    @status
  end

  def submit
    @board = Array.new(9) { Array.new(9, 0) }
    array_params = params.require(:array).permit!
    array_params.to_h.each_with_index do |(_, row), i|
      row.each_with_index do |(_, col), j|
        @board[i][j] = col.to_i
      end
    end

    if params[:solver] == "AUTO"
      solve_auto
    else
      solve_manual
    end
  end

  def solve_manual
    @status = valid_sudoku? @board
  end

  def solve_auto
    solve_sudoku @board
    @status = valid_sudoku? @board
  end

  def solve_sudoku(sudoku)
    row, col = find_empty_cell(sudoku)

    return true if row.nil?

    (1..9).each do |num|
      if valid_move?(sudoku, row, col, num)
        sudoku[row][col] = num

        return true if solve_sudoku(sudoku)

        sudoku[row][col] = 0
      end
    end

    false
  end

  def find_empty_cell(sudoku)
    sudoku.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        return [i, j] if cell == 0
      end
    end
    [nil, nil]
  end

  def valid_move?(sudoku, row, col, num)
    return false if sudoku[row].include?(num)

    return false if sudoku.transpose[col].include?(num)

    square_row = (row / 3) * 3
    square_col = (col / 3) * 3
    square = sudoku[square_row..square_row + 2].map { |r| r[square_col..square_col + 2] }.flatten
    return false if square.include?(num)

    true
  end

  private

  def valid_sudoku?(board)
    board.each do |row|
      return false unless row.uniq.size == 9
    end

    9.times do |j|
      column = board.map { |row| row[j] }
      return false unless column.uniq.size == 9
    end

    3.times do |i|
      3.times do |j|
        square = []
        3.times do |ii|
          3.times do |jj|
            square << board[i * 3 + ii][j * 3 + jj]
          end
        end
        return false unless square.uniq.size == 9
      end
    end

    true
  end

  def generate
    result = Array.new(9) { Array.new(9, 0) }
    lst = Sudoku.new
    lst.get_grid.each_with_index do |value, index|
      row = index / 9
      col = index % 9
      result[row][col] = value
    end
    result
  end
end

