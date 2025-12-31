class GreetingsController < ApplicationController
  def show
    render json: { message: "Hello World" }, status: :ok
  end
end

