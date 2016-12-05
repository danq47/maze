# First program to generate mazes using recursive backtracking algorithm

# 1. Initialise the grid
$width  = 2
$length = 4
$start = [0,0]

grid = Array.new($length){Array.new($width) {["N","S","E","W"]}}
# Each point on the grid has 4 attributes - i.e. a wall on the north, south, east, west.
# These are all there to start, however, we can get rid of them as we go
# The only ones that we can't remove are outer walls (i.e. the north wall on the top row etc)

have_visited = Array.new($length){Array.new($width) {0}} # array of all squares in grid

# 2. Define function to visit neighbour
def find_neighbours(x,y)
  raise ArgumentError if x >= $width or y >= $length
  neighbours = [[x,y+1],[x,y-1],[x+1,y],[x-1,y]]
  neighbours.each { |i| neighbours.delete(i) if i[0] < 0 or 
    i[1] < 0 or
    i[1] >= $length or
    i[0] >= $width}
    neighbours
end

p find_neighbours(1,1)
