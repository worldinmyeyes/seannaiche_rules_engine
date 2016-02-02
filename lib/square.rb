require_relative "piece"

module Engine

class Square
  attr_reader :x, :y, :passable, :landable, :level, :excluded, :conferred_spells, :owner, :magic_immune, :mist_spell_owner
  attr_accessor :piece, :misted_piece, :frozen, :shielded, :possess_protected

  def initialize(x,y,colourised=true)
    @x = x
    @y = y
    @colourised = colourised
    @landable = true
    @passable = true
    @excluded = []
    @level = 0
    @piece = nil
    #@letter_mappings = {0 => "a", 1 => "b", 2 => "c", 3 => "d", 4 => "e", 5 => "f", 6 => "g", 7 => "h", 8 => "i", 9 => "j", 10 => "k", 11 => "l", 12 => "m", 13 => "n", 14 => "o", 15 => "p"}
    @conferred_spells = []
    @owner = nil
    @misted_piece = nil
    @magic_immune = false
    @frozen = false
    @shielded = nil
    @possess_protected = false
    @mist_spell_owner = nil
  end
  
  def blocked?
    not (@landable or @passable)
  end
  
  def occupied?
    @piece != nil
  end
  
  def to_s
    if misted?
      return "M".colorize(34, @colourised)
    elsif frozen
      return "F".colorize(34, @colourised)
    end
    if @piece == nil
      return @char
    end
    return @piece.to_s.colorize(@piece.owner.color, @colourised)
  end
  
  def to_s_ignoring_spells
    if @piece == nil
      if @misted_piece
        return @misted_piece.to_s.colorize(@misted_piece.owner.color, @colourised)
      else
        return @char
      end      
    end
    return @piece.to_s.colorize(@piece.owner.color, @colourised)
  end
  
  #def mapped_x
  #  if @letter_mappings.keys.include? @x
  #    return @letter_mappings[@x]
  #  end
  #  return @x
  #end
  

  def lvl_lt(square)
    @level < square.level
  end
  
  def lvl_gt(square)
    @level > square.level
  end
  
  def lvl_eq(square)
    @level == square.level
  end
  
  def lvl_dist(square)
    (@level - square.level).abs
  end
  
  def entering_level(n, square)
    @level == n-1 and square.level == n 
  end
  
  def leaving_level(n, square)
    @level == n and square.level == n-1 
  end
  
  def make_misted(hostile_spellcaster, player)
    @misted_piece = @piece
    if hostile_spellcaster
      @misted_piece.active= false
    end
    @piece = nil
    @mist_spell_owner = player
  end
  
  def misted?
    @misted_piece != nil
  end
  
  def adj_to(square)
    dist_from(square) == 1 
  end
  
  # Manhattan distance
  def dist_from(square)
    (@x - square.x).abs + (@y - square.y).abs
  end
end

class NormalSquare < Square
  def initialize(x,y,colourised=true)
    super(x,y,colourised)
    @char = "-"
  end
end

class BlockedSquare < Square
  def initialize(x,y,colourised=true)
    super(x,y,colourised)
    @char = "*"
    @landable = false
    @passable = false
  end
end

class Hill1Square < Square
  def initialize(x,y,colourised=true)
    super(x,y,colourised)
    @char = "'"
    @excluded = [Champion, LeapingChieftain, SquareChieftain, DiagonalChieftain, Bansidh]
    @level = 1
    @magic_immune = true
  end
end

class Hill2Square < Square
  def initialize(x,y,colourised=true)
    super(x,y,colourised)
    @char = "+"
    @excluded = [Champion, LeapingChieftain, SquareChieftain, DiagonalChieftain, Bansidh]
    @level = 2
    @magic_immune = true
  end
end

class BansidhTempleSquare < Square
  def initialize(x,y,owner, colourised=true)
    super(x,y,colourised)
    @char = "b"
    @passable = false
    @excluded = [Champion, LeapingChieftain, SquareChieftain, DiagonalChieftain, Seannaiche, Clansman]
    @owner = owner
  end
end

class SeannaicheTempleSquare < Square
def initialize(x,y,owner,colourised=true)
    super(x,y,colourised)
    @char = "s"
    @passable = false
    @excluded = [Champion, LeapingChieftain, SquareChieftain, DiagonalChieftain, Bansidh, Clansman]
    @owner = owner
  end
end

class BansidhPassSquare < Square
def initialize(x,y,colourised=true)
    super(x,y,colourised)
    @char = "="
    @landable = false
    @excluded = [Champion, LeapingChieftain, SquareChieftain, DiagonalChieftain, Seannaiche, Clansman]
  end
end

class CauldronSquare < Square
def initialize(x,y,colourised=true)
    super(x,y,colourised)
    @char = "o"
    @excluded = [Champion, LeapingChieftain, SquareChieftain, DiagonalChieftain, Bansidh]
    @level = 3
    @magic_immune = true
    @conferred_spells = [:cauldron]
  end
end

class BoltSquare < Square
  def initialize(x,y,colourised=true)
    super(x,y,colourised)
    @char = "z"
    @conferred_spells = [:bolt]
  end
end

class MistSquare < Square
  def initialize(x,y,colourised=true)
    super(x,y,colourised)
    @char = "m"
    @conferred_spells = [:mist]
  end
end

class ShieldSquare < Square
  def initialize(x,y,colourised=true)
    super(x,y,colourised)
    @char = "d"
    @conferred_spells = [:shield]
  end
end

class FreezeSquare < Square
  def initialize(x,y,colourised=true)
    super(x,y,colourised)
    @char = "i"
    @conferred_spells = [:freeze]
  end
end

class HammerSquare < Square
  def initialize(x,y,colourised=true)
    super(x,y,colourised)
    @char = "h"
    @conferred_spells = [:hammer]
  end
end

class ShapeshiftSquare < Square
  def initialize(x,y,colourised=true)
    super(x,y,colourised)
    @char = "a"
    @conferred_spells = [:shapeshift]
  end
end

class FlightSquare < Square
  def initialize(x,y,colourised=true)
    super(x,y,colourised)
    @char = "f"
    @conferred_spells = [:flight]
  end
end

class PossessSquare < Square
  def initialize(x,y,colourised=true)
    super(x,y,colourised)
    @char = "p"
    @conferred_spells = [:possess]
  end
end

end