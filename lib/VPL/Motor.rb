require 'singleton'

class Motor
  include Singleton

  def get(box_id)
    @boxes[box_id]
  end
  alias :[] :get

  def add_box(box)
    @boxes ||= {}
    @boxes.merge!(box.name => box)
  end
  alias :<< :add_box

  def draw
    @boxes.each { |box_name, box| box.draw }
  end

end
