script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.get_player(event.player_index)
  if player then
    player.print({"mod-template.hello"})
  end
end)
