class SearchesController < ApplicationController
  # def show
  #   # Travel.joins(:start => :city).select("travels.id as travel_id").first.travel_id
  #   @destinations_name = Destination.joins(:city
  #     ).select("travel_id",
  #              "cities.name as destination_name").order("travel_id")
  #   @destinations = {}
  #   @destinations_name.each do |item|
  #     if @destinations[item.travel_id]
  #       @destinations[item.travel_id] = @destinations[item.travel_id] + [item.destination_name]
  #     else
  #       @destinations[item.travel_id] = [item.destination_name]
  #     end
  #   end

  #   @travels = Travel.all
  #   travels = []
  #   @travels.each do |item|
  #     travel = item.attributes
  #     travel['destinations'] = @destinations[item.id]
  #     travels += [travel]
  #   end

  #   render json:  if params[:page]
  #                   page = params[:page].to_i
  #                   {
  #                     travels: travels[(page * 10)..((page + 1) * 10 - 1)],
  #                     status: 201
  #                   }
  #                 else
  #                   {
  #                     travels: travels,
  #                     status: 201
  #                   }
  #                 end
  # end

  def show
    puts params[:type]
    travel_ids = Travel.joins(:travel_types).where("rating >= #{params[:rating]} AND
      lower_price >= #{params[:lower_price]} AND
      upper_price <= #{params[:upper_price]}")
                    .where("travel_types.type_id in (#{params[:type]})")
                    .select(:id).distinct.map(&:id)
    user_id = params[:user_id]
    partner = params[:partner]
    time = params[:time]
    File.open("CARSKit.Workspace/user#{user_id}_travel.txt", 'w') do |f|
      travel_ids.each { |i| f.write("#{i}\n")}
    end
    head = []
    File.open("CARSKit.Workspace/train.csv", 'r') do |f|
      head = f.readline().split(', ')
      # puts head
    end
    File.open("CARSKit.Workspace/user#{user_id}_context.txt", 'w') do |f|
      context = "#{head.index("partner:#{partner}")-3},#{head.index("time:#{time}")-3}"
      f.write(context)
    end
    system("java -jar Recommender.jar -c setting.conf -u #{user_id}")
    travels = []
    File.open("CARSKit.Workspace/user#{user_id}_suggestion.txt", 'r') do |f|
      travel_all = f.read().split('\n')
      travel_all.each do |travel|
        travel = travel.split(',')
        travels = travels + [[travel[0], travel[1]]]
      end
    end
    puts travels.to_s
    render json: {
      suggestions: travel_ids
    }
  end

  def search_params
    params.permit(:rating, :lower_price, :upper_price, :type)
  end
end
