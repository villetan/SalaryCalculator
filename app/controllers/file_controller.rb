class FileController < ApplicationController
  include FileHelper
  def upload
    if params[:file]
      time, salaries = handle_file(params[:file])
      redirect_to results_path(:salaries => salaries, time: time)
    else
      redirect_to root_path, notice: "Upload a file please"
    end
  end
end
