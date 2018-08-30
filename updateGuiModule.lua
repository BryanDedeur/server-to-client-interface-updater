--local interactionModule = require(game:GetService("ServerScriptService").InteractionModule)
local modules = game:GetService("ServerScriptService"):WaitForChild("Modules")
local tycoonModule = require(modules:WaitForChild("TycoonModule"))

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local updateGuiEvent = ReplicatedStorage:WaitForChild("UpdateGuiEvent")

local ret = {} -- return functions

local serverStorage = game:GetService("ServerStorage")
local storageComponents = serverStorage:WaitForChild("StoreComponents")


function getCategoryList()
  local list = {}
  for _, folder in pairs (storageComponents:GetChildren()) do
    list[#list + 1] = folder.Name
  end
  return list
end

function getComponentList(player, category)
  local list = {}
  for _, product in pairs (category:GetChildren()) do
    local configInfo = product:FindFirstChild("Configuration", true)
    local quantity = player:FindFirstChild(product.Name, true).Value
    local image = "rbxgameasset://Images/"..product.Name
    list[#list + 1] = {product.Name, configInfo.Description.Value, configInfo.Price.Value, quantity, image}
  end
  return list
end

function ret:ProcessClientUpdateGui(player, listName, specifiedObject)
  local settings = {}
  if listName == "CategoryList" then
    for i, property in pairs (getCategoryList()) do
      table.insert(settings, {"ShopGui.Components.CategoryList.CategoryListFrame.Category.Name", "AdjustThis"})
      table.insert(settings, {"ShopGui.Components.CategoryList.CategoryListFrame.AdjustThis.Text", property})
      table.insert(settings, {"ShopGui.Components.CategoryList.CategoryListFrame.AdjustThis.Name", property})
    end
  elseif listName == "Component" then
    local category = storageComponents:FindFirstChild(specifiedObject)
    if category then
      for i, property in pairs (getComponentList(player, category)) do
        table.insert(settings, {"ShopGui.Components.ComponentList.ComponentListFrame.Component.Name", "AdjustThis"})
        table.insert(settings, {"ShopGui.Components.ComponentList.ComponentListFrame.AdjustThis.Title.Text", property[1]})
        table.insert(settings, {"ShopGui.Components.ComponentList.ComponentListFrame.AdjustThis.Description.Value", property[2]})
        table.insert(settings, {"ShopGui.Components.ComponentList.ComponentListFrame.AdjustThis.Price.Value", property[3]})
        table.insert(settings, {"ShopGui.Components.ComponentList.ComponentListFrame.AdjustThis.Quantity.Text", property[4]})
        table.insert(settings, {"ShopGui.Components.ComponentList.ComponentListFrame.AdjustThis.ImageButton.Image", property[5]})
        table.insert(settings, {"ShopGui.Components.ComponentList.ComponentListFrame.AdjustThis.Name", property[1]})
      end
    end
  end
  updateGuiEvent:FireClient(player, settings) -- Screen Gui, container(nil will adjust default gui), visiblity
end

return ret
