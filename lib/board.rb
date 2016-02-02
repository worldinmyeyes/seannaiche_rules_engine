require "matrix"

require_relative "square"

module Engine

class Board
  attr_reader :cauldron, :height, :width
  
  def initialize(lines, players, mappings, colourised=true)
    @colourised = colourised
    load_squares(lines, players, mappings)
  end
  
  def find(x,y)
    if x==@cauldron.x and y==@cauldron.y
      return @cauldron
    end
    begin
      return @squares[x][y]
    rescue
      raise "square not on board"
    end
  end
  
  def load_squares(lines, players, mappings)
    @width = lines[0].size/2
    @height = lines.size
    @cauldron = CauldronSquare.new(16,16)
    @squares = []
    0.upto(@height-1) do |i|
      @squares.push([])
      0.upto(@width-1) do |j|
        @squares[i].push([])
      end
    end
    #@squares.push(@cauldron)
    
    i = 0
    lines.each do |l|
      # incrementing by 2 since characters are read in 2's
      (0...@width).to_a.each do |j|
        
        # Temple squares "s" and "b" on the board are treated differently, since they have owners.
        # That is, players who aren't the owner of the square can't be allowed to land on them.
        
        if not (l[2*j] == "s" or l[2*j] == "b")
          @squares[i][j] = mappings[l[2*j]].new(i, j, @colourised) 
        else
          @squares[i][j] = mappings[l[2*j]].new(i, j, players[Integer(l[2*j+1])], @colourised)
        end
      end
      i+=1
    end
  end
  
  def get_rotated_coords(x,y, n)
    v = Vector[x,y]
    c = Vector[@width/2 - 0.5,@height/2 - 0.5]
    v -= c
    # rotation matrix
    a = Matrix[[0,-1], [1,0]]
    a**n * v + c
  end
  
  def rotate(n=0)
    if n==0
      return @squares
    end
    rotated_board = []
    0.upto(@height-1) do |i|
      rotated_board.push([])
      0.upto(@width-1) do |j|
        rotated_board[i].push([])
      end
    end
    0.upto(@height-1) do |i|
      0.upto(@width-1) do |j|
        w = get_rotated_coords(i,j, n)
        rotated_board[i][j] = @squares[w[0]][w[1]]
      end
    end
    rotated_board
  end
  
  def flattened
    @squares.flatten.push(@cauldron)
  end
  
  def on_board(v)
    (0...@width).cover? v[0] and (0...@height).cover? v[1]
  end
end

end