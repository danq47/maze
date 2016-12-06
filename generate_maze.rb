# Going to write maze as a class
class Maze
  # Define some class variables
  @@length = 5
  @@width = 5
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
    @facing = "N" # we start facing north (maybe later we can change this)
    @current_location_solution = @maze_start
    @route_to_finish = [@maze_start] # This will be how many steps it takes to get from the start to the finish
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
    raise ArgumentError if not valid_point(x,y)
    neighbours = unvisited_neighbours
    @current_location = neighbours.values.sample
    @route.push(@current_location) # add to route so we can backtrack
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

  def can_turn_left
# We need to check if a different wall exisits depending on which way we are facing
    wall_to_check = Hash[ "N" => "W", "W" => "S", "S" => "E", "E" => "N"]
    if @grid[@current_location_solution[1]][@current_location_solution[0]].include? wall_to_check[@facing]
      return false
    else
      return true
    end
  end

  def can_go_straight
    if @grid[@current_location_solution[1]][@current_location_solution[0]].include? @facing
      return false
    else
      return true
    end
  end

  def can_turn_right
# We need to check if a different wall exisits depending on which way we are facing
    wall_to_check = Hash[ "N" => "E", "W" => "N", "S" => "W", "E" => "S"]
    if @grid[@current_location_solution[1]][@current_location_solution[0]].include? wall_to_check[@facing]
      return false
    else
      return true
    end
  end

  def move_forward
    move = Hash[ "N" => [@current_location_solution[0],@current_location_solution[1]+1],
    "W" => [@current_location_solution[0]-1,@current_location_solution[1]], 
    "S" => [@current_location_solution[0],@current_location_solution[1]-1],
    "E" => [@current_location_solution[0]+1,@current_location_solution[1]] ]
    @current_location_solution = move[@facing]
    @route_to_finish.push(@current_location_solution)
  end

  def left_hand_rule
# We will implement a rule where we always keep our left hand on the wall.
# Therefore, if we CAN turn left, we will
# Will implement this by doing a change of compass directions and then moving forward one space
# To start, we will implement this in the most basic way possible, but we can improve later on
# For example, if the goal is in the line of sight, ignore the algorithm and simply move towards it
# Also maybe there is a smart way to choose which initial direction to go in
    left_turn = Hash[ "N" => "W", "W" => "S", "S" => "E", "E" => "N"] # this is what happens to our @facing direction
    right_turn = left_turn.invert # this is a new hash, with the opposite directions
    p @facing
    if can_turn_left
      @facing = left_turn[@facing]
      move_forward
    elsif can_go_straight
      # no_turn
      move_forward
    elsif can_turn_right
      @facing = right_turn[@facing]
      move_forward
    else
      @facing = left_turn[left_turn[@facing]]
      move_forward
    end
  end

  def lhr_algorithm
    p "Start:#{@maze_start},End:#{@maze_end}"
    while @current_location_solution != @maze_end
      left_hand_rule
      p "Current location:#{@current_location_solution}"
    end
  end

end

m1 = Maze.new
puts m1.print_maze
m1.lhr_algorithm
