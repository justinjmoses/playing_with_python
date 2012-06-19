define ['text!./player.html', 'libs/eventbus', 'libs/format'], (viewTemplate, bus, format) ->
  Backbone.View.extend
    initialize: ->
      @playing = @options.playing
      @queue = @options.queue
      @playing.on 'start', (track) =>
        @showPlaying() 

      @playing.on 'stop', =>
        @showStopped()

      @playing.on 'clear', =>
        @showNone()

      @playing.on 'tick', (position) =>
        @$('.now-playing .progress-bar').progressbar
          value: position / @playing.track().get('length') * 100
        @$('.now-playing .elapsed').html format.time(@playing.get('position')) 
          
    render: ->
      @$el.html viewTemplate
      @

    showPlaying: () ->
      return unless @playing.track()
      @$('.btn.play').removeClass('play').addClass('stop')
      @$('.now-playing .track').html @playing.track().get('name')
      @$('.now-playing .artist').html @playing.track().get('artist')
      @$('.now-playing .album').html @playing.track().get('album')
      @$('.now-playing .total').html format.time(@playing.track().get('length')) 
        
      @$('.info').html "Now Playing: "
      @$('.now-playing').fadeTo(250, 1)
      
    showStopped: ->
      @$('.now-playing').fadeTo(250, 0.5)
      @$('.info').html "Stopped: "
      @$('.btn.stop').removeClass('stop').addClass('play')

    showNone: ->
      @$('.now-playing .track').html ""
      @$('.now-playing .artist').html ""
      @$('.now-playing .album').html ""

    onPlayPress: (evt) -> 
      return unless @playing.track()
      bus.trigger 'player:play'
      @showPlaying()

    onStopPress: (evt) -> 
      bus.trigger 'player:stop'
      @showStopped()

    onNextPress: (evt) ->
      next = @queue.next(@playing.track())
      if next then bus.trigger 'playing:set', next 

    onPrevPress: (evt) ->
      prev = @queue.prev(@playing.track())
      if prev then bus.trigger 'playing:set', prev
        
    events: 
      'click .play': 'onPlayPress'
      'click .stop': 'onStopPress'
      'click .next': 'onNextPress'
      'click .prev': 'onPrevPress'