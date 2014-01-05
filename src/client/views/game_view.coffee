require '../../define_property.coffee'

screen = require '../screen'
buffer = require '../buffer'
Game = require '../../models/game'
Cycle = require '../../models/cycle'
CycleView = require './cycle_view'
playerColors = require './player_colors'

ARENA_WALL_CHARS = {
  HORIZONTAL: buffer(0xE2, 0x95, 0x90)
  VERTICAL: buffer(0xE2, 0x95, 0x91)
  TOP_LEFT_CORNER: buffer(0xE2, 0x95, 0x94)
  TOP_RIGHT_CORNER: buffer(0xE2, 0x95, 0x97)
  BOTTOM_LEFT_CORNER: buffer(0xE2, 0x95, 0x9A)
  BOTTOM_RIGHT_CORNER: buffer(0xE2, 0x95, 0x9D)
}

CYCLE_NUMBER_NAMES = {
  1: 'ONE'
  2: 'TWO'
  3: 'THREE'
  4: 'FOUR'
  5: 'FIVE'
  6: 'SIX'
  7: 'SEVEN'
  8: 'EIGHT'
}

cycleNumberName = (cycleNumber)-> CYCLE_NUMBER_NAMES[cycleNumber]

class GameView

  constructor: ->
    @cycleViews = []
    @countString = ''

  @property 'state', get: -> @_game?.state
  @property 'game', {
    set: (game)->
      @_game = game
      @startX = Math.round(screen.center - (@_game.gridSize/2))
      if @_game.count != @lastCount and @state == Game.STATES.COUNTDOWN
        @lastCount = @_game.count
        @countString += "#{@_game.count}..."
      @generateCycleViews()
    get: -> @_game
  }
  @property 'stateString', get: ->
    switch @_game?.state
      when Game.STATES.WAITING then 'Waiting for other players'
      when Game.STATES.COUNTDOWN then 'Get ready'
      when Game.STATES.STARTED then 'Go'
      when Game.STATES.FINISHED then 'Game over'

  generateCycleViews: ->
    @cycleViews = (new CycleView(cycle, @_game, @startX) for cycle in @_game.cycles)

  render: ->
    screen.clear()
    if @state == Game.STATES.WAITING
      @renderWaitScreen()
    else if @state == Game.STATES.COUNTDOWN
      @renderCountdown()
    else
      @renderArena()
      @renderCycleViews()
    @renderGameInfo()

  renderArena: ->
    screen.setForegroundColor 3
    xRange = @game.gridSize - 1
    yRange = @game.gridSize - 1
    endX = @startX + @game.gridSize
    endY = @game.gridSize
    screen.moveTo(@startX,1)
    screen.render ARENA_WALL_CHARS.TOP_LEFT_CORNER
    for x in [1..xRange]
      screen.moveTo (@startX + x), 1
      screen.render ARENA_WALL_CHARS.HORIZONTAL
    screen.moveTo endX, 1
    screen.render ARENA_WALL_CHARS.TOP_RIGHT_CORNER
    for y in [2..yRange]
      screen.moveTo endX, y
      screen.render ARENA_WALL_CHARS.VERTICAL
    screen.moveTo endX, endY
    screen.render ARENA_WALL_CHARS.BOTTOM_RIGHT_CORNER
    for x in [xRange..1]
      screen.moveTo (@startX + x), endY
      screen.render ARENA_WALL_CHARS.HORIZONTAL
    screen.moveTo @startX, endY
    screen.render ARENA_WALL_CHARS.BOTTOM_LEFT_CORNER
    for y in [yRange..2]
      screen.moveTo @startX, y
      screen.render ARENA_WALL_CHARS.VERTICAL

  renderWaitScreen: ->
    @renderArena()
    instructions = [
      'left............h'
      'down............j'
      'up..............k'
      'right...........l'
      'insert mode.....i'
      'normal mode...esc'
    ]
    centerX = @startX + Math.round(@game.gridSize/2)
    y = Math.round(@game.gridSize/2) - 4
    screen.setForegroundColor 6
    screen.print('vimTronner', centerX, y, screen.TEXT_ALIGN.CENTER)
    y += 2
    screen.resetColors()
    screen.print(instructions[i], centerX, y + i, screen.TEXT_ALIGN.CENTER) for i in [0...instructions.length]
    y += instructions.length + 1
    screen.setForegroundColor playerColors(@cycleNumber)
    screen.print("READY PLAYER #{cycleNumberName(@cycleNumber)}", centerX, y, screen.TEXT_ALIGN.CENTER)
    screen.resetColors()

  renderCountdown: ->
    @renderArena()
    @renderCycleViews()
    @renderCount()

  renderCount: ->
    screen.setForegroundColor 3
    countX = @startX + Math.round(@game.gridSize/2)
    screen.print @countString, countX, Math.round(@game.gridSize/2), screen.TEXT_ALIGN.CENTER

  renderCycleViews: ->
    cycleView.render() for cycleView in @cycleViews

  renderGameInfo: ->
    if @game.name? and @cycleNumber?
      screen.setBackgroundColor playerColors(@cycleNumber)
      screen.setForegroundColor 0
      screen.print((' ' for i in [1..screen.columns]).join(''), 1, screen.rows - 1)
      screen.print("#{@game.name}  Player: #{@cycleNumber}  State: #{@stateString}", 1, screen.rows - 1)
      screen.resetColors()
      if @playerCycle.state == 4
        screen.setForegroundColor playerColors(@cycleNumber)
        screen.print('-- INSERT --', 1, screen.rows)
        screen.resetColors()

  @property 'playerCycle', get: ->
    (cycle for cycle in @_game.cycles when cycle.number == @cycleNumber).pop()

module.exports = GameView