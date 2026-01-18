--============================================================================
-- WoW API Stubs for Autocomplete
-- This file provides function signatures for common WoW API functions
-- to help with autocomplete in Cursor/VSCode. This file is NOT loaded in-game.
--============================================================================

-- WoW Frame API
function CreateFrame(frameType, name, parent, template) return nil end
function GetMouseFocus() return nil end

-- WoW UI API
function UIParent() return nil end
function GameTooltip() return nil end
function AddonCompartmentFrame() return nil end

-- WoW Item API
function Item:CreateFromItemID(itemID) return nil end
function C_Item.GetItemInfo(itemID) return nil, nil end
function GetItemCount(itemID, includeBank) return 0 end

-- WoW Timer API
function C_Timer.After(delay, func) end

-- WoW Trade Skill API
C_TradeSkillUI = {
    GetAllRecipeIDs = function() return {} end,
    GetRecipeInfo = function(recipeID) return nil end,
    GetRecipeOutputItemData = function(recipeID) return nil end,
    IsTradeSkillReady = function() return false end,
    SetRecipeID = function(recipeID) end,
    CraftRecipe = function(recipeID, quantity) end,
}

-- WoW Auction House API
Auctionator = {
    API = {
        v1 = {
            GetAuctionPriceByItemLink = function(addonName, itemLink) return nil end,
            MultiSearchExact = function(addonName, searchTerms) end,
            RegisterForDBUpdate = function(addonName, callback) end,
        }
    }
}

-- WoW Static Popup API
StaticPopupDialogs = {}
function StaticPopup_Show(dialog, text, data, data2) return nil end
function StaticPopup_FindVisible(dialog) return nil end

-- WoW Locale API
function GetLocale() return "enUS" end

-- WoW Event API
function RegisterEvent(event) end
function UnregisterEvent(event) end

-- Global variables that exist in WoW
_G = {}
