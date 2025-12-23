--============================================================================
-- QuickCrafts: Core.lua
-- Initialization, event handling, and slash commands
--============================================================================

local addonName, addon = ...
local L = addon.L
local TEXT = addon.CONST.TEXT

--============================================================================
-- SLASH COMMANDS
--============================================================================

SLASH_QUICKCRAFTS1 = "/calc"
SLASH_QUICKCRAFTS2 = "/qc"
SLASH_QUICKCRAFTS3 = "/qcrafts"

SlashCmdList["QUICKCRAFTS"] = function(msg)
    local cmd = msg:lower():trim()
    
    if cmd == "help" then
        print("|cFF00FF00" .. L(TEXT.HELP_TITLE) .. "|r")
        print("  |cFFFFFF00" .. L(TEXT.HELP_CMD_CALC) .. "|r")
        print("  |cFFFFFF00" .. L(TEXT.HELP_CMD_HELP) .. "|r")
        return
    end
    
    -- Default: toggle window
    addon.UI:Toggle()
end

--============================================================================
-- EVENT HANDLING
--============================================================================

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Initialize saved variables with defaults
        addon:InitializeDB()
        
        -- Start loading item info
        addon.PriceSource:LoadAllItemInfo()
        
        -- Print load message
        local available, sourceName = addon.PriceSource:IsAvailable()
        if available then
            -- print(string.format(
            --     "|cFF00FF00" .. L(TEXT.ADDON_LOADED) .. "|r",
            --     addon.name,
            --     addon.version,
            --     sourceName
            -- ))
        else
            print(string.format(
                "|cFF00FF00" .. L(TEXT.ADDON_LOADED_NO_PRICE) .. "|r",
                addon.name,
                addon.version
            ))
        end
    end
    
    if event == "PLAYER_ENTERING_WORLD" then
        -- Delay to ensure dependencies are fully loaded
        C_Timer.After(2, function()
            -- Register for Auctionator price updates (auto-refresh after searches)
            addon.PriceSource:RegisterForPriceUpdates()
            addon.PriceSource:LoadAllItemInfo(function()
                C_Timer.After(0.5, function()
                    addon.Calculator:CalculateAllRecipes()
                end)
            end)
        end)
    end
    
    if event == "PLAYER_LOGOUT" then
    end
end)

if AddonCompartmentFrame and AddonCompartmentFrame.RegisterAddon then
    AddonCompartmentFrame:RegisterAddon({
        text = L(TEXT.WINDOW_TITLE),
        icon = "Interface\\Icons\\INV_Misc_StoneTablet_04",
        notCheckable = true,
        func = function()
            addon.UI:Toggle()
        end,
    })
end


--[[
function addon:Debug(...)
    if self.debugMode then
        print("|cFFFF00FF[QuickCrafts Debug]|r", ...)
    end
end

addon.debugMode = false  -- Set to true to enable debug messages

_G.QuickCrafts = addon
]]--
