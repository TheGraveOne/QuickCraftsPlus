--============================================================================
-- QuickCrafts: Crafting.lua
-- Profession-agnostic crafting helpers (Retail) for selecting/crafting recipes.
--
-- Design goals:
--  * Best-effort + safe: user should open the relevant profession/crafting UI.
--  * Works for ANY recipe type available via C_TradeSkillUI (Alchemy, Inscription,
--    player housing dyes, etc.)
--  * Accepts either a recipeID directly OR can resolve a recipeID by output itemID
--    (and optionally name) from the currently open profession.
--============================================================================

local addonName, addon = ...

addon.Crafting = addon.Crafting or {}

local function qcPrint(msg)
    print("|cFF00CCFFQuickCrafts|r: " .. tostring(msg))
end

local function isTradeSkillReady()
    if not C_TradeSkillUI then return false end
    if C_TradeSkillUI.IsTradeSkillReady then
        return C_TradeSkillUI.IsTradeSkillReady()
    end
    return false
end

function addon.Crafting:IsAvailable()
    return C_TradeSkillUI
        and C_TradeSkillUI.GetAllRecipeIDs
        and C_TradeSkillUI.GetRecipeInfo
        and C_TradeSkillUI.CraftRecipe
end

local function getItemIDFromLink(link)
    if not link then return nil end
    local itemID = link:match("item:(%d+)")
    if itemID then return tonumber(itemID) end
    return nil
end

-- Cache outputItemID -> recipeID for the currently open profession.
addon.Crafting._outputToRecipeID = addon.Crafting._outputToRecipeID or {}

function addon.Crafting:ClearCache()
    wipe(self._outputToRecipeID)
end

function addon.Crafting:EnsureReadyOrWarn()
    if not self:IsAvailable() then
        qcPrint("Crafting API not available on this client.")
        return false
    end
    if not isTradeSkillReady() then
        qcPrint("Open the relevant profession/crafting window first, then try again.")
        return false
    end
    return true
end

function addon.Crafting:SelectRecipeID(recipeID)
    if not recipeID then return false end
    if C_TradeSkillUI.SetRecipeID then
        C_TradeSkillUI.SetRecipeID(recipeID)
        return true
    end
    if TradeSkillFrame and TradeSkillFrame.RecipeList and TradeSkillFrame.RecipeList.SelectRecipe then
        pcall(function() TradeSkillFrame.RecipeList:SelectRecipe(recipeID) end)
        return true
    end
    return false
end

-- Best-effort: resolve a recipeID in the CURRENTLY OPEN profession by output itemID.
function addon.Crafting:FindRecipeIDByOutputItemID(outputItemID)
    if not self:IsAvailable() then return nil end
    outputItemID = tonumber(outputItemID)
    if not outputItemID then return nil end

    if self._outputToRecipeID[outputItemID] then
        return self._outputToRecipeID[outputItemID]
    end

    if not C_TradeSkillUI.GetRecipeOutputItemData then
        return nil
    end

    local all = C_TradeSkillUI.GetAllRecipeIDs()
    if not all then return nil end

    for _, recipeID in ipairs(all) do
        local out = C_TradeSkillUI.GetRecipeOutputItemData(recipeID)
        if out and out.hyperlink then
            local outItemID = getItemIDFromLink(out.hyperlink)
            if outItemID == outputItemID then
                self._outputToRecipeID[outputItemID] = recipeID
                return recipeID
            end
        end
    end

    return nil
end

-- Resolve recipeID from a "recipe spec".
-- Supported shapes:
--  * { recipeID = 123 }
--  * { outputItemID = 12345 }
--  * QuickCrafts recipe tables: { name=..., product={itemID=...}, ... }
function addon.Crafting:ResolveRecipeID(spec)
    if type(spec) ~= "table" then return nil end

    if spec.recipeID then
        return spec.recipeID
    end

    -- Prefer explicit outputItemID when present.
    -- Support multiple table shapes used across the addon:
    --  * Transmutes recipes: { product = { itemID = ... } }
    --  * Dyes entries:       { itemID = ... }
    --  * Generic:            { outputItemID = ... }
    local outputItemID = spec.outputItemID or spec.itemID
    if not outputItemID and spec.product and spec.product.itemID then
        outputItemID = spec.product.itemID
    end
    if outputItemID then
        local rid = self:FindRecipeIDByOutputItemID(outputItemID)
        if rid then return rid end
    end

    -- Fallback: match by name within the currently open profession.
    if spec.name then
        local all = C_TradeSkillUI.GetAllRecipeIDs()
        if all then
            for _, recipeID in ipairs(all) do
                local info = C_TradeSkillUI.GetRecipeInfo(recipeID)
                if info and info.name == spec.name then
                    return recipeID
                end
            end
        end
    end

    return nil
end

function addon.Crafting:OpenRecipe(spec)
    if not self:EnsureReadyOrWarn() then return false end

    local recipeID = self:ResolveRecipeID(spec)
    if not recipeID then
        qcPrint("Couldn't find that recipe in the currently open profession window.")
        return false
    end

    self:SelectRecipeID(recipeID)
    return true
end

function addon.Crafting:Craft(spec, quantity)
    if not self:EnsureReadyOrWarn() then return false end
    quantity = tonumber(quantity) or 1
    if quantity < 1 then quantity = 1 end

    local recipeID = self:ResolveRecipeID(spec)
    if not recipeID then
        qcPrint("Couldn't find that recipe in the currently open profession window.")
        return false
    end

    -- Select first so the player sees what's being crafted.
    self:SelectRecipeID(recipeID)

    local ok, err = pcall(function()
        C_TradeSkillUI.CraftRecipe(recipeID, quantity)
    end)
    if not ok then
        qcPrint("Craft failed: " .. tostring(err))
        return false
    end
    return true
end

--============================================================================
-- Craft X popup
--============================================================================

addon.Crafting._pendingSpec = nil

if not StaticPopupDialogs then
    return
end

StaticPopupDialogs["QUICKCRAFTS_CRAFT_X"] = {
    text = "Craft how many?",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    editBoxWidth = 64,
    maxLetters = 4,
    OnShow = function(self)
        self.editBox:SetText("1")
        self.editBox:HighlightText()
    end,
    OnAccept = function(self)
        local qty = tonumber(self.editBox:GetText())
        local spec = addon.Crafting._pendingSpec
        addon.Crafting._pendingSpec = nil
        if spec and qty and qty > 0 then
            addon.Crafting:Craft(spec, math.floor(qty))
        end
    end,
    OnCancel = function()
        addon.Crafting._pendingSpec = nil
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function addon.Crafting:PromptCraftX(spec)
    self._pendingSpec = spec
    StaticPopup_Show("QUICKCRAFTS_CRAFT_X")
end
