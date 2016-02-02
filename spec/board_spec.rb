require_relative "spec_helper"

describe Board do
  before do
    @b = Board.new(16,16,4)
  end
  
  describe "#load_squares" do
    it "creates the correct number of squares" do
      @b.load_squares
      @b.squares.flatten.size.should eq(16*16)
    end
  end
    
  describe "#places_piece" do
    it "places a piece on the given square" do
      @b.place_piece(@b.squares[5][5], Champion.new(@b.squares[5][5], @b.players[0]))
      @b.squares[5][5].piece.instance_of?(Champion).should eq(true)
    end
  end
  
  describe "#get_graphic" do
    it "returns a textual representation of the board" do
      # note: different sides should be represented by different colours
      @b.get_graphic(false).should eq( "\
b = = B R L D C C D L R S * * b
* = * * P P P P P P P P * * = =
* * = * - - - - - - - - * = * =
S * * - - - - - - - - - - * * B
R P - - - - - - - - - - - - P R
L P - - - - - - - - - - - - P L
D P - - - - - ' ' - - - - - P D
C P - - - - ' + + ' - - - - P C
C P - - - - ' + + ' - - - - P C
D P - - - - - ' ' - - - - - P D
L P - - - - - - - - - - - - P L
R P - - - - - - - - - - - - P R
B * * - - - - - - - - - - * * S
= * = * - - - - - - - - * = * *
= = * * P P P P P P P P * * = *
b * * S R L D C C D L R B = = b")
    end
   end
   
   describe "#load_pieces" do
     it "reads the pieces from a string and places them on the board" do
       @b.load_pieces
       @b.squares[3][0].piece.instance_of?(Seannaiche).should eq(true)
     end
   end
   
   describe "#make_move" do
     it "makes the appropriate piece movement on the board" do
       m = PieceMove.new(@b.squares[7][1], @b.squares[7][3])
       @b.load_pieces
       @b.make_move(m)
       b1 = @b.squares.clone
       @b.load_pieces(
"- * * B2R2L2D2C2C2D2L2R2S2* * -
* * * * P2P2P2P2P2P2P2P2* * * *
* * * * - - - - - - - - * * * *
S1* * - - - - - - - - - - * * B3
R1P1- - - - - - - - - - - - P3R3
L1P1- - - - - - - - - - - - P3L3
D1P1- - - - - ' ' - - - - - P3D3
C1- - P1- ' + + ' - - - - - P3C3
C1P1- - - - ' + + ' - - - - P3C3
D1P1- - - - - ' ' - - - - - P3D3
L1P1- - - - - - - - - - - - P3L3
R1P1- - - - - - - - - - - - P3R3
B1* * - - - - - - - - - - * * S3
* * * * - - - - - - - - * * * *
* * * * P0P0P0P0P0P0P0P0* * * *
- * * S0R0L0D0C0C0D0L0R0B0* * -")
       b2 = @b.squares.clone
       b1.should eq b2
     end
   end
   
   describe "#on_board" do
     it "returns whether or not a square is on the board" do
       @b.on_board(Vector[16,16]).should eq(false)
       @b.on_board(Vector[25,8]).should eq(false)
       @b.on_board(Vector[3,-1]).should eq(false)
       @b.on_board(Vector[0,0]).should eq(true)
       @b.on_board(Vector[15,15]).should eq(true)
     end
   end
   
   describe "#get_moves(player)" do
     it "should find 50 moves for the initial position" do
       require "set"
       @b.get_moves(@b.players[@b.side_to_move])
       @b.players[@b.side_to_move].available_moves.to_set.to_a.size.should eq(50)
     end
   end
   
   describe "move list" do
     it "should not contain duplicate moves" do
       require "set"
       a = @b.players[@b.side_to_move].available_moves
       b = a.to_set.to_a
       a.size.should eq(b.size)
     end
   end
   
   # takeback in initial position shouldn't cause an error
end  
     