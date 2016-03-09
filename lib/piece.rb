require "matrix"

module Engine

class Piece
  
  attr_reader :collects_spells, :magic_immune
  attr_accessor :moved, :available_moves, :square, :active, :mov_vecs, :cap_vecs, :extends_movement, :extends_movement2, :extends_captures, :owner, :mov_vecs2, :first_mov_vecs, :first_cap_vecs, :extends_captures2, :mercenary, :shielded
  
  def initialize(square, player)
    @moved = false
    @square = square
    @owner = player
    # @owner.piece= self
    @owner.add_to_piece_list(self)
    @cap_vecs = nil
    @mov_vecs2 = nil
    @cap_vecs2 = nil
    @available_moves = []
    @type_enters_cauldron = false
    @can_enter_cauldron = false
    @collects_spells = false
    @magic_immune = false
    #@shielded = false
    @active = true
    @mercenary = false
  end
  
  def moves_same_as_cap
    @cap_vecs == nil
  end
  
  def moves_same_as_cap2
    @cap_vecs2 == nil
  end
  
  def first_move_same_as_cap
    @first_cap_vecs == nil
  end
  
  def has_second_move
    @mov_vecs2 != nil
  end
  
  def has_different_first_move
    @first_mov_vecs != nil
  end
  
  def has_different_first_cap
    @first_cap_vecs != nil
  end
  
  def set_owner(player)
    @owner.piece_list.delete(self)
    @owner = player
    @owner.piece_list.push(self)
  end
  
  def can_enter_cauldron
    extra_cond = true
    if is_a? Seannaiche
      extra_cond = @owner.spells[:hammer] >= 1
    end
    square.level == 2 and @type_enters_cauldron and extra_cond
  end
end

class Champion < Piece 
  def initialize(*params)
    super(*params)
    set_vecs
  end
  
  def set_vecs
    @mov_vecs = [Vector[-1,1],Vector[0,1],Vector[1,1],Vector[-1,0],Vector[1,0],Vector[-1,-1],Vector[0,-1],Vector[1,-1]]
    @extends_movement = true
    @extends_captures = true
    @mov_vecs2 = nil
  end
  
  def to_s
    "C"
  end
end

class Seannaiche < Piece
  def initialize(*params)
    super(*params)
    set_vecs
    @type_enters_cauldron = true
    @collects_spells = true
    @magic_immune = true
  end
  
  def set_vecs
    @mov_vecs = [Vector[-1,1],Vector[0,1],Vector[1,1],Vector[-1,0],Vector[1,0],Vector[-1,-1],Vector[0,-1],Vector[1,-1]]
    @extends_movement = false
    @extends_captures = false
    @mov_vecs2 = nil
  end
  
  def to_s
    "S"
  end
end

class LeapingChieftain < Piece
  def initialize(*params)
    super(*params)
    set_vecs
  end
  
  def set_vecs
    @mov_vecs = [Vector[1,2],Vector[2,1],Vector[2,-1],Vector[1,-2],Vector[-1,-2],Vector[-2,-1],Vector[-2,1],Vector[-1,2]]
    @extends_movement = false
    @extends_captures = false
    @mov_vecs2 = nil
  end
  
  def to_s
    "L"
  end
end

class SquareChieftain < Piece   
  def initialize(*params)
    super(*params)
    set_vecs
  end
  
  def set_vecs
    @mov_vecs = [Vector[0,1],Vector[1,0],Vector[0,-1],Vector[-1,0]]
    @extends_movement = true
    @extends_captures = true
    @mov_vecs2 = nil
  end
  
  def to_s
    "R"
  end
end

class DiagonalChieftain < Piece  
  def initialize(*params)
    super(*params)
    set_vecs
  end
  
  def set_vecs
    @mov_vecs = [Vector[1,1],Vector[1,-1],Vector[-1,-1],Vector[-1,1]]
    @extends_movement = true
    @extends_captures = true
    @mov_vecs2 = nil
  end
  
  def to_s
    "D"
  end
end

class Clansman < Piece  
  def initialize(*params)
    super(*params)
    set_vecs
    @type_enters_cauldron = true
  end
  
  def set_vecs
    @mov_vecs = [Vector[-1,1],Vector[0,1],Vector[1,1],Vector[-1,0],Vector[1,0],Vector[-1,-1],Vector[0,-1],Vector[1,-1]]
    @cap_vecs = [Vector[1,1],Vector[1,-1],Vector[-1,-1],Vector[-1,1]]
    @first_mov_vecs = [Vector[-2,2],Vector[0,2],Vector[2,2],Vector[-2,0],Vector[2,0],Vector[-2,-2],Vector[0,-2],Vector[2,-2]]
    @first_cap_vecs = [Vector[2,2],Vector[2,-2],Vector[-2,-2],Vector[-2,2]]
    @extends_movement = false
    @extends_captures = false
    @mov_vecs2 = nil
  end
  
  def to_s
    "P"
  end
end

class Bansidh < Piece 
  def initialize(*params)
    super(*params)
    set_vecs
    @collects_spells = true
    @magic_immune = true
  end
  
  def set_vecs
    @mov_vecs = [Vector[-1,1],Vector[0,1],Vector[1,1],Vector[-1,0],Vector[1,0],Vector[-1,-1],Vector[0,-1],Vector[1,-1]]
  @mov_vecs2 = [Vector[1,2],Vector[2,1],Vector[2,-1],Vector[1,-2],Vector[-1,-2],Vector[-2,-1],Vector[-2,1],Vector[-1,2]]
    @extends_movement = true
    @extends_movement2 = false
    @extends_captures = true
    @extends_captures2 = false
  end
  
  def to_s
    "B"
  end
end

end