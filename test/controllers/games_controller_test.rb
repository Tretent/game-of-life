require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
  end

  test "uploading large 99x99 grid does not cause overflow" do
    large_grid = build_grid(99, 99)
    file = create_pattern_file(generation: 1, rows: 99, columns: 99, grid: large_grid)

    assert_difference "Game.count", 1 do
      post customize_games_path, params: {
        customize: {
          name: "Large Grid Test",
          initial_state: file
        }
      }
    end

    assert_redirected_to customize_games_path

    draft_game = Game.last
    assert draft_game.draft
    assert_equal "Large Grid Test", draft_game.name
    assert_equal 99, draft_game.rows
    assert_equal 99, draft_game.columns
    assert_equal users(:one), draft_game.user
  end

  test "index only shows non-draft games for current user" do
    user = users(:one)
    user.games.create!(name: "Published", rows: 5, columns: 5, history: [ build_grid(5, 5) ], draft: false)
    user.games.create!(name: "Draft", rows: 5, columns: 5, history: [ build_grid(5, 5) ], draft: true)

    get games_path

    assert_response :success
    assert_select "h2", text: "Published"
    assert_select "h2", text: "Draft", count: 0
  end

  test "index does not show other users games" do
    user = users(:one)
    other_user = users(:two)
    user.games.create!(name: "My Game", rows: 5, columns: 5, history: [ build_grid(5, 5) ], draft: false)
    other_user.games.create!(name: "Other Game", rows: 5, columns: 5, history: [ build_grid(5, 5) ], draft: false)

    get games_path

    assert_response :success
    assert_select "h2", text: "My Game"
    assert_select "h2", text: "Other Game", count: 0
  end

  test "customize POST creates draft game in database" do
    file = create_pattern_file(generation: 3, rows: 4, columns: 8, grid: build_grid(4, 8))

    assert_difference "Game.where(draft: true).count", 1 do
      post customize_games_path, params: {
        customize: {
          name: "Test Game",
          initial_state: file
        }
      }
    end

    draft_game = Game.last
    assert draft_game.draft
    assert_equal 3, draft_game.current_generation
  end



  private

  def build_grid(rows, columns)
    Array.new(rows) { Array.new(columns) { [ true, false ].sample } }
  end

  def create_pattern_file(generation:, rows:, columns:, grid:)
    content = "Generation #{generation}:\n"
    content += "#{rows} #{columns}\n"
    grid.each do |row|
      content += row.map { |cell| cell ? "*" : "." }.join + "\n"
    end

    # simulate file upload
    Rack::Test::UploadedFile.new(
      StringIO.new(content),
      "text/plain",
      original_filename: "pattern.txt"
    )
  end
end
