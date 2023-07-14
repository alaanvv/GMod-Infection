-- Setup
POINTS_BY_SEC = 1

infected_players = {}
ranking = {}

match_running = false

-- Functions
function infect_player(player)
  infected_players[player:UserID()] = player
  player:PrintMessage(HUD_PRINTCENTER, 'You got infected')
end
function infect_random_player()
  local all_players = player.GetHumans()
  local random_player = all_players[math.floor(math.random(#all_players))]
  infect_player(random_player)

  return random_player
end
function disinfect_player(player)
  infected_players[player:UserID()] = nil
  player:PrintMessage(HUD_PRINTCENTER, 'You got disinfected')

  if #infected_players == 0 then end_match() end
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

function add_points(player, points)
  local id = player:UserID()
  if not ranking[id] then ranking[id] = points
  else ranking[id] = ranking[id] + points end
end
function give_points_to_not_infected()
  if not match_running then return end

  for _, player in pairs(player.GetAll()) do
    if not infected_players[player:UserID()] then add_points(player, POINTS_BY_SEC * 5) end
  end
end

function end_match()
  if not match_running then return end

  match_running = false

  show_ranking()

  infected_players = {}
  ranking = {}
end
function show_ranking()
  for id, points in pairs(ranking) do
    PrintMessage(HUD_PRINTTALK, Player(id):Name() .. ': ' .. points .. 'pts')
  end
end

-- Console Commands
concommand.Add('start_match', function(player)
  if not player:IsAdmin() or match_running then return end

  match_running = true

  infected_player = infect_random_player()
  PrintMessage(HUD_PRINTTALK, player:Name() .. ' got randomly infected!')
end)
concommand.Add('end_match', function(player)
  if not player:IsAdmin() then return end

  end_match()
end)
concommand.Add('get_infected', function(player)
  if not player:IsAdmin() then return end

  infect_player(player)
end)
concommand.Add('get_disinfected', function(player)
  if not player:IsAdmin() then return end

  disinfect_player(player)
end)
concommand.Add('purge_infection', function(player)
  if not player:IsAdmin() then return end

  purge_infection()
end)
concommand.Add('infected_players', function(player)
  if not player:IsAdmin() then return end

  for _, player in pairs(infected_players) do
    print(player)
  end
end)
concommand.Add('ranking', function(player)
  if not player:IsAdmin() then return end

  show_ranking()
end)

-- Hooks
hook.Add('PlayerHurt', 'HitByInfectedCrowbar', function(player, attacker)
  if (not attacker:IsPlayer() or attacker:GetActiveWeapon():GetClass() ~= 'weapon_crowbar' or not infected_players[attacker:UserID()] or infected_players[player:UserID()]) then return end

  add_points(attacker, POINTS_BY_SEC * 30)

  infect_player(player)
  attacker:PrintMessage(HUD_PRINTCENTER, 'You infected ' .. player:Name())
end)
hook.Add('PostPlayerDeath', 'DisinfectDeadPlayers', disinfect_player)

-- Timers
timer.Create('deal_infection_damage', 1, 0, deal_infection_damage)
timer.Create('give_points_to_not_infected', 5, 0, give_points_to_not_infected)
