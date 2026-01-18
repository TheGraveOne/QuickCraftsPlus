--============================================================================
-- QuickCrafts: Dyes.lua
--============================================================================

local addonName, addon = ...

addon.Dyes = {
    black_dye_pigment = {
        pigmentID = 262639,
        dyes = {
            -- NOTE: recipeID is optional.
            -- If not set, QuickCrafts will try to resolve the recipeID at runtime by
            -- matching this dye's output itemID in the currently open profession window.
            -- If you want instant, reliable crafting without lookup, fill in recipeID.
            { itemID = 259109, name = "Dark Iron Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259098, name = "Darkwood Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259111, name = "Ironclaw Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259121, name = "Obsidium Black Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259123, name = "Stormheim Grey Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259104, name = "Stormsteel Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
        },
    },
    blue_dye_pigment = {
        pigmentID = 262643,
        dyes = {
            { itemID = 259115, name = "Alliance Blue Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259153, name = "Dusk Lily Grey Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259135, name = "Midnight Blue Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259146, name = "Nazjatar Navy Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259129, name = "Zephras Blue Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
        },
    },
    brown_dye_pigment = {
        pigmentID = 262642,
        dyes = {
            { itemID = 259112, name = "Dark Gold Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259122, name = "Earthen Brown Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259103, name = "Heartwood Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259128, name = "Kalimdor Sand Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259096, name = "Mesquite Brown Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259101, name = "Pale Umber Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259145, name = "Timbermaw Brown Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259141, name = "Vol'dun Taupe Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259053, name = "Warm Teak Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
        },
    },
    green_dye_pigment = {
        pigmentID = 262647,
        dyes = {
            { itemID = 259133, name = "Dustwallow Green Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259150, name = "Earthroot Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259134, name = "Emerald Dreaming Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259143, name = "Gravemoss Green Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259147, name = "Grizzly Hills Green Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259114, name = "Lush Green Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259124, name = "Silversage Green Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
        },
    },
    orange_dye_pigment = {
        pigmentID = 262656,
        dyes = {
            { itemID = 259108, name = "Bronze Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259105, name = "Copper Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259118, name = "Elywnn Pumpkin Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259132, name = "Kodohide Brown Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
        },
    },
    purple_dye_pigment = {
        pigmentID = 262625,
        dyes = {
            { itemID = 259131, name = "Arcwine Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259144, name = "Forsaken Plum Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259116, name = "Kirin Tor Violet Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259140, name = "Moonberry Amethyst Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259119, name = "Netherstorm Fuchsia Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259130, name = "Nightsong Lilac Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259126, name = "Void Violet Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
        },
    },
    red_dye_pigment = {
        pigmentID = 262655,
        dyes = {
            { itemID = 259151, name = "Deep Mageroyal Red Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259127, name = "Firebloom Red Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259139, name = "Gilnean Rose Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259152, name = "Hinterlands Hickory Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259113, name = "Horde Red Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259102, name = "Mahogany Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259154, name = "Rain Poppy Red Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
			{ itemID = 259142, name = "Ratchet Rust Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
        },
    },
    teal_dye_pigment = {
        pigmentID = 262628,
        dyes = {
            { itemID = 259110, name = "Kul Tiran Steel Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259148, name = "Tidesage Teal Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259125, name = "Un'Goro Green Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259136, name = "Vortex Teal Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
        },
    },
    white_dye_pigment = {
        pigmentID = 260947,
        dyes = {
            { itemID = 259078, name = "Basic Birch Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259120, name = "Bone-White Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259149, name = "Highborne Marble Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259099, name = "Highland Birch Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
        },
    },
    yellow_dye_pigment = {
        pigmentID = 262648,
        dyes = {
            { itemID = 259107, name = "Brass Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 258838, name = "Gold Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259100, name = "Holy Oak Tan Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259097, name = "Pinewood Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
			{ itemID = 259117, name = "Sandfury Yellow Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259138, name = "Savannah Gold Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259137, name = "Sungrass Yellow Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
            { itemID = 259106, name = "Zandalari Gold Dye", recipeID = nil, outputCount = 1, pigmentAmount = 1 },
        },
    },
}

--============================================================================
-- HELPER FUNCTIONS
--============================================================================

-- Get dyes for a pigment by pigment ID string
function addon:GetDyesForPigment(pigmentID)
    return self.Dyes[pigmentID]
end

-- Get all dye item IDs (for preloading)
function addon:GetAllDyeItemIDs()
    local itemIDs = {}
    for _, dyeGroup in pairs(self.Dyes) do
        for _, dye in ipairs(dyeGroup.dyes) do
            if dye.itemID and dye.itemID > 0 then
                itemIDs[dye.itemID] = true
            end
        end
    end
    return itemIDs
end

-- Update GetAllItemIDs to include dyes
local originalGetAllItemIDs = addon.GetAllItemIDs
function addon:GetAllItemIDs()
    local itemIDs = {}
    
    -- Get recipe item IDs
    for _, recipe in ipairs(self.Recipes) do
        itemIDs[recipe.product.itemID] = true
        for _, mat in ipairs(recipe.materials) do
            itemIDs[mat.itemID] = true
        end
    end
    
    -- Get pigment item IDs
    for _, pigment in ipairs(self.Pigments) do
        itemIDs[pigment.itemID] = true
        for _, herb in ipairs(pigment.herbs) do
            itemIDs[herb.itemID] = true
        end
    end
    
    -- Get dye item IDs
    for _, dyeGroup in pairs(self.Dyes) do
        for _, dye in ipairs(dyeGroup.dyes) do
            if dye.itemID and dye.itemID > 0 then
                itemIDs[dye.itemID] = true
            end
        end
    end
    
    return itemIDs
end
