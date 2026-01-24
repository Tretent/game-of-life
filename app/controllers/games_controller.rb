class GamesController < ApplicationController
  before_action :set_game, only: %i[ show destroy next_generation reset ]

  def index
    @games = Current.user.games.where(draft: false)
  end

  def new
    cleanup_abandoned_draft
  end

  def create
    @game = Current.user.games.find_by(id: session[:draft_game_id], draft: true)
    unless @game
      redirect_to new_game_path
      return
    end

    grid = JSON.parse(create_params[:grid])
    GameOfLife::GridValidator.validate!(grid, expected_rows: @game.rows, expected_columns: @game.columns)

    @game.history = Game.build_history(@game.current_generation, grid)
    @game.draft = false

    if @game.save
      session.delete(:draft_game_id)
      redirect_to @game
    else
      @draft = draft_data_from_game(@game)
      render :customize, status: :unprocessable_entity
    end
  rescue GameOfLife::GridValidator::ValidationError => e
    @draft = draft_data_from_game(@game)
    @error = e.message
    render :customize, status: :unprocessable_entity
  end

  def show
  end

  def destroy
    @game.destroy
    redirect_to games_path, status: :see_other
  end

  def customize
    if request.post?
      handle_customize_post
    else
      handle_customize_get
    end
  end

  def next_generation
    @game.advance_generation!
  end

  def reset
    @game.reset_to_initial!
  end

  private

  def set_game
    @game = Current.user.games.find(params[:id])
  end

  def handle_customize_post
    result = GameOfLife::PatternParser.parse_file(customize_params[:initial_state])

    cleanup_abandoned_draft
    @game = Game.create_draft_from_parse_result(
      user: Current.user,
      name: customize_params[:name],
      result: result
    )

    session[:draft_game_id] = @game.id
    redirect_to customize_games_path
  rescue GameOfLife::PatternParser::ParseError => e
    @error = e.message
    render :new, status: :unprocessable_entity
  end

  def handle_customize_get
    @game = Current.user.games.find_by(id: session[:draft_game_id], draft: true)
    unless @game
      redirect_to new_game_path
      return
    end

    @draft = draft_data_from_game(@game)
  end

  def draft_data_from_game(game)
    {
      "name" => game.name,
      "generation" => game.current_generation,
      "rows" => game.rows,
      "columns" => game.columns,
      "grid" => game.current_grid
    }
  end

  def cleanup_abandoned_draft
    Current.user.games.where(id: session[:draft_game_id], draft: true).destroy_all
    session.delete(:draft_game_id)
  end

  def customize_params
    params.expect(customize: [ :name, :initial_state ])
  end

  def create_params
    params.expect(create: [ :grid ])
  end
end
