--============================================================================
-- QuickCrafts: Crafting.lua
-- Lightweight crafting helpers (Retail) for selecting/crafting recipes.
-- Designed to be "best effort" and safe: user should open the profession UI.
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
    -- Fallback: if API doesn't exist, assume not ready
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

function addon.Crafting:FindTradeSkillRecipeID(recipe)
    if not self:IsAvailable() then return nil end
    if not recipe or not recipe.name then return nil end

    local all = C_TradeSkillUI.GetAllRecipeIDs()
    if not all then return nil end

    local targetName = recipe.name
    local targetItemID = recipe.product and recipe.product.itemID or nil

    local nameMatches = {}
    for _, recipeID in ipairs(all) do
        local info = C_TradeSkillUI.GetRecipeInfo(recipeID)
        if info and info.name == targetName then
            table.insert(nameMatches, recipeID)
        end
    end

    if #nameMatches == 0 then
        return nil
    end
    if #nameMatches == 1 or not targetItemID then
        return nameMatches[1]
    end

    -- If multiple recipes share the same name, try to match output itemID.
    for _, recipeID in ipairs(nameMatches) do
        if C_TradeSkillUI.GetRecipeOutputItemData then
            local out = C_TradeSkillUI.GetRecipeOutputItemData(recipeID)
            if out and out.hyperlink then
                local outItemID = getItemIDFromLink(out.hyperlink)
                if outItemID == targetItemID then
                    return recipeID
                end
            end
        end
    end

    return nameMatches[1]
end

function addon.Crafting:EnsureReadyOrWarn()
    if not self:IsAvailable() then
        qcPrint("Crafting API not available on this client.")
        return false
    end
    if not isTradeSkillReady() then
        qcPrint("Open your profession window first (e.g., Alchemy), then try again.")
        return false
    end
    return true
end

function addon.Crafting:OpenRecipe(recipe)
    if not self:EnsureReadyOrWarn() then return false end

    local recipeID = self:FindTradeSkillRecipeID(recipe)
    if not recipeID then
        qcPrint("Couldn't find recipe in the currently open profession: " .. (recipe and recipe.name or "(unknown)"))
        return false
    end

    if C_TradeSkillUI.SetRecipeID then
        C_TradeSkillUI.SetRecipeID(recipeID)
    elseif TradeSkillFrame and TradeSkillFrame.RecipeList and TradeSkillFrame.RecipeList.SelectRecipe then
        -- Fallback (older UI): best effort
        pcall(function() TradeSkillFrame.RecipeList:SelectRecipe(recipeID) end)
    end

    return true
end

function addon.Crafting:Craft(recipe, quantity)
    if not self:EnsureReadyOrWarn() then return false end
    quantity = tonumber(quantity) or 1
    if quantity < 1 then quantity = 1 end

    local recipeID = self:FindTradeSkillRecipeID(recipe)
    if not recipeID then
        qcPrint("Couldn't find recipe in the currently open profession: " .. (recipe and recipe.name or "(unknown)"))
        return false
    end

    -- Select first so the player sees what's being crafted.
    if C_TradeSkillUI.SetRecipeID then
        C_TradeSkillUI.SetRecipeID(recipeID)
    end

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

addon.Crafting._pendingRecipe = nil

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
        local recipe = addon.Crafting._pendingRecipe
        addon.Crafting._pendingRecipe = nil
        if recipe and qty and qty > 0 then
            addon.Crafting:Craft(recipe, math.floor(qty))
        end
    end,
    OnCancel = function()
        addon.Crafting._pendingRecipe = nil
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function addon.Crafting:PromptCraftX(recipe)
    self._pendingRecipe = recipe
    StaticPopup_Show("QUICKCRAFTS_CRAFT_X")
end
