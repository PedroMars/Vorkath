local API                  = require("api")
local Setup                = {}
--------------------------------------------------------------------------------------------------------------------------------
--# CHANGE THESE VALUES TO MATCH YOUR SETUP. DEFAULTS SHOWN BELOW.
--------------------------------------------------------------------------------------------------------------------------------
-- Variable Name          | Default Value       | Description
--------------------------------------------------------------------------------------------------------------------------------
Setup.HAS_ZUK_CAPE         = true               -- Whether you are using the Zuk Necro cape or not
Setup.RING_SWITCH          = "Occultist's ring"  -- Name of ring to switch to for Zuk fight (exact match required)
Setup.ADREN_POT_NAME       = "Adrenaline renewal"  -- Name of the adrenaline potion (partial match allowed)
Setup.FOOD_NAME            = "Shark" -- Name of the food on your action bar (partial match allowed)
Setup.FOOD_POT_NAME        = "Guthix rest"       -- Name of the food potion on your action bar (partial match allowed)
Setup.RESTORE_NAME         = "Super restore"     -- Name of the restore potion (partial match allowed)
Setup.NECRO_PRAYER_NAME    = "Ruination"            -- Name of the Necromancy prayer (exact match required)
Setup.NECRO_PRAYER_BUFF_ID = 30769              -- Buff ID for the Necromancy prayer when active (find using API.Buffbar_GetAllIDs)
Setup.OVERLOAD_NAME        = "Elder overload"    -- Name of the overload potion (partial match allowed)
Setup.OVERLOAD_BUFF_ID     = 49039               -- Buff ID for the overload potion when active (API.Buffbar_GetAllIDs)
Setup.USE_BOOK             = true                -- Whether to use a scripture book (false ignores the book values below)
Setup.BOOK_NAME            = "Scripture of Ful"  -- Name of the scripture book on your action bar (exact match required)
Setup.BOOK_BUFF_ID         = 52494               -- Buff ID for the scripture book when activated
Setup.USE_EXCAL            = true               -- Whether to use Enhanced Excalibur for healing (must be in inventory)
Setup.USE_ELVEN_SHARD      = true                -- Whether to use Elven Ritual Shard for prayer restore (must be in inventory)
Setup.USE_POISON           = true                -- Whether to use weapon poison (any type, must be in inventory)
--------------------------------------------------------------------------------------------------------------------------------
--# END
--------------------------------------------------------------------------------------------------------------------------------
local function checkSetup()
  local ERRORS             = { { "Setup Errors:", "" }, }
  local EXPECTED_ABILITIES = {
    "Greater Bone Shield",
    "Invoke Death",
    "Conjure Undead Army",
    "Touch of Death",
    "Soul Sap",
    "Basic<nbsp>Attack",
    "Threads of Fate",
    "Death Skulls",
    "Bloat",
    "Volley of Souls",
    "Finger of Death",
    "Weapon Special Attack",
    "Conjure Vengeful Ghost",
    "Conjure Skeleton Warrior",
    "Soul Strike",
    "Spectral Scythe",
    "Living Death",
    "Split Soul",
    "Freedom",
    "Resonance",
    "Anticipation",
    "Darkness",
    "Surge",
    "Devotion",
    "Barricade",
    "Soul Split",
    "Deflect Melee",
    "Deflect Magic",
    "Deflect Ranged",
    Setup.FOOD_NAME,
    Setup.FOOD_POT_NAME,
    Setup.NECRO_PRAYER_NAME
  }

  local EXPECTED_GEAR      = {
    "TokKul-Zo (Charged)",
    "Deathwarden nexus"
  }

  if Setup.HAS_ZUK_CAPE then table.insert(EXPECTED_GEAR, "Igneous Kal-Mor") end
  if Setup.USE_BOOK then table.insert(EXPECTED_ABILITIES, BOOK_NAME) end
  if Setup.USE_BOOK then table.insert(EXPECTED_GEAR, BOOK_NAME) end
  if Setup.USE_ELVEN_SHARD then table.insert(EXPECTED_INVENTORY, "elven ritual shard") end
  if Setup.USE_EXCAL then table.insert(EXPECTED_INVENTORY, "Excalibur") end
  if Setup.USE_POISON then table.insert(EXPECTED_INVENTORY, "Weapon poison") end

  for _, abilityName in ipairs(EXPECTED_ABILITIES) do
    local ability = API.GetABs_name(abilityName, false)
    if ability.id == 0 then
      table.insert(ERRORS, { "Missing ability from action bar", abilityName })
    end
  end

  for _, item in ipairs(EXPECTED_INVENTORY) do
    local count = API.InvItemcount_String(item)
    if count == 0 then
      table.insert(ERRORS, { "Missing from inventory", item })
    end
  end

  for _, gear in ipairs(EXPECTED_GEAR) do
    local equipped = Equipment:Contains(gear)
    if not equipped then
      table.insert(ERRORS, { "Missing from gear", gear })
    end
  end

  if #ERRORS > 1 then
    API.DrawTable(ERRORS)
  else
    API.DrawTable({ { "Setup: ", "Everything looks good!" } })
  end
end

if ... == nil then
  checkSetup()
end

return Setup
