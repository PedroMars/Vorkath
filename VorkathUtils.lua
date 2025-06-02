local API = require("api")
local Data = require("kerapac/KerapacData")
local State = require("kerapac/KerapacState")
local Logger = require("kerapac/KerapacLogger")

local KerapacUtils = {}

function KerapacUtils:SleepTickRandom(sleepticks)
    API.Sleep_tick(sleepticks)
    API.RandomSleep2(1, 120, 0)
end

function KerapacUtils:WhichFood()
    local food = ""
    local foundFood = false
    for i = 1, #Data.foodItems do
        foundFood = Inventory:Contains(Data.foodItems[i])
        if foundFood then
            food = Data.foodItems[i]
            break
        end
    end
    return food
end

function KerapacUtils:WhichEmergencyDrink()
    local emergencyDrink = ""
    local foundEmergencyDrink = false
    for i = 1, #Data.emergencyDrinkItems do
        foundEmergencyDrink = Inventory:Contains(Data.emergencyDrinkItems[i])
        if foundEmergencyDrink then
            emergencyDrink = Data.emergencyDrinkItems[i]
            break
        end
    end
    return emergencyDrink
end

function KerapacUtils:WhichEmergencyFood()
    local emergencyFood = ""
    local foundEmergencyFood = false
    for i = 1, #Data.emergencyFoodItems do
        foundEmergencyFood = Inventory:Contains(Data.emergencyFoodItems[i])
        if foundEmergencyFood then
            emergencyFood = Data.emergencyFoodItems[i]
            break
        end
    end
    return emergencyFood
end

function KerapacUtils:WhichPrayerRestore()
    local prayerRestore = ""
    local foundPrayerRestore = false
    for i = 1, #Data.prayerRestoreItems do
        foundPrayerRestore = Inventory:Contains(Data.prayerRestoreItems[i])
        if foundPrayerRestore then
            prayerRestore = Data.prayerRestoreItems[i]
            break
        end
    end
    return prayerRestore
end

function KerapacUtils:WhichOverload()
    local overload = ""
    local foundOverload = false
    for i = 1, #Data.overloadItems do
        foundOverload = Inventory:Contains(Data.overloadItems[i])
        if foundOverload then
            overload = Data.overloadItems[i]
            break
        end
    end
    return overload
end

function KerapacUtils:WhichWeaponPoison()
    local weaponPoison = ""
    local foundWeaponPoison = false
    for i = 1, #Data.weaponPoisonItems do
        foundWeaponPoison = Inventory:Contains(Data.weaponPoisonItems[i])
        if foundWeaponPoison then
            weaponPoison = Data.weaponPoisonItems[i]
            break
        end
    end
    return weaponPoison
end

function KerapacUtils:WhichAdrenalinePotion()
    local adrenalinePotion = ""
    local foundadrenalinePotion = false
    for i = 1, #Data.adrenalinePotionItems do
        foundadrenalinePotion = Inventory:Contains(Data.adrenalinePotionItems[i])
        if foundadrenalinePotion then
            adrenalinePotion = Data.adrenalinePotionItems[i]
            break
        end
    end
    return adrenalinePotion
end

function KerapacUtils:WhichFamiliar()
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

function KerapacUtils:IsFamiliarHpBelowPercentage(hpString, percentage)
    if not hpString or type(hpString) ~= "string" then
        return nil
    end
    if not percentage or type(percentage) ~= "number" or percentage < 0 then
        return nil
    end

    local currentHpStr, maxHpStr = string.match(hpString, "^([^/]+)/([^/]+)$")

    if not currentHpStr then
        hpString = hpString:match("^%s*(.-)%s*$")
        if hpString then
             currentHpStr, maxHpStr = string.match(hpString, "^([^/]+)/([^/]+)$")
        end
        if not currentHpStr then
             return nil
        end
    end

    currentHpStr = string.gsub(currentHpStr, ",", "")
    maxHpStr = string.gsub(maxHpStr, ",", "")

    local currentHp = tonumber(currentHpStr)
    local maxHp = tonumber(maxHpStr)

    if not currentHp or not maxHp then
        return nil
    end
    if maxHp <= 0 then
        return nil
    end

    local thresholdValue = maxHp * (percentage / 100.0)
    local isBelow = currentHp < thresholdValue

    return isBelow
end

function KerapacUtils:HandleSpecialSummoning()
    if not (API.Get_tick() - State.summoningSpecialTicks > 4) then return end
    if not Familiars:HasFamiliar() then return end 
    if not (Familiars:GetSpellPoints() >= Data.summoningPointsForScroll) then return end
    if Familiars:GetName() ~= "Hellhound" then return end
    
    local isHealable = self:IsFamiliarHpBelowPercentage(API.ScanForInterfaceTest2Get(false, { { 662,0,-1,0 }, { 662,43,-1,0 }, { 662,44,-1,0 }, { 662,64,-1,0 }, { 662,65,-1,0 }, { 662,66,-1,0 }, { 662,66,8,0 } })[1].textids, 70)
    if not isHealable then return end
    
    Familiars:CastSpecialAttack()
    State.summoningSpecialTicks = API.Get_tick()
    Logger:Info("Used familiar special attack")
end

function KerapacUtils:EatFood()
    if not Inventory:ContainsAny(Data.foodItems) and 
       not Inventory:ContainsAny(Data.emergencyDrinkItems) and 
       not Inventory:ContainsAny(Data.emergencyFoodItems) and 
       not API.Buffbar_GetIDstatus(Data.extraAbilities.immortalityAbility.buffId).found or
       API.GetHPrecent() >= Data.hpThreshold or 
       API.Get_tick() - State.eatFoodTicks <= Data.foodCooldown then 
        return 
    end
    
    local hasFood = Inventory:ContainsAny(Data.foodItems)
    local hasEmergencyFood = Inventory:ContainsAny(Data.emergencyFoodItems)
    local hasEmergencyDrink = Inventory:ContainsAny(Data.emergencyDrinkItems)
    local emergencyFoodAB = nil
    local emergencyDrinkAB = nil
    local eatFoodAB = API.GetABs_name1(self:WhichFood())
    if string.find(string.lower(self:WhichEmergencyFood()), "blue blubber") then
        emergencyFoodAB = API.GetABs_name1("Blue blubber jellyfish")
    elseif string.find(string.lower(self:WhichEmergencyFood()), "green blubber") then
        emergencyFoodAB = API.GetABs_name1("Green blubber jellyfish")
    end
    if string.find(string.lower(self:WhichEmergencyDrink()), "super guthix") then
        emergencyDrinkAB = API.GetABs_name1("Super Guthix rest")
    elseif string.find(string.lower(self:WhichEmergencyDrink()), "guthix") then
        emergencyDrinkAB = API.GetABs_name1("Guthix rest")
    elseif string.find(string.lower(self:WhichEmergencyDrink()), "super saradomin") then
        emergencyDrinkAB = API.GetABs_name1("Super Saradomin brew")
    elseif string.find(string.lower(self:WhichEmergencyDrink()), "saradomin") then
        emergencyDrinkAB = API.GetABs_name1("Saradomin brew")
    end
    
    if API.GetHPrecent() <= Data.emergencyEatThreshold then
        if hasFood then
            API.DoAction_Ability_Direct(eatFoodAB, 1, API.OFF_ACT_GeneralInterface_route)
        end
        if hasEmergencyFood and emergencyFoodAB ~= nil then
            API.DoAction_Ability_Direct(emergencyFoodAB, 1, API.OFF_ACT_GeneralInterface_route)
        end
        if hasEmergencyDrink and emergencyDrinkAB ~= nil then
            API.DoAction_Ability_Direct(emergencyDrinkAB, 1, API.OFF_ACT_GeneralInterface_route)
        end
        
        if Inventory:Contains("Enhanced Excalibur") and
           not API.DeBuffbar_GetIDstatus(Data.extraItems.excalibur, false).found then
            local excal = API.GetABs_name1("Enhanced Excalibur")
            API.DoAction_Ability_Direct(excal, 1, API.OFF_ACT_GeneralInterface_route)
        elseif Inventory:Contains("Augmented enhanced Excalibur") and
               not API.DeBuffbar_GetIDstatus(Data.extraItems.excalibur, false).found then
                local excal = API.GetABs_name1("Augmented enhanced Excalibur")
                API.DoAction_Ability_Direct(excal, 1, API.OFF_ACT_GeneralInterface_route)
        end
        
        Logger:Info("Eating a lot of food - emergency eating")
        State.eatFoodTicks = API.Get_tick()
    else
        if hasFood then
            API.DoAction_Ability_Direct(eatFoodAB, 1, API.OFF_ACT_GeneralInterface_route)
            Logger:Info("Eating some food")
            State.eatFoodTicks = API.Get_tick()
        elseif hasEmergencyFood and emergencyFoodAB ~= nil then
            API.DoAction_Ability_Direct(emergencyFoodAB, 1, API.OFF_ACT_GeneralInterface_route)
            Logger:Info("Eating some emergency food")
            State.eatFoodTicks = API.Get_tick()
        elseif hasEmergencyDrink and emergencyDrinkAB ~= nil then
            API.DoAction_Ability_Direct(emergencyDrinkAB, 1, API.OFF_ACT_GeneralInterface_route)
            Logger:Info("Drinking emergency potion")
            State.eatFoodTicks = API.Get_tick()
        end
    end
end

function KerapacUtils:DrinkPrayer()
    if not Inventory:ContainsAny(Data.prayerRestoreItems) or 
    API.GetPrayPrecent() >= Data.prayerThreshold or 
    API.Get_tick() - State.drinkRestoreTicks <= Data.drinkCooldown then return end

    local prayerAB = nil
    local prayerName = self:WhichPrayerRestore()
    
    if string.find(prayerName, "Prayer") then
        prayerAB = API.GetABs_name1("Prayer potion")
    elseif string.find(prayerName, "Super prayer") then
        prayerAB = API.GetABs_name1("Super prayer potion")
    elseif string.find(prayerName, "Extreme prayer") then
        prayerAB = API.GetABs_name1("Extreme prayer potion")
    elseif string.find(prayerName, "Super restore") then
        prayerAB = API.GetABs_name1("Super restore potion")
    end
    if prayerAB ~= nil then
       API.DoAction_Ability_Direct(prayerAB, 1, API.OFF_ACT_GeneralInterface_route) 
    end
    Logger:Info("Drinking prayer potion")
    State.drinkRestoreTicks = API.Get_tick()
end

function KerapacUtils:DrinkOverload()
    if not Inventory:ContainsAny(Data.overloadItems) or 
    API.Buffbar_GetIDstatus(Data.overloadBuff.ElderOverload.buffId).found or 
    API.Buffbar_GetIDstatus(Data.overloadBuff.Overload.buffId).found or
    API.Buffbar_GetIDstatus(Data.overloadBuff.SupremeOverload.buffId).found or
    API.Get_tick() - State.drinkRestoreTicks <= Data.drinkCooldown then return end

    local overloadAB = nil
    local overloadName = self:WhichOverload()
    
    if string.find(overloadName, "Overload") then
        overloadAB = API.GetABs_name1("Overload potion")
    elseif string.find(overloadName, "Holy overload") then
        overloadAB = API.GetABs_name1("Holy overload potion")
    elseif string.find(overloadName, "Searing overload") then
        overloadAB = API.GetABs_name1("Searing overload potion")
    elseif string.find(overloadName, "Overload salve") then
        overloadAB = API.GetABs_name1("Overload salve")
    elseif string.find(overloadName, "Aggroverload") then
        overloadAB = API.GetABs_name1("Aggroverload")
    elseif string.find(overloadName, "Holy aggroverload") then
        overloadAB = API.GetABs_name1("Holy aggroverload")
    elseif string.find(overloadName, "Supreme overload salve") then
        overloadAB = API.GetABs_name1("Supreme overload salve")
    elseif string.find(overloadName, "Elder overload salve") then
        overloadAB = API.GetABs_name1("Elder overload salve")
    elseif string.find(overloadName, "Supreme overload potion") then
        overloadAB = API.GetABs_name1("Supreme overload potion")
    elseif string.find(overloadName, "Elder overload potion") then
        overloadAB = API.GetABs_name1("Elder overload potion")
    end

    if overloadAB ~= nil then
        API.DoAction_Ability_Direct(overloadAB, 1, API.OFF_ACT_GeneralInterface_route) 
    end
    Logger:Info("Drinking overload potion")
    State.drinkRestoreTicks = API.Get_tick()
end

function KerapacUtils:DrinkWeaponPoison()
    if not Inventory:ContainsAny(Data.weaponPoisonItems) or 
    API.Buffbar_GetIDstatus(Data.weaponPoisonBuff).found or
    API.Get_tick() - State.drinkRestoreTicks <= Data.drinkCooldown then return end

    local weaponPoisonAB = nil
    local items = {
        "Weapon Poison",
        "Weapon Poison++",
        "Weapon Poison+++"
    }
    
    for i = 1, #items, 1 do
        local ab = items[i]
        local ability = API.GetABs_name1(ab)
        if(ability.enabled)then
            weaponPoisonAB = ability
        end
    end
    
    if weaponPoisonAB ~= nil then
        API.DoAction_Ability_Direct(weaponPoisonAB, 1, API.OFF_ACT_GeneralInterface_route)
    end
    Logger:Info("Applying weapon poison")
    State.drinkRestoreTicks = API.Get_tick()
end

function KerapacUtils:DrinkAdrenalinePotion()
    if not Inventory:ContainsAny(Data.adrenalinePotionItems) or 
    API.DeBuffbar_GetIDstatus(26094).found or
    API.Get_tick() - State.drinkRestoreTicks <= Data.drinkCooldown then return end

    local adrenalineAB = nil
    local potionName = self:WhichAdrenalinePotion()
    
    if string.find(potionName, "Adrenaline renewal") then
        adrenalineAB = API.GetABs_name1("drenaline renewal")
    elseif string.find(potionName, "Adrenaline potion") then
        adrenalineAB = API.GetABs_name1("Adrenaline potion")
    elseif string.find(potionName, "Super adrenaline potion") then
        adrenalineAB = API.GetABs_name1("Super adrenaline potion")
    elseif string.find(potionName, "Replenishment potion") then
        adrenalineAB = API.GetABs_name1("Replenishment potion")
    elseif string.find(potionName, "Enhanced replenishment potion") then
        adrenalineAB = API.GetABs_name1("Enhanced replenishment potion")
    end

    API.DoAction_Ability_Direct(adrenalineAB, 1, API.OFF_ACT_GeneralInterface_route)
    Logger:Info("Drinking adrenaline potion")
    State.drinkRestoreTicks = API.Get_tick()
end

function KerapacUtils:CheckForScripture()
    if API.Container_Get_s(94, Data.extraBuffs.scriptureOfJas.itemId).item_id > 0 then
        State.scripture = Data.extraBuffs.scriptureOfJas
        State.isScriptureEquipped = true
    end
    if API.Container_Get_s(94, Data.extraBuffs.scriptureOfWen.itemId).item_id > 0 then
        State.scripture = Data.extraBuffs.scriptureOfWen
        State.isScriptureEquipped = true
    end
    if API.Container_Get_s(94, Data.extraBuffs.scriptureOfFul.itemId).item_id > 0 then
        State.scripture = Data.extraBuffs.scriptureOfFul
        State.isScriptureEquipped = true
    end
    if API.Container_Get_s(94, Data.extraBuffs.scriptureOfAmascut.itemId).item_id > 0 then
        State.scripture = Data.extraBuffs.scriptureOfAmascut
        State.isScriptureEquipped = true
    end
end

function KerapacUtils:ValidateAbilityBars()
    if State.isAbilityBarsValidated then return end
    local hasFood = Inventory:ContainsAny(Data.foodItems)
    local hasEmergencyFood = Inventory:ContainsAny(Data.emergencyFoodItems)
    local hasEmergencyDrink = Inventory:ContainsAny(Data.emergencyDrinkItems)
    local hasAdrenPot = Inventory:ContainsAny(Data.adrenalinePotionItems)
    local hasWeaponPoison = Inventory:ContainsAny(Data.weaponPoisonItems)
    local hasOverload = Inventory:ContainsAny(Data.overloadItems)
    local hasPrayer = Inventory:ContainsAny(Data.prayerRestoreItems)
    local hasEnhancedExcal = Inventory:Contains("Enhanced Excalibur")
    local hasAugEnhExcal = Inventory:Contains("Augmented enhanced Excalibur")
    local hasVitPot =  Inventory:Contains("Powerburst of vitality (4)") or Inventory:Contains("Powerburst of vitality (3)") or Inventory:Contains("Powerburst of vitality (2)") or Inventory:Contains("Powerburst of vitality (1)")
    local hasVulnBomb = Inventory:Contains("Vulnerability bomb")
    local emergencyFoodAB = nil
    local emergencyDrinkAB = nil
    local adrenalineAB = nil
    local weaponPoisonAB = nil
    local overloadAB = nil
    local excalAB = nil
    local prayerAB = nil
    local overloadName = self:WhichOverload()
    local eatFoodAB = API.GetABs_name1(self:WhichFood())
    local potionName = self:WhichAdrenalinePotion()
    local prayerName = self:WhichPrayerRestore()
    local items = {
        "Weapon Poison",
        "Weapon Poison++",
        "Weapon Poison+++"
    }
    for i = 1, #items, 1 do
        local ab = items[i]
        local ability = API.GetABs_name1(ab)
        if(ability.enabled)then
            weaponPoisonAB = ability
        end
    end
    self:CheckForScripture()
    
    if string.find(potionName, "Adrenaline renewal") then
        adrenalineAB = API.GetABs_name1("drenaline renewal")
    elseif string.find(potionName, "Adrenaline potion") then
        adrenalineAB = API.GetABs_name1("Adrenaline potion")
    elseif string.find(potionName, "Super adrenaline potion") then
        adrenalineAB = API.GetABs_name1("Super adrenaline potion")
    elseif string.find(potionName, "Replenishment potion") then
        adrenalineAB = API.GetABs_name1("Replenishment potion")
    elseif string.find(potionName, "Enhanced replenishment potion") then
        adrenalineAB = API.GetABs_name1("Enhanced replenishment potion")
    end
    if string.find(string.lower(self:WhichEmergencyFood()), "blue blubber") then
        emergencyFoodAB = API.GetABs_name1("Blue blubber jellyfish")
    elseif string.find(string.lower(self:WhichEmergencyFood()), "green blubber") then
        emergencyFoodAB = API.GetABs_name1("Green blubber jellyfish")
    end
    if string.find(string.lower(self:WhichEmergencyDrink()), "super guthix") then
        emergencyDrinkAB = API.GetABs_name1("Super Guthix rest")
    elseif string.find(string.lower(self:WhichEmergencyDrink()), "guthix") then
        emergencyDrinkAB = API.GetABs_name1("Guthix rest")
    elseif string.find(string.lower(self:WhichEmergencyDrink()), "super saradomin") then
        emergencyDrinkAB = API.GetABs_name1("Super Saradomin brew")
    elseif string.find(string.lower(self:WhichEmergencyDrink()), "saradomin") then
        emergencyDrinkAB = API.GetABs_name1("Saradomin brew")
    end

    if string.find(overloadName, "Overload") then
        overloadAB = API.GetABs_name1("Overload potion")
    elseif string.find(overloadName, "Holy overload") then
        overloadAB = API.GetABs_name1("Holy overload potion")
    elseif string.find(overloadName, "Searing overload") then
        overloadAB = API.GetABs_name1("Searing overload potion")
    elseif string.find(overloadName, "Overload salve") then
        overloadAB = API.GetABs_name1("Overload salve")
    elseif string.find(overloadName, "Aggroverload") then
        overloadAB = API.GetABs_name1("Aggroverload")
    elseif string.find(overloadName, "Holy aggroverload") then
        overloadAB = API.GetABs_name1("Holy aggroverload")
    elseif string.find(overloadName, "Supreme overload salve") then
        overloadAB = API.GetABs_name1("Supreme overload salve")
    elseif string.find(overloadName, "Elder overload salve") then
        overloadAB = API.GetABs_name1("Elder overload salve")
    elseif string.find(overloadName, "Supreme overload potion") then
        overloadAB = API.GetABs_name1("Supreme overload potion")
    elseif string.find(overloadName, "Elder overload potion") then
        overloadAB = API.GetABs_name1("Elder overload potion")
    end
    
    if string.find(prayerName, "Prayer") then
        prayerAB = API.GetABs_name1("Prayer potion")
    elseif string.find(prayerName, "Super prayer") then
        prayerAB = API.GetABs_name1("Super prayer potion")
    elseif string.find(prayerName, "Extreme prayer") then
        prayerAB = API.GetABs_name1("Extreme prayer potion")
    elseif string.find(prayerName, "Super restore") then
        prayerAB = API.GetABs_name1("Super restore potion")
    end

    if hasEnhancedExcal then
        excalAB = API.GetABs_name1("Enhanced Excalibur")
    end
    if hasAugEnhExcal then
        excalAB = API.GetABs_name1("Augmented enhanced Excalibur")
    end

    if State.isHardMode then
        if not hasVitPot then
            local data = {
                { "Ernie's Kerapac Bosser ", "Version: " .. Data.version },
                { "-------", "-------" },
                { "- Missing powerburst of vitality", ""},
                { "-------", "-------" }
            }
        
            API.DrawTable(data)
            Logger:Error("No Powerburst of vitality found in Inventory")
            API.Write_LoopyLoop(false)
        end
    end

    local noFoodFound = false
    local noEmergencyFoodFound = false
    local noEmergencyDrinkFound = false
    local noAdrenPotFound = false
    local noWeapPoisonFound = false
    local noOverloadFound = false
    local noPrayerFound = false
    local noExcalFound = false
    local noScriptureFound = false
    local noVulnBomb = false

    if hasFood then
        if not eatFoodAB.enabled then
            noFoodFound = true
        end
    end

    if hasEmergencyFood then
        if not emergencyFoodAB.enabled then
            noEmergencyFoodFound = true
        end
    end

    if hasEmergencyDrink then
        if not emergencyDrinkAB.enabled then
            noEmergencyDrinkFound = true
        end
    end

    if hasAdrenPot then
        if not adrenalineAB.enabled then
            noAdrenPotFound = true
        end
    end

    if hasWeaponPoison then
        if weaponPoisonAB == nil or not weaponPoisonAB.enabled then
            noWeapPoisonFound = true
        end
    end

    if hasOverload then
        if not overloadAB.enabled then
            noOverloadFound = true
        end
    end

    if hasPrayer then
        if not prayerAB.enabled then
            noPrayerFound = true
        end
    end

    if hasVulnBomb then
        if not API.GetABs_name1("Vulnerability bomb").enabled then
            noVulnBomb = true
        end
    end

    if hasEnhancedExcal or hasAugEnhExcal then
        if not excalAB.enabled then
            noExcalFound = true
        end
    end

    if State.isScriptureEquipped then
        if not State.scripture.AB.enabled then
            noScriptureFound = true
        end
    end

    local message = ""
    local hasAnyMissing = false
    
    if noFoodFound then 
        message = message .. "Food\n"
        hasAnyMissing = true
    end

    if noEmergencyFoodFound then
        message = message .. "Emergency food\n"
        hasAnyMissing = true
    end

    if noEmergencyDrinkFound then
        message = message .. "Emergency drink\n"
        hasAnyMissing = true
    end

    if noAdrenPotFound then
        message = message .. "Adrenaline potion\n"
        hasAnyMissing = true
    end

    if noWeapPoisonFound then
        message = message .. "Weapon poison\n"
        hasAnyMissing = true
    end

    if noOverloadFound then
        message = message .. "Overload\n"
        hasAnyMissing = true
    end

    if noPrayerFound then 
        message = message .. "Prayer restore\n"
        hasAnyMissing = true
    end

    if noVulnBomb then
        message = message .. "Vulnerability bomb\n"
        hasAnyMissing = true
    end

    if noExcalFound then 
        message = message .. "Enhanced Excalibur\n"
        hasAnyMissing = true
    end

    if noScriptureFound then 
        message = message .. "Scripture\n"
        hasAnyMissing = true
    end

    if hasAnyMissing then
            local data = {
        { "Ernie's Kerapac Bosser ", "Version: " .. Data.version },
        { "-------", "-------" },
        { "- Missing items on Ability bar", message},
        { "-------", "-------" }
    }

    API.DrawTable(data)
        Logger:Error("Your ability bar is missing the following: " .. message)
        API.Write_LoopyLoop(false)
    end

end

function KerapacUtils:SummonFamiliar()
    if not Familiars:HasFamiliar() and Inventory:ContainsAny(Data.summoningPouches) then
        Logger:Info("Summoning familiar " .. self:WhichFamiliar())
        Inventory:DoAction(self:WhichFamiliar(), 1, API.OFF_ACT_GeneralInterface_route)
        State.isFamiliarSummoned = true
        self:SleepTickRandom(1)
    else
        Logger:Debug("familiar is summoned or pouch in inventory")
    end
end

function KerapacUtils:SetupAutoFire()
    if Familiars:HasFamiliar() and not State.isAutoFireSetup and Familiars:GetName() ~= "Hellhound" then
        API.DoAction_Interface(0xffffffff,0xffffffff,1,662,74,-1,API.OFF_ACT_GeneralInterface_route)
        self:SleepTickRandom(2)
        API.KeyPress_(0x01)
        API.KeyPress_2(0x0D)
        Logger:Info("Setting up auto fire of scrolls")
        State.isAutoFireSetup = true
    else
        Logger:Debug("auto fire not setup")
    end
end

function KerapacUtils:StoreScrollsInFamiliar()
    if Familiars:HasFamiliar() and State.isAutoFireSetup then
        API.DoAction_Interface(0xffffffff,0xffffffff,1,662,78,-1,API.OFF_ACT_GeneralInterface_route)
        Logger:Info("Storing scrolls in familiar")
        self:SleepTickRandom(1)
    end
end

function KerapacUtils:RenewFamiliar()
    if API.Buffbar_GetIDstatus(26095).found then
        local timeRemaining = tonumber(string.match(API.Buffbar_GetIDstatus(26095).text, "(-?%d+%.?%d*)"))
        if timeRemaining ~=nil then
            if timeRemaining <= 1 then
                if Familiars:HasFamiliar() then
                    if(Inventory:ContainsAny(Data.summoningPouches)) then
                        API.DoAction_Interface(0xffffffff,0xffffffff,1,662,53,-1,API.OFF_ACT_GeneralInterface_route)
                        self:SleepTickRandom(1)
                        Logger:Info("Renewing familiar")
                    end
                end
            end
        end
    end
end

function KerapacUtils:CheckWeaponType()
    local equippedItems = API.Container_Get_all(94)
    for i = 1, #equippedItems do
        local itemId = equippedItems[i].item_id
        
        for j = 1, #Data.deathGuardIds do
            if itemId == Data.deathGuardIds[j] then
                State.hasDeathGuardEquipped = true
                Logger:Info("Death Guard equipped")
                break
            end
        end

        for k = 1, #Data.omniGuardIds do
            if itemId == Data.omniGuardIds[k] then
                State.hasOmniGuardEquipped = true
                Logger:Info("Omni Guard equipped")
                break
            end
        end
    end
end

function KerapacUtils:CheckForZukCape()
    for i = 1, #API.Container_Get_all(94) do
        if API.Container_Get_all(94)[i].item_id == 55189 or API.Container_Get_all(94)[i].item_id == 52504 then
            Data.extraAbilities.deathSkullsAbility.threshold = 60
            Logger:Info("Zuk Cape detected - adjusted Death Skulls threshold")
            break
        end
    end
end

function KerapacUtils:RemoveDuplicates(tbl)
    local hash, result = {}, {}
    for _, v in pairs(tbl) do
        if not hash[v] then
            hash[v] = true
            table.insert(result, v)
        end
    end
    return result
end

function KerapacUtils:AddIfNotExists(array, value)
    value = value % 360
    for _, v in ipairs(array) do
        if v == value then
            return false
        end
    end
    table.insert(array, value)
    return true
end

function KerapacUtils:findMatchingValues(lootTable, rareDropsTable)
    local matches = {}
    
    for _, itemId in ipairs(lootTable) do
        if rareDropsTable[itemId] then
            local dropData = {
                id = itemId,
                name = rareDropsTable[itemId].name,
                thumbnail = rareDropsTable[itemId].icon,
                message = nil
            }
            table.insert(matches, dropData)
        end
    end
    
    return matches
end

function KerapacUtils:WarsTeleport()
    API.DoAction_Ability("War's Retreat", 1, API.OFF_ACT_GeneralInterface_route, false)
    self:SleepTickRandom(10)
    Logger:Info("Teleported to War's Retreat")
end

function KerapacUtils:handleTimeWarpBuff()
    if State.hasTimeWarpBuff then
        local buff = API.Buffbar_GetIDstatus(Data.timeWarpBuff).found
        if not buff then 
            State.hasTimeWarpBuff = false
            if not State.isEchoesDead then
                local HardMode = require("kerapac/KerapacHardMode")
                HardMode:AttackEcho()
            else
                local Combat = require("kerapac/KerapacCombat")
                Combat:AttackKerapac()
            end
            return 
        end
    end
    if not State.hasTimeWarpBuff then
    State.hasTimeWarpBuff = true
    end
end

function KerapacUtils:handleCombatMode()
    if State.isFullManualEnabled then return end
    if API.VB_FindPSettinOrder(627, 0).state == 1073750353 then
        State.isFullManualEnabled = true
        self:SleepTickRandom(1)
    else
        API.DoAction_Interface(0xffffffff,0xffffffff,4,1430,265,-1,API.OFF_ACT_GeneralInterface_route)
        self:SleepTickRandom(1)
    end
    if State.isAutoRetaliateDisabled then return end
    if API.VB_FindPSettinOrder(462, 0).state == 1 then
        State.isAutoRetaliateDisabled = true
        self:SleepTickRandom(1)
    else
        API.DoAction_Interface(0xffffffff,0xffffffff,1,1430,57,-1,API.OFF_ACT_GeneralInterface_route)
        self:SleepTickRandom(1)
    end
end

function KerapacUtils:forceUseTimeWarpBuff()
    if State.hasTimeWarpBuff then
        API.DoAction_Interface(0x2e, 0xffffffff, 1, 743, 1, -1, API.OFF_ACT_GeneralInterface_route)
        State.hasTimeWarpBuff = false
    end
end

function KerapacUtils:TrackingData()
    local data = {
        { "Ernie's Kerapac Bosser ", "Version: " .. Data.version },
        { "-------", "-------" },
        { "Data:",API.ScriptRuntimeString() },
        { "- Total Kills", Data.totalKills},
        { "- Total Deaths", Data.totalDeaths},
        { "- Total Rares", Data.totalRares},
        { "-------", "-------" },
    }

    API.DrawTable(data)
end

function KerapacUtils:SendDropNotification(rareDrop)
    local embed = {
        title = string.format("Oops Kerapac dropped the following item for you %s", rareDrop.name),
        description = rareDrop.message,
        color = 8380656,
        author = {
            name = "Ernie's Kerapac Bosser ",
            icon_url = "https://media.tenor.com/A-dUfi3bkMoAAAAj/pato-juan.gif"
        },
        thumbnail = {url = rareDrop.thumbnail},
        fields = {
            {name = "Kill Number", value = tostring(Data.totalKills), inline = true},
            {name = "Runtime", value = API.ScriptRuntimeString(), inline = true}
        }
    }
    
    local payload = {
        content = "^<@"..Data.discordUserId.."^>",
        embeds = {embed}
    }
    
    local jsonPayload = API.JsonEncode(payload)
    local commandPayload = jsonPayload:gsub('"', '\\"')
    
    local command = string.format(
        'curl.exe -X POST -H "Content-Type: application/json" -d "%s" "%s"',
        commandPayload,
        Data.discordWebhookUrl
    )
    
    return os.execute(command)
end

return KerapacUtils