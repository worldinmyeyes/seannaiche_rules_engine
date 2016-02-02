module Engine

class Player
  attr_reader :turn_order, :pieces, :spells
  attr_accessor :available_moves, :piece_list, :active, :waiting_pieces, :shielded_square, :mercenary, :name, :possess_protected_square, :non_spell_enabled_moves
  
  def initialize(turn_order, name=nil)
    if name
      @name = name
    else
      @name = "player#{turn_order}"
    end
    @turn_order = turn_order
    @piece_list = []
    @available_moves = []
    @spells = {:mist => 0, :bolt => 0, :hammer => 0, :shield => 0, :freeze => 0, :shapeshift => 0, :possess => 0, :flight => 0, :cauldron => 0}
    @active = true
    @waiting_pieces = []
    @shielded_square = nil
    @possess_protected_square = nil
    @mercenary = false
    @non_spell_enabled_moves = nil
  end
  
  def <=>(p)
    if @turn_order < p.turn_order
      return -1
    elsif @turn_order > p.turn_order
      return 1
    end
    return 0
  end
  
  def add_to_piece_list(piece)
    @piece_list.push(piece)
  end
  
  def color
    mappings = {0 => 31, 1 => 32, 2 => 33, 3 => 35}
    mappings[@turn_order]
  end
  
  def find_piece(piece)
    #@piece_list.reject{|x| not(x.is_a?(piece))}.first
    @piece_list.find{|x| x.is_a?(piece)}
  end
  
  def find_pieces(piece)
    @piece_list.select{|x| x.is_a?(piece)}
  end
  
  def to_s
    @name
  end
  
  # for the purposes of shapeshifting
  def make_piece_movs_bansidhs
    @piece_list.each do |p|
      @first_mov_vecs = nil
      @first_cap_vecs = nil
      p.cap_vecs = nil
      p.mov_vecs = [Vector[-1,1],Vector[0,1],Vector[1,1],Vector[-1,0],Vector[1,0],Vector[-1,-1],Vector[0,-1],Vector[1,-1]]
      p.mov_vecs2 = [Vector[1,2],Vector[2,1],Vector[2,-1],Vector[1,-2],Vector[-1,-2],Vector[-2,-1],Vector[-2,1],Vector[-1,2]]
      p.extends_movement = true
      p.extends_movement2 = false
      p.extends_captures = true
      p.extends_captures2 = false
    end
  end
  
  def make_piece_movs_reset
    @piece_list.each do |p|
      p.set_vecs
    end
  end
  
  def waiting_piece
    waiting_pieces.last
  end
end

end