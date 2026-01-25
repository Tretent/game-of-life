require "test_helper"

class GameTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @game = games(:one)
  end

  # Validations
  test "is valid with valid attributes" do
    game = Game.new(name: "Test Game", rows: 10, columns: 10, user: @user)
    assert game.valid?
  end

  test "requires name" do
    game = Game.new(rows: 10, columns: 10, user: @user)
    assert_not game.valid?
    assert_includes game.errors[:name], "can't be blank"
  end

  test "requires name to be at most 255 characters" do
    game = Game.new(name: "a" * 256, rows: 10, columns: 10, user: @user)
    assert_not game.valid?
    assert_includes game.errors[:name], "is too long (maximum is 255 characters)"
  end

  test "requires rows" do
    game = Game.new(name: "Test", rows: nil, columns: 10, user: @user)
    assert_not game.valid?
    assert game.errors[:rows].any?
  end

  test "requires rows to be greater than 0" do
    game = Game.new(name: "Test", rows: 0, columns: 10, user: @user)
    assert_not game.valid?
    assert_includes game.errors[:rows], "must be greater than 0"
  end

  test "requires rows to be less than 100" do
    game = Game.new(name: "Test", rows: 100, columns: 10, user: @user)
    assert_not game.valid?
    assert_includes game.errors[:rows], "must be less than 100"
  end

  test "requires columns" do
    game = Game.new(name: "Test", rows: 10, columns: nil, user: @user)
    assert_not game.valid?
    assert game.errors[:columns].any?
  end

  test "requires columns to be greater than 0" do
    game = Game.new(name: "Test", rows: 10, columns: 0, user: @user)
    assert_not game.valid?
    assert_includes game.errors[:columns], "must be greater than 0"
  end

  test "requires columns to be less than 100" do
    game = Game.new(name: "Test", rows: 10, columns: 100, user: @user)
    assert_not game.valid?
    assert_includes game.errors[:columns], "must be less than 100"
  end

  # Associations
  test "belongs to user" do
    assert_equal @user, @game.user
  end

  # Instance methods
  test "current_generation returns 0 when history is nil" do
    @game.history = nil
    assert_equal 0, @game.current_generation
  end

  test "current_generation returns history length" do
    @game.history = [ nil, nil, [ [ true, false ], [ false, true ] ] ]
    assert_equal 3, @game.current_generation
  end

  test "current_grid returns nil when history is nil" do
    @game.history = nil
    assert_nil @game.current_grid
  end

  test "current_grid returns last element of history" do
    grid = [ [ true, false ], [ false, true ] ]
    @game.history = [ nil, grid ]
    assert_equal grid, @game.current_grid
  end

  test "advance_generation! appends next generation to history" do
    # blinker
    initial_grid = [
      [ false, true, false ],
      [ false, true, false ],
      [ false, true, false ]
    ]
    @game.history = [ initial_grid ]
    @game.save!

    @game.advance_generation!

    expected_next = [
      [ false, false, false ],
      [ true, true, true ],
      [ false, false, false ]
    ]
    assert_equal 2, @game.current_generation
    assert_equal expected_next, @game.current_grid
  end

  test "reset_to_initial! keeps only elements up to first non-nil" do
    initial_grid = [ [ true, false ], [ false, true ] ]
    @game.history = [ nil, nil, initial_grid, [ [ false, false ], [ false, false ] ] ]
    @game.save!

    @game.reset_to_initial!

    assert_equal [ nil, nil, initial_grid ], @game.history
  end

  test "reset_to_initial! doesn't fail if history is nil" do
    @game.history = nil
    @game.save!

    @game.reset_to_initial!

    assert_nil @game.history
  end

  # Class methods
  test "build_history creates array with nils and grid at end" do
    grid = [ [ true ] ]
    result = Game.build_history(3, grid)
    assert_equal [ nil, nil, grid ], result
  end

  test "build_history with generation 1 returns array with just the grid" do
    grid = [ [ true ] ]
    result = Game.build_history(1, grid)
    assert_equal [ grid ], result
  end

  test "build_history raises error when generation is 0" do
    grid = [ [ true ] ]
    error = assert_raises(ArgumentError) { Game.build_history(0, grid) }
    assert_equal "generation must be greater than 0", error.message
  end

  test "build_history raises error when generation is negative" do
    grid = [ [ true ] ]
    error = assert_raises(ArgumentError) { Game.build_history(-1, grid) }
    assert_equal "generation must be greater than 0", error.message
  end

  test "build_history raises error when generation is 1000 or more" do
    grid = [ [ true ] ]
    error = assert_raises(ArgumentError) { Game.build_history(1000, grid) }
    assert_equal "generation must be less than 1000", error.message
  end

  test "create_draft_from_parse_result creates game with correct attributes" do
    parse_result = {
      generation: 2,
      rows: 4,
      columns: 5,
      grid: [ [ true, false, false, false, false ], [ false, false, false, false, false ], [ false, false, false, false, false ], [ false, false, false, false, false ] ]
    }

    game = Game.create_draft_from_parse_result(
      user: @user,
      name: "Uploaded Pattern",
      result: parse_result
    )

    assert game.persisted?
    assert_equal "Uploaded Pattern", game.name
    assert_equal 4, game.rows
    assert_equal 5, game.columns
    assert_equal [ nil, parse_result[:grid] ], game.history
    assert game.draft
    assert_equal @user, game.user
  end
end
