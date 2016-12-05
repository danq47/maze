# First program to generate mazes using recursive backtracking algorithm

# 1. Initialise the grid
$width  = 2
$length = 2

$current_location = [0,0] # (0,0) is bottom left corner

$grid = Array.new($length){Array.new($width) {["N","S","E","W"]}}
# Each point on the grid has 4 attributes - i.e. a wall on the north, south, east, west.
# These are all there to start, however, we can get rid of them as we go
# The only ones that we can't remove are outer walls (i.e. the north wall on the top row etc)

$visited = Array.new($length){Array.new($width) {0}} # array of all squares in grid

# 2. Define function to visit neighbour

def on_board(x,y)
# check point is on board
  if x >= 0 and y >= 0 and x < $width and y < $length
    true
  else
    false
  end
end

# def unvisited_neighbours(x,y)
#   raise ArgumentError if not on_board(x,y)
#   neighbours = [ [x,y+1], [x,y-1], [x+1,y], [x-1,y] ]
#   neighbours.each { |x| neighbours.delete(x) if not on_board(x[0],x[1]) }
#   neighbours.each { |x| neighbours.delete(x) if $visited[x[1]][x[0]] != 0 }
# end

def unvisited_neighbours(x,y)
  raise ArgumentError if not on_board(x,y)
  neighbours = Hash[ "N" => [x,y+1], "S" => [x,y-1], "E" => [x+1,y], "W" => [x-1,y] ]
  neighbours.delete_if { |key, value| not on_board(value[0],value[1]) }
  neighbours.delete_if { |key, value| $visited[value[1]][value[0]] != 0 }
end

def move_to_neighbour(x,y)
  raise ArgumentError if not on_board(x,y)
  neighbours = unvisited_neighbours(x,y)
  $current_location = neighbours.values.sample
  delete_wall(x,y,$current_location[0],$current_location[1])
end

def delete_wall(x1,y1,x2,y2) # (x1,y1) is the initial point, (x2,y2) final
  # raise ArgumentError if not on_board(x1,y1) or not on_board(x2,y2)
  move = [x2 - x1, y2 - y1]
# Figure out which walls this move means we must delete
# Will make a hash, where the first direction is the wall to delete on the origin cell,
# and the second in the hash value is the wall in the destination cell
  walls_to_delete = Hash[ [1,0] => ["E","W"], [-1,0] => ["W","E"], [0,1] => ["N","S"], [0,-1] => ["S","N"] ]

  $grid[y1][x1].delete(walls_to_delete[move][0])
  $grid[y2][x2].delete(walls_to_delete[move][1])

end

