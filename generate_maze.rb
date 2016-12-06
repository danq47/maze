# Going to write maze as a class
class Maze
  # Define some class variables
  @@length = 2
  @@width = 2
  attr_reader :visited, :grid, :current_location, :route# won't want this in the end, it's just for debugging along the way

  def initialize
    @current_location = [0,0] # (0,0) is bottom left corner
    @grid = Array.new(@@length){Array.new(@@width) {["N","S","E","W"]}}
# Each point on the grid has 4 attributes - i.e. a wall on the north, south, east, west.
# These are all there to start, however, we can get rid of them as we go
# The only ones that we can't remove are outer walls (i.e. the north wall on the top row etc)
    @visited = Array.new(@@length){Array.new(@@width) {0}} # array of all squares in grid - 0 means not visited, 1 means visited
    @visited[0][0] = 1 # origin starts as visited
    @route = [[0,0]] # Keep track of our route so we can backtrack
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
  def unvisited_neighbours(x,y)
    raise ArgumentError if not valid_point(x,y)
    neighbours = Hash[ "N" => [x,y+1], "S" => [x,y-1], "E" => [x+1,y], "W" => [x-1,y] ]
    neighbours.delete_if { |key, value| not valid_point(value[0],value[1]) }
    neighbours.delete_if { |key, value| @visited[value[1]][value[0]] != 0 }
  end

# takes input as old current location (x,y), and moves to new current location (@current_location[0],@current_location[1])
  def move_to_unvisited_neighbour(x,y) 
    raise ArgumentError if not valid_point(x,y)
    neighbours = unvisited_neighbours(x,y)
    @current_location = neighbours.values.sample
    @route.append(@current_location) # add to route so we can backtrack
    delete_wall(x,y,@current_location[0],@current_location[1])
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

end

# m1 = Maze.new

# while m1.route != []
#   while 


# m1 = Maze.new
# p m1.move_to_unvisited_neighbour(0,0)

# p m1.visited
# p m1.grid