class ApplicationController < ActionController::Base
  # protect_from_forgery

  # rescue_from NameError, :with => :show_errors

  def show_errors(exception)
    logger.info exception
    h = {error: exception.message}
    render :status => 500, :json => h
  end
end
