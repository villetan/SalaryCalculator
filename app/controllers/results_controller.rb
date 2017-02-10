class ResultsController < ApplicationController
  def index
    @salaries = params[:salaries]
    @time = params[:time]
  end
end