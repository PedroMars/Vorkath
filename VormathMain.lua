local API = require("api")
local PrayerFlicker = require("VorkathNoob.prayer_flicker")
local VORKATHPreparation = require("VorkathNoob.VorkathPreparation")
local Setup = require("VorkathNoob.setup")
local TIMER = require("VorkathNoob.timer")
-- file saved in Lua_Scripts\rasial

local Npc1 = 30664
local DisruptPortal = "Place of power"
local Npc2 = 30665
local Npc3 = 30666
local fase1 = false
local fase2 = false
local fase3 = false
local boss1 = 30690
local boss2 = 30692
local CoordPortal1 = nil
local CoordPortal2 = nil
local CoordPortal3 = nil
LAST_CAST = os.clock()


HAS_ZUK_CAPE = Setup.HAS_ZUK_CAPE
USE_BOOK = Setup.USE_BOOK
USE_POISON = Setup.USE_POISON
USE_EXCAL = Setup.USE_EXCAL
USE_ELVEN_SHARD = Setup.USE_ELVEN_SHARD
OVERLOAD_NAME = type(Setup.OVERLOAD_NAME) == "string" and Setup.OVERLOAD_NAME or ""
OVERLOAD_BUFF_ID = Setup.OVERLOAD_BUFF_ID
NECRO_PRAYER_NAME = type(Setup.NECRO_PRAYER_NAME) == "string" and Setup.NECRO_PRAYER_NAME or ""
NECRO_PRAYER_BUFF_ID = Setup.NECRO_PRAYER_BUFF_ID
BOOK_NAME = type(Setup.BOOK_NAME) == "string" and Setup.BOOK_NAME or ""
BOOK_BUFF_ID = Setup.BOOK_BUFF_ID
RESTORE_NAME = type(Setup.RESTORE_NAME) == "string" and Setup.RESTORE_NAME or ""
FOOD_NAME = type(Setup.FOOD_NAME) == "string" and Setup.FOOD_NAME or ""
FOOD_POT_NAME = type(Setup.FOOD_POT_NAME) == "string" and Setup.FOOD_POT_NAME or ""
ADREN_POT_NAME = type(Setup.ADREN_POT_NAME) == "string" and Setup.ADREN_POT_NAME or ""
RING_SWITCH = type(Setup.RING_SWITCH) == "string" and Setup.RING_SWITCH or ""

---------------------------------------------------------------------
--# CHANGE THESE VALUES IN `setup.lua`
---------------------------------------------------------------------

---------------------------------------------------------------------
--# END
---------------------------------------------------------------------3


local function inThreadsRotation()
    if API.IsTargeting() then
        return true
    else
        return false
    end
end

local TIMERS = {
    GCD = { -- global cooldown tracker
        name = "GCD",
        duration = 1600,
    },
    Vuln = { -- prevent vuln bomb spam
        name = "Vuln Bomb",
        duration = 1800,
    },
    Excal = { -- keep track of 5min cooldown instead of checking each time
        name = "Excal",
        duration = (1000 * 60 * 5) + 1,
    },
    Elven = { -- keep track of 5min cooldown instead of checking each time
        name = "Elven",
        duration = (1000 * 60 * 5) + 1,
    },
    Buffs = { -- check buffs every second
        name = "Buffs",
        duration = 1000,
    }
}
local habilitcast = 0
local function useAbility(abilityName)
    if not API.Read_LoopyLoop() then return false end
    local ability = API.GetABs_name(abilityName, true)
    if not ability or
            ability.enabled == false or
            ability.slot <= 0 or
            ability.cooldown_timer > 1 then
        return false
    end
    local stateTmp = API.VB_FindPSettinOrder(4501).state
    if API.DoAction_Ability(abilityName, 1, API.OFF_ACT_GeneralInterface_route, true) then
        local start = os.clock()
        local successful = true
        while LAST_GCD_STATE == stateTmp do
            local elapsed = os.clock() - start
            if elapsed >= 0.6 then
                successful = false
                break
            end
            LAST_GCD_STATE = API.VB_FindPSettinOrder(4501).state
            if LAST_GCD_STATE ~= stateTmp then
                successful = true
                break
            end
            API.RandomSleep2(5, 0, 0)
        end
        if not successful  then
            API.logDebug("Failed to cast ability " .. abilityName .. ", recasting")
            return
        end
        local now = os.clock()
        local tickCasted = API.Get_tick()
        API.logDebug(string.format(
                "[CASTING] Successfully cast ability (%s) | DeltaT: %.5f s | Tick: %s",
                abilityName,
                now - LAST_CAST, tickCasted))
        LAST_CAST = now
        LAST_GCD_STATE = API.VB_FindPSettinOrder(4501).state
        TIMER:createSleep(TIMERS.GCD.name, TIMERS.GCD.duration)
        habilitcast = 0
        return true
    end
    API.logWarn(string.format("[CASTING] Failed to use ability (%s)", abilityName))
    habilitcast = habilitcast + 1
    return false
end



local function getBuff(buffId)
    local buff = API.Buffbar_GetIDstatus(buffId, false)
    return { found = buff.found, remaining = (buff.found and API.Bbar_ConvToSeconds(buff)) or 0 }
end

--- Source: https://github.com/sonsonmagro/Sonsons-Rasial/blob/main/core/player_manager.lua#L445
--- Checks if the player has a specific debuff
--- @param debuffId number
--- @return {found: boolean, remaining: number}
local function getDebuff(debuffId)
    local debuff = API.DeBuffbar_GetIDstatus(debuffId, false)
    return { found = debuff.found or false, remaining = (debuff.found and API.Bbar_ConvToSeconds(debuff)) or 0 }
end

local function targetBloated()
    return API.VB_FindPSettinOrder(11303).state >> 5 & 0x1 == 1
end

local function targetVulned()
    return API.VB_FindPSettinOrder(896).state >> 29 & 0x1 == 1
end

local function targetDeathMarked()
    return API.VB_FindPSettinOrder(11303).state >> 7 & 0x1 == 1
end

local function invokeDeathActive()
    return getBuff(30100).found
end



local function specAttackOnCooldown()
    return API.DeBuffbar_GetIDstatus(55480, false).found
end

local function specAttackOnCooldown2()
    return API.DeBuffbar_GetIDstatus(55524, false).found
end


local function necrosisStacks()
    return getBuff(30101).remaining or 0
end

local function soulStacks()
    return getBuff(30123).remaining or 0
end

local function onCooldown(abilityName)
    return API.GetABs_name(abilityName, true).cooldown_timer > 0
end

local function targetStunnedOrBound()
    return (API.VB_FindPSett(896).state >> 0 & 0x1 == 1) or
            (API.VB_FindPSett(896).state >> 1 & 0x1 == 1)
end

local function deathSkullsActive()
    return #API.GetAllObjArray1({ 7882 }, 12, { 5 }) > 0
end

local function manageBuffs()
    if not TIMER:shouldRun(TIMERS.Buffs.name) then return end

    local prayer = API.GetPray_()
    local hp = API.GetHP_()
    local overload = getBuff(OVERLOAD_BUFF_ID)
    local necroPrayer = getBuff(NECRO_PRAYER_BUFF_ID)
    local book = USE_BOOK and getBuff(BOOK_BUFF_ID) or nil
    local poison = getBuff(30095)
    local darkness = getBuff(30122)
    local boneShield = API.GetABs_name("Greater Bone Shield", true)


    if boneShield.action == "Activate" then
        if useAbility("Greater Bone Shield") then
            API.RandomSleep2(300, 200, 200)
        end
    end

    if USE_ELVEN_SHARD and TIMER:shouldRun(TIMERS.Elven.name) then
        local shardOnCooldown = getDebuff(43358).found
        if not shardOnCooldown and API.GetPray_() < math.random(500, 700) then
            if API.DoAction_Inventory3("elven ritual shard", 0, 1, API.OFF_ACT_GeneralInterface_route) then
                TIMER:createSleep(TIMERS.Elven.name, TIMERS.Elven.duration)
            end
        end
    end

    if hp < math.random(2500, 5000) then
        if API.DoAction_Ability_check(FOOD_NAME, 1, API.OFF_ACT_GeneralInterface_route, true, true, false) then
            API.RandomSleep2(60, 10, 10)
            API.DoAction_Ability_check(FOOD_POT_NAME, 1, API.OFF_ACT_GeneralInterface_route, true, true, false)
        end
        print("deu fome")
    end

    if not darkness.found or (darkness.found and darkness.remaining <= math.random(10, 120)) then
        if useAbility("Darkness") then
            API.RandomSleep2(300, 200, 200)
            print("preciso me manter o batman")
        end
    end

    if prayer < math.random(200, 400) or API.GetSkillsTableSkill(6) < 99 then
        if API.DoAction_Inventory3(RESTORE_NAME, 0, 1, API.OFF_ACT_GeneralInterface_route) then
            API.RandomSleep2(300, 200, 200)
        end
    end

    if not overload.found or (overload.found and overload.remaining > 1 and overload.remaining < math.random(30)) then
        if API.DoAction_Inventory3(OVERLOAD_NAME, 0, 1, API.OFF_ACT_GeneralInterface_route) then
            API.RandomSleep2(300, 200, 200)
        end
    end


    if not necroPrayer.found and prayer > 50 then
        if API.DoAction_Ability(NECRO_PRAYER_NAME, 1, API.OFF_ACT_GeneralInterface_route, true) then
            API.RandomSleep2(300, 200, 200)
        end

    end

    if USE_BOOK and not book.found then
        if API.DoAction_Ability(BOOK_NAME, 1, API.OFF_ACT_GeneralInterface_route, true) then
            API.RandomSleep2(300, 200, 200)
        end
        print("sempre bom estudar")
    end



    TIMER:createSleep(TIMERS.Buffs.name, TIMERS.Buffs.duration)
end

local function goToSafespot(safespot)
    local playerPos = API.PlayerCoord()
    if playerPos.x == safespot.x and playerPos.y == safespot.y then
        return
    end
    if API.DoAction_Tile(safespot) then
        API.RandomSleep2(600, 200, 200)
        if API.Dist_FLPW(safespot) > 12 then
            if API.DoAction_Ability_check("Surge", 1, API.OFF_ACT_GeneralInterface_route, true, true, true) then
                API.RandomSleep2(600, 200, 200)
                API.DoAction_Tile(safespot)
            end
        end
        API.WaitUntilMovingEnds(7, 10)
    end
end

local function findArenaCoords()
    --- Função auxiliar para gerar um número randômico entre -2 e 2 (inclusive)
    local function getRandomOffset()
        -- API.Math_RandomNumber(5) gera um número entre 0 e 4
        -- subtrair 2 para obter um range de -2 a 2
        return API.Math_RandomNumber(5) - 2
    end

    --- @type AllObject | nil
    local player = API.GetAllObjArrayFirst({128389}, 12, { 12 })
    if player ~= nil then
        local playerX = math.floor(player.Tile_XYZ.x)
        local playerY = math.floor(player.Tile_XYZ.y)
        print("Finding arena coords for " .. tostring(playerX) .. ", " .. tostring(playerY))

        local offset1X = getRandomOffset()
        local offset1Y = getRandomOffset()
        CoordPortal1 = WPOINT.new(playerX + 9 + offset1X, playerY + 32 + offset1Y, 0)
        print("CoordPortal1: X = " .. CoordPortal1.x .. ", Y = " .. CoordPortal1.y .. ", Z = " .. CoordPortal1.z .. " (Offset X: " .. offset1X .. ", Y: " .. offset1Y .. ")")

        local offset2X = getRandomOffset()
        local offset2Y = getRandomOffset()
        CoordPortal2 = WPOINT.new(playerX - 42 + offset2X, playerY + 25 + offset2Y, 0)
        print("CoordPortal2: X = " .. CoordPortal2.x .. ", Y = " .. CoordPortal2.y .. ", Z = " .. CoordPortal2.z .. " (Offset X: " .. offset2X .. ", Y: " .. offset2Y .. ")")

        local offset3X = getRandomOffset()
        local offset3Y = getRandomOffset()
        CoordPortal3 = WPOINT.new(playerX - 49 + offset3X, playerY - 19 + offset3Y, 0)
        print("CoordPortal3: X = " .. CoordPortal3.x .. ", Y = " .. CoordPortal3.y .. ", Z = " .. CoordPortal3.z .. " (Offset X: " .. offset3X .. ", Y: " .. offset3Y .. ")")

        return true
    end
    return false
end

local function HasNpcNearby(npcIdentifier, maxDistance)
    local npcs
    if type(npcIdentifier) == "number" then

        npcs = API.GetAllObjArray1({npcIdentifier}, maxDistance, {1})
    elseif type(npcIdentifier) == "string" then

        npcs = API.GetAllObjArrayInteract_str({npcIdentifier}, maxDistance, {1}) -- Assumindo que esta função é para string input

    end

    if npcs and #npcs > 0 then
        return true
    else
        return false
    end
end

local function waveClearRotation()

    if not targetVulned() and TIMER:shouldRun(TIMERS.Vuln.name) then
        if Inventory:Contains("Vulnerability bomb") then
            if API.DoAction_Inventory3("Vulnerability bomb", 0, 1, API.OFF_ACT_GeneralInterface_route) then
                API.RandomSleep2(300, 200, 200)
                TIMER:createSleep(TIMERS.Vuln.name, TIMERS.Vuln.duration)
                return
            end
        end
    end

    if useAbility("Conjure Undead Army") and inThreadsRotation() then
        print("chamei a tropa")return end

    if not targetDeathMarked() and not invokeDeathActive() and
            API.ReadTargetInfo(false).Hitpoints >= 20000 and inThreadsRotation() then
        if useAbility("Invoke Death") then
            print("espero que morra")return end
    end

    if not deathSkullsActive() and soulStacks() >= 2  and inThreadsRotation() then
        if useAbility("Threads of Fate")
        then print("nao sei oq to fazendo")return end
    end

        if useAbility("Death Skulls") and inThreadsRotation() then
            print("tomacaverada")return end


    if not targetBloated() and inThreadsRotation() then
        if useAbility("Bloat") then
            print("acho que comi demais")return end
    end

    if  soulStacks() >= 3 then
        if useAbility("Volley of Souls") and inThreadsRotation() then
            print("sai pra assombracao")return end
    end

    if  necrosisStacks() >= 6 and inThreadsRotation() then
        if useAbility("Finger of Death")  then
            print("fio terra")return end
    end

    if  necrosisStacks() >= 1 and
            necrosisStacks() <= 5 and not specAttackOnCooldown() and inThreadsRotation() then
        if useAbility("Weapon Special Attack") then return end
    end

    if useAbility("Conjure Undead Army") then return end
    if useAbility("Command Vengeful Ghost") then return end
    if useAbility("Command Skeleton Warrior") then return end
    if useAbility("Touch of Death") then return end
    if useAbility("Soul Sap") then return end
    if useAbility("Basic<nbsp>Attack") then return end
end

local function doRotation()
    if not TIMER:shouldRun(TIMERS.GCD.name) then return end
    local adren = API.GetAdrenalineFromInterface()

    if inThreadsRotation() then
        return waveClearRotation()
    end
end

-- Fase 1

--Go to center

local function attackTarget(target)
    if target ~= nil then
        if API.DoAction_NPC(0x2a,API.OFF_ACT_AttackNPC_route,{ target },30) then
        end
        API.RandomSleep2(600, 300, 300)
        return true
    end
    return false
end

function IsPlayerAtWPoint(target_wpoint, tolerance)
    -- Obtém a coordenada atual do jogador
    local player_coord = API.PlayerCoord()

    -- Verifica se as coordenadas do jogador foram obtidas com sucesso
    if not player_coord then
        API.Log("Não foi possível obter as coordenadas do jogador. Ele pode não estar logado ou em um estado inválido.", "warn")
        return false
    end

    -- Verifica se o nível do andar (Z) corresponde
    if player_coord.z ~= target_wpoint.z then
        return false
    end

    -- Calcula a distância entre o jogador e o WPOINT alvo
    -- A API.Math_DistanceW calcula a distância entre dois WPOINTs.
    local distance = API.Math_DistanceW(player_coord, target_wpoint)

    -- Retorna true se a distância for menor ou igual à tolerância
    if distance <= tolerance then
        API.Log(string.format("Jogador está em %d,%d,%d (distância %.2f do alvo %d,%d,%d).",
                player_coord.x, player_coord.y, player_coord.z, distance,
                target_wpoint.x, target_wpoint.y, target_wpoint.z), "debug")
        return true
    else
        API.Log(string.format("Jogador está em %d,%d,%d (distância %.2f do alvo %d,%d,%d). Fora da tolerância de %d.",
                player_coord.x, player_coord.y, player_coord.z, distance,
                target_wpoint.x, target_wpoint.y, target_wpoint.z, tolerance), "debug")
        return false
    end
end

local function GetCurrentTargetId()
    local targetInfo = API.ReadTargetInfo(false) -- 'false' para não forçar uma atualização imediata dos buffs, o que geralmente não é necessário para o ID do alvo.

    if targetInfo ~= nil then
        -- O struct Target_data (retornado por ReadTargetInfo) contém o campo 'id' do alvo.
        return targetInfo.id
    else
        return nil
    end
end

local PRAYER_CONFIG = {
    defaultPrayer = PrayerFlicker.CURSES.SOUL_SPLIT,
    threats = {
        name = "Attack Vorkath",
        type = "Animation",
        range = 50,
        prayer = PrayerFlicker.CURSES.DEFLECT_NECROMANCY,
        npcId = boss1,
        id = 35693,
        priority = 11,
        delay = 0,
        duration = 2
    },
    {
        name = "Fatal challenge range attack",
        type = "Projectile",
        range = 30,
        prayer = PrayerFlicker.CURSES.DEFLECT_NECROMANCY,
        id = 8101,
        priority = 10,
        delay = 1,
        duration = 2
    },
    }


local prayerFlicker = PrayerFlicker.new(PRAYER_CONFIG)
local tentativas = 0

local function doExtraActionButton()
    API.logWarn("Clicking extra action button")
    return     API.DoAction_Interface(0x2e,0xffffffff,1,743,1,-1,API.OFF_ACT_GeneralInterface_route)
end

local function executefase1()
    API.RandomSleep2(5000,1000,600)
    Interact:Object("Fort Forinthry Gate","Begin Encounter",15)
    API.RandomSleep2(3000,1000,600)
    findArenaCoords()
    while not IsPlayerAtWPoint(CoordPortal1,5) and tentativas < 6  do
        goToSafespot(CoordPortal1)
        API.WaitUntilMovingEnds(1, 3)
        tentativas = tentativas + 1
        API.logWarn("[SEAR] Moving to safe point")

    end
    API.logWarn("[SEAR] To seguro mamae")
    tentativas = 0


    API.RandomSleep()
    if HasNpcNearby(Npc1,20) then
        attackTarget(Npc1)
        while HasNpcNearby(Npc1,20) do
            attackTarget(Npc1)
            if API.GetInCombBit()  then
                doRotation()
                manageBuffs()
                prayerFlicker:update()
            end
        end

    end
    Interact:Object(DisruptPortal,"Disrupt",15)
    API.RandomSleep2(2000,1000,600)

    if not Interact:Object(DisruptPortal,"Disrupt",15) and not HasNpcNearby(Npc1,20) then
        fase1 = true
        print("portal 1 ativado")
        return true
    else
        return false
    end
end

local function executefase2()
    goToSafespot(CoordPortal2)
    while not IsPlayerAtWPoint(CoordPortal2,5) and tentativas < 6  do
        goToSafespot(CoordPortal2)
        API.WaitUntilMovingEnds(2, 3)
        tentativas = tentativas + 1
        API.logWarn("[SEAR] Moving to safe point")
    end
    API.logWarn("[SEAR] To seguro mamae")
    tentativas = 0
    if HasNpcNearby(Npc2,20) then
        attackTarget(Npc2)

        while HasNpcNearby(Npc2,35) do
            attackTarget(Npc2)
            if API.GetInCombBit()  then
                doRotation()
                manageBuffs()
                prayerFlicker:update()
            end
        end

    end
    Interact:Object(DisruptPortal,"Disrupt",15)
    API.RandomSleep2(2000,1000,600)

    if not Interact:Object(DisruptPortal,"Disrupt",15) and not HasNpcNearby(Npc2,35)  then
        fase2=true
        print("portal 2 ativado")
        return true
    else
        return false
    end
end

local function executefase3()
    goToSafespot(CoordPortal3)
    while not IsPlayerAtWPoint(CoordPortal3,5) and tentativas < 6   do
        goToSafespot(CoordPortal3)
        API.WaitUntilMovingEnds(1, 3)
        API.logWarn("[SEAR] Moving to safe point")
        tentativas = tentativas + 1

    end
    API.logWarn("[SEAR] To seguro mamae")
    tentativas = 0
    API.RandomSleep()
    if HasNpcNearby(Npc3,20) then
        attackTarget(Npc3)
        while HasNpcNearby(Npc3,20) do
            if API.GetInCombBit()  then
                doRotation()
                manageBuffs()
                prayerFlicker:update()
            end
        end

    end
    Interact:Object(DisruptPortal,"Disrupt",15)
    API.RandomSleep2(2000,1000,600)

    if not Interact:Object(DisruptPortal,"Disrupt",15) and not HasNpcNearby(Npc3,20) then
        fase3=true
        print("portal 3 ativado")
        return true
    else
        return false
    end
end
local function HasItemNotUnderPlayerAndMoveIfOnTop(itemId, safeMoveRadius)
    local targetItemId = itemId
    local radius = safeMoveRadius or 3 -- Raio padrão de 3 se não especificado

    -- Tipo AllObject para item no chão é 3
    local groundItems = API.GetAllObjArray1({targetItemId}, 60, {0}) -- Busca por itens no chão com o ID especificado, até 60 tiles

    if groundItems and #groundItems > 0 then
        local playerCoord = API.PlayerCoord() -- Obtém as coordenadas do jogador

        local playerIsOnAnItem = false
        for _, item in ipairs(groundItems) do
            local itemTile = API.Math_FlattenFloat(item.Tile_XYZ)

            -- Verifica se o jogador está na mesma tile de algum item
            if itemTile.x == playerCoord.x and itemTile.y == playerCoord.y and itemTile.z == playerCoord.z then
                playerIsOnAnItem = true
                break -- Encontramos um item debaixo do jogador, não precisamos verificar mais
            end
        end

        if playerIsOnAnItem then
            API.logInfo("Você está em cima do item " .. targetItemId .. ". Tentando mover para uma tile segura...")

            -- Tentar encontrar uma tile segura em um raio de 'radius' tiles
            -- Precisamos de uma lista de tiles bloqueadas (onde estão os itens)
            local occupiedTiles = {}
            for _, item in ipairs(groundItems) do
                table.insert(occupiedTiles, API.Math_FlattenFloat(item.Tile_XYZ))
            end

            -- Adicionar a posição atual do player como uma tile bloqueada
            table.insert(occupiedTiles, API.CreateFFPOINT(playerCoord.x, playerCoord.y, playerCoord.z))

            -- Buscar por tiles livres ao redor do jogador
            local safeTiles = API.Math_FreeTiles(occupiedTiles, 1, radius, {}, false)

            if safeTiles and #safeTiles > 0 then
                -- Ordenar as tiles seguras pela distância em relação ao jogador para escolher a mais próxima (opcional)
                local sortedSafeTiles = API.Math_SortAODistFromA(API.CreateFFPOINT(playerCoord.x, playerCoord.y, playerCoord.z), safeTiles)
                local targetSafeTile = sortedSafeTiles[1] -- Pega a tile segura mais próxima

                if targetSafeTile then
                    API.logInfo("Movendo para a tile segura: X=" .. targetSafeTile.x .. ", Y=" .. targetSafeTile.y .. ", Z=" .. targetSafeTile.z)
                    -- Converter FFPOINT para WPOINT para DoAction_WalkerW
                    local safeWPoint = WPOINT.new(math.floor(targetSafeTile.x), math.floor(targetSafeTile.y), math.floor(targetSafeTile.z))
                    API.DoAction_WalkerW(safeWPoint) -- Move o jogador para a tile segura
                    API.WaitUntilMovingEnds(5, 5) -- Espera até que o movimento termine
                    return true -- Sinaliza que o item foi encontrado e o movimento foi iniciado/concluído
                else
                    API.logWarn("Nenhuma tile segura encontrada em um raio de " .. radius .. " tiles.")
                    return false
                end
            else
                API.logWarn("Nenhuma tile segura encontrada em um raio de " .. radius .. " tiles.")
                return false
            end
        else
            -- O jogador NÃO está em cima de nenhum item, então o item foi encontrado e a condição é satisfeita
            return true
        end
    end

    -- Nenhum item com o ID especificado foi encontrado no chão
    return false
end

local targetItemId = 128522
local moveRadius = 3

local function faseboss()
    if HasNpcNearby(boss1,20) and HasNpcNearby(boss2,30) then
        attackTarget(boss1)
            if API.GetInCombBit()  then
                doRotation()
                manageBuffs()
                prayerFlicker:update()
                if HasItemNotUnderPlayerAndMoveIfOnTop(targetItemId, moveRadius) then
                end
            end
    else
        if HasNpcNearby(boss2,30) then
            doExtraActionButton()
            API.RandomSleep()
            attackTarget(boss2)
                if HasNpcNearby(boss1,20) then
                    attackTarget(boss1)
                end

                if API.GetInCombBit()  then
                doRotation()
                manageBuffs()
                prayerFlicker:update()
                if HasItemNotUnderPlayerAndMoveIfOnTop(targetItemId, moveRadius) then
                end

            end
            elseif HasNpcNearby(30648,20) then
            fase1 = false
            fase2 = false
            fase3 = false
            VORKATHPreparation:FullPreparationCycle()

            end
        end
    end






API.Write_fake_mouse_do(false)
API.SetDrawLogs(true)
API.SetMaxIdleTime(9)
VORKATHPreparation:FullPreparationCycle()

while API.Read_LoopyLoop() do
    -- Update buffs and overheads
    manageBuffs()
    prayerFlicker:update()
    if not fase1 then
        executefase1()
    end
    if not fase2 then
    executefase2()

    end
    if not fase3 then
        executefase3()
    end
    faseboss()

end
