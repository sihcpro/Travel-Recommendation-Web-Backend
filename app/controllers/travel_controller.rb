class TravelController < ApplicationController
  def show
    @travel = Travel.find(params[:id])
    @destinations = @travel.destination
    @cities = []
    for @destination in @destinations
      @cities += [@destination.city.name]
    end
    @start = @travel.start
    if @start
      @start = @start.city.name
    end
    render json: if @travel
      {
        id: @travel.id,
        title: @travel.title,
        date: @travel.date,
        duration: @travel.duration,
        start: @start,
        destinations: @cities,
        status: 201
      }
    else
      {
        status: 404
      }
    end
  end
end