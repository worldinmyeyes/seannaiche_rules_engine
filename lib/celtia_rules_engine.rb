require_relative "game"
require_relative "string"
require "pry"
require "readline"

module Engine

class CeltiaRulesEngine
  
  attr_accessor :games, :current_game
  
  @@COMMANDS = ["new", "move", "display_moves", "to_move", "exit", "random_move", "interactive", "takeback", "move_special", "move_list", "save", "pass", "load_pos", "load", "rotate", "run_tests", "colour", "commands", "clear", "purge", "list_games", "list_spells", "get_pos2"].sort
  @@MAX_GAMES = 1024
  @@MAGIC_NUMBERS = {normal: 0, mist: 1, bolt_kill: 2, freeze: 3, hammer: 4, possess: 5, shapeshift: 6, flight: 7, shield: 8, promote: 9, bolt_revive: 10, cauldron: 11}
    
  
  def self.commands
    @@COMMANDS
  end
  
  def initialize(cmd_line_mode=true, interactive_mode=true, colourised=true)
    @games = []
    @current_game = 0
    @interactive_mode = interactive_mode
    @colourised = colourised
    
    if cmd_line_mode
      comp = proc {|s| @@COMMANDS.grep(/^#{Regexp.escape(s)}/)}
      Readline.completion_append_character = " "
      Readline.completion_proc = comp
      in_game = false
      #binding.pry
      while line = Readline.readline('> ', true) do
        while in_game == true do
          handle_line_game(line)
        end
        handle_line(line)
      end
    end
  end
  
  def handle_line(line)
    s = line.split(" ")
    if s[0] =~ /^exit$/i
      exit 0
    elsif s[0] =~ /^new$/i
      in_game = true
      if @games.size==@@MAX_GAMES
        handle_line("purge_inactive")
      end
      
      g = nil
      if s.size==2 and @games.size<=@@MAX_GAMES
        g = Game.new(4, s[1], @interactive_mode, @colourised) 
      elsif s.size==1 and @games.size<=@@MAX_GAMES
        g = Game.new(4, @games.size.to_s, @interactive_mode, @colourised)
      elsif s.size==3 and @games.size<=@@MAX_GAMES
        g = Game.new(s[2].to_i, s[1], @interactive_mode, @colourised)
      end
      @games.push g
      @current_game = @games.index(g)
      
    elsif s[0] =~ /^move$/i or s[0] =~ /^move2$/i 
      if @games[@current_game].nil?
        puts "No game in progress."
      else
        extra_param = nil
        if s[0] =~ /^move2$/i
          extra_param = s[5]
        else
          extra_param = nil
        end
        @games[@current_game].match_move(move_type: 0, square1_x: s[1].to_i, square1_y: s[2].to_i, square2_x: s[3].to_i, square2_y: s[4].to_i, player_name: extra_param)
      end
    elsif s[0] =~ /^move_special$/i or s[0] =~ /^move_special_fail$/i
      if @games[@current_game].nil?
        puts "No game in progress."
      else
        case s[1].to_i
        when @@MAGIC_NUMBERS[:normal]
          @games[@current_game].match_move(move_type:0, square1_x: s[2].to_i,square1_y: s[3].to_i,square2_x: s[4].to_i,square2_y: s[5].to_i, misted: (s.size==7 ? s[6].to_i==1 : false))
        when @@MAGIC_NUMBERS[:mist]
          @games[@current_game].match_move(move_type: 1, square1_x: s[2].to_i, square1_y: s[3].to_i)
        when @@MAGIC_NUMBERS[:bolt_kill]
          @games[@current_game].match_move(move_type: 2, square1_x: s[2].to_i, square1_y: s[3].to_i)
        when @@MAGIC_NUMBERS[:freeze]
          @games[@current_game].match_move(move_type: 3, square1_x: s[2].to_i, square1_y: s[3].to_i)
        when @@MAGIC_NUMBERS[:possess]
          @games[@current_game].match_move(move_type: 5)
        when @@MAGIC_NUMBERS[:shapeshift]
          @games[@current_game].match_move(move_type: 6)
        when @@MAGIC_NUMBERS[:flight]
          @games[@current_game].match_move(move_type: 7)
        when @@MAGIC_NUMBERS[:shield]
          @games[@current_game].match_move(move_type: 8, square1_x: s[2].to_i, square1_y: s[3].to_i)
        when @@MAGIC_NUMBERS[:promote]
          @games[@current_game].match_move(move_type: 9, square1_x: s[2].to_i, square1_y: s[3].to_i, promotion_piece: s[4])
        when @@MAGIC_NUMBERS[:bolt_revive]
          @games[@current_game].match_move(move_type: 10, promotion_piece: s[2])
        when @@MAGIC_NUMBERS[:cauldron]
          @games[@current_game].match_move(move_type: 11)
        end
      end
    elsif s[0] =~ /^display_moves$/i
      @games[@current_game].display_moves
    elsif s[0] =~ /^move_list$/i
      @games[@current_game].get_move_list
    elsif s[0] =~ /^to_move$/i
      @games[@current_game].to_move
    # TODO: user should be able to specify a move, but right now duplicate moves are generated (duplicates are only removed from the display_moves output, not the player's available moves)
    elsif s[0] =~ /^random_move$/i
      @games[@current_game].random_move
    elsif s[0] =~ /^interactive$/i
      if Integer(s[1]) == 1
        @games[@current_game].interactive_mode= true
      elsif Integer(s[1]) == 0
        @games[@current_game].interactive_mode= false
      end
    elsif s[0] =~ /^takeback$/i
      @games[@current_game].takeback
    elsif s[0] =~ /^save$/i
      name = s[1]
      f = File.open(name, "w")
      while not Readline::HISTORY.empty?
        if Readline::HISTORY[0] =~ /^save/i
          Readline::HISTORY.shift
        else
          f.puts Readline::HISTORY.shift
        end
      end
      f.close
    elsif s[0] =~ /^pass$/i
      @games[@current_game].next_turn(1)
      @games[@current_game].ready_for_move
      @games[@current_game].last_move_okay = true
    elsif s[0] =~ /^load_pos$/i
      @games[@current_game].load_pieces(s[1])
    elsif s[0] =~ /^load$/i
      f = File.open(s[1], "r")
      f.readlines.each do |l|
        handle_line(l)
      end
    elsif s[0] =~ /^set_game$/i
      @current_game = @games.index {|h| h.game_id == s[1]}
    elsif s[0] =~ /^rotate$/i
      @games[@current_game].rotate_board
    elsif s[0] =~ /^run_tests$/i
      error_count = 0
      f = File.open("./test/output.txt", "w")
      $stdout = f
      g = File.open("./test/log.txt", "w")
      Dir.glob("./test/test_games/*") do |path|
        STDOUT.puts path
        h = File.open(path, "r")
        lines = h.readlines
        lines.each_with_index do |l, i|
          handle_line(l)
          @games[@current_game].colourised= false if i==0
          if (not @games[@current_game].last_move_okay and not l =~ /^move_special_fail/i) or (@games[@current_game].last_move_okay and l =~ /^move_special_fail/i) 
            g.puts "failure in #{path} at line #{i+2}, turn #{@games[@current_game].turn_counter}: \"#{l.chomp}\""
            error_count += 1           
          end
        end
        h.close
      end
      f.close
      g.close
      $stdout = STDOUT
      puts "Completed with #{error_count} errors.  See log.txt for details."
    elsif s[0] =~ /^colour$/i
      @games[@current_game].colourised= s[1].to_i == 1
    elsif s[0] =~ /^commands$/i
      puts @@COMMANDS
    elsif s[0] =~ /^clear$/
      @games.clear
    elsif s[0] =~ /^purge$/
      @games.reject! {|h| not h.active}
    elsif s[0] =~ /^list_games$/
      p @games.select{|h| h.active}
    elsif s[0] =~ /^list_spells$/
      spells = @games[@current_game].players.find{|p| p.name == s[1]}.spells
      spells_hash = "{"
      spells.keys.each do |t|
        spells_hash += "#{t}: #{spells[t]}"
        spells_hash += ", " if not t.equal?(spells.keys.last)
      end
      spells_hash += "}"
      print spells_hash
    elsif s[0] =~ /^get_pos2$/
      @games[@current_game].get_pos2
    elsif line.strip == ""
      
    else
      puts "command not recognised"
    end
  end

  def handle_line_game(line)
    s = line.split(" ")
    if s[0] =~ /^exit$/i
      #exit 0
      in_game = false
    elsif s[0] =~ /^new$/i
      if @games.size==@@MAX_GAMES
        handle_line("purge_inactive")
      end
      
      g = nil
      if s.size==2 and @games.size<=@@MAX_GAMES
        g = Game.new(4, s[1], @interactive_mode, @colourised) 
      elsif s.size==1 and @games.size<=@@MAX_GAMES
        g = Game.new(4, @games.size.to_s, @interactive_mode, @colourised)
      elsif s.size==3 and @games.size<=@@MAX_GAMES
        g = Game.new(s[2].to_i, s[1], @interactive_mode, @colourised)
      end
      @games.push g
      @current_game = @games.index(g)
      #binding.pry
    elsif s[0] =~ /^move$/i or s[0] =~ /^move2$/i 
      if @games[@current_game].nil?
        puts "No game in progress."
      else
        extra_param = nil
        if s[0] =~ /^move2$/i
          extra_param = s[5]
        else
          extra_param = nil
        end
        @games[@current_game].match_move(move_type: 0, square1_x: s[1].to_i, square1_y: s[2].to_i, square2_x: s[3].to_i, square2_y: s[4].to_i, player_name: extra_param)
      end
    elsif s[0] =~ /^move_special$/i or s[0] =~ /^move_special_fail$/i
      if @games[@current_game].nil?
        puts "No game in progress."
      else
        case s[1].to_i
        when @@MAGIC_NUMBERS[:normal]
          @games[@current_game].match_move(move_type:0, square1_x: s[2].to_i,square1_y: s[3].to_i,square2_x: s[4].to_i,square2_y: s[5].to_i, misted: (s.size==7 ? s[6].to_i==1 : false))
        when @@MAGIC_NUMBERS[:mist]
          @games[@current_game].match_move(move_type: 1, square1_x: s[2].to_i, square1_y: s[3].to_i)
        when @@MAGIC_NUMBERS[:bolt_kill]
          @games[@current_game].match_move(move_type: 2, square1_x: s[2].to_i, square1_y: s[3].to_i)
        when @@MAGIC_NUMBERS[:freeze]
          @games[@current_game].match_move(move_type: 3, square1_x: s[2].to_i, square1_y: s[3].to_i)
        when @@MAGIC_NUMBERS[:possess]
          @games[@current_game].match_move(move_type: 5)
        when @@MAGIC_NUMBERS[:shapeshift]
          @games[@current_game].match_move(move_type: 6)
        when @@MAGIC_NUMBERS[:flight]
          @games[@current_game].match_move(move_type: 7)
        when @@MAGIC_NUMBERS[:shield]
          @games[@current_game].match_move(move_type: 8, square1_x: s[2].to_i, square1_y: s[3].to_i)
        when @@MAGIC_NUMBERS[:promote]
          @games[@current_game].match_move(move_type: 9, square1_x: s[2].to_i, square1_y: s[3].to_i, promotion_piece: s[4])
        when @@MAGIC_NUMBERS[:bolt_revive]
          @games[@current_game].match_move(move_type: 10, promotion_piece: s[2])
        when @@MAGIC_NUMBERS[:cauldron]
          @games[@current_game].match_move(move_type: 11)
        end
      end
    elsif s[0] =~ /^display_moves$/i
      @games[@current_game].display_moves
    elsif s[0] =~ /^move_list$/i
      @games[@current_game].get_move_list
    elsif s[0] =~ /^to_move$/i
      @games[@current_game].to_move
    # TODO: user should be able to specify a move, but right now duplicate moves are generated (duplicates are only removed from the display_moves output, not the player's available moves)
    elsif s[0] =~ /^random_move$/i
      @games[@current_game].random_move
    elsif s[0] =~ /^interactive$/i
      if Integer(s[1]) == 1
        @games[@current_game].interactive_mode= true
      elsif Integer(s[1]) == 0
        @games[@current_game].interactive_mode= false
      end
    elsif s[0] =~ /^takeback$/i
      @games[@current_game].takeback
    elsif s[0] =~ /^save$/i
      name = s[1]
      f = File.open(name, "w")
      while not Readline::HISTORY.empty?
        if Readline::HISTORY[0] =~ /^save/i
          Readline::HISTORY.shift
        else
          f.puts Readline::HISTORY.shift
        end
      end
      f.close
    elsif s[0] =~ /^pass$/i
      @games[@current_game].next_turn(1)
      @games[@current_game].ready_for_move
      @games[@current_game].last_move_okay = true
    elsif s[0] =~ /^load_pos$/i
      @games[@current_game].load_pieces(s[1])
    elsif s[0] =~ /^load$/i
      f = File.open(s[1], "r")
      f.readlines.each do |l|
        handle_line(l)
      end
    elsif s[0] =~ /^set_game$/i
      @current_game = @games.index {|h| h.game_id == s[1]}
    elsif s[0] =~ /^rotate$/i
      @games[@current_game].rotate_board
    elsif s[0] =~ /^run_tests$/i
      error_count = 0
      f = File.open("./test/output.txt", "w")
      $stdout = f
      g = File.open("./test/log.txt", "w")
      Dir.glob("./test/test_games/*") do |path|
        STDOUT.puts path
        h = File.open(path, "r")
        lines = h.readlines
        lines.each_with_index do |l, i|
          handle_line(l)
          @games[@current_game].colourised= false if i==0
          if (not @games[@current_game].last_move_okay and not l =~ /^move_special_fail/i) or (@games[@current_game].last_move_okay and l =~ /^move_special_fail/i) 
            g.puts "failure in #{path} at line #{i+2}, turn #{@games[@current_game].turn_counter}: \"#{l.chomp}\""
            error_count += 1           
          end
        end
        h.close
      end
      f.close
      g.close
      $stdout = STDOUT
      puts "Completed with #{error_count} errors.  See log.txt for details."
    elsif s[0] =~ /^colour$/i
      @games[@current_game].colourised= s[1].to_i == 1
    elsif s[0] =~ /^commands$/i
      puts @@COMMANDS
    elsif s[0] =~ /^clear$/
      @games.clear
    elsif s[0] =~ /^purge$/
      @games.reject! {|h| not h.active}
    elsif s[0] =~ /^list_games$/
      p @games.select{|h| h.active}
    elsif s[0] =~ /^list_spells$/
      spells = @games[@current_game].players.find{|p| p.name == s[1]}.spells
      spells_hash = "{"
      spells.keys.each do |t|
        spells_hash += "#{t}: #{spells[t]}"
        spells_hash += ", " if not t.equal?(spells.keys.last)
      end
      spells_hash += "}"
      print spells_hash
    elsif s[0] =~ /^get_pos2$/
      @games[@current_game].get_pos2
    elsif line.strip == ""
      
    else
      puts "command not recognised"
    end
  end
end

end

#for testing purposes, with IDE's that can't interpret the executable ruby files
#engine = Engine::CeltiaRulesEngine.new(true)
