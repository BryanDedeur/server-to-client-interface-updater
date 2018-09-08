local Players = game:GetService("Players")
local player = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local showHideEvent = ReplicatedStorage:WaitForChild("UpdateGuiEvent")

local anTime = .5

local function getContentsHeight(gui)
  local size = 0
  for _, content in pairs(gui:GetChildren()) do
    if content:IsA("GuiObject") then
      if content.Visible == true then
        size = size + content.Size.Y.Offset + 4
      end
    end
  end
  return size
end

local function adjustVisibility(container, visibility)
  if not container.Visible == visibility then
    if container.Parent:IsA("ScreenGui") then -- adjust position
      if container.Visible == true then
        container:TweenPosition(UDim2.new(0, - 200, 0.5, container.Position.Y.Offset), "In", "Back", anTime, false)
        wait(anTime)
        container.Visible = false
      else
        container.Visible = true
        if container:IsA("TextButton") then
          container:TweenPosition(UDim2.new(0, - 65, 0.5, 0), "Out", "Quad", anTime, false)
        else
          container:TweenPosition(UDim2.new(0, 5, 0.5, container.Position.Y.Offset), "Out", "Back", anTime, false)
        end
        wait(anTime)
      end
    elseif container.Parent:IsA("Frame") then -- resize animation
      if container.Visible == true then -- hide gui
        container.Visible = false
        container.Parent:TweenSize(UDim2.new(0, 200, 0, getContentsHeight(container.Parent)), "In", "Back", anTime, false)
        wait(anTime)
      else -- show gui
        container.Visible = true
        container.Parent:TweenSize(UDim2.new(0, 200, 0, getContentsHeight(container.Parent)), "Out", "Back", anTime, false)
        wait(anTime)
      end
    end
  end
end

local function makeNewClone(objectToFind, index)
  --	print("Making new clone of ", objectToFind, " at this index ", index)
  local newObject = script:FindFirstChild(objectToFind)
  if newObject then
    newObject = newObject:Clone()
    newObject.Name = objectToFind
    for _, item in pairs(newObject:GetChildren()) do
      if item:IsA("Script") then
        item.Disabled = false
      end
    end
    newObject.Parent = index
    return newObject
  else
    return index
  end
end

local function hideAllContainers(gui, exception)
  for _, v in pairs(gui:GetChildren()) do
    if v:IsA("GuiObject") and v ~= exception then
      adjustVisibility(v, false)
    end
  end
end

local function setProperty(object, property, value)
  --	print("Setting", property, ": ", value, " to ", object)
  if property == "Visible" then
    if object.Parent:IsA("ScreenGui") and value == true then
      hideAllContainers(object.Parent, object)
    end
    adjustVisibility(object, value)
  else
    object[property] = value
  end
end

local function indexMembers(totalMembers, key, value)
  --print(totalMembers, key, value)
  local index = script.Parent
  for word in string.gmatch(key, "%a+") do
    local testIndex = index:FindFirstChild(word)
    if testIndex then
      index = testIndex
    elseif totalMembers == 1 then -- set a value to the member
      setProperty(index, word, value)
    else -- create a new member with the details
      index = makeNewClone(word, index)
    end
    totalMembers = totalMembers - 1
  end
end

local function getNumberOfMembers(key)
  local count = 0
  for w in string.gmatch(key, "%a+") do
    count = count + 1
  end
  return count
end

local function parseTable(memberTable)
  indexMembers(getNumberOfMembers(memberTable[1]), memberTable[1], memberTable[2])
end

local function onEventFired(settings)
  if settings then
    for key, value in pairs(settings) do
      --			local index = script.Parent
      local totalMembers = getNumberOfMembers(key)
      --print("Total number of members is: ", totalMembers, value)
      if totalMembers == 0 then
        parseTable(value)
      else
        indexMembers(totalMembers, key, value)
      end
    end
  end
end

showHideEvent.OnClientEvent:Connect(onEventFired)
