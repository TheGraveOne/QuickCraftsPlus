--============================================================================
-- QuickCrafts: Dyes.lua
--============================================================================

local addonName, addon = ...

addon.Dyes = {
    black_dye_pigment = {
        pigmentID = 262639,
        dyes = {
            { itemID = 259109, name = "Dark Iron Dye" },
            { itemID = 259098, name = "Darkwood Dye" },
            { itemID = 259111, name = "Ironclaw Dye" },
            { itemID = 259121, name = "Obsidium Black Dye" },
            { itemID = 259123, name = "Stormheim Grey Dye" },
            { itemID = 259104, name = "Stormsteel Dye" },
        },
    },
    blue_dye_pigment = {
        pigmentID = 262643,
        dyes = {
            { itemID = 259115, name = "Alliance Blue Dye" },
            { itemID = 259153, name = "Dusk Lily Grey Dye" },
            { itemID = 259135, name = "Midnight Blue Dye" },
            { itemID = 259146, name = "Nazjatar Navy Dye" },
            { itemID = 259129, name = "Zephras Blue Dye" },
        },
    },
    brown_dye_pigment = {
        pigmentID = 262642,
        dyes = {
            { itemID = 259112, name = "Dark Gold Dye" },
            { itemID = 259122, name = "Earthen Brown Dye" },
            { itemID = 259103, name = "Heartwood Dye" },
            { itemID = 259128, name = "Kalimdor Sand Dye" },
            { itemID = 259096, name = "Mesquite Brown Dye" },
            { itemID = 259101, name = "Pale Umber Dye" },
            { itemID = 259145, name = "Timbermaw Brown Dye" },
            { itemID = 259141, name = "Vol'dun Taupe Dye" },
            { itemID = 259053, name = "Warm Teak Dye" },
        },
    },
    green_dye_pigment = {
        pigmentID = 262647,
        dyes = {
            { itemID = 259133, name = "Dustwallow Green Dye" },
            { itemID = 259150, name = "Earthroot Dye" },
            { itemID = 259134, name = "Emerald Dreaming Dye" },
            { itemID = 259143, name = "Gravemoss Green Dye" },
            { itemID = 259147, name = "Grizzly Hills Green Dye" },
            { itemID = 259114, name = "Lush Green Dye" },
            { itemID = 259124, name = "Silversage Green Dye" },
        },
    },
    orange_dye_pigment = {
        pigmentID = 262656,
        dyes = {
            { itemID = 259108, name = "Bronze Dye" },
            { itemID = 259105, name = "Copper Dye" },
            { itemID = 259118, name = "Elywnn Pumpkin Dye" },
            { itemID = 259132, name = "Kodohide Brown Dye" },
        },
    },
    purple_dye_pigment = {
        pigmentID = 262625,
        dyes = {
            { itemID = 259131, name = "Arcwine Dye" },
            { itemID = 259144, name = "Forsaken Plum Dye" },
            { itemID = 259116, name = "Kirin Tor Violet Dye" },
            { itemID = 259140, name = "Moonberry Amethyst Dye" },
            { itemID = 259119, name = "Netherstorm Fuchsia Dye" },
            { itemID = 259130, name = "Nightsong Lilac Dye" },
            { itemID = 259126, name = "Void Violet Dye" },
        },
    },
    red_dye_pigment = {
        pigmentID = 262655,
        dyes = {
            { itemID = 259151, name = "Deep Mageroyal Red Dye" },
            { itemID = 259127, name = "Firebloom Red Dye" },
            { itemID = 259139, name = "Gilnean Rose Dye" },
            { itemID = 259152, name = "Hinterlands Hickory Dye" },
            { itemID = 259113, name = "Horde Red Dye" },
            { itemID = 259102, name = "Mahogany Dye" },
            { itemID = 259154, name = "Rain Poppy Red Dye" },
			{ itemID = 259142, name = "Ratchet Rust Dye" },
        },
    },
    teal_dye_pigment = {
        pigmentID = 262628,
        dyes = {
            { itemID = 259110, name = "Kul Tiran Steel Dye" },
            { itemID = 259148, name = "Tidesage Teal Dye" },
            { itemID = 259125, name = "Un'Goro Green Dye" },
            { itemID = 259136, name = "Vortex Teal Dye" },
        },
    },
    white_dye_pigment = {
        pigmentID = 260947,
        dyes = {
            { itemID = 259078, name = "Basic Birch Dye" },
            { itemID = 259120, name = "Bone-White Dye" },
            { itemID = 259149, name = "Highborne Marble Dye" },
            { itemID = 259099, name = "Highland Birch Dye" },
        },
    },
    yellow_dye_pigment = {
        pigmentID = 262648,
        dyes = {
            { itemID = 259107, name = "Brass Dye" },
            { itemID = 258838, name = "Gold Dye" },
            { itemID = 259100, name = "Holy Oak Tan Dye" },
            { itemID = 259097, name = "Pinewood Dye" },
			{ itemID = 259117, name = "Sandfury Yellow Dye" },
            { itemID = 259138, name = "Savannah Gold Dye" },
            { itemID = 259137, name = "Sungrass Yellow Dye" },
            { itemID = 259106, name = "Zandalari Gold Dye" },
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
