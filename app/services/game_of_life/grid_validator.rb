module GameOfLife
  class GridValidator
    class ValidationError < StandardError; end

    def initialize(grid, expected_rows:, expected_columns:)
      @grid = grid
      @expected_rows = expected_rows
      @expected_columns = expected_columns
    end

    def validate!
      validate_is_array!
      validate_row_count!
      validate_rows!
      true
    end

    def self.validate!(grid, expected_rows:, expected_columns:)
      new(grid, expected_rows: expected_rows, expected_columns: expected_columns).validate!
    end

    private

    def validate_is_array!
      raise ValidationError, "Grid must be an array" unless @grid.is_a?(Array)
    end

    def validate_row_count!
      raise ValidationError, "Grid has #{@grid.length} rows, expected #{@expected_rows}" unless @grid.length == @expected_rows
    end

    def validate_rows!
      @grid.each_with_index do |row, index|
        raise ValidationError, "Row #{index + 1} must be an array" unless row.is_a?(Array)
        raise ValidationError, "Row #{index + 1} has #{row.length} columns, expected #{@expected_columns}" unless row.length == @expected_columns

        row.each_with_index do |cell, col_index|
          unless cell == true || cell == false
            raise ValidationError, "Cell at row #{index + 1}, column #{col_index + 1} must be a boolean"
          end
        end
      end
    end
  end
end