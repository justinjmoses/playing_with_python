define ['libs/eventbus'], (bus) ->
  Backbone.Model.extend 
    defaults: 
      is_playing: false
      position: 0
      track: null

    initialize: ->
      @interval = undefined

      bus.on 'playing:set', (track) =>
        return if @get('track') is track
        @stop() if @get('is_playing') is true
        @set 'track', track
        @set 'is_playing', true
        @set 'position', -1
        @start track

      bus.on 'player:stop', () => @stop()
      bus.on 'player:play', () => @start @get('track')

    eachSecond: (track) ->
      return @stop() if @get('position')+1 >= @get('track').get('length')
      @set 'position', (@get('position')+1)
      @trigger 'tick', @get('position')

    start: (track) ->
      @interval = setInterval () =>
        @eachSecond()
      , 20 
      @eachSecond() #first run at 0s
      @trigger 'start', track

    stop: ->
      clearInterval @interval if @interval
      @set 'is_playing', false
      @trigger 'stop'

    clear: ->
      @stop()
      @set 'track', null
      @trigger 'clear'

    track: -> @get('track') 