-- Setup
infected_players = {}

-- Functions
function infect_player(player)
  infected_players[player:UserID()] = player
  player:PrintMessage(HUD_PRINTCENTER, 'You got infected')
end
function disinfect_player(player)
  infected_players[player:UserID()] = nil
  player:PrintMessage(HUD_PRINTCENTER, 'You got disinfected')
end
function purge_infection()
  infected_players = {}
  PrintMessage(HUD_PRINTCENTER, 'Everybody got disinfected')
end
function deal_infection_damage()
  for _, player in pairs(infected_players) do
    player:TakeDamage(5, player, player)
  end
end

-- Console Commands
concommand.Add('get_infected', function(player)
  infect_player(player)
end)
concommand.Add('get_disinfected', function(player)
  disinfect_player(player)
end)
concommand.Add('purge_infection', function(player)
  purge_infection()
end)
concommand.Add('infected_players', function()
  for _, player in pairs(infected_players) do
    print(player)
  end
end)

-- Hooks
hook.Add('PlayerHurt', 'HitByInfectedCrowbar', function(player, attacker)
  if (not attacker:IsPlayer() or attacker:GetActiveWeapon():GetClass() ~= 'weapon_crowbar' or not infected_players[attacker:UserID()] or infected_players[player:UserID()]) then return end

  infect_player(player)
  attacker:PrintMessage(HUD_PRINTCENTER, 'You infected ' .. player:Name())
end)
hook.Add('PostPlayerDeath', 'DisinfectDeadPlayers', disinfect_player)

-- Timers
timer.Create('deal_infection_damage', 1, 0, deal_infection_damage)
