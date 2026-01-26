require "application_system_test_case"

class GridEditorTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
  end

  test "clicking a dead cell toggles it to alive" do
    create_draft_and_visit_customize

    # Find a dead cell and click it
    dead_cell = find(".game-grid td.dead", match: :first)
    dead_cell.click

    # Cell should now be alive
    assert dead_cell[:class].include?("alive"), "Cell should be alive after click"
    assert_not dead_cell[:class].include?("dead"), "Cell should not be dead after click"
  end

  test "clicking an alive cell toggles it to dead" do
    create_draft_and_visit_customize

    # Find an alive cell and click it
    alive_cell = find(".game-grid td.alive", match: :first)
    alive_cell.click

    # Cell should now be dead
    assert alive_cell[:class].include?("dead"), "Cell should be dead after click"
    assert_not alive_cell[:class].include?("alive"), "Cell should not be alive after click"
  end

  test "multiple cell toggles work correctly" do
    create_draft_and_visit_customize

    # Toggle same cell twice - should return to original state
    cell = find(".game-grid td.dead", match: :first)

    cell.click
    assert cell[:class].include?("alive")

    cell.click
    assert cell[:class].include?("dead")
  end

  test "cell changes persist when creating game" do
    create_draft_and_visit_customize

    # Toggle a specific cell
    cell = find(".game-grid tr:first-child td:first-child")
    was_alive = cell[:class].include?("alive")
    cell.click

    click_button "Create game"

    # Verify we're on the show page and cell state persisted
    assert_selector "h1", text: "Test Pattern"

    first_cell = find(".game-grid tr:first-child td:first-child")
    if was_alive
      assert first_cell[:class].include?("dead"), "Cell should be dead after toggle"
    else
      assert first_cell[:class].include?("alive"), "Cell should be alive after toggle"
    end
  end

  private

  def create_draft_and_visit_customize
    sign_in_as(@user)
    visit new_game_path

    # Attach file first, then fill name - avoids race condition where
    # async validateFile() calls updateSubmitState() before name is set
    attach_pattern_file("Generation 1:\n3 3\n.*.\n.*.\n.*.")
    fill_in "Name", with: "Test Pattern"

    # Wait for JS validation and submit
    assert_button "Next", disabled: false
    click_button "Next"

    # Should redirect to customize page
    assert_selector "h1", text: "Customize game"
  end

  def attach_pattern_file(content)
    file = Tempfile.new(%w[pattern .txt])
    file.write(content)
    file.rewind
    attach_file I18n.t("games.new.pattern_file"), file.path
  end
end
