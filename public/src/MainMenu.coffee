class Crashed.MainMenu
  constructor: (game) ->
    # @music = null;
    @playButton = null

  create: () ->

    # We've already preloaded our assets, so let's kick right into the Main Menu itself.
    # Here all we're doing is playing some music and adding a picture and button
    # Naturally I expect you to do something significantly better :)

    # @music = @add.audio('titleMusic');
    # @music.play();
    [ cx, cy ] = [ @game.width/ 2, @game.height / 2 ]
    [ w, h ] = [ 326, 287 ]
    @add.sprite 0, 0, 'titlepage'
    
    @playButton = @add.button(cx - (3*w/4), cy, 'playButton', @startGame, @, 'buttonOver', 'buttonOut', 'buttonOver');
    @playButton.anchor.set 0.5, 0.5

    @loadButton = @add.button(cx, cy - h/2, 'loadButton', @savedGames, @, 'buttonOver', 'buttonOut', 'buttonOver');
    @loadButton.anchor.set 0.5, 0.5

  update: () ->
    # Do some nice funky main menu effect here

  savedGames: () ->
    @state.start 'SavedGames'

  startGame: (pointer) ->
    # Ok, the Play Button has been clicked or touched, so let's stop the music (otherwise it'll carry on playing)
    # @music.stop();
    # And start the actual game
    @state.start 'Game'