require_relative 'instance_counter'
require_relative 'manufacturer'

class Train
  include InstanceCounter
  include Manufacturer
  
  attr_reader :number, :railcars, :speed, :route, :station

  @@all_trains = {}

  def self.find(number)
    @@all_trains[number]
  end

  def initialize(number)
    @number = number
    @railcars = []
    @speed = 0
    @route = nil
    @station = nil
    validate!
    register_instance
    @@all_trains[number] = self
  end

  def type
  end

  def to_s
    "Train number #{number}"
  end

  def valid?
    validate!
  rescue
    false
  end

  def speed_up(speed_delta)
    speed += speed_delta if speed_delta > 0
  end

  def stop
    self.speed = 0
  end

  def attach_railcar(railcar)
    railcars << railcar if speed.zero? && railcar.type == type
  end

  def remove_railcar(railcar)
    railcars.delete(railcar) if speed.zero?
  end

  def assign_route(route)
    self.route = route
    self.station = route.first_station
    station.arrive(self)
  end

  def goto_next_station
    if station && route && station != route.last_station
      station.depart(self)
      self.station = next_station
      station.arrive(self)
    end
  end

  def goto_prev_station
    if station && route && station != route.first_station
      station.depart(self)
      self.station = prev_station
      station.arrive(self)
    end
  end

  def prev_station
    route.stations[route.stations.find_index(station) - 1] if route && station != route.first_station
  end

  def next_station
    route.stations[route.stations.find_index(station) + 1] if route && station != route.last_station
  end

  protected

  attr_writer :speed, :route, :station

  def validate!
    raise "Train has to have type"        if type.nil?
    raise "Train number cannot be empty"  if number.nil? || number.empty?
    raise "Train number has wrong format" if number !~ /^[a-z0-9]{3}-?[a-z0-9]{2}$/i
    true
  end
end
