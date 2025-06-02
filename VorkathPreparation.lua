local API = require("api")

local Logger = require("zukME-main.ZukLogger")

local Utils = require("kerapac/KerapacUtils")

local Data = require("zukME-main.KerapacData")

local AURAS = require("core.auras")


local ALTAR_OF_WAR_ID = 114748

local BANK_CHEST_ID = 114750

local BOSS_PORTAL_ID = 128529

local DEATH_NPC_ID = 27299

local COLOSSEUM_ENTRANCE_ID = 120046


local COMBAT_START_INTERFACE_ID = 1671


local COMBAT_INITIATOR_NPC_ID = 28525

local npcdeath = false




local State = {

    isPlayerDead = false,

    isInWarsRetreat = false,

    isRestoringPrayer = false,

    isBanking = false,

    isMaxAdrenaline = false,

    isPortalUsed = false,

    canAttack = false,

    isSetupFirstInstance = false,

    playerPosition = nil,

    centerOfArenaPosition = nil,

    startLocationOfArena = nil

}



function State:Reset()

    self.isInWarsRetreat = false

    self.isRestoringPrayer = false

    self.isBanking = false

    self.isMaxAdrenaline = false

    self.isPortalUsed = false

    Logger:Info("Estado do script resetado.")

end



local zukPreparation = {}

function zukPreparation:HasNpcNearbyById(npc_id, distance)
    -- O tipo de objeto '1' é para NPCs (do arquivo api.lua)
    local npcs_found = API.GetAllObjArray1({npc_id}, distance, {1})

    if npcs_found and #npcs_found > 0 then
        API.Log(string.format("NPC com ID %d encontrado a até %d tiles de distância.", npc_id, distance), "info")
        return true
    else
        return false
    end
end

function zukPreparation:WhichFamiliar()
    local familiar = ""
    local foundFamiliar = false
    for i = 1, #Data.summoningPouches do
        foundFamiliar = Inventory:Contains(Data.summoningPouches[i])
        if foundFamiliar then
            familiar = Data.summoningPouches[i]
            break
        end
    end
    return familiar
end

function zukPreparation:SummonFamiliar()
    if not Familiars:HasFamiliar() and Inventory:ContainsAny(Data.summoningPouches) then
        Logger:Info("Summoning familiar " .. self:WhichFamiliar())
        Inventory:DoAction(self:WhichFamiliar(), 1, API.OFF_ACT_GeneralInterface_route)
        State.isFamiliarSummoned = true
        API.RandomSleep()
    else
        Logger:Debug("familiar is summoned or pouch in inventory")
    end
end




function zukPreparation:IsDialogInterfacePresent()

    Logger:Info("DEBUG: Checking if dialog interface is present using API.Check_Dialog_Open().")

    local isPresent = API.Check_Dialog_Open()

    if isPresent then

        Logger:Debug("Dialog interface is present.")

    else

        Logger:Debug("Dialog interface is NOT present.")

    end

    return isPresent

end



function zukPreparation:IsCombatStartInterfacePresent()

    Logger:Info("DEBUG: Checking if combat start interface is present using API.Compare2874Status().")

    local isPresent = API.Compare2874Status(COMBAT_START_INTERFACE_ID, false)

    if isPresent then

        Logger:Debug("Combat start interface (ID: " .. COMBAT_START_INTERFACE_ID .. ") is present via Compare2874Status.")

    else

        Logger:Debug("Combat start interface (ID: " .. COMBAT_START_INTERFACE_ID .. ") is NOT present via Compare2874Status.")

    end

    return isPresent

end



function zukPreparation:CheckStartLocation()

    if not (API.Dist_FLP(FFPOINT.new(3299, 10131, 0)) < 30) then

        Logger:Info("Teleporting to War's Retreat")

        Utils:WarsTeleport()

        API.RandomSleep()

    else

        Logger:Info("Already in War's Retreat")

        State.isInWarsRetreat = true

        API.RandomSleep() -- Substituído de Utils:SleepTickRandom(2)

    end

end



function zukPreparation:HandlePrayerRestore()

    if API.GetPrayPrecent() < 100 or API.GetSummoningPoints_() < 60 then

        Logger:Info("Restoring prayer and summoning at Altar of War")

        API.DoAction_Object1(0x3d, API.OFF_ACT_GeneralObject_route0, { ALTAR_OF_WAR_ID }, 50)

        API.WaitUntilMovingEnds(10, 4)

    end

    State.isRestoringPrayer = true

end



function zukPreparation:HandleBanking()

    API.DoAction_Object1(0x33, API.OFF_ACT_GeneralObject_route3, { BANK_CHEST_ID }, 50)

    API.WaitUntilMovingEnds(10, 4)

    Logger:Info("Loading preset")

    State.isBanking = true

end



function zukPreparation:HandleAdrenalineCrystal()

    while not State.isMaxAdrenaline do

        if API.GetAddreline_() ~= 100 then

            Logger:Info("Charging adrenaline...")

            Interact:Object("Adrenaline crystal", "Channel", 60)

            API.WaitUntilMovingandAnimEnds(10, 4)

            API.RandomSleep() -- Substituído de Utils:SleepTickRandom(1)

        else

            State.isMaxAdrenaline = true

            Logger:Info("Adrenaline fully charged.")

        end

        API.RandomSleep() -- Substituído de Utils:SleepTickRandom(1)

    end

end



local function MoveYPositive(distance)

    local random_x_offset = math.random(-5, 5)

    local currentPosition = API.PlayerCoord()

    local targetPosition = FFPOINT.new(currentPosition.x + random_x_offset, currentPosition.y + distance, currentPosition.z)



    Logger:Info(string.format("Moving player %d fields in positive Y direction to (%d, %d)", distance, targetPosition.x, targetPosition.y))

    API.DoAction_TileF(targetPosition)

    API.WaitUntilMovingEnds(20, 4) -- Espera o movimento terminar

    Logger:Info("Movement complete.")

end





function zukPreparation:GoThroughPortal()

    Logger:Info("Going through boss portal")

    API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route0, { BOSS_PORTAL_ID }, 50)

    API.WaitUntilMovingEnds(20, 4)

    API.RandomSleep2(10000, 1000, 2000) -- Substituído de Utils:SleepTickRandom(5) para um sleep em milissegundos com mais controle


    Interact:Object("Commemorative statue", "Claim loot", 10)


end

local function getBuff(buffId)
    local buff = API.Buffbar_GetIDstatus(buffId, false)
    return { found = buff.found, remaining = (buff.found and API.Bbar_ConvToSeconds(buff)) or 0 }
end
local Bonfire = getBuff(10931)




function zukPreparation:FullPreparationCycle()

    Logger:Info("Iniciando ciclo de preparação completo.")


    if not Equipment:Contains("Augmented Omni guard") then
        self:ReclaimItemsAtGrave()
        if not Equipment:Contains("Augmented Omni guard") then
            return false
        end
    end


    self:CheckStartLocation()

    API.RandomSleep() -- Substituído de Utils:SleepTickRandom(2)


    self:HandleBanking()

    API.RandomSleep() -- Substituído de Utils:SleepTickRandom(2)



    self:HandlePrayerRestore()

    API.RandomSleep() -- Substituído de Utils:SleepTickRandom(2)


    self:SummonFamiliar()

    API.RandomSleep()

    API.RandomSleep()

    self:HandleAdrenalineCrystal()

    API.RandomSleep() -- Substituído de Utils:SleepTickRandom(2)



    self:GoThroughPortal()

    API.RandomSleep() -- Substituído de Utils:SleepTickRandom(2)



    Interact:Object("Commemorative statue", "Inspect", 10)


    API.RandomSleep2(1300, 1500, 2500) -- Pequena pausa para a interface aparecer, agora mais randomizada


    API.RandomSleep() -- Substituído de Utils:SleepTickRandom(3)

    if API.DoAction_Interface(0x24,0xffffffff,1,1591,60,-1,API.OFF_ACT_GeneralInterface_route) then
        Logger:Info("Cliquei em iniciar.")
    else
        return false
    end



    API.RandomSleep2(500, 1000, 2000) -- Mais tempo para o carregamento da luta, randomizado

    npcdeath = false

    Logger:Info("Ciclo de preparação completo finalizado.")

end



function zukPreparation:ReclaimItemsAtGrave()
    API.RandomSleep2(10000, 3000, 4000) -- Substituído de Utils:SleepTickRandom(10)

    if API.DoAction_NPC(0x29,API.OFF_ACT_InteractNPC_route3,{ DEATH_NPC_ID },50) and State.isPlayerDead then
        API.RandomSleep2(1000, 1000, 1500)
        API.DoAction_NPC(0x29,API.OFF_ACT_InteractNPC_route3,{ 27299 },9)
        API.RandomSleep2(1000, 1000, 1500) -- Substituído de Utils:SleepTickRandom(5)

        if API.DoAction_Interface(0xffffffff,0xffffffff,1,1626,47,-1,API.OFF_ACT_GeneralInterface_route) then
            API.RandomSleep2(1000, 1000, 1500)
        end


        if API.DoAction_Interface(0xffffffff,0xffffffff,0,1626,72,-1,API.OFF_ACT_GeneralInterface_Choose_option) then

            API.RandomSleep2(500, 1000, 1500) -- Substituído de Utils:SleepTickRandom(5)

            Logger:Info("Items reclaimed from grave")

        end
        return true
    else
        return false
    end

end

function zukPreparation:CheckPlayerDeath()
    zukPreparation:VerificarNpcDeath()
    if API.GetHP_() <= 0 and not State.isPlayerDead or npcdeath == true then
        State.isPlayerDead = true
        Data.totalDeaths = Data.totalDeaths + 1
        Logger:Warn("Player died!")
    end
end

function zukPreparation:checkAndActiveAura()
    if getBuff(26098) then
        API.DoAction_Interface(0xffffffff,0xffffffff,1,1464,15,14,API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(1000, 500, 200)
        API.DoAction_Interface(0xffffffff,0x5716,1,1929,95,23,API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(1000, 500, 200)
        API.DoAction_Interface(0xffffffff,0x7c68,1,1929,24,-1,API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep()
        API.DoAction_Interface(0xffffffff,0xffffffff,0,1188,8,-1,API.OFF_ACT_GeneralInterface_Choose_option)
        API.RandomSleep2(1000, 500, 200)
        API.DoAction_Interface(0x24,0xffffffff,1,1929,16,-1,API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(1000, 500, 200)
        API.DoAction_Interface(0x24,0xffffffff,1,1929,167,-1,API.OFF_ACT_GeneralInterface_route)
    end
end
npcdeath = false
function zukPreparation:VerificarNpcDeath()

    if API.DoAction_NPC(0x29,API.OFF_ACT_InteractNPC_route3,{ DEATH_NPC_ID },50) then
        npcdeath = true
    else
        npcdeath = false
    end
end

function zukPreparation:HandleDeathNPC() -- Use 'self' ou o nome da tabela (zukPreparation) para métodos
    -- Procura o NPC da Morte (tipo 1, a uma distância de até 20 tiles)
    if State.isPlayerDead then
        if zukPreparation:ReclaimItemsAtGrave() then -- Chama a função de resgate de itens que já deve estar aqui
            API.RandomSleep2(1000, 500, 200) -- Pequeno sleep após a ação
            if not Equipment:Contains("Augmented Omni guard") then
                API.logInfo("Deu algo errado man.")
                zukPreparation:ReclaimItemsAtGrave()
                if Equipment:Contains("Augmented Omni guard") then
                    zukPreparation:FullPreparationCycle()
                    return true
                else
                    return false
                end
            end
            zukPreparation:FullPreparationCycle()
        else
            return false
        end
    end

end




return zukPreparation