require "application_system_test_case"

class GamesTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
  end

  test "load example button loads valid pattern file" do
    sign_in_as(@user)
    visit new_game_path
    fill_in "Name", with: "Example Game"

    # Initially Next button should be disabled
    assert_button "Next", disabled: true

    # Click Load example button
    click_button "Load example"

    # Wait for JS validation to complete - button should become enabled
    assert_button "Next", disabled: false, wait: 5

    # Should be able to proceed to customize page
    click_button "Next"
    # Wait for navigation to complete
    assert_selector "h1", text: "Customize game", wait: 5
  end

  test "next button disabled after loading invalid file following valid file" do
    sign_in_as(@user)

    visit new_game_path
    fill_in "Name", with: "Test Game"

    # First, load a valid file
    attach_pattern_file(valid_pattern)
    assert_button "Next", disabled: false, wait: 5

    # Now load an invalid file (wrong column count)
    attach_pattern_file("Generation 1:\n3 3\n...\n.*\n...")
    # Wait for JS validation to complete - error should appear
    assert_file_error "Row 2 has 2 columns, expected 3"
    assert_button "Next", disabled: true
  end

  test "validation error: file must have at least 3 lines" do
    assert_pattern_invalid "Generation 1:\n3 3", "File must have at least 3 lines"
  end

  test "validation error: invalid header format" do
    assert_pattern_invalid "Gen 1:\n3 3\n...\n...\n...", "Invalid header format"
  end

  test "validation error: generation must be at least 1" do
    assert_pattern_invalid "Generation 0:\n3 3\n...\n...\n...", "Generation must be at least 1"
  end

  test "validation error: generation must be less than 1000" do
    assert_pattern_invalid "Generation 1000:\n3 3\n...\n...\n...", "Generation must be less than 1000"
  end

  test "validation error: invalid dimensions format" do
    assert_pattern_invalid "Generation 1:\n3x3\n...\n...\n...", "Invalid dimensions format"
  end

  test "validation error: rows must be at least 1" do
    assert_pattern_invalid "Generation 1:\n0 3\n...", "Rows must be at least 1"
  end

  test "validation error: rows must be less than 100" do
    assert_pattern_invalid "Generation 1:\n100 3\n...", "Rows must be less than 100"
  end

  test "validation error: columns must be at least 1" do
    assert_pattern_invalid "Generation 1:\n3 0\n...", "Columns must be at least 1"
  end

  test "validation error: columns must be less than 100" do
    assert_pattern_invalid "Generation 1:\n3 100\n...", "Columns must be less than 100"
  end

  test "validation error: wrong number of grid rows" do
    assert_pattern_invalid "Generation 1:\n3 3\n...\n...", "Expected 3 grid rows, got 2"
  end

  test "validation error: wrong column count in row" do
    assert_pattern_invalid "Generation 1:\n3 3\n...\n..\n...", "Row 2 has 2 columns, expected 3"
  end

  test "validation error: invalid characters in grid" do
    assert_pattern_invalid "Generation 1:\n3 3\n...\n.X.\n...", "Row 2 contains invalid characters"
  end

  private

  def valid_pattern
    "Generation 1:\n3 3\n...\n.*.\n..."
  end

  def assert_pattern_invalid(content, expected_error)
    sign_in_as(@user)
    visit new_game_path
    fill_in "Name", with: "Test Game"

    attach_pattern_file(content)

    assert_button "Next", disabled: true
    assert_file_error expected_error
  end

  def attach_pattern_file(content)
    @pattern_file = Tempfile.new(%w[pattern .txt])
    @pattern_file.write(content)
    @pattern_file.flush
    @pattern_file.rewind
    attach_file I18n.t("games.new.pattern_file"), @pattern_file.path
    # Ensure the change event fires for Stimulus validation
    page.execute_script("document.querySelector('input[type=file]').dispatchEvent(new Event('change'))")
  end

  def assert_file_error(text)
    assert_selector "[data-pattern-form-target='fileError']", text: text
  end
end
