class MotorBox 
  attr_reader :data

  attr_accessor :state
  
  def initialize(data)
    @data   = data
    @state  = :ok
  end

  def name; @name ||= data[:name] end

  def state_color
    {ok: :green, ko: :red, bad: :orange}[@state]
  end

  def draw
    print box
  end

  def box
    if data[:title]
      TTY::Box.frame(
        top: data[:top], 
        left: data[:left], 
        style: {
          bg: state_color,
          border: {bg: state_color, fg: state_color}
        },
        padding:[0,2,0,2]) { data[:title] }
    else
      TTY::Box.frame(
        top: data[:top], 
        left: data[:left],
        height:data[:height]|| 1,
        width: data[:width] || 1,
        style: {
          bg: state_color,
          border: {bg: state_color, fg: state_color}
        })
    end
  end
end
