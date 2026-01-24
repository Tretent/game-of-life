require "test_helper"

module GameOfLife
  class GridValidatorTest < ActiveSupport::TestCase
    test "validates a correct grid" do
      grid = [
        [ true, false, true ],
        [ false, true, false ]
      ]

      assert GridValidator.validate!(grid, expected_rows: 2, expected_columns: 3)
    end

    test "raises error when grid is not an array" do
      error = assert_raises(GridValidator::ValidationError) do
        GridValidator.validate!("not an array", expected_rows: 2, expected_columns: 3)
      end

      assert_equal "Grid must be an array", error.message
    end

    test "raises error when row count does not match" do
      grid = [
        [ true, false ],
        [ false, true ]
      ]

      error = assert_raises(GridValidator::ValidationError) do
        GridValidator.validate!(grid, expected_rows: 3, expected_columns: 2)
      end

      assert_match(/Grid has 2 rows, expected 3/, error.message)
    end

    test "raises error when row is not an array" do
      grid = [
        [ true, false ],
        "not an array"
      ]

      error = assert_raises(GridValidator::ValidationError) do
        GridValidator.validate!(grid, expected_rows: 2, expected_columns: 2)
      end

      assert_match(/Row 2 must be an array/, error.message)
    end

    test "raises error when column count does not match" do
      grid = [
        [ true, false, true ],
        [ false, true ]
      ]

      error = assert_raises(GridValidator::ValidationError) do
        GridValidator.validate!(grid, expected_rows: 2, expected_columns: 3)
      end

      assert_match(/Row 2 has 2 columns, expected 3/, error.message)
    end

    test "raises error when cell is not a boolean" do
      grid = [
        [ true, false ],
        [ false, "alive" ]
      ]

      error = assert_raises(GridValidator::ValidationError) do
        GridValidator.validate!(grid, expected_rows: 2, expected_columns: 2)
      end

      assert_match(/Cell at row 2, column 2 must be a boolean/, error.message)
    end

    test "raises error when cell is nil" do
      grid = [
        [ true, false ],
        [ false, nil ]
      ]

      error = assert_raises(GridValidator::ValidationError) do
        GridValidator.validate!(grid, expected_rows: 2, expected_columns: 2)
      end

      assert_match(/must be a boolean/, error.message)
    end

    test "raises error when cell is an integer" do
      grid = [
        [ true, false ],
        [ false, 1 ]
      ]

      error = assert_raises(GridValidator::ValidationError) do
        GridValidator.validate!(grid, expected_rows: 2, expected_columns: 2)
      end

      assert_match(/must be a boolean/, error.message)
    end
  end
end
