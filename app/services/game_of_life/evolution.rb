module GameOfLife
  class Evolution
    def initialize(grid)
      @grid = grid || []
      @rows = grid.length
      @columns = grid.first&.length || 0
    end

    def next_generation
      return [] if @rows.zero? || @columns.zero?

      Array.new(@rows) do |row|
        Array.new(@columns) do |col|
          cell_fate(@grid[row][col], count_live_neighbors(row, col))
        end
      end
    end

    def self.next_generation(grid)
      new(grid).next_generation
    end

    private

    def cell_fate(alive, neighbors)
      if alive
        neighbors == 2 || neighbors == 3
      else
        neighbors == 3
      end
    end

    def count_live_neighbors(row, column)
      count = 0
      (-1..1).each do |row_delta|
        (-1..1).each do |column_delta|
          next if row_delta.zero? && column_delta.zero?

          neighbor_row = row + row_delta
          neighbor_column = column + column_delta

          next if neighbor_row.negative? || neighbor_row >= @rows
          next if neighbor_column.negative? || neighbor_column >= @columns

          count += 1 if @grid[neighbor_row][neighbor_column]
        end
      end
      count
    end
  end
end
