--============================================================================
-- QuickCrafts: Config.lua
-- Handles saved variables, default settings, and configuration
--============================================================================
local addonName, addon = ...

addon.name = addonName
addon.version = "v0.1.1"

-- Initialize localization system
addon.LOCAL:Init()

-- populated by other files
addon.UI = {}              
addon.Recipes = {}         
addon.Pigments = {}         
addon.Calculator = {}       
addon.PigmentCalculator = {} 
addon.PriceSource = {}     

-- Data storage
addon.itemLinks = {}
addon.itemNames = {}
addon.itemIcons = {}
addon.calculatedData = {}   
addon.pigmentData = {}      

--============================================================================
-- DEFAULT SETTINGS
--============================================================================
addon.defaults = {
    ahCut = true,           -- Deduct 5% AH cut from sale price
    mastery = false,        -- Transmute Mastery enabled
    buyPigments = false,    -- Buy Pigments or Craft Pigments with Herbs (Player Housing Dyes)
    history = {},           -- Price history
    windowPosition = nil,   
    lastTab = "pigments",
    debug = false,
    -- Sorting settings for TransmutesView
    sortColumn = "profit",  -- Column to sort by: "name", "cost", "sell", "profit"
    sortDirection = "desc", -- Sort direction: "asc" or "desc"
    -- Sorting settings for PigmentsView
    pigmentSortColumn = "profit",  -- Column to sort by: "name", "herb", "dye", "profit"
    pigmentSortDirection = "desc", -- Sort direction: "asc" or "desc"
}

--============================================================================
-- SETTINGS ACCESS FUNCTIONS
--============================================================================

-- Initialize saved variables with defaults
function addon:InitializeDB()
    if not QuickCraftsPlusDB then
        QuickCraftsPlusDB = {}
    end
    
    -- Fill in any missing defaults
    for key, value in pairs(self.defaults) do
        if QuickCraftsPlusDB[key] == nil then
            QuickCraftsPlusDB[key] = value
        end
    end
    
    -- Ensure sort settings exist (migration for existing users)
    if not QuickCraftsPlusDB.sortColumn then
        QuickCraftsPlusDB.sortColumn = "profit"
    end
    if not QuickCraftsPlusDB.sortDirection then
        QuickCraftsPlusDB.sortDirection = "desc"
    end
    if not QuickCraftsPlusDB.pigmentSortColumn then
        QuickCraftsPlusDB.pigmentSortColumn = "profit"
    end
    if not QuickCraftsPlusDB.pigmentSortDirection then
        QuickCraftsPlusDB.pigmentSortDirection = "desc"
    end
end

-- Get a setting value
function addon:GetSetting(key)
    if QuickCraftsPlusDB and QuickCraftsPlusDB[key] ~= nil then
        return QuickCraftsPlusDB[key]
    end
    return self.defaults[key]
end

-- Set a setting value
function addon:SetSetting(key, value)
    if not QuickCraftsPlusDB then
        QuickCraftsPlusDB = {}
    end
    QuickCraftsPlusDB[key] = value
end

-- Toggle a boolean setting
function addon:ToggleSetting(key)
    local current = self:GetSetting(key)
    self:SetSetting(key, not current)
    return not current
end
