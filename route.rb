require_relative 'instance_counter'

class Route
  include InstanceCounter

  attr_reader :stations

  def initialize(first_station, last_station)
    @stations = [first_station, last_station]
    validate!
    register_instance
  end

  def to_s
    "Route from #{first_station.name} to #{last_station.name}"
  end

  def valid?
    validate!
  rescue
    false
  end

  def first_station
    stations.first
  end

  def last_station
    stations.last
  end

  def add_station(station)
    stations.insert(-2, station) unless stations.include?(station)
  end

  def del_station(station)
    stations.delete(station) unless [first_station, last_station].include?(station)
  end

  def stations_list
    stations.each { |x| puts x.name }
  end

  protected

  def validate!
    raise "Route has to have at least two stations" if stations.class != Array || stations.size < 2
    raise "First and last stations cannot be equal" if first_station == last_station
    raise "First station cannot be empty" if first_station.nil?
    raise "Last station cannot be empty"  if last_station.nil?
    true
  end
end
