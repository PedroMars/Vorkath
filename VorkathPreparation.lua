local API = require("api")

local Utils = require("VorkathNoob.VorkathUtils")

local Data = require("VorkathNoob.VorkathData")



local ALTAR_OF_WAR_ID = 114748

local BANK_CHEST_ID = 114750

local BOSS_PORTAL_ID = 128529

local DEATH_NPC_ID = 27299

local COMBAT_START_INTERFACE_ID = 1671

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

        Inventory:DoAction(self:WhichFamiliar(), 1, API.OFF_ACT_GeneralInterface_route)
        State.isFamiliarSummoned = true
        API.RandomSleep()
    end
end




function zukPreparation:IsDialogInterfacePresent()


    local isPresent = API.Check_Dialog_Open()

    if isPresent then

    end

    return isPresent

end



function zukPreparation:IsCombatStartInterfacePresent()


    local isPresent = API.Compare2874Status(COMBAT_START_INTERFACE_ID, false)

    if isPresent then


    end

    return isPresent

end



function zukPreparation:CheckStartLocation()

    if not (API.Dist_FLP(FFPOINT.new(3299, 10131, 0)) < 30) then



        Utils:WarsTeleport()

        API.RandomSleep()

    else



        State.isInWarsRetreat = true

        API.RandomSleep() -- Substituído de Utils:SleepTickRandom(2)

    end

end



function zukPreparation:HandlePrayerRestore()

    if API.GetPrayPrecent() < 100 or API.GetSummoningPoints_() < 60 then



        API.DoAction_Object1(0x3d, API.OFF_ACT_GeneralObject_route0, { ALTAR_OF_WAR_ID }, 50)

        API.WaitUntilMovingEnds(10, 4)

    end

    State.isRestoringPrayer = true

end



function zukPreparation:HandleBanking()

    API.DoAction_Object1(0x33, API.OFF_ACT_GeneralObject_route3, { BANK_CHEST_ID }, 50)

    API.WaitUntilMovingEnds(10, 4)



    State.isBanking = true

end



function zukPreparation:HandleAdrenalineCrystal()

    while not State.isMaxAdrenaline do

        if API.GetAddreline_() ~= 100 then



            Interact:Object("Adrenaline crystal", "Channel", 60)

            API.WaitUntilMovingandAnimEnds(10, 4)

            API.RandomSleep() -- Substituído de Utils:SleepTickRandom(1)

        else

            State.isMaxAdrenaline = true


        end

        API.RandomSleep() -- Substituído de Utils:SleepTickRandom(1)

    end

end


function zukPreparation:GoThroughPortal()


    API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route0, { BOSS_PORTAL_ID }, 50)

    API.WaitUntilMovingEnds(20, 4)

    API.RandomSleep2(10000, 1000, 2000) -- Substituído de Utils:SleepTickRandom(5) para um sleep em milissegundos com mais controle


    Interact:Object("Commemorative statue", "Claim loot", 10)


end

local function getBuff(buffId)
    local buff = API.Buffbar_GetIDstatus(buffId, false)
    return { found = buff.found, remaining = (buff.found and API.Bbar_ConvToSeconds(buff)) or 0 }
end



function zukPreparation:FullPreparationCycle()

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

    else
        return false
    end



    API.RandomSleep2(500, 1000, 2000) -- Mais tempo para o carregamento da luta, randomizado

    npcdeath = false


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




return zukPreparationlocal API = require("api")

local Utils = require("VorkathNoob.VorkathUtils")

local Data = require("VorkathNoob.VorkathData")



local ALTAR_OF_WAR_ID = 114748

local BANK_CHEST_ID = 114750

local BOSS_PORTAL_ID = 128529

local DEATH_NPC_ID = 27299

local COMBAT_START_INTERFACE_ID = 1671

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

        Inventory:DoAction(self:WhichFamiliar(), 1, API.OFF_ACT_GeneralInterface_route)
        State.isFamiliarSummoned = true
        API.RandomSleep()
    end
end




function zukPreparation:IsDialogInterfacePresent()


    local isPresent = API.Check_Dialog_Open()

    if isPresent then

    end

    return isPresent

end



function zukPreparation:IsCombatStartInterfacePresent()


    local isPresent = API.Compare2874Status(COMBAT_START_INTERFACE_ID, false)

    if isPresent then


    end

    return isPresent

end



function zukPreparation:CheckStartLocation()

    if not (API.Dist_FLP(FFPOINT.new(3299, 10131, 0)) < 30) then



        Utils:WarsTeleport()

        API.RandomSleep()

    else



        State.isInWarsRetreat = true

        API.RandomSleep() -- Substituído de Utils:SleepTickRandom(2)

    end

end



function zukPreparation:HandlePrayerRestore()

    if API.GetPrayPrecent() < 100 or API.GetSummoningPoints_() < 60 then



        API.DoAction_Object1(0x3d, API.OFF_ACT_GeneralObject_route0, { ALTAR_OF_WAR_ID }, 50)

        API.WaitUntilMovingEnds(10, 4)

    end

    State.isRestoringPrayer = true

end



function zukPreparation:HandleBanking()

    API.DoAction_Object1(0x33, API.OFF_ACT_GeneralObject_route3, { BANK_CHEST_ID }, 50)

    API.WaitUntilMovingEnds(10, 4)



    State.isBanking = true

end



function zukPreparation:HandleAdrenalineCrystal()

    while not State.isMaxAdrenaline do

        if API.GetAddreline_() ~= 100 then



            Interact:Object("Adrenaline crystal", "Channel", 60)

            API.WaitUntilMovingandAnimEnds(10, 4)

            API.RandomSleep() -- Substituído de Utils:SleepTickRandom(1)

        else

            State.isMaxAdrenaline = true


        end

        API.RandomSleep() -- Substituído de Utils:SleepTickRandom(1)

    end

end


function zukPreparation:GoThroughPortal()


    API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route0, { BOSS_PORTAL_ID }, 50)

    API.WaitUntilMovingEnds(20, 4)

    API.RandomSleep2(10000, 1000, 2000) -- Substituído de Utils:SleepTickRandom(5) para um sleep em milissegundos com mais controle


    Interact:Object("Commemorative statue", "Claim loot", 10)


end

local function getBuff(buffId)
    local buff = API.Buffbar_GetIDstatus(buffId, false)
    return { found = buff.found, remaining = (buff.found and API.Bbar_ConvToSeconds(buff)) or 0 }
end



function zukPreparation:FullPreparationCycle()

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

    else
        return false
    end



    API.RandomSleep2(500, 1000, 2000) -- Mais tempo para o carregamento da luta, randomizado

    npcdeath = false


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