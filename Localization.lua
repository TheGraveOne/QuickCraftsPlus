--============================================================================
-- QuickCrafts: Localization.lua
-- Handles loading and retrieving localized text
--============================================================================

local addonName, addon = ...

addon.LOCAL = {}
addon.LOCAL.CLIENT = {}  -- Current client's local
addon.LOCAL.EN = {}      -- English fallback

--============================================================================
-- INITIALIZATION
--============================================================================

function addon.LOCAL:Init()
    local currentLocale = GetLocale()
    local LOCALES = addon.CONST.LOCALS
    
    -- Always load English as fallback
    addon.LOCAL.EN = addon.LOCAL_EN:GetData()
    
    -- Loads the correct local based on client
    if currentLocale == LOCALES.EN then
        addon.LOCAL.CLIENT = addon.LOCAL.EN
    elseif currentLocale == LOCALES.DE and addon.LOCAL_DE then
        addon.LOCAL.CLIENT = addon.LOCAL_DE:GetData()
    elseif currentLocale == LOCALES.FR and addon.LOCAL_FR then
        addon.LOCAL.CLIENT = addon.LOCAL_FR:GetData()
    elseif currentLocale == LOCALES.ES and addon.LOCAL_ES then
        addon.LOCAL.CLIENT = addon.LOCAL_ES:GetData()
    elseif currentLocale == LOCALES.MX and addon.LOCAL_MX then
        addon.LOCAL.CLIENT = addon.LOCAL_MX:GetData()
    elseif currentLocale == LOCALES.PT and addon.LOCAL_PT then
        addon.LOCAL.CLIENT = addon.LOCAL_PT:GetData()
    elseif currentLocale == LOCALES.IT and addon.LOCAL_IT then
        addon.LOCAL.CLIENT = addon.LOCAL_IT:GetData()
    elseif currentLocale == LOCALES.RU and addon.LOCAL_RU then
        addon.LOCAL.CLIENT = addon.LOCAL_RU:GetData()
    elseif currentLocale == LOCALES.KO and addon.LOCAL_KO then
        addon.LOCAL.CLIENT = addon.LOCAL_KO:GetData()
    elseif currentLocale == LOCALES.CN and addon.LOCAL_CN then
        addon.LOCAL.CLIENT = addon.LOCAL_CN:GetData()
    elseif currentLocale == LOCALES.TW and addon.LOCAL_TW then
        addon.LOCAL.CLIENT = addon.LOCAL_TW:GetData()
    else
        -- Fallback to English just in case
        addon.LOCAL.CLIENT = addon.LOCAL.EN
    end
end

--============================================================================
-- TEXT RETRIEVAL
--============================================================================

--- Get localized text by ID
---@param ID string The text ID from addon.CONST.TEXT
---@return string The localized text, or English fallback if not found
function addon.LOCAL:GetText(ID)
    local localizedText = addon.LOCAL.CLIENT[ID]
    
    if not localizedText then
        -- Fall back to English
        local englishText = addon.LOCAL.EN[ID]
        if englishText then
            return englishText
        else
            return localizedText
        end
    end
    
    return localizedText
end

--============================================================================
-- SHORTHAND HELPER
--============================================================================

-- Shorthand function for calling
-- Example: local L = addon.L; button:SetText(L("BTN_REFRESH"))
function addon.L(ID)
    return addon.LOCAL:GetText(ID)
end
