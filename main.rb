require_relative 'station'
require_relative 'route'
require_relative 'railcar'
require_relative 'cargo_railcar'
require_relative 'passenger_railcar'
require_relative 'train'
require_relative 'cargo_train'
require_relative 'passenger_train'

class Main
  def initialize
    @stations = []
    @routes   = []
    @trains   = []
    @show_info_for_object = {}
    @show_info_for_object[:station] = Proc.new { |station, index| puts "ID #{index}: #{station.to_s}" }
    @show_info_for_object[:route]   = Proc.new { |route,   index| puts "ID #{index}: #{route.to_s}" }
    @show_info_for_object[:train]   = Proc.new { |train,   index| puts "ID #{index}: #{train.to_s}" }
    @show_info_for_object[:railcar] = Proc.new { |railcar, index| puts "ID #{index}" }
  end

  def start
    puts "\nWelcome to the Railroad Cockpit\n"

    show_commands_list

    exit_flag = false

    until exit_flag do
      exit_flag = ask_user_to_select_command
    end
  end

  private

  attr_reader :stations, :routes, :trains, :show_info_for_object

  def ask_user_to_select_command
    print \
      "====================\n"\
      "Enter command ID: "

    exit_flag = false

    command = gets.chomp

    case command
    when  "0" then show_commands_list
    when  "1" then add_station
    when  "2" then add_train
    when  "3" then add_route
    when  "4" then add_station_to_route
    when  "5" then remote_station_from_route
    when  "6" then assign_route_to_train
    when  "7" then attach_railcar_to_train
    when  "8" then remove_railcar_from_train
    when  "9" then move_train_to_next_station
    when "10" then move_train_to_previous_station
    when "11" then show_stations_list
    when "12" then show_trains_list_at_station
    when "99" then exit_flag = true
    else puts "Unknown command"
    end

    exit_flag
  end

  def show_commands_list
    puts "Select command:"
    puts \
      "ID  0: Show commands list\n"\
      "ID  1: Add new station\n"\
      "ID  2: Add new train\n"\
      "ID  3: Add new route\n"\
      "ID  4: Add station to route\n"\
      "ID  5: Remote station from route\n"\
      "ID  6: Assign route to train\n"\
      "ID  7: Attach railcar to train\n"\
      "ID  8: Remove railcar from train\n"\
      "ID  9: Move train to next station\n"\
      "ID 10: Move train to previous station\n"\
      "ID 11: Show stations list\n"\
      "ID 12: Show trains list at station\n"\
      "ID 99: Exit"
  end

  def add_station
    print "Enter station name: "
    station_name = gets.chomp
    stations << Station.new(station_name)
  rescue RuntimeError => e
    puts e.message
  end
  
  def add_train
    print "Enter train number: "
    train_number = gets.chomp
    print "Enter c for cargo, p for passenger train: "
    train_type = gets.chomp
    begin
      case train_type
      when "c" then trains << CargoTrain.new(train_number)
      when "p" then trains << PassengerTrain.new(train_number)
      else raise "Wrong train type"
      end
      puts "#{train_type == "c" ? "Cargo" : "Passenger"} train number #{train_number} successfully added"
    rescue RuntimeError => e
      puts e.message
    end
  end

  def add_route
    first_station = ask_user_to_select_station(stations, "Select first station:")
    last_station  = ask_user_to_select_station(stations, "Select last station:") if first_station
    routes << Route.new(first_station, last_station)
  rescue RuntimeError => e
    puts e.message
  end

  def add_station_to_route
    route   = ask_user_to_select_route
    station = ask_user_to_select_station(stations) if route
    route.add_station(station) if route && station
  end

  def remote_station_from_route
    route   = ask_user_to_select_route
    station = ask_user_to_select_station(route.stations) if route
    route.remove_station(station) if route && station
  end

  def assign_route_to_train
    train = ask_user_to_select_train
    route = ask_user_to_select_route if train
    train.assign_route(route) if train && route
  end

  def attach_railcar_to_train
    train = ask_user_to_select_train
    if train
      case train.type
      when :cargo     then train.attach_railcar(CargoRailcar.new)
      when :passenger then train.attach_railcar(PassengerRailcar.new)
      end
    end
  end

  def remove_railcar_from_train
    train   = ask_user_to_select_train
    railcar = ask_user_to_select_railcar(train.railcars) if train
    train.remove_railcar(railcar) if train && railcar
  end

  def move_train_to_next_station
    train = ask_user_to_select_train
    if train
      if train.station
        train.goto_next_station
      else
        puts "Station is not assigned"
      end
    end
  end

  def move_train_to_previous_station
    train = ask_user_to_select_train
    if train
      if train.station
        train.goto_prev_station
      else
        puts "Station is not assigned"
      end
    end
  end

  def show_stations_list
    if stations.empty?
      puts "There are no stations"
    else
      stations.each { |station| puts "Station #{station.name}" }
    end
  end

  def show_trains_list_at_station
    station = ask_user_to_select_station(stations)
    if station
      if station.trains.empty?
        puts "There are no trains at station"
      else
        station.trains.each { |train| puts "Train #{train.number}" }
      end
    end
  end

  def ask_user_to_select_station(stations, text = "Select station:")
    ask_user_to_select(:station, stations, text, "Enter station ID: ")
  end

  def ask_user_to_select_route(text = "Select route:")
    ask_user_to_select(:route, routes, text, "Enter route ID: ")
  end

  def ask_user_to_select_train(text = "Select train:")
    ask_user_to_select(:train, trains, text, "Enter train ID: ")
  end

  def ask_user_to_select_railcar(railcars, text = "Select railcar:")
    ask_user_to_select(:railcar, railcars, text, "Enter railcar ID: ")
  end

  def ask_user_to_select(array_type, array, text_title, text_welcome_to_action)
    if array.empty?
      puts "There are no #{array_type.to_s}s"
    else
      puts text_title
      array.each_with_index(&show_info_for_object[array_type])
      print text_welcome_to_action
      result_id = gets.to_i
      if result_id.negative? || result_id >= array.size
        puts "Wrong ID"
      else
        array[result_id]
      end
    end
  end
end

Main.new.start
