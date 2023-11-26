-- Setup
DISINFECT_ON_INFECTING = true
DISINFECT_ON_DEAD = false
INFECTION_DPS = 10
INFECTED_RUNSPEED = 1000

infected = {} -- [Player:UserID()] Player

-- Functions
function infect(player)
    infected[player:UserID()] = player
    player:SetRunSpeed(INFECTED_RUNSPEED)

    PrintMessage(HUD_PRINTTALK, player:Name() .. ' got infected')
    player:PrintMessage(HUD_PRINTCENTER, 'You are infected')
end
function infect_random()
    local all_players = player.GetAll()
    local random_player = all_players[math.random(#all_players)]
    infect(random_player)
end

function disinfect(player)
    infected[player:UserID()] = nil
    player:SetRunSpeed(600)

    player:PrintMessage(HUD_PRINTCENTER, 'You are disinfected')
end
function purge_infection()
    infected = {}

    PrintMessage(HUD_PRINTCENTER, 'Infection purged')
end

function deal_infection_damage()
    for _, player in pairs(infected) do
        player:TakeDamage(INFECTION_DPS, player, player)
    end
end

-- Console Commands
concommand.Add('infect_random', function(player)
    if not player:IsAdmin() then
        return
    end

    infect_random()
end)
concommand.Add('get_infected', function(player)
    if not player:IsAdmin() then
        return
    end

    infect(player)
end)
concommand.Add('get_disinfected', function(player)
    if not player:IsAdmin() then
        return
    end

    disinfect(player)
end)
concommand.Add('purge_infection', function(player)
    if not player:IsAdmin() then
        return
    end

    purge_infection()
end)
concommand.Add('infected_players', function(player)
    if not player:IsAdmin() then
        return
    end

    for _, player in pairs(infected) do
        print(player:Name())
    end
end)

-- Hooks
hook.Add('EntityTakeDamage', 'HitByInfectedCrowbar', function(player, damageInfo)
    local attacker = damageInfo:GetAttacker()
    
    if (not damageInfo:IsDamageType(DMG_CLUB) or not infected[attacker:UserID()] or infected[player:UserID()]) then return end

    if DISINFECT_ON_INFECTING then disinfect(attacker) end
    infect(player)

    attacker:PrintMessage(HUD_PRINTCENTER, 'You infected ' .. player:Name())
end)
hook.Add('PostPlayerDeath', 'DisinfectDeadPlayers', function(player)
  if DISINFECT_ON_DEAD then disinfect(player) end
end)

-- Timers
timer.Create('deal_infection_damage', 1, 0, deal_infection_damage)