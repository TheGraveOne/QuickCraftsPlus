--============================================================================
-- QuickCrafts: Recipes.lua
--============================================================================

local addonName, addon = ...

--============================================================================
-- Recipe structure:
--   id          = unique string identifier (used internally)
--   name        = display name
--   product     = { itemID = number, amount = number }
--   materials   = list of { itemID = number, amount = number, name = string }
--   isTransmute = true/false (affects Transmute Mastery calculation)
--============================================================================

addon.Recipes = {
    {
        id = "arcanite_bar",
        name = "Arcanite Bar",
        product = { itemID = 12360, amount = 1 },
        materials = {
            { itemID = 12363, amount = 1, name = "Arcane Crystal" },
            { itemID = 12359, amount = 1, name = "Thorium Bar" },
        },
        isTransmute = true,
    },
    {
        id = "titanium_bar",
        name = "Titanium Bar",
        product = { itemID = 41163, amount = 1 },
        materials = {
            { itemID = 36913, amount = 8, name = "Saronite Bar" },
        },
        isTransmute = true,
    },
    {
        id = "trillium_bar",
        name = "Trillium Bar",
        product = { itemID = 72095, amount = 1 },
        materials = {
            { itemID = 72096, amount = 10, name = "Ghost Iron Bar" },
        },
        isTransmute = true,
    },
}

--============================================================================
-- HELPER FUNCTIONS
--============================================================================

-- Get a recipe by its ID
function addon:GetRecipeByID(recipeID)
    for _, recipe in ipairs(self.Recipes) do
        if recipe.id == recipeID then
            return recipe
        end
    end
    return nil
end

-- Get all item IDs used in recipes (for preloading)
function addon:GetAllItemIDs()
    local itemIDs = {}
    for _, recipe in ipairs(self.Recipes) do
        itemIDs[recipe.product.itemID] = true
        for _, mat in ipairs(recipe.materials) do
            itemIDs[mat.itemID] = true
        end
    end
    return itemIDs
end

-- Get recipe count
function addon:GetRecipeCount()
    return #self.Recipes
end
