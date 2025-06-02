local KerapacData = {}

KerapacData.version = "10.0"

-- User configuration - modify these values
KerapacData.partyLeader = nil -- replace nil with playername like this "Bob" 
KerapacData.partyMembers = {} -- Add all player names including partyleader like this {"Bob", "Jo", "Mama"}
KerapacData.bankPin = nil     -- replace nil with your bank pin like this 1234 don't add ""
KerapacData.discordWebhookUrl = "" -- add your Discord Webhook URL here
KerapacData.discordUserId = "" -- add your Discord User ID here

KerapacData.prayerType = {
    Curses = { name = "Curses" },
    Prayers = { name = "Prayers" }
}

KerapacData.foodItems = {
    "Lobster", "Swordfish", "Desert sole", "Catfish", "Monkfish", "Beltfish", 
    "Ghostly sole", "Cooked eeligator", "Shark", "Sea turtle", "Great white shark", 
    "Cavefish", "Manta ray", "Rocktail", "Tiger shark", "Sailfish", 
    "Potato with cheese", "Tuna potato", "Baron shark", "Juju gumbo", 
    "Great maki", "Great gunkan", "Rocktail soup", "Sailfish soup", 
    "Fury shark", "Primal feast"
}

KerapacData.emergencyFoodItems = {
    "Green blubber jellyfish", "Blue blubber jellyfish", 
    "2/3 green blubber jellyfish", "2/3 blue blubber jellyfish", 
    "1/3 green blubber jellyfish", "1/3 blue blubber jellyfish", 
}

KerapacData.emergencyDrinkItems = {
    "Guthix rest (4)", "Guthix rest (3)", "Guthix rest (2)", "Guthix rest (1)",
    "Guthix rest flask (6)", "Guthix rest flask (5)", "Guthix rest flask (4)", "Guthix rest flask (3)", "Guthix rest flask (2)", "Guthix rest flask (1)",
    "Saradomin brew (4)", "Saradomin brew (3)", "Saradomin brew (2)", "Saradomin brew (1)",
    "Saradomin brew flask (6)", "Saradomin brew flask (5)", "Saradomin brew flask (4)", "Saradomin brew flask (3)", "Saradomin brew flask (2)", "Saradomin brew flask (1)",
    "Super Guthix rest (4)", "Super Guthix rest (3)", "Super Guthix rest (2)", "Super Guthix rest (1)",
    "Super Guthix rest flask (6)", "Super Guthix rest flask (5)", "Super Guthix rest flask (4)", "Super Guthix rest flask (3)", "Super Guthix rest flask (2)", "Super Guthix rest flask (1)",
    "Super Saradomin brew (4)", "Super Saradomin brew (3)", "Super Saradomin brew (2)", "Super Saradomin brew (1)",
    "Super Saradomin brew flask (6)", "Super Saradomin brew flask (5)", "Super Saradomin brew flask (4)", "Super Saradomin brew flask (3)", "Super Saradomin brew flask (2)", "Super Saradomin brew flask (1)"
}

KerapacData.prayerRestoreItems = {
    "Super restore (4)", "Super restore (3)", "Super restore (2)", "Super restore (1)",
    "Super restore flask (6)", "Super restore flask (5)", "Super restore flask (4)", 
    "Super restore flask (3)", "Super restore flask (2)", "Super restore flask (1)",
    "Prayer potion (1)", "Prayer potion (2)", "Prayer potion (3)", "Prayer potion (4)",
    "Prayer flask (1)", "Prayer flask (2)", "Prayer flask (3)", "Prayer flask (4)", 
    "Prayer flask (5)", "Prayer flask (6)",
    "Super prayer (1)", "Super prayer (2)", "Super prayer (3)", "Super prayer (4)",
    "Super prayer flask (1)", "Super prayer flask (2)", "Super prayer flask (3)", 
    "Super prayer flask (4)", "Super prayer flask (5)", "Super prayer flask (6)",
    "Extreme prayer (1)", "Extreme prayer (2)", "Extreme prayer (3)", "Extreme prayer (4)",
    "Extreme prayer flask (1)", "Extreme prayer flask (2)", "Extreme prayer flask (3)", 
    "Extreme prayer flask (4)", "Extreme prayer flask (5)", "Extreme prayer flask (6)"
}

KerapacData.overloadItems = {
    "Overload (4)", "Overload (3)", "Overload (2)", "Overload (1)",
    "Overload Flask (6)", "Overload Flask (5)", "Overload Flask (4)", 
    "Overload Flask (3)", "Overload Flask (2)", "Overload Flask (1)",
    "Holy overload (6)", "Holy overload (5)", "Holy overload (4)", 
    "Holy overload (3)", "Holy overload (2)", "Holy overload (1)",
    "Searing overload (6)", "Searing overload (5)", "Searing overload (4)", 
    "Searing overload (3)", "Searing overload (2)", "Searing overload (1)",
    "Overload salve (6)", "Overload salve (5)", "Overload salve (4)", 
    "Overload salve (3)", "Overload salve (2)", "Overload salve (1)",
    "Aggroverload (6)", "Aggroverload (5)", "Aggroverload (4)", 
    "Aggroverload (3)", "Aggroverload (2)", "Aggroverload (1)",
    "Holy aggroverload (6)", "Holy aggroverload (5)", "Holy aggroverload (4)", 
    "Holy aggroverload (3)", "Holy aggroverload (2)", "Holy aggroverload (1)",
    "Supreme overload salve (6)", "Supreme overload salve (5)", 
    "Supreme overload salve (4)", "Supreme overload salve (3)", 
    "Supreme overload salve (2)", "Supreme overload salve (1)",
    "Elder overload potion (6)", "Elder overload potion (5)", 
    "Elder overload potion (4)", "Elder overload potion (3)", 
    "Elder overload potion (2)", "Elder overload potion (1)",
    "Elder overload salve (6)", "Elder overload salve (5)", 
    "Elder overload salve (4)", "Elder overload salve (3)", 
    "Elder overload salve (2)", "Elder overload salve (1)",
    "Supreme overload potion (1)", "Supreme overload potion (2)", 
    "Supreme overload potion (3)", "Supreme overload potion (4)", 
    "Supreme overload potion (5)", "Supreme overload potion (6)"
}

KerapacData.weaponPoisonItems = {
    "Weapon poison (1)", "Weapon poison (2)", "Weapon poison (3)", "Weapon poison (4)",
    "Weapon poison+ (1)", "Weapon poison+ (2)", "Weapon poison+ (3)", "Weapon poison+ (4)",
    "Weapon poison++ (1)", "Weapon poison++ (2)", "Weapon poison++ (3)", "Weapon poison++ (4)",
    "Weapon poison+++ (1)", "Weapon poison+++ (2)", "Weapon poison+++ (3)", "Weapon poison+++ (4)",
    "Weapon poison flask (1)", "Weapon poison flask (2)", "Weapon poison flask (3)", 
    "Weapon poison flask (4)", "Weapon poison flask (5)", "Weapon poison flask (6)",
    "Weapon poison+ flask (1)", "Weapon poison+ flask (2)", "Weapon poison+ flask (3)", 
    "Weapon poison+ flask (4)", "Weapon poison+ flask (5)", "Weapon poison+ flask (6)",
    "Weapon poison++ flask (1)", "Weapon poison++ flask (2)", "Weapon poison++ flask (3)", 
    "Weapon poison++ flask (4)", "Weapon poison++ flask (5)", "Weapon poison++ flask (6)",
    "Weapon poison+++ flask (1)", "Weapon poison+++ flask (2)", "Weapon poison+++ flask (3)", 
    "Weapon poison+++ flask (4)", "Weapon poison+++ flask (5)", "Weapon poison+++ flask (6)"
}

KerapacData.summoningPouches = {
    "Blood nihil pouch", "Ice nihil pouch", "Shadow nihil pouch", "Smoke nihil pouch", 
    "Binding contract (ripper demon)", "Binding contract (kal'gerion demon)", 
    "Binding contract (blood reaver)", "Binding contract (hellhound)", "Holy scarab pouch"
}

KerapacData.adrenalinePotionItems = {
    "Adrenaline potion (1)", "Adrenaline potion (2)", "Adrenaline potion (3)", "Adrenaline potion (4)",
    "Adrenaline flask (1)", "Adrenaline flask (2)", "Adrenaline flask (3)", "Adrenaline flask (4)", "Adrenaline flask (5)", "Adrenaline flask (6)",
    "Super adrenaline potion (1)", "Super adrenaline potion (2)", "Super adrenaline potion (3)", "Super adrenaline potion (4)",
    "Super adrenaline flask (1)", "Super adrenaline flask (2)", "Super adrenaline flask (3)", "Super adrenaline flask (4)", "Super adrenaline flask (5)", "Super adrenaline flask (6)",
    "Adrenaline renewal potion (1)", "Adrenaline renewal potion (2)", "Adrenaline renewal potion (3)", "Adrenaline renewal potion (4)",
    "Adrenaline renewal flask (1)", "Adrenaline renewal flask (2)", "Adrenaline renewal flask (3)", "Adrenaline renewal flask (4)", "Adrenaline renewal flask (5)", "Adrenaline renewal flask (6)",
    "Replenishment potion (1)", "Replenishment potion (2)", "Replenishment potion (3)", "Replenishment potion (4)", "Replenishment potion (5)", "Replenishment potion (6)",
    "Enhanced replenishment potion (1)", "Enhanced replenishment potion (2)", "Enhanced replenishment potion (3)", "Enhanced replenishment potion (4)", "Enhanced replenishment potion (5)", "Enhanced replenishment potion (6)"
}

KerapacData.extraItems = {
    excalibur = 14632,
    augmentedExcalibur = 36619
}

KerapacData.extraAbilities = {
    darknessAbility = {
        name = "Darkness", 
        buffId = 30122, 
        AB = nil,
        threshold = 0
    },
    invokeDeathAbility = {
        name = "Invoke Death", 
        debuffId = 30100, 
        AB = nil,
        threshold = 0
    },
    splitSoulAbility = {
        name = "Split Soul", 
        buffId = 30126, 
        AB = nil,
        threshold = 0
    },
    devotionAbility = {
        name = "Devotion", 
        buffId = 21665, 
        AB = nil,
        threshold = 50,
        adrenaline = -15
    },
    debilitateAbility = {
        name = "Debilitate", 
        debuffId = 14226, 
        AB = nil,
        threshold = 50,
        adrenaline = -15
    },
    freedomAbility = {
        name = "Freedom", 
        buffId = 14220, 
        AB = nil,
        threshold = 0,
        adrenaline = 0
    },
    reflectAbility = {
        name = "Reflect", 
        buffId = 14225, 
        AB = nil,
        threshold = 50,
        adrenaline = -15
    },
    resonanceAbility = {
        name = "Resonance", 
        buffId = 14222, 
        AB = nil,
        threshold = 0,
        adrenaline = 0
    },
    preparationAbility = {
        name = "Preparation",
        buffId = 14223,
        AB = nil,
        threshold = 0,
        adrenaline = 0
    },
    immortalityAbility = {
        name = "Immortality", 
        buffId = 14230, 
        AB = nil,
        threshold = 100,
        adrenaline = -100
    },
    sacrificeAbility = {
        name = "Sacrifice",
        AB = nil,
        threshold = 0,
        adrenaline = 8
    },
    necroBasicAbility = {
        name = "Necromancy basic attack",
        AB = nil,
        threshold = 0,
        adrenaline = 9
    },
    touchOfDeathAbility = {
        name = "Touch of Death",
        AB = nil,
        threshold = 0,
        adrenaline = 9
    },
    soulSapAbility = {
        name = "Soul Sap",
        AB = nil,
        threshold = 0,
        adrenaline = 9
    },
    volleyOfSoulsAbility = {
        name = "Volley of Souls",
        AB = nil,
        threshold = 0,
        adrenaline = 0
    },
    conjureUndeadArmyAbility = {
        name = "Conjure Undead Army",
        AB = nil,
        threshold = 0,
        adrenaline = 0
    },
    conjureSkeletonWarriorAbility = {
        name = "Conjure Skeleton Warrior",
        AB = nil,
        threshold = 0,
        adrenaline = 0
    },
    conjureVengefulGhostAbility = {
        name = "Conjure Vengeful Ghost",
        AB = nil,
        threshold = 0,
        adrenaline = 0
    },
    conjurePutridZombieAbility = {
        name = "Conjure Putrid Zombie",
        AB = nil,
        threshold = 0,
        adrenaline = 0
    },
    commandSkeletonWarriorAbility = {
        name = "Command Skeleton Warrior",
        AB = nil,
        threshold = 0,
        adrenaline = 0
    },
    commandVengefulGhostAbility = {
        name = "Command Vengeful Ghost",
        AB = nil,
        threshold = 0,
        adrenaline = 0
    },
    fingerOfDeathAbility = {
        name = "Finger of Death",
        AB = nil,
        threshold = 60,
        adrenaline = -60
    },
    bloatAbility = {
        name = "Bloat",
        buffId = 30098,
        AB = nil,
        threshold = 10,
        adrenaline = -10
    },
    deathGraspAbility = {
        name = "Death Grasp",
        AB = nil,
        threshold = 25,
        adrenaline = -25
    },
    deathEssenceAbility = {
        name = "Death Essence",
        AB = nil,
        threshold = 30,
        adrenaline = -30
    },
    deathSkullsAbility = {
        name = "Death Skulls",
        AB = nil,
        threshold = 100,
        adrenaline = -100
    },
    livingDeathAbility = {
        name = "Living Death",
        buffid = 30078,
        AB = nil,
        threshold = 100,
        adrenaline = -100
    },
    barricadeAbility = {
        name = "Barricade",
        AB = nil,
        buffId = 14228,
        threshold = 100,
        adrenaline = -100
    },
    rejuvenateAbility = {
        name = "Rejuvenate",
        AB = nil,
        buffId = 14229,
        threshold = 100,
        adrenaline = -100
    },
    specialAttackAbility = {
        name = "Weapon Special Attack"
    },
    essenceOfFinalityAbility = {
        name = "Essence of Finality"
    },
}

KerapacData.overheadPrayersBuffs = {
    PrayMage = { 
        name = "Protect from Magic", 
        buffId = 25959, 
        AB = nil
    },
    PrayMelee = { 
        name = "Protect from Melee", 
        buffId = 25961, 
        AB = nil
    }
}

KerapacData.overheadCursesBuffs = {
    PrayMage = { 
        name = "Deflect Magic", 
        buffId = 26041, 
        AB = nil
    },
    PrayMelee = { 
        name = "Deflect Melee", 
        buffId = 26040, 
        AB = nil
    },
    SoulSplit = {
        name = "Soul Split",
        buffId = 26033,
        AB = nil
    }
}

KerapacData.passiveBuffs = {
    Ruination = { 
        name = "Ruination", 
        buffId = 30769, 
        AB = nil,
        type = KerapacData.prayerType.Curses.name 
    },
    Sorrow = { 
        name = "Sorrow", 
        buffId = 30771, 
        AB = nil,
        type = KerapacData.prayerType.Curses.name 
    },
    Turmoil = { 
        name = "Turmoil", 
        buffId = 26019, 
        AB = nil,
        type = KerapacData.prayerType.Curses.name 
    },
    Malevolence = { 
        name = "Malevolence", 
        buffId = 29262, 
        AB = nil,
        type = KerapacData.prayerType.Curses.name 
    },
    Anguish = { 
        name = "Anguish", 
        buffId = 26020, 
        AB = nil,
        type = KerapacData.prayerType.Curses.name 
    },
    Desolation = { 
        name = "Desolation", 
        buffId = 29263, 
        AB = nil,
        type = KerapacData.prayerType.Curses.name 
    },
    Torment = { 
        name = "Torment", 
        buffId = 26021, 
        AB = nil,
        type = KerapacData.prayerType.Curses.name 
    },
    Affliction = { 
        name = "Affliction", 
        buffId = 29264, 
        AB = nil,
        type = KerapacData.prayerType.Curses.name 
    },
    Piety = { 
        name = "Piety", 
        buffId = 25973, 
        AB = nil,
        type = KerapacData.prayerType.Prayers.name 
    },
    Rigour = { 
        name = "Rigour", 
        buffId = 25982, 
        AB = nil,
        type = KerapacData.prayerType.Prayers.name 
    },
    Augury = { 
        name = "Augury", 
        buffId = 25974, 
        AB = nil,
        type = KerapacData.prayerType.Prayers.name 
    },
    Sanctity = { 
        name = "Sanctity", 
        buffId = 30925, 
        AB = nil,
        type = KerapacData.prayerType.Prayers.name 
    },
    None = {
        name = "None", 
        buffId = nil, 
        AB = nil, 
        type = nil
    }
}

KerapacData.overloadBuff = {
    Overload = {
        buffId = 26093
    },
    ElderOverload = {
        buffId = 49039
    },
    SupremeOverload = {
        buffId = 33210
    }
}

KerapacData.extraBuffs = {
    scriptureOfJas = {
        name = "Scripture of Jas", 
        itemId = 51814,
        buffId = 51814, 
        AB = nil
    },
    scriptureOfWen = {
        name = "Scripture of Wen", 
        itemId = 52117,
        buffId = 52117, 
        AB = nil
    },
    scriptureOfFul = {
        name = "Scripture of Ful", 
        itemId = 52494,
        buffId = 52494, 
        AB = nil
    },
    scriptureOfAmascut = {
        name = "Scripture of Amascut", 
        itemId = 57126,
        buffId = 57126, 
        AB = nil
    },
}

KerapacData.bossStateEnum = {
    BASIC_ATTACK = { 
        name = "BASIC_ATTACK", 
        animations = { 34192 } 
    },
    TEAR_RIFT_ATTACK_COMMENCE = { 
        name = "TEAR_RIFT_ATTACK_COMMENCE", 
        animations = { 34198 } 
    },
    TEAR_RIFT_ATTACK_MOVE = { 
        name = "TEAR_RIFT_ATTACK_MOVE", 
        animations = { 34199 } 
    },
    JUMP_ATTACK_COMMENCE = { 
        name = "JUMP_ATTACK_COMMENCE", 
        animations = { 34193 } 
    },
    JUMP_ATTACK_IN_AIR = { 
        name = "JUMP_ATTACK_IN_AIR", 
        animations = { 34194 } 
    },
    JUMP_ATTACK_LANDED = {
        name = "JUMP_ATTACK_LANDED", 
        animations = { 34195 }
    },
    LIGHTNING_ATTACK = { 
        name = "LIGHTNING_ATTACK", 
        animations = { 34197 } 
    },
    PHASE4 = {
        name = "PHASE4",
        animations = {34201}
    }
}

KerapacData.echoAreasMap = {
    northEcho = {
        bottomLeft = {x = -6, y = 4},
        topRight = {x = 4, y = 17},
        echoSpot = {x = 0, y = 14}
     },
    westEcho = {
        bottomLeft = {x = -17, y = -6},
        topRight = {x = -7, y = 4},
        echoSpot = {x = -14, y = 0}
    },
    southEcho ={
        bottomLeft = {x = -4, y = -17},
        topRight = {x = 6, y = -8},
        echoSpot = {x = -1, y = -15}
    }
}

KerapacData.deltaTileMap = {
    [1] = {x = -10, y = -10},
    [2] = {x = -10, y = 10},
    [3] = {x = 10, y = 10},
    [4] = {x = 10, y = -10},
    [5] = {x = -10, y = 0},
    [6] = {x = 0, y = 10},
    [7] = {x = 10, y = 0},
    [8] = {x = 0, y = -10}
}

KerapacData.singlesMap = {
    [0] = 1,
    [45] = 1,
    [90] = 1,
    [135] = 2,
    [180] = 2,
    [225] = 3,
    [270] = 3,
    [315] = 4
}

KerapacData.doublesMap = {
    [45] = 1,
    [90] = 1,
    [270] = 4,
    [315] = 4,
    [45 * 1000 + 90] = 1,
    [45 * 1000 + 135] = 5,
    [45 * 1000 + 315] = 8,
    [90 * 1000 + 135] = 2,
    [90 * 1000 + 180] = 2,
    [135 * 1000 + 180] = 2,
    [135 * 1000 + 225] = 6,
    [180 * 1000 + 225] = 3,
    [180 * 1000 + 270] = 3,
    [225 * 1000 + 270] = 3,
    [225 * 1000 + 315] = 7,
    [270 * 1000 + 315] = 4
}

KerapacData.triplesMap = {
    [45 * 1000 + 90] = 1,
    [45 * 1000 + 315] = 8,
    [270 * 1000 + 315] = 4,
    [45 * 1000000 + 90 * 1000 + 135] = 5,
    [90 * 1000000 + 135 * 1000 + 180] = 2,
    [135 * 1000000 + 180 * 1000 + 225] = 6,
    [180 * 1000000 + 225 * 1000 + 270] = 3,
    [225 * 1000000 + 270 * 1000 + 315] = 7
}

KerapacData.rareDrops = {
    [51767] = {
        name = "Kerapac's wrist wraps",
        icon = "https://runescape.wiki/images/Kerapac%27s_wrist_wraps_detail.png?17d3d",
        message = "These surely will keep my hands warm"
    },
    [51843] = {
        name = "Greater Concentrated blast ability codex",
        icon = "https://runescape.wiki/images/Greater_Concentrated_blast_ability_codex_detail.png?97097",
        message = "Ah yes a book"
    },
    [51812] = {
        name = "Scripture of Jas",
        icon = "https://runescape.wiki/images/Scripture_of_Jas_detail.png?48529",
        message = "Ah yes another book"
    },
    [51862] = {
        name = "Kerapac's mask piece",
        icon = "https://runescape.wiki/images/Kerapac%27s_mask_piece_detail.png?e1b0b",
        message = "Look at this lil fella, what a funny little character"
    },
    [51776] = {
        name = "Fractured Armadyl symbol",
        icon = "https://runescape.wiki/images/Fractured_Armadyl_symbol_detail.png?30c48",
        message = "What an odd looking symbol"
    },
    [51779] = {
        name = "Fractured stabilisation gem",
        icon = "https://runescape.wiki/images/Fractured_stabilisation_gem_detail.png?d32f2",
        message = "A diamond is a better looking gem"
    },
    [51782] = {
        name = "Staff of Armadyl's fractured shaft",
        icon = "https://runescape.wiki/images/thumb/Staff_of_Armadyl%27s_fractured_shaft_detail.png/800px-Staff_of_Armadyl%27s_fractured_shaft_detail.png?5aae3",
        message = "Hehe get shafted"      
    }
}

KerapacData.deathGuardIds = {55524, 55532, 55540, 55528, 55536, 55544}
KerapacData.omniGuardIds = {55484, 55480}
KerapacData.deathSparkReady = 30127

KerapacData.MARGIN = 100
KerapacData.PADDING_Y = 6
KerapacData.PADDING_X = 5
KerapacData.LINE_HEIGHT = 12
KerapacData.BOX_WIDTH = 340
KerapacData.BOX_HEIGHT = 130
KerapacData.BOX_START_Y = 600
KerapacData.BOX_END_Y = KerapacData.BOX_START_Y + KerapacData.BOX_HEIGHT
KerapacData.BOX_END_X = KerapacData.MARGIN + KerapacData.BOX_WIDTH + (2 * KerapacData.PADDING_X)
KerapacData.BUTTON_WIDTH = 70
KerapacData.BUTTON_HEIGHT = 25
KerapacData.BUTTON_MARGIN = 8

KerapacData.hpThreshold = 70
KerapacData.prayerThreshold = 30
KerapacData.emergencyEatThreshold = 50
KerapacData.foodCooldown = 3
KerapacData.drinkCooldown = 3
KerapacData.phaseTransitionThreshold = 50000
KerapacData.lootPosition = 5
KerapacData.stun = 26103
KerapacData.dodgeCooldown = 6
KerapacData.distanceThreshold = 6
KerapacData.proximityThreshold = 50
KerapacData.weaponPoisonBuff = 30095
KerapacData.waitForCheckTicks = 0
KerapacData.playerClone = 28073
KerapacData.kerapacClones = 28076
KerapacData.summoningPointsForScroll = 20
KerapacData.adrenalineCrystal = 114749
KerapacData.timeWarpBuff = 15142
KerapacData.totalKills = 0
KerapacData.totalRares = 0
KerapacData.totalDeaths = 0

return KerapacData