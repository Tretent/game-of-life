class GamesController < ApplicationController
  before_action :set_game, only: %i[ show destroy ]

  def index
    @games = Current.user.games.where(draft: false)
  end

  def new
    # Clean up any abandoned draft when starting a new game
    Current.user.games.where(id: session[:draft_game_id], draft: true).destroy_all
    session.delete(:draft_game_id)
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

  private

  def set_game
    @game = Current.user.games.find(params[:id])
  end

  def handle_customize_post
    result = GameOfLife::PatternParser.parse_file(customize_params[:initial_state])

    # Clean up any existing draft for this session
    Current.user.games.where(id: session[:draft_game_id], draft: true).destroy_all

    @game = Current.user.games.create!(
      name: customize_params[:name],
      rows: result[:rows],
      columns: result[:columns],
      history: Array.new(result[:generation] - 1, nil) << result[:grid],
      draft: true
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

  def customize_params
    params.expect(customize: [ :name, :initial_state ])
  end
end
