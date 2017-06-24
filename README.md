# Hermes.spoon

A Spoon for Hammerspoon. Like hs.itunes for Hermes.app (a Pandora player).


## Install

Copy directory as Hermes.spoon to ~/.hammerspoon/Spoons/
Include `hs.loadSpoon("Hermes")` in your ~/.hammerspoon/init.lua before any other `spoon.Hermes` code.


## Use

In your ~/.hammerspoon/init.lua you might include something like:

    spoon.Hermes:bindHotkeys( {
      playpause={{"⌥", "⌃", "⇧"}, "p"},
      displayCurrentTrack={{"⌥", "⌃", "⇧"}, "d"},
      -- etc.
      -- playpause, play, pause, next, like, dislike, tired, hide, quit
      -- displayCurrentTrack, getCurrentArtist, getCurrentAlbum, getCurrentTrack,
      -- getPlaybackState, isRunning, isPlaying, getVolume, setVolume, volumeUp, volumeDown, getPosition, getDuration
    })

Anywhere else (that will be executed after the `hs.loadspoon("Hermes")` call), you might include something like:

    spoon.Hermes.play()

… or…

    spoon.Hermes.isPlaying()

etc.
