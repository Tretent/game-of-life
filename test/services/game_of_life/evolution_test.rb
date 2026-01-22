require "test_helper"

module GameOfLife
  class EvolutionTest < ActiveSupport::TestCase
    test "live cell with fewer than 2 neighbors dies (underpopulation)" do
      grid = [
        [ false, false, false ],
        [ false, true,  false ],
        [ false, false, false ]
      ]

      result = Evolution.next_generation(grid)

      assert_equal false, result[1][1]
    end

    test "live cell with 2 neighbors survives" do
      grid = [
        [ true,  false, false ],
        [ false, true,  false ],
        [ false, false, true  ]
      ]

      result = Evolution.next_generation(grid)

      assert_equal true, result[1][1]
    end

    test "live cell with 3 neighbors survives" do
      grid = [
        [ true,  true,  false ],
        [ false, true,  false ],
        [ false, false, true  ]
      ]

      result = Evolution.next_generation(grid)

      assert_equal true, result[1][1]
    end

    test "live cell with more than 3 neighbors dies (overpopulation)" do
      grid = [
        [ true,  true,  true  ],
        [ false, true,  false ],
        [ false, true,  false ]
      ]

      result = Evolution.next_generation(grid)

      assert_equal false, result[1][1]
    end

    test "dead cell with exactly 3 neighbors becomes alive (reproduction)" do
      grid = [
        [ true,  true,  false ],
        [ false, false, false ],
        [ true,  false, false ]
      ]

      result = Evolution.next_generation(grid)

      assert_equal true, result[1][1]
    end

    test "dead cell with 2 neighbors stays dead" do
      grid = [
        [ true,  true,  false ],
        [ false, false, false ],
        [ false, false, false ]
      ]

      result = Evolution.next_generation(grid)

      assert_equal false, result[1][1]
    end

    test "handles non-square grids" do
      grid = [
        [ true,  false, true, false ],
        [ false, true,  false, true ]
      ]

      result = Evolution.next_generation(grid)

      assert_equal 2, result.length
      assert_equal 4, result[0].length
    end

    test "edge cells have no neighbors outside grid (finite grid)" do
      grid = [
        [ true, true ],
        [ true, false ]
      ]

      result = Evolution.next_generation(grid)

      # The top-left cell has 2 neighbours, survives
      assert_equal true, result[0][0]
      # The bottom-right cell has 3 neighbours, becomes alive
      assert_equal true, result[1][1]
    end

    test "blinker pattern oscillates" do
      grid = [
        [ false, true,  false ],
        [ false, true,  false ],
        [ false, true,  false ]
      ]

      result = Evolution.next_generation(grid)

      expected = [
        [ false, false, false ],
        [ true,  true,  true  ],
        [ false, false, false ]
      ]

      assert_equal expected, result
    end

    test "empty grid returns empty grid" do
      grid = []

      result = Evolution.next_generation(grid)

      assert_equal [], result
    end
  end
end
