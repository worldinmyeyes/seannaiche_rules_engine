require_relative "square"
require_relative "piece"

module Engine

class Move
  attr_reader :player, :turn_cost
  
  def initialize(player)
    @player = player
    @turn_cost = 1
  end
end

class PieceMove < Move 
  
attr_reader :captured_piece, :from_square, :to_square, :piece, :player, :first_move, :turn_cost, :is_capture, :is_hillmove, :promotion_piece
attr_accessor :possess_protect_move
  
  def initialize(from, to, piece)
    @from_square = from
    @to_square = to
    @piece = piece
    @player = @piece.owner
    super(@player)
    
    # nil if not a capture
    @captured_piece = @to_square.piece
    
    @first_move = not(@piece.moved)
    
    @is_capture = @to_square.piece != nil
    @is_cauldron_move = @to_square.instance_of? CauldronSquare
    # @is_promotion = (@is_cauldron_move and @piece.instance_of? Clansman)
    @is_hillmove = @to_square.level >= 1
    @promotion_piece = nil
    @possess_protect_move = false
  end
  
  def to_s
    if is_capture
      return "#{@piece.to_s}(#{@from_square.x},#{@from_square.y})x(#{@to_square.x},#{@to_square.y})" + @letter.to_s
    end
    return "#{@piece.to_s}(#{@from_square.x},#{@from_square.y})-(#{@to_square.x},#{@to_square.y})" + @letter.to_s
  end
  
  def moving_misted_piece
    (from_square.misted? and piece.equal?(from_square.misted_piece))
  end
  
  def ==(move)
    true if to_s == move.to_s
  end
end

class PromoteMove < PieceMove
  def initialize(from, to, promotion_piece, piece)
    super(from, to, piece)
    @promotion_piece = promotion_piece
  end
  
  def to_s
    super.to_s + @promotion_piece.to_s
  end
end

class SpellMove < Move
  attr_reader :effect_square, :symbol, :official_name
  
  def initialize(player)
    super(player)
    @letter = ""
    @effect_square = nil
    @symbol = nil
  end
  
  def to_s
    if not @effect_square.nil?
      return "#{@letter}(#{@effect_square.x},#{@effect_square.y})"
    end
    return @letter
  end
end

class MistMove < SpellMove
  def initialize(square, player)
    super(player)
    @effect_square = square
    @letter = "m"
    @symbol = :mist
  end
  
  def official_name
    "Mist"
  end
end

# 2 uses for bolt, treated as different moves which both consume the spell

class BoltKillMove < SpellMove
  def initialize(square, player)
    super(player)
    @effect_square = square
    @letter = "z"
    @symbol = :bolt_kill
  end
  
  def official_name
    "Dagda's Club"
  end
end

class BoltReviveMove < SpellMove
  attr_reader :promotion_piece
  
  def initialize(promotion_piece, player)
    super(player)
    @promotion_piece = promotion_piece
    @letter = "z"
    @symbol = :bolt_revive
  end
  
  def official_name
    "Dagda's Club"
  end
end

class ShapeshiftMove < SpellMove
  def initialize(player)
    super(player)
    @turn_cost = 0
    @letter = "a"
    @symbol = :shapeshift
  end
end

class FreezeMove < SpellMove
  def initialize(square, player)
    super(player)
    @effect_square = square
    @letter = "i"
    @symbol = :freeze
  end
  
  def official_name
    "Freeze"
  end
end

class FlightMove < SpellMove
  def initialize(player)
    super(player)
    @turn_cost = 0
    @letter = "f"
    @symbol = :flight
  end
  
  def official_name
    "Flight"
  end
end

class HammerMove < SpellMove
  def initialize(spell, player)
    super(player)
    @spell = spell
    @letter = "h"
    @symbol = :hammer
  end
  
  def official_name
    "Spellhammer"
  end
end

class ShieldMove < SpellMove
  def initialize(square, player)
    super(player)
    @effect_square = square
    @turn_cost = 0
    @letter = "d"
    @symbol = :shield
  end
  
  def official_name
    "Shield"
  end
end

class PossessMove < SpellMove
  def initialize(player)
    super(player)
    @turn_cost = 0
    @letter = "p"
    @symbol = :possess
  end
  
  def official_name
    "Possession"
  end
end

class CauldronMove < SpellMove
  def initialize(player)
    super(player)
    @turn_cost = 0
    @letter = "c"
    @symbol = :cauldron
  end
  
  def official_name
    "Cauldron"
  end
end

end