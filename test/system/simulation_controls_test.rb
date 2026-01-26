require "application_system_test_case"

class SimulationControlsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @game = games(:blinker)
  end

  test "initial button states: play, next, reset enabled; pause disabled" do
    sign_in_as(@user)
    visit game_path(@game)

    assert_button "Play", disabled: false
    assert_button "Pause", disabled: true
    assert_button "Next", disabled: false
    assert_button "Reset", disabled: false
  end

  test "next button advances generation by one" do
    sign_in_as(@user)
    visit game_path(@game)

    assert_selector "#generation_count", text: "1"

    click_button "Next"

    assert_selector "#generation_count", text: "2"
  end

  test "next button evolves blinker pattern" do
    sign_in_as(@user)
    visit game_path(@game)

    # Initial state: vertical blinker (column of 3)
    within ".game-grid" do
      assert_selector "tr:nth-child(1) td:nth-child(2).alive"
      assert_selector "tr:nth-child(2) td:nth-child(2).alive"
      assert_selector "tr:nth-child(3) td:nth-child(2).alive"
    end

    click_button "Next"

    # After one generation: horizontal blinker (row of 3)
    within ".game-grid" do
      assert_selector "tr:nth-child(2) td:nth-child(1).alive"
      assert_selector "tr:nth-child(2) td:nth-child(2).alive"
      assert_selector "tr:nth-child(2) td:nth-child(3).alive"
    end
  end

  test "reset button returns to initial generation" do
    sign_in_as(@user)
    visit game_path(@game)

    # Advance a few generations (wait for each Turbo response)
    click_button "Next"
    assert_selector "#generation_count", text: "2"
    click_button "Next"
    assert_selector "#generation_count", text: "3"

    click_button "Reset"

    assert_selector "#generation_count", text: "1"
  end

  test "reset restores original grid pattern" do
    sign_in_as(@user)
    visit game_path(@game)

    click_button "Next"

    # Wait for Turbo response - after next: horizontal blinker
    within ".game-grid" do
      assert_selector "tr:nth-child(2) td:nth-child(1).alive"
      assert_selector "tr:nth-child(2) td:nth-child(2).alive"
      assert_selector "tr:nth-child(2) td:nth-child(3).alive"
    end

    click_button "Reset"

    # Wait for Turbo response - after reset: back to vertical blinker
    within ".game-grid" do
      assert_selector "tr:nth-child(1) td:nth-child(2).alive"
      assert_selector "tr:nth-child(2) td:nth-child(2).alive"
      assert_selector "tr:nth-child(3) td:nth-child(2).alive"
      assert_selector "tr:nth-child(2) td:nth-child(1).dead"
    end
  end

  test "play button starts auto-advancing and disables other controls" do
    sign_in_as(@user)
    visit game_path(@game)

    click_button "Play"

    # During play: only pause is enabled
    assert_button "Play", disabled: true
    assert_button "Pause", disabled: false
    assert_button "Next", disabled: true
    assert_button "Reset", disabled: true
  end

  test "pause button stops auto-advancing and re-enables controls" do
    sign_in_as(@user)
    visit game_path(@game)

    click_button "Play"
    assert_button "Pause", disabled: false  # Wait for play state
    click_button "Pause"

    # After pause: play, next, reset enabled; pause disabled
    assert_button "Play", disabled: false
    assert_button "Pause", disabled: true
    assert_button "Next", disabled: false
    assert_button "Reset", disabled: false
  end

  test "play auto-advances generation after interval" do
    sign_in_as(@user)
    visit game_path(@game)

    assert_selector "#generation_count", text: "1"

    click_button "Play"

    # Play immediately advances, then waits 1 second for next
    assert_selector "#generation_count", text: "2"

    # Wait for auto-advance
    sleep 1.2
    generation = find("#generation_count").text.to_i
    assert generation >= 3, "Expected generation >= 3 after auto-play, got #{generation}"

    click_button "Pause"
  end

  test "pause then reset returns to initial state" do
    sign_in_as(@user)
    visit game_path(@game)

    click_button "Play"
    assert_button "Pause", disabled: false  # Wait for play state

    # Must pause first since reset is disabled during playback
    click_button "Pause"
    assert_button "Reset", disabled: false  # Wait for pause state
    click_button "Reset"

    # After reset: controls should be back to initial state
    assert_button "Play", disabled: false
    assert_button "Pause", disabled: true
    assert_selector "#generation_count", text: "1"
  end
end
