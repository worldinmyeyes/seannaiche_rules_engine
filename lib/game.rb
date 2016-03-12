require "matrix"
require "stringio"

require_relative "piece"
require_relative "square"
require_relative "player"
require_relative "move"
require_relative "board"

module Engine

class Game
  attr_reader :players, :board, :max_players, :turn_counter, :side_to_move, :game_id, :last_move_valid, :active, :last_player_killed, :result
  attr_accessor :interactive_mode, :last_message, :colourised, :last_move_okay

  @@DEFAULT_BOARD =
"b2= = - - - - - - - - - s2* * b3
* = * * - - - - - - - - * * = =
* * = * - - - - - - - - * = * =
s1* * d - - - - - - - - d * * -
- - - - h - - - - - - h - - - -
- - - - - f z a p i f - - - - -
- - - - - i m ' ' m z - - - - -
- - - - - p ' + + ' a - - - - -
- - - - - a ' + + ' p - - - - -
- - - - - z m ' ' m i - - - - -
- - - - - f i p a z f - - - - -
- - - - h - - - - - - h - - - -
- * * d - - - - - - - - d * * s3
= * = * - - - - - - - - * = * *
= = * * - - - - - - - - * * = *
b1* * s0- - - - - - - - - = = b0"

# only capital letters and numbers are read, other characters are just to give a better sense of the board layout
@@DEFAULT_PIECES = 
"- * * B2R2L2D2C2C2D2L2R2S2* * -
* * * * P2P2P2P2P2P2P2P2* * * *
* * * * - - - - - - - - * * * *
S1* * - - - - - - - - - - * * B3
R1P1- - - - - - - - - - - - P3R3
L1P1- - - - - - - - - - - - P3L3
D1P1- - - - - ' ' - - - - - P3D3
C1P1- - - - ' + + ' - - - - P3C3
C1P1- - - - ' + + ' - - - - P3C3
D1P1- - - - - ' ' - - - - - P3D3
L1P1- - - - - - - - - - - - P3L3
R1P1- - - - - - - - - - - - P3R3
B1* * - - - - - - - - - - * * S3
* * * * - - - - - - - - * * * *
* * * * P0P0P0P0P0P0P0P0* * * *
- * * S0R0L0D0C0C0D0L0R0B0* * -"

@@TWO_PLAYERS =
"- * * B1R1L1D1C1C1D1L1R1S1* * -
* * * * P1P1P1P1P1P1P1P1* * * *
* * * * - - - - - - - - * * * *
- * * - - - - - - - - - - * * B1
R0P0- - - - - - - - - - - - P1R1
L0P0- - - - - - - - - - - - P1L1
D0P0- - - - - ' ' - - - - - P1D1
C0P0- - - - ' + + ' - - - - P1C1
C0P0- - - - ' + + ' - - - - P1C1
D0P0- - - - - ' ' - - - - - P1D1
L0P0- - - - - - - - - - - - P1L1
R0P0- - - - - - - - - - - - P1R1
B0* * - - - - - - - - - - * * -
* * * * - - - - - - - - * * * *
* * * * P0P0P0P0P0P0P0P0* * * *
- * * S0R0L0D0C0C0D0L0R0B0* * -"

@THREE_PLAYERS =
"- * * B1R1L1D1C1C1D1L1R1S1* * -
* * * * P1P1P1P1P1P1P1P1* * * *
* * * * - - - - - - - - * * * *
- * * - - - - - - - - - - * * B1
R0P0- - - - - - - - - - - - P1R1
L0P0- - - - - - - - - - - - P1L1
D0P0- - - - - ' ' - - - - - P1D1
C0P0- - - - ' + + ' - - - - P1C1
C0P0- - - - ' + + ' - - - - P1C1
D0P0- - - - - ' ' - - - - - P1D1
L0P0- - - - - - - - - - - - P1L1
R0P0- - - - - - - - - - - - P1R1
B0* * - - - - - - - - - - * * -
* * * * - - - - - - - - * * * *
* * * * P0P0P0P0P0P0P0P0* * * *
- * * S0R0L0D0C0C0D0L0R0B0* * -"

@@TWO_PLAYER_SQUARES =
"b1= = - - - - - - - - - s1* * b1
* = * * - - - - - - - - * * = =
* * = * - - - - - - - - * = * =
s0* * d - - - - - - - - d * * -
- - - - h - - - - - - h - - - -
- - - - - f z a p i f - - - - -
- - - - - i m ' ' m z - - - - -
- - - - - p ' + + ' a - - - - -
- - - - - a ' + + ' p - - - - -
- - - - - z m ' ' m i - - - - -
- - - - - f i p a z f - - - - -
- - - - h - - - - - - h - - - -
- * * d - - - - - - - - d * * s1
= * = * - - - - - - - - * = * *
= = * * - - - - - - - - * * = *
b0* * s0- - - - - - - - - = = b0"

@@CHAR_MAPPINGS = {"-" => NormalSquare, "=" => BansidhPassSquare, "*" => BlockedSquare, "b" => BansidhTempleSquare, "s" => SeannaicheTempleSquare, "d" => ShieldSquare, "h" => HammerSquare, "f" => FlightSquare, "i" => FreezeSquare, "m" => MistSquare, "p" => PossessSquare, "a" => ShapeshiftSquare, "z" => BoltSquare, "'" => Hill1Square, "+" => Hill2Square}
@@PIECE_MAPPINGS = {"S" => Seannaiche, "R" => SquareChieftain, "L" => LeapingChieftain, "D" => DiagonalChieftain, "C" => Champion, "P" => Clansman, "B" => Bansidh}
@@LAYOUTS = [nil, nil, @@TWO_PLAYERS, @THREE_PLAYERS, @@DEFAULT_PIECES]
@@SQUARE_LAYOUTS = [nil, nil, @@TWO_PLAYER_SQUARES, @@DEFAULT_BOARD, @@DEFAULT_BOARD]


  def initialize(max_players, game_id="", interactive_mode=true, colourised=true)
    @game_id = game_id
    @board = nil
    @max_players = max_players
    @interactive_mode = interactive_mode
    @colourised = colourised
    @players = []
    @turn_counter = 0
    @move_list = []
    @piece_list = []
    @active = true
    @result = ""
    @active_spells = []
    @board_rotation = 0
    @last_message = ""
    @last_move_okay = true
    @message_log = []
    @last_player_killed = nil
    
    # TODO: get the player names and colours from the command line
    0.upto(@max_players-1) do |i|
      @players.push(Player.new(i))
    end
    
    # sort the players on their assigned turn index, so they play in the correct order 
    @players.sort!
    load_board(@@SQUARE_LAYOUTS[@max_players])
    load_pieces(@@LAYOUTS[@max_players])
    ready_for_move
  end
  
  def load_board(layout)
    lines = layout.split("\n")
    @board = Board.new(lines, @players, @@CHAR_MAPPINGS, @colourised)
  end
  
  #def find_square(x, y)
  #  0.upto(@width-1) do |i|
  #    0.upto(@height-1) do |j|
  #      if squares[i][j].x == i and squares[i][j].y == j
  #        squares[i][j]
  #      end
  #    end
  #  end
  #  nil 
  #end
 
  def load_pieces(layout)
    lines = nil
    #begin
    #  f = File.open(filename, "r")
    #  lines = f.readlines
    #  f.close
    #rescue
      lines = layout.split("\n")
    #end
    i = 0
    lines.each do |l|
      
      # incrementing by 2 since characters are read in 2's
      (0...@board.width).to_a.each do |j|
        if @@PIECE_MAPPINGS.keys.include? l[2*j]
          @board.find(i,j).piece= @@PIECE_MAPPINGS[l[2*j]].new(@board.find(i,j), @players[Integer(l[2*j+1])])
          @piece_list.push(@board.find(i,j).piece)
        end
      end
      
      i+=1
    end
  end
 
  def load_pos(pos)
    pos.piece_dict.keys.each do |s|
      s.piece= pos.piece_dict[s]
    end
  end
  
  # The reason this method prints directly is because it will also be responsible for changing the font colour, so players can be identified by their colour.  But it should also return the string it prints.
  def get_graphic(n=1, colourised=true)
    s = ""
    0.upto(@board.height-1) do |i|
      b = @board.rotate(n)
      print i.to_s + "\t"
      s += i.to_s + "\t"
      0.upto(@board.width-1) do |j|
        print b[i][j].to_s + (j==@board.width-1 ? "" : " ")
        s += b[i][j].to_s + (j==@board.width-1 ? "" : " ")
      end
      if i==(@board.width-1)/2
        print "\t\t#{@board.cauldron.to_s}"
        s += "\t\t#{@board.cauldron.to_s}"
      end
      puts
      s+="\n"
    end
    print "\n\t"
    s += "\n\t"
    0.upto(@board.width-1) do |j|
      print "#{j%10} "
      s += "#{j%10} "
    end
    puts
    s+="\n"
    if not colourised
      # remove all colour characters from the output
      puts s.gsub!(/\e\[\d+m/,"")
    end
    return s
  end
  
  def place_piece(square, piece)
    if not piece.owner.piece_list.include? piece
      piece.owner.piece_list.push piece
    end
    # actually, don't really need to do this check
    if square.occupied?
      unplace_piece(square)
    end
    piece.square= square
    square.piece= piece
  end
  
  def unplace_piece(square, misted=false)
    if misted
      square.misted_piece.owner.piece_list.delete square.misted_piece
      square.misted_piece.square= nil
      square.misted_piece= nil
    else
      square.piece.owner.piece_list.delete square.piece
      square.piece.square= nil
      square.piece= nil
    end
  end
  
  def move_piece(from, to, misted=false)
    p = nil
    if misted
      p = from.misted_piece
    else
      p = from.piece
    end
    # Only case when a piece is not unplaced: when there's a piece on the square to be unplace, when a misted piece moves, and that misted piece is the same colour as the piece on the square.
    if not (misted and from.piece and (from.piece.owner.equal?(from.misted_piece.owner)))
      unplace_piece(from, misted)
    end
    place_piece(to, p)
  end
  
  def make_move(move)
    puts move if @interactive_mode
    # @message_log.push move.to_s
    @last_player_killed = nil
    if move.class <= PieceMove
      p = nil
      if move.moving_misted_piece
        p = move.from_square.misted_piece
      else
        p = move.from_square.piece
      end
      p.moved= true
      move_piece(move.from_square, move.to_square, move.moving_misted_piece)
      if p.square.equal?(@board.cauldron) and p.is_a?(Clansman) and not move.is_a?(PromoteMove)
        unplace_piece(p.square)
      end
      #check if move.is_capture and move.captured_piece.
      if not move.player.waiting_pieces.empty? and move.from_square.is_a?(SeannaicheTempleSquare) and move.from_square.owner.equal?(move.player) and not move.player.mercenary
        r = move.player.waiting_pieces.shift
        place_piece(move.from_square, r)
        @message_log.push ("A #{r.class} was reincarnated.")
      end
      if (move.is_capture and move.captured_piece.is_a? Seannaiche)
        owner = move.captured_piece.owner
        owner.piece_list.clone.each do |q|
          q.mercenary= true
        end
        
        owner.mercenary= true
        owner.active= false
        @last_player_killed = owner
        
        in_prog = false
        @players.each do |s|
          next if s.equal?(move.player)
          if s.active
            in_prog = true
            break
          end
        end
        if not in_prog
          @active = false
          @message_log.push "#{move.player} wins by capturing all opposing Seannaiche's."
          @result = "#{move.player} wins by capturing all opposing Seannaiche's."
          return
        end
      end
      if move.piece.is_a?(Seannaiche) and move.to_square.is_a?(SeannaicheTempleSquare) and move.player.spells[:cauldron] >= 1
        @active = false
        @message_log.push "#{move.player} wins by capturing the cauldron."
        @result = "#{move.player} wins by capturing the cauldron."
        return
      end
      
      # if the piece has moved to a spell square, collect spells 
      if p.collects_spells
        move.to_square.conferred_spells.each do |s|
          move.player.spells[s] = [1,p.owner.spells[s]+1].min
          @message_log.push "#{p.owner.name} obtained the #{s.to_s} spell."
        end
      end
      if move.instance_of? PromoteMove
        unplace_piece(p.square)
        resurrect(move.player, move.promotion_piece)
      end
      if move.possess_protect_move
        move.to_square.possess_protected= true
        move.player.possess_protected_square = move.to_square 
      end
      
    # possibility of moves that are both PieceMoves and SpellMoves?
    elsif move.class < SpellMove
      @message_log.push "The #{move.official_name} spell was invoked."
      if move.is_a?(BoltKillMove)
        unplace_piece(move.effect_square)
        move.player.spells[:bolt] -= 1
      elsif move.is_a?(BoltReviveMove)
        resurrect(move.player, move.promotion_piece)
        move.player.spells[:bolt] -= 1
      elsif move.is_a?(MistMove)
        s = move.effect_square
        s.make_misted(friendly_occupied?(s, s.piece), move.player)
        move.player.spells[:mist] -= 1
      elsif move.is_a?(PossessMove)
        @active_spells.push :possess
        move.player.spells[:possess] -= 1
      elsif move.is_a?(FlightMove)
        @active_spells.push :flight
        move.player.spells[:flight] -= 1
      elsif move.is_a?(FreezeMove)
        s = move.effect_square
        s.frozen= true
        if s.piece
          move.effect_square.piece.active= false
        end
        move.player.spells[:freeze] -= 1
      elsif move.is_a?(ShapeshiftMove)
        @active_spells.push :shapeshift
        move.player.spells[:shapeshift] -= 1
      elsif move.is_a?(ShieldMove)
        @active_spells.push :shield
        move.player.shielded_square= move.effect_square 
        move.effect_square.shielded= move.player
        move.player.spells[:shield] -= 1
      elsif move.is_a?(CauldronMove)
        @active_spells.push(:cauldron)
      end
    end
    @players[side_to_move].available_moves= []
    @players[side_to_move].non_spell_enabled_moves= nil
    next_turn(move.turn_cost)
    @move_list.push(move)
  end
  
  def unmake_move(move=@move_list.last)
    p = move.to_square.piece
    p.moved= not(move.first_move)
    if move.is_promotion
      place_piece(p, move.to_square)
      p.owner.piece_list.push(p)
    end
    move_piece(move.to_square, move.from_square)
    if move.is_capture
      place_piece(move.to_square.piece, move.captured_piece)
      # move.captured_piece.owner.piece_list.push(move.captured_piece)
    end
    @players[side_to_move].available_moves= []
    @players[side_to_move].non_spell_enabled_moves= nil
    @turn_counter -= move.turn_cost
    @move_list.delete(move)
  end
  
  def get_moves(player, already_possessing=false, use_active_spells=true)
    # debugger if @turn_counter == 20
    generate_moves(player, already_possessing, false)
    # to handle magic immunity, need to do it again (uses existing moves generated above without spells)
    generate_moves(player, already_possessing, true) if not @active_spells.empty?
    player.non_spell_enabled_moves = nil
  end
  
  def generate_moves(player, already_possessing, use_active_spells)
    @active_spells_considered = [] 
    if use_active_spells
      @active_spells_considered = @active_spells
    end
    # TODO: only clear moves and spells once, and do it only in ready_move
    player.available_moves.clear
    if @active_spells_considered.include? :shapeshift
      player.make_piece_movs_bansidhs
    end
    player.piece_list.each do |p|
      if p.active
        player.available_moves.concat(get_moves_piece(p))
      end
    end
    if can_cast_magic(player)
      if player.spells[:bolt] >= 1
        @piece_list.each do |p|
          if p.square and p.square.occupied? and not (friendly_occupied?(p.square, player) or p.magic_immune or p.square.magic_immune)
            player.available_moves.push BoltKillMove.new(p.square, player)
          end
        end
        @@PIECE_MAPPINGS.values.each do |q|
          r = @piece_list.find{|x| x.is_a?(q) and x.square.nil? and x.owner.equal?(player)}
          if r
            player.available_moves.push(BoltReviveMove.new(r, player))
          end
        end
      end
      if player.spells[:mist] >= 1 || @active_spells_considered.include?(:cauldron)
        # Woj Zscz: changed restriction of spell on all non-magic immune pieces
        #@board.flattened.each do |s|
        @piece_list.each do |p|
          #if not s.magic_immune and s.occupied?
          if (p.square && p.square.occupied? && p.magic_immune == false && p.square.magic_immune == false)
          #changed s to p.square
            player.available_moves.push MistMove.new(p.square, player)
          end
        end
      end
      if player.spells[:freeze] >= 1 || @active_spells_considered.include?(:cauldron)
        # Woj Zscz: changed restriction of spell on all non-magic immune pieces
        #@board.flattened.each do |s|
        @piece_list.each do |p|
          # if not s.magic_immune and not friendly_occupied?(s,player)
          if (p.square && p.square.occupied? && p.magic_immune == false && p.square.magic_immune == false)
          # if p.square and p.square.occupied? 
            #changed s to p.square
            player.available_moves.push FreezeMove.new(p.square, player)
          end
        end
      end
      if player.spells[:possess] >= 1 || @active_spells_considered.include?(:cauldron)
        player.available_moves.push PossessMove.new(player)
      end
      if player.spells[:flight] >= 1 || @active_spells_considered.include?(:cauldron)
        player.available_moves.push FlightMove.new(player)
      end
      if player.spells[:shapeshift] >= 1 || @active_spells_considered.include?(:cauldron)
        player.available_moves.push ShapeshiftMove.new(player)
      end
      if player.spells[:shield] >= 1 || @active_spells_considered.include?(:cauldron)
        @board.flattened.each do |t|
          next if t.magic_immune
          player.available_moves.push ShieldMove.new(t, player)
        end
      end
      if player.spells[:cauldron] >= 1 || @active_spells_considered.include?(:cauldron)
        player.available_moves.push(CauldronMove.new(player))
      end
    end
    if not player.mercenary and not already_possessing
      @players.select{|p| p.mercenary}.each do |m|
          get_moves(m)
          player.available_moves.concat(m.available_moves) if not m.available_moves.empty?
        end
    end
    if (@active_spells_considered.include?(:possess) || @active_spells_considered.include?(:cauldron)) and not already_possessing
      @players.each do |p|
        if not p.equal?(player)
          get_moves(p, true)
          possess_moves = []
          p.available_moves.each do |m|
            next if not m.is_a? PieceMove
            m2 = m.clone
            m2.possess_protect_move= true
            possess_moves.push m2
          end
          player.available_moves.concat(possess_moves)
        end
      end
    end
    if @active_spells_considered.include? :shapeshift
      player.make_piece_movs_reset
    end
    if not use_active_spells
      player.non_spell_enabled_moves = player.available_moves.clone
    end
  end
  
  # TODO: investigate why this is producing some duplicate moves
  def get_moves_piece(piece)
    w_old = Vector[piece.square.x, piece.square.y]
    moves = []
    if piece.can_enter_cauldron
      if piece.is_a?(Seannaiche) or (piece.is_a?(Clansman) and piece.owner.mercenary)
        moves.push(PieceMove.new(piece.square, @board.cauldron, piece))
      elsif piece.is_a? Clansman
        @@PIECE_MAPPINGS.values.each do |q|
        r = @piece_list.find{|x| x.is_a?(q) and x.square.nil? and x.owner.equal?(piece.owner)}
        if r
          moves.push(PromoteMove.new(piece.square, @board.cauldron, r, piece))
        end
    end
      end
    end
    # TODO: a bit of a workaround, adding moves off the cauldron only in the special case of the standard 16x16 board.  A more general solution for handling multiple cauldrons would probably be a good idea.
    if piece.square.level == 3
      moves.push(PieceMove.new(@board.cauldron, @board.find(7,7), piece))
      moves.push(PieceMove.new(@board.cauldron, @board.find(7,8), piece))
      moves.push(PieceMove.new(@board.cauldron, @board.find(8,7), piece))
      moves.push(PieceMove.new(@board.cauldron, @board.find(8,8), piece))
    end
    piece.mov_vecs.each do |v|
      moves.concat iterate_move(v, w_old, piece, :move_or_cap)
    end      
    if not piece.moves_same_as_cap
      piece.cap_vecs.each do |v|
        moves.concat iterate_move(v, w_old, piece, :normal_capture)
      end
    end
    # only piece satisfying this is Bansidh (which moves_same_as_cap), and so a separate loop for adding captures isn't currently necessary.  In the future though, it would probably be a good idea.
    if piece.has_second_move
      piece.mov_vecs2.each do |v|
        moves.concat iterate_move(v, w_old, piece, :bansidh_move)
      end
    end
    if piece.has_different_first_move and not piece.moved
      piece.first_mov_vecs.each do |v|
        moves.concat iterate_move(v, w_old, piece, :move_or_cap)
      end
      if not piece.first_move_same_as_cap
        piece.first_cap_vecs.each do |v|
          moves.concat iterate_move(v, w_old, piece, :normal_capture)
        end
      end
    end
    return moves
  end
  
  def friendly_occupied?(square, player)
    if square.piece
      return square.piece.owner == player
    end
    return false
  end
  
  def side_to_move
    @turn_counter % @players.size
    $turn_counter = @turn_counter % @players.size
  end
  
  def iterate_move(v, w_old, piece, move_type)
    conditions = nil
    extends = nil
    moves = []
    got_this_far_by_flight = false
    w = w_old
    while @board.on_board(w += v) do
      start_square = @board.find(w_old[0],w_old[1])
      end_square = @board.find(w[0],w[1])
      capture_condition = !(friendly_occupied?(end_square,piece.owner) || (!(end_square.piece.nil?) && end_square.piece.magic_immune && got_this_far_by_flight) || (!(end_square.piece.nil?) && end_square.shielded && !piece.owner.equal?(end_square.shielded)) || (!(end_square.piece.nil?) && end_square.possess_protected))
      
      # either piece moves same as it captures, and we can add the move providing it isn't a capture of a friendly piece; or the square isn't occupied, so it doesn't matter whether piece moves same as it captures or not
      if move_type == :move_or_cap
        conditions = ((piece.moves_same_as_cap and capture_condition) or not end_square.occupied?)
        extend_condition = piece.extends_movement
      elsif move_type == :normal_capture
        conditions = capture_condition
        extend_condition = piece.extends_captures
      elsif move_type == :bansidh_move
        conditions = ((piece.moves_same_as_cap and not friendly_occupied?(end_square,piece.owner)) or not end_square.occupied?)
        extend_condition = piece.extends_movement2
      end
      if end_square.landable and conditions and not end_square.excluded.include?(piece.class) and (end_square.level - start_square.level).abs <= 1 and ((start_square.entering_level(2, end_square) == true and not piece.is_a?(Seannaiche)) or (start_square.entering_level(2, end_square) == true and piece.is_a?(Seannaiche) and piece.owner.spells[:hammer] >= 1) or start_square.entering_level(2, end_square) != true) and not @board.find(w[0], w[1]).frozen and not (piece.is_a?(Seannaiche) and (start_square.is_a?(SeannaicheTempleSquare) or end_square.is_a?(SeannaicheTempleSquare)) and start_square.dist_from(end_square) == 2) and not (start_square.level == 2 and end_square.level == 2 and start_square.dist_from(end_square) == 2)        
        pm = PieceMove.new(start_square, end_square, piece)
        # debugger if start_square.x == 15 and start_square.y == 6 and end_square.x == 14 and end_square.y == 5 and @turn_counter == 20 and start_square.piece.owner.non_spell_enabled_moves
        moves.push(pm) if not (not(end_square.piece.nil?) and end_square.piece.magic_immune and start_square.piece.owner.non_spell_enabled_moves and not start_square.piece.owner.non_spell_enabled_moves.find{|m| m.to_s == pm.to_s})
      end
      # if impassable (due to either square type, or a friendly piece being there), stop looking in this direction
      if (not end_square.passable or end_square.occupied? or not extend_condition or (end_square.level - start_square.level).abs >= 1) or end_square.frozen
        if not @active_spells_considered.include?(:flight)
          return moves
        else
          got_this_far_by_flight = true
        end
      end
    end
    return moves
  end
  
  def display_moves
    require "set"
    l = @players[side_to_move].available_moves.map do |m|
      m.to_s
    end
    l = l.to_set.to_a
    p l
  end
  
  def match_move(move_type:, square1_x:nil, square1_y:nil, square2_x:nil, square2_y:nil, promotion_piece:nil, misted:false, player_name:nil)
    types = {0 => :normal, 1 => :mist, 2 => :bolt_kill, 3 => :freeze, 4 => :hammer, 5 => :possess, 6 => :shapeshift, 7 => :flight, 8 => :shield, 9 => :promote, 10 => :bolt_revive, 11 => :cauldron}
    s1 = nil
    if square1_x && square1_y
      s1 = @board.find(square1_x,square1_y)
    end
    @players[side_to_move].available_moves.each do |m|
      conditions = nil
      case types[move_type]
      when :normal
        s2 = @board.find(square2_x,square2_y)
        mist_condition = nil
        if m.is_a?(PieceMove)
          if misted
            mist_condition = m.moving_misted_piece
          else
            mist_condition = !m.moving_misted_piece
          end
        else
          mist_condition = true
        end 
        conditions = m.is_a?(PieceMove) && m.from_square.equal?(s1) && m.to_square.equal?(s2) && mist_condition
      when :bolt_kill
        conditions = m.is_a?(BoltKillMove) && m.effect_square.equal?(s1)
      when :promote
        pp = @@PIECE_MAPPINGS[promotion_piece]
        conditions = m.is_a?(PromoteMove) && m.from_square.equal?(s1) && m.promotion_piece.is_a?(pp)
      when :bolt_revive
        pp = @@PIECE_MAPPINGS[promotion_piece]
        conditions = m.is_a?(BoltReviveMove) && m.promotion_piece.is_a?(pp)
      when :mist
        conditions = m.is_a?(MistMove) && m.effect_square.equal?(s1)
      when :freeze
        conditions = m.is_a?(FreezeMove) && m.effect_square.equal?(s1)
      when :possess
        conditions = m.is_a?(PossessMove)
      when :flight
        conditions = m.is_a?(FlightMove)
      when :shapeshift
        conditions = m.is_a?(ShapeshiftMove)
      when :shield
        conditions = m.is_a?(ShieldMove) && m.effect_square.equal?(s1)
      when :cauldron
        conditions = m.is_a?(CauldronMove)
      end
      if player_name
        conditions = conditions && m.player.name == player_name
      end
      if conditions
        make_move(m)
        # move confirmation should go here
        @last_move_okay = true
        ready_for_move
        return
      end
    end
    if @interactive_mode
      puts "Illegal move: #{move_type} #{square1_x} #{square1_y} #{square2_x} #{square2_y} #{promotion_piece}"
    else
      puts "move invalid"
    end
    @message_log.push "Illegal move: #{move_type} #{square1_x} #{square1_y} #{square2_x} #{square2_y} #{promotion_piece}"
    @last_move_okay = false
  end
  
  def to_move
    puts "#{@players[side_to_move].to_s.colorize(@players[side_to_move].color, @colourised)} to move."
    @message_log.push "#{@players[side_to_move].to_s.colorize(@players[side_to_move].color, @colourised)} to move."
    puts $turn_counter.to_s
  end
  
  def random_move
    random = (@players[side_to_move].available_moves.length)
    make_move(@players[side_to_move].available_moves[rand(random)])
    #make_move(@players[side_to_move].available_moves.#)
    ready_for_move
  end
  
  def ready_for_move
    if @active
      if @interactive_mode
        get_graphic(@board_rotation, @colourised)
        to_move
      else
        puts "move okay"
      end
      # @active_spells.clear
      get_moves(@players[side_to_move])
    else
      if @interactive_mode
        puts "Game over: #{@result}"
      end
      @message_log.push "Game over: #{@result}" 
    end
  end
  
  def takeback
    unmake_move
    ready_for_move
  end
  
  def get_move_list
    p @move_list
  end
  
  def next_turn(n)
    if n>=1
      @turn_counter += n
      
      @active_spells.clear
      @players[side_to_move].piece_list.each do |p|
        p.set_vecs
      end
      if @players[side_to_move].shielded_square
        @players[side_to_move].shielded_square.shielded= nil
        @players[side_to_move].shielded_square= nil
      end
      if @players[side_to_move].possess_protected_square
        @players[side_to_move].possess_protected_square.possess_protected= false
        @players[side_to_move].possess_protected_square= nil
      end
    end
    while not @players[side_to_move].active
      @turn_counter += 1
    end
  end
  
  def can_cast_magic(player)
    s = player.find_piece(Seannaiche)
    return ((s and s.square.equal?(@board.cauldron)) or (player.piece_list.select{|p| p.is_a?(Bansidh) and p.square.is_a?(BansidhTempleSquare) and p.square.owner.equal?(player)}.size >= 1))
  end
  
  def resurrect(player, piece)
    temple_square = @board.flattened.find{|s| s.class == SeannaicheTempleSquare and s.owner.equal?(player)}
    if temple_square.occupied?
      player.waiting_pieces.push piece
    else
      place_piece(temple_square, piece)
    end
  end
  
  def generate_promotions(type,piece=nil)
    @@PIECE_MAPPINGS.values.each do |q|
    r = @piece_list.find{|x| x.is_a?(q) and x.square.nil? and x.owner.equal?(piece.owner)}
      if r
          moves.push(PromoteMove.new(piece.square, @board.cauldron, r, piece))
      end
    end
  end
  
  def rotate_board
    @board_rotation = @board_rotation + 1 % 4
    get_graphic(@board_rotation, @colourised)
  end
  
  def get_pos2
    l = []
    frontend_pieces = {Clansman => "1", Champion => "2", DiagonalChieftain => "3", LeapingChieftain => "4", SquareChieftain => "5", Seannaiche => "6", Bansidh => "7"}
    players = {@players[0].name => "R", @players[1].name => "W", @players[2].name => "G", @players[3].name => "B"}
    @piece_list.each do |p|
      if p.square
        l.push [players[p.owner.name]+frontend_pieces[p.class], p.square.x, p.square.y]
      end
    end
    puts l.to_s
  end
  
  def message_log_html
    s = StringIO.new
    s << "<div id=\"message_div\">"
    @message_log.each do |l|
      s << "<div>" << l << "</div>"
    end
    s << "</div>"
    s.string
  end
  
  def moves_from_square(square)
    @players[@side_to_move].available_moves.select{|m| m.from_square.equal? square}
  end
  
  def squares_reachable(square)
    moves_from_square(square).map{|m| m.to_square}
  end
  
end

end