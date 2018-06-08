require_relative 'manufacturer'

class Railcar
  include Manufacturer

  def initialize
    validate!
  end

  def type
  end

  def valid?
    validate!
  rescue
    false
  end

  protected

  def validate!
    raise "Railcar has to have type" if type.nil?
    true
  end
end
