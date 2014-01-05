directions = require './directions'
Wall = require './wall'

CYCLE_STATES = {
  RACING: 0
  EXPLODING: 1
  DEAD: 2
  WINNER: 3
  INSERTING: 4
}

DIRECTIONS_TO_WALL_TYPES = {}
DIRECTIONS_TO_WALL_TYPES[directions.UP] = {}
DIRECTIONS_TO_WALL_TYPES[directions.UP][directions.UP] = Wall.WALL_TYPES.NORTH_SOUTH
DIRECTIONS_TO_WALL_TYPES[directions.UP][directions.DOWN] = Wall.WALL_TYPES.NORTH_SOUTH
DIRECTIONS_TO_WALL_TYPES[directions.UP][directions.LEFT] = Wall.WALL_TYPES.NORTH_EAST
DIRECTIONS_TO_WALL_TYPES[directions.UP][directions.RIGHT] = Wall.WALL_TYPES.NORTH_WEST
DIRECTIONS_TO_WALL_TYPES[directions.DOWN] = {}
DIRECTIONS_TO_WALL_TYPES[directions.DOWN][directions.UP] = Wall.WALL_TYPES.NORTH_SOUTH
DIRECTIONS_TO_WALL_TYPES[directions.DOWN][directions.DOWN] = Wall.WALL_TYPES.NORTH_SOUTH
DIRECTIONS_TO_WALL_TYPES[directions.DOWN][directions.LEFT] = Wall.WALL_TYPES.SOUTH_EAST
DIRECTIONS_TO_WALL_TYPES[directions.DOWN][directions.RIGHT] = Wall.WALL_TYPES.SOUTH_WEST
DIRECTIONS_TO_WALL_TYPES[directions.LEFT] = {}
DIRECTIONS_TO_WALL_TYPES[directions.LEFT][directions.UP] = Wall.WALL_TYPES.SOUTH_WEST
DIRECTIONS_TO_WALL_TYPES[directions.LEFT][directions.DOWN] = Wall.WALL_TYPES.NORTH_WEST
DIRECTIONS_TO_WALL_TYPES[directions.LEFT][directions.LEFT] = Wall.WALL_TYPES.EAST_WEST
DIRECTIONS_TO_WALL_TYPES[directions.LEFT][directions.RIGHT] = Wall.WALL_TYPES.EAST_WEST
DIRECTIONS_TO_WALL_TYPES[directions.RIGHT] = {}
DIRECTIONS_TO_WALL_TYPES[directions.RIGHT][directions.UP] = Wall.WALL_TYPES.SOUTH_EAST
DIRECTIONS_TO_WALL_TYPES[directions.RIGHT][directions.DOWN] = Wall.WALL_TYPES.NORTH_EAST
DIRECTIONS_TO_WALL_TYPES[directions.RIGHT][directions.LEFT] = Wall.WALL_TYPES.EAST_WEST
DIRECTIONS_TO_WALL_TYPES[directions.RIGHT][directions.RIGHT] = Wall.WALL_TYPES.EAST_WEST

class Cycle
  @STATES: CYCLE_STATES

  constructor: (attributes={})->
    @number = attributes.number
    @x = attributes.x
    @y = attributes.y
    @direction = attributes.direction
    @color = attributes.color
    @state = attributes.state ? CYCLE_STATES.RACING
    @game = attributes.game
    @explosionFrame = 0
    @walls = if attributes.walls?
      (new Wall(wall) for wall in attributes.walls)
    else
      []

  navigate: (movement) ->
    switch movement
      when 27
        @state = CYCLE_STATES.RACING if @active()
      when 105
        @state = CYCLE_STATES.INSERTING if @active()
      when 106
        @turnDown() unless @inserting()
      when 107
        @turnUp() unless @inserting()
      when 104
        @turnLeft() unless @inserting()
      when 108
        @turnRight() unless @inserting()

  inserting: ->
    @state == CYCLE_STATES.INSERTING

  active: ->
    @state == CYCLE_STATES.INSERTING or @state == CYCLE_STATES.RACING

  step: ->
    if @state == CYCLE_STATES.EXPLODING
      if @explosionFrame <= 10
        @explosionFrame++
      else
        @state = CYCLE_STATES.DEAD
    else
      if @state == CYCLE_STATES.INSERTING
        @walls.push new Wall({
          x: @x
          y: @y
          type: @nextWallType()
          direction: @direction
        })

      switch @direction
        when directions.UP
          @y -= 1 unless @y == 0
        when directions.DOWN
          @y += 1 unless @y == (@game.gridSize - 1)
        when directions.LEFT
          @x -= 1 unless @x == 0
        when directions.RIGHT
          @x += 1 unless @x == (@game.gridSize - 2)

  checkCollisionWith: (object)->
    @x == object.x and @y == object.y

  checkCollisions: (cycles)->
    if @state == CYCLE_STATES.RACING or @state == CYCLE_STATES.INSERTING
      bottomWallY = (@game.gridSize - 1)
      rightWallX = (@game.gridSize - 2)
      if (@y == 0 or @x == 0 or @y == bottomWallY or @x == rightWallX)
        @triggerCollision()
        return
      for cycle in cycles
        unless cycle is @
          if @checkCollisionWith(cycle)
            @triggerCollision()
            return
        for wall in cycle.walls
          if @checkCollisionWith(wall)
            @triggerCollision()
            return

  triggerCollision: ->
    @state = CYCLE_STATES.EXPLODING
    @walls.length = 0

  nextWallType: ->
    lastWallDirection = @walls[@walls.length - 1]?.direction ? @direction
    DIRECTIONS_TO_WALL_TYPES[lastWallDirection][@direction]

  turnLeft: -> @direction = directions.LEFT unless @direction is directions.RIGHT
  turnRight: -> @direction = directions.RIGHT unless @direction is directions.LEFT
  turnUp: -> @direction = directions.UP unless @direction is directions.DOWN
  turnDown: -> @direction = directions.DOWN unless @direction is directions.UP

  makeWinner: ->
    @state = Cycle.STATES.WINNER

  toJSON: -> {
    number: @number
    x: @x
    y: @y
    color: @color
    state: @state
    direction: @direction
    explosionFrame: @explosionFrame
    walls: (wall.toJSON() for wall in @walls)
  }

module.exports = Cycle