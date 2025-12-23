--============================================================================
-- QuickCrafts: Config.lua
-- Handles saved variables, default settings, and configuration
--============================================================================
local addonName, addon = ...

addon.name = addonName
addon.version = "0.0.2"

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
    history = {},           -- Price history
    windowPosition = nil,   
    lastTab = "pigments", 
}

--============================================================================
-- SETTINGS ACCESS FUNCTIONS
--============================================================================

-- Initialize saved variables with defaults
function addon:InitializeDB()
    if not QuickCraftsDB then
        QuickCraftsDB = {}
    end
    
    -- Fill in any missing defaults
    for key, value in pairs(self.defaults) do
        if QuickCraftsDB[key] == nil then
            QuickCraftsDB[key] = value
        end
    end
end

-- Get a setting value
function addon:GetSetting(key)
    if QuickCraftsDB and QuickCraftsDB[key] ~= nil then
        return QuickCraftsDB[key]
    end
    return self.defaults[key]
end

-- Set a setting value
function addon:SetSetting(key, value)
    if not QuickCraftsDB then
        QuickCraftsDB = {}
    end
    QuickCraftsDB[key] = value
end

-- Toggle a boolean setting
function addon:ToggleSetting(key)
    local current = self:GetSetting(key)
    self:SetSetting(key, not current)
    return not current
end
