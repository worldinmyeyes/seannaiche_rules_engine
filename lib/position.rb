module Engine

class Position
  attr_reader :piece_dict
  
  # TODO: take a FEN string as a parameter
  def initialize(piece_dict)
    @piece_dict = piece_dict
  end
end

end