# Going to write maze as a class
class Maze
  # Define some class variables
  @@length = 20
  @@width = 20
  attr_reader :visited, :grid, :current_location, :route# won't want this in the end, it's just for debugging along the way

  def initialize
    @grid = Array.new(@@length){Array.new(@@width) {["N","S","E","W"]}}
# Each point on the grid has 4 attributes - i.e. a wall on the north, south, east, west.
# These are all there to start, however, we can get rid of them as we go
# The only ones that we can't remove are outer walls (i.e. the north wall on the top row etc)
    @visited = Array.new(@@length){Array.new(@@width) {0}} # array of all squares in grid - 0 means not visited, 1 means visited
    @start = [(0...@@width).to_a.sample,(0...@@length).to_a.sample] # Choose a random point to start
    @current_location = @start
    @visited[@start[1]][@start[0]] = 1
    @route = [visited[@start[1]][@start[0]]] # Keep track of our route so we can backtrack
    generate_maze
    add_start_and_finish
  end

# check point is within our defined ranges
  def valid_point(x,y)
    if x >= 0 and y >= 0 and x < @@width and y < @@length
      true
    else
      false
    end
  end

# Find which neighbours are unvisited
  def unvisited_neighbours
    x = @current_location[0]
    y = @current_location[1]
    raise ArgumentError if not valid_point(x,y)
    neighbours = Hash[ "N" => [x,y+1], "S" => [x,y-1], "E" => [x+1,y], "W" => [x-1,y] ]
    neighbours.delete_if { |key, value| not valid_point(value[0],value[1]) }
    neighbours.delete_if { |key, value| @visited[value[1]][value[0]] != 0 }
  end

# takes input as old current location (x,y), and moves to new current location (@current_location[0],@current_location[1])
  def move_to_unvisited_neighbour
    x = @current_location[0]
    y = @current_location[1]
    # p "x:#{x},y:#{y},cx:#{current_location[0]},cy:#{current_location[1]}"
    raise ArgumentError if not valid_point(x,y)
    neighbours = unvisited_neighbours
    @current_location = neighbours.values.sample
    # p "x:#{x},y:#{y},cx:#{current_location[0]},cy:#{current_location[1]}"
    @route.push(@current_location) # add to route so we can backtrack
    delete_wall(x,y,@current_location[0],@current_location[1])
    # p "x:#{x},y:#{y},cx:#{current_location[0]},cy:#{current_location[1]}"
    @visited[@current_location[1]][@current_location[0]] = 1
  end

  def delete_wall(x1,y1,x2,y2) # (x1,y1) is the initial point, (x2,y2) final
    move = [x2 - x1, y2 - y1] # each of the 4 possible moves will correspond to a certain pair of walls to delete
# Assign moves to a hash, with value[0]=wall to delete in origin cell, value[1]=wall to delete in final cell
    walls_to_delete = Hash[ [1,0] => ["E","W"], [-1,0] => ["W","E"], [0,1] => ["N","S"], [0,-1] => ["S","N"] ]
    @grid[y1][x1].delete(walls_to_delete[move][0])
    @grid[y2][x2].delete(walls_to_delete[move][1])
  end

  def backtrack
    @route.pop
    @current_location = @route[-1]
  end

  def generate_maze
    while route != []
      while unvisited_neighbours != {}
        move_to_unvisited_neighbour
      end
      backtrack
    end
  end

  def add_start_and_finish
# Add a start and finish to the maze so that we can start to look at solving it
    @maze_start = [(0...@@width).to_a.sample,(0...@@length).to_a.sample]
    @maze_end = [(0...@@width).to_a.sample,(0...@@length).to_a.sample]
  end

  def print_maze

    output = []
    @grid.each {|y| 
      line = "|"
      y.each { |x| # skip final one, as we know that it will have a 
        if x.include? "E" and x.include? "S" # put in east and north walls
          line << "_|"
        elsif x.include? "E" and not x.include? "S"
          line << " |"
        elsif x.include? "S" and not x.include? "E"
          line << "__"
        else
          line << "  "
        end }
      line << "\n" 

      output.push(line) } 

    upper_border = " " << "_" * (@@width * 2 - 1) <<"\n"
    output.push(upper_border)
    output.reverse!

  end

end

# m1 = Maze.new

# # puts m1.print_maze

# # puts "test"

# # out = open("maze.txt","w")
# # m1.print_maze.each { |line| out.write(line) }
