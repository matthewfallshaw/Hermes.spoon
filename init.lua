--- === Hermes ===
---
--- Controls for Hermes music player

local obj={}
obj.__index = obj

local logger = hs.logger.new("Hermes")

-- Metadata
obj.name = "Hermes"
obj.version = "0.1"
obj.author = "Matthew Fallshaw <m@fallshaw.me>"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.homepage = "https://github.com/matthewfallshaw/Hermes.spoon"

-- Strings returned by `Hermes:getPlaybackState()`
obj.state_paused = "paus"   -- Note Applescript Hermes Dictionary claims this is "paused"
obj.state_playing = "play"  -- Note Applescript Hermes Dictionary claims this is "playing"
obj.state_stopped = "stopped"  -- Claimed by Applescript Hermes Dictionary, untested (impossible?)


-- Internal function to pass a command to Applescript.
local function tell(cmd)
  local _cmd = 'tell application "Hermes" to ' .. cmd
  local ok, result = hs.applescript.applescript(_cmd)
  if ok then
    return result
  else
    return nil
  end
end

local function alertwithlog(message, level)
  if not level then level = logger.level end
  hs.alert.show(message)
  if level == 0 then     -- nothing
    -- log nothing
  elseif level == 1 then -- error
    logger.e(message)
  elseif level == 2 then -- warning
    logger.w(message)
  elseif level == 3 then -- info
    logger.i(message)
  elseif level == 4 then -- debug
    logger.d(message)
  elseif level == 5 then -- verbose
    logger.v(message)
  end
end

--- Hermes:playpause()
--- Method
--- Toggles play/pause of current Hermes track
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:playpause()
  tell('playpause')
  state = obj.getPlaybackState()
  if state == obj.state_playing then
    alertwithlog("Hermes playing", 3)
  elseif state == obj.state_paused or state == obj.state_stopped then
    alertwithlog("Hermes paused", 3)
  else  -- unknown state
    return nil
  end
  return obj
end

--- Hermes:play()
--- Method
--- Plays the current Hermes track
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:play()
  tell('play')
  alertwithlog("Hermes playing", 3)
  return obj
end

--- Hermes:pause()
--- Method
--- Pauses the current Hermes track
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:pause()
  if obj.isRunning() then
    tell('pause')
    alertwithlog("Hermes paused", 3)
    return obj
  else
    hs.alert.show("Hermes isn't running")
  end
end

--- Hermes:next()
--- Method
--- Skips to the next Hermes track
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:next()
  if obj.isRunning() then
    tell('next song')
    alertwithlog("Next song in Hermes", 3)
  else
    hs.alert.show("Hermes isn't running")
  end
  return obj
end

--- Hermes:like()
--- Method
--- Likes (thumbs up) the current Hermes track
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:like()
  if obj.isRunning() then
    if obj.getCurrentRating() ~= 1 then
      tell('thumbs up')
      alertwithlog("Liked song in Hermes", 3)
    else
      alertwithlog("Song in Hermes already Liked", 3)
    end
    return obj
  else
    hs.alert.show("Hermes isn't running")
  end
end

--- Hermes:dislike()
--- Method
--- Dislikes (thumbs down) the current Hermes track
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:dislike()
  if obj.isRunning() then
    tell('thumbs down')
    alertwithlog("Disliked song in Hermes", 3)
    return obj
  else
    hs.alert.show("Hermes isn't running")
  end
end

--- Hermes:tired()
--- Method
--- Puts the current Hermes track on the shelf for a while
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:tired()
  if obj.isRunning() then
    tell('tired of song')
    alertwithlog("Shelved song for a while in Hermes", 3)
    return obj
  else
    hs.alert.show("Hermes isn't running")
  end
end

--- Hermes:quit()
--- Method
--- Quit Hermes
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:quit()
  if obj.isRunning() then
    hs.application.get("Hermes"):kill()
    alertwithlog("Quit Hermes", 3)
    return obj
  else
    hs.alert.show("Hermes isn't running")
  end
end

--- Hermes:hide()
--- Method
--- Hide (or show) Hermes
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:hide()
  if obj.isRunning() then
    local hermes = hs.application.get("Hermes")
    if hermes:isHidden() then
      hermes:unhide()
      alertwithlog("Unhid Hermes", 3)
    else
      hermes:hide()
      alertwithlog("Hid Hermes", 3)
    end
    return obj
  else
    hs.alert.show("Hermes isn't running")
  end
end

--- Hermes:displayCurrentTrack()
--- Method
--- Displays information for current track on screen
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:displayCurrentTrack()
  if obj.isRunning() then
    local artist = tell('artist of the current song as string') or "Unknown artist"
    local album  = tell('album of the current song as string') or "Unknown album"
    local track  = tell('title of the current song as string') or "Unknown track"
    alertwithlog(track .."\n".. album .."\n".. artist .."\nin Hermes", 1.75, 3)
  else
    hs.alert.show("Hermes isn't running")
  end
  return obj
end

--- Hermes:setVolume(volume)
--- Method
--- Sets the Hermes playback volume
---
--- Parameters:
---  * vol - A number, between 0 and 100
---
--- Returns:
---  * None
function obj:setVolume(volume)
  if obj:isRunning() then
    volume = math.min(100, math.max(0, tonumber(volume)))
    if not volume then error('volume must be a number 0..100',2) end
    tell('set playback volume to '.. volume)
    if volume == 0 then
      alertwithlog("Hermes muted", 3)
    else
      hs.alert.closeAll(0)
      alertwithlog("Hermes volume: ".. volume, 3)
    end
    return obj
  else
    hs.alert.show("Hermes isn't running")
  end
end

--- Hermes:mute()
--- Method
--- Toggle Hermes mute state
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:mute()
  if obj:isRunning() then
    if obj:getVolume() > 0 then
      obj.mute_restore_volume = obj:getVolume()
      obj:setVolume(0)
    else
      if obj.mute_restore_volume then
        obj:setVolume(obj.mute_restore_volume)
      else
        obj:setVolume(10)
      end
      obj.mute_restore_volume = nil
    end
    return obj
  else
    hs.alert.show("Hermes isn't running")
  end
end

--- Hermes:volumeUp()
--- Method
--- Increases the Hermes playback volume
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:volumeUp()
  if obj:isRunning() then
    obj:setVolume(obj:getVolume() + 1)
    return obj
  else
    hs.alert.show("Hermes isn't running")
  end
end

--- Hermes:volumeDown()
--- Method
--- Decreases the Hermes playback volume
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:volumeDown()
  if obj:isRunning() then
    obj:setVolume(obj:getVolume() - 1)
    return obj
  else
    hs.alert.show("Hermes isn't running")
  end
end



--- Hermes:getCurrentArtist() -> string or nil
--- Function
--- Gets the name of the current Artist
---
--- Parameters:
---  * None
---
--- Returns:
---  * A string containing the Artist of the current track, or nil if an error occurred
function obj:getCurrentArtist()
  if obj.isRunning() then
    return tell('artist of the current song as string')
  end
end

--- Hermes:getCurrentAlbum() -> string or nil
--- Function
--- Gets the name of the current Album
---
--- Parameters:
---  * None
---
--- Returns:
---  * A string containing the Album of the current track, or nil if an error occurred
function obj:getCurrentAlbum()
  if obj.isRunning() then
    return tell('album of the current song as string')
  end
end

--- Hermes:getCurrentTrack() -> string or nil
--- Function
--- Gets the name of the current track
---
--- Parameters:
---  * None
---
--- Returns:
---  * A string containing the name of the current track, or nil if an error occurred
function obj:getCurrentTrack()
  if obj.isRunning() then
    return tell('title of the current song as string')
  end
end

--- Hermes:getCurrentRating() -> number or nil
--- Function
--- Gets the rating of the current track; 1:liked, 0:normal, -1:disliked
---
--- Parameters:
---  * None
---
--- Returns:
---  * A number, the rating of the current track, or nil if an error occurred
function obj:getCurrentRating()
  if obj.isRunning() then
    return tell('rating of current song as integer')
  else
    return nil
  end
end

--- Hermes:getPlaybackState() -> string or nil
--- Function
--- Gets the current playback state of Hermes
---
--- Parameters:
---  * None
---
--- Returns:
---  * A string containing one of the following constants:
---    - `Hermes:state_stopped`
---    - `Hermes:state_paused`
---    - `Hermes:state_playing`
function obj:getPlaybackState()
  if obj.isRunning() then
    return tell('get playback state')
  else
    return nil
  end
end

--- Hermes:isRunning() -> boolean
--- Function
--- Returns whether Hermes is currently open. Most other functions in Hermes.spoon will automatically start the application, so this function can be used to guard against that.
---
--- Parameters:
---  * None
---
--- Returns:
---  * A boolean value indicating whether the Hermes application is running.
function obj:isRunning()
  return hs.application.get("Hermes") ~= nil
end

--- Hermes:isPlaying() -> boolean or nil
--- Function
--- Returns whether Hermes is currently playing
---
--- Parameters:
---  * None
---
--- Returns:
---  * A boolean value indicating whether Hermes is currently playing a track, or nil if an error occurred (unknown player state). Also returns false if the application is not running
function obj:isPlaying()
  -- We check separately to avoid starting the application if it's not running
  if not obj.isRunning() then
    return false
  end
  state = obj.getPlaybackState()
  if state == obj.state_playing then
    return true
  elseif state == obj.state_paused or state == obj.state_stopped then
    return false
  else  -- unknown state
    return nil
  end
end

--- Hermes:getVolume() -> number
--- Function
--- Gets the current Hermes volume setting
---
--- Parameters:
---  * None
---
--- Returns:
---  * A number, between 1 and 100, containing the current Hermes playback volume
function obj:getVolume()
  if obj:isRunning() then
    return tell('playback volume')
  end
end

--- Hermes:getPosition() -> number
--- Function
--- Gets the playback position (in seconds) of the current song
---
--- Parameters:
---  * None
---
--- Returns:
---  * A number indicating the current position in the song
function obj:getPosition()
  if obj:isRunning() then
    return tell('playback position')
  end
end

--- Hermes:getDuration() -> number
--- Function
--- Gets the duration (in seconds) of the current song
---
--- Parameters:
---  * None
---
--- Returns:
---  * The number of seconds long the current song is, 0 if no song is playing
function obj:getDuration()
  if obj:isRunning() then
    local duration = tonumber(tell('current song duration'))
    return duration ~= nil and duration or 0
  end
end



obj.hotkeys={}
--- Hermes:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for Hermes
---
--- Parameters:
---  * mapping - A table containing hotkey modifier/key details for the following items:
---   * see docs.json
function obj:bindHotkeys(mapping)
  for k,v in pairs(mapping) do
    if obj[k] and type(obj[k]) == 'function' then
      if obj.hotkeys[k] then obj.hotkeys[k]:delete() end

      local mods, hotkey = mapping[k][1], mapping[k][2]
      obj.hotkeys[k] = hs.hotkey.bind(mods, hotkey, function() obj[k]() end)
    else
      logger.ef("Error: Hotkey requested for undefined action '%s'", name)
    end
  end
end

return obj
