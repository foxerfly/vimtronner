buffer = require './buffer'

WALL_TYPES = {
  EAST_WEST: 0
  NORTH_SOUTH: 1
  SOUTH_WEST: 2
  NORTH_WEST: 3
  NORTH_EAST: 4
  SOUTH_EAST: 5
}

WALL_CHARACTERS = {}
WALL_CHARACTERS[WALL_TYPES.EAST_WEST] = buffer(0xE2, 0x94, 0x80)
WALL_CHARACTERS[WALL_TYPES.NORTH_SOUTH] = buffer(0xE2, 0x94, 0x82)
WALL_CHARACTERS[WALL_TYPES.SOUTH_WEST] = buffer(0xE2, 0x94, 0x94)
WALL_CHARACTERS[WALL_TYPES.NORTH_WEST] = buffer(0xE2, 0x94, 0x8C)
WALL_CHARACTERS[WALL_TYPES.NORTH_EAST] = buffer(0xE2, 0x94, 0x90)
WALL_CHARACTERS[WALL_TYPES.SOUTH_EAST] = buffer(0xE2, 0x94, 0x98)

class Wall
  constructor: (@x, @y, @type, @direction)->

  character: -> WALL_CHARACTERS[@type]

  @WALL_TYPES: WALL_TYPES

  toJSON: -> {
    x: @x
    y: @y
    type: @type
    direction: @direction
  }

module.exports = Wall
