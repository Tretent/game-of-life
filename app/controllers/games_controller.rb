class GamesController < ApplicationController
  before_action :set_game, only: %i[ show destroy next_generation reset ]

  def index
    @games = Current.user.games.where(draft: false)
  end

  def new
  end

  def create
  end

  def show
  end

  def destroy
    @game.destroy
    redirect_to games_path, status: :see_other
  end

  private

  def set_game
    @game = Current.user.games.find(params[:id])
  end
end
