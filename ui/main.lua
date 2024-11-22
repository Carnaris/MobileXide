local CoreGui = game:GetService("CoreGui")
local UserInput = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Interface = import("rbxassetid://11389137937")

if oh.Cache["ui/main"] then
    return Interface
end

import("ui/controls/TabSelector")
local MessageBox, MessageType = import("ui/controls/MessageBox")

local RemoteSpy
local ClosureSpy
local ScriptScanner
local ModuleScanner
local UpvalueScanner
local ConstantScanner

xpcall(function()
    RemoteSpy = import("ui/modules/RemoteSpy")
    ClosureSpy = import("ui/modules/ClosureSpy")
    ScriptScanner = import("ui/modules/ScriptScanner")
    ModuleScanner = import("ui/modules/ModuleScanner")
    UpvalueScanner = import("ui/modules/UpvalueScanner")
    ConstantScanner = import("ui/modules/ConstantScanner")
end, function(err)
    local message
    if err:find("valid member") then
        message = "The UI has updated, please rejoin and restart. If you get this message more than once, screenshot this message and report it in the Hydroxide server.\n\n" .. err
    else
        message = "Report this error in Hydroxide's server:\n\n" .. err
    end

    MessageBox.Show("An error has occurred", message, MessageType.OK, function()
        Interface:Destroy() 
    end)
end)

local constants = {
    opened = UDim2.new(0.5, -325, 0.5, -175),
    closed = UDim2.new(0.5, -325, 0, -400),
    reveal = UDim2.new(0.5, -15, 0, 20),
    conceal = UDim2.new(0.5, -15, 0, -75)
}

local Open = Interface.Open
local Base = Interface.Base
local Drag = Base.Drag
local Status = Base.Status
local Collapse = Drag.Collapse

function oh.setStatus(text)
    Status.Text = '• Status: ' .. text
end

function oh.getStatus()
    return Status.Text:gsub('• Status: ', '')
end

local dragging
local dragStart
local startPos

-- Функция для обработки начала перетаскивания
local function beginDrag(input)
    dragging = true
    dragStart = input.Position
    startPos = Base.Position

    local dragEnded = input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            dragging = false
            dragEnded:Disconnect()
        end
    end)
end

-- Поддержка начала перетаскивания с использованием сенсорного экрана
Drag.TouchBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        beginDrag(input)
    end
end)

-- Функция для обработки изменения позиции при перетаскивании
oh.Events.Drag = UserInput.TouchMoved:Connect(function(touch)
    if dragging then
        local delta = touch.Position - dragStart
        Base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Open.TouchTap:Connect(function()
    Open:TweenPosition(constants.conceal, "Out", "Quad", 0.15)
    Base:TweenPosition(constants.opened, "Out", "Quad", 0.15)
end)

Collapse.TouchTap:Connect(function()
    Base:TweenPosition(constants.closed, "Out", "Quad", 0.15)
    Open:TweenPosition(constants.reveal, "Out", "Quad", 0.15)
end)

-- Добавляем поддержку долгого нажатия для мобильных устройств с контекстным меню
local longPressDuration = 0.5  -- Длительность долгого нажатия в секундах
local isLongPressing = false
local longPressConnection

local function showContextMenu(position)
    local contextMenu = Instance.new("Frame")
    contextMenu.Size = UDim2.new(0, 150, 0, 100)
    contextMenu.Position = UDim2.new(0, position.X, 0, position.Y)
    contextMenu.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    contextMenu.BorderSizePixel = 2
    contextMenu.BorderColor3 = Color3.fromRGB(255, 255, 255)
    contextMenu.Parent = CoreGui

    local button1 = Instance.new("TextButton")
    button1.Size = UDim2.new(1, -10, 0, 30)
    button1.Position = UDim2.new(0, 5, 0, 5)
    button1.Text = "Option 1"
    button1.Parent = contextMenu
    button1.MouseButton1Click:Connect(function()
        MessageBox.Show("Option 1", "Вы выбрали Опцию 1", MessageType.OK)
        contextMenu:Destroy()
    end)

    local button2 = Instance.new("TextButton")
    button2.Size = UDim2.new(1, -10, 0, 30)
    button2.Position = UDim2.new(0, 5, 0, 40)
    button2.Text = "Option 2"
    button2.Parent = contextMenu
    button2.MouseButton1Click:Connect(function()
        MessageBox.Show("Option 2", "Вы выбрали Опцию 2", MessageType.OK)
        contextMenu:Destroy()
    end)

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(1, -10, 0, 30)
    closeButton.Position = UDim2.new(0, 5, 0, 75)
    closeButton.Text = "Close"
    closeButton.Parent = contextMenu
    closeButton.MouseButton1Click:Connect(function()
        contextMenu:Destroy()
    end)
end

Drag.TouchLongPress:Connect(function(touchPositions, state)
    if state == Enum.UserInputState.Begin then
        isLongPressing = true

        longPressConnection = RunService.Heartbeat:Connect(function(deltaTime)
            if isLongPressing then
                longPressDuration = longPressDuration - deltaTime
                if longPressDuration <= 0 then
                    -- Показываем контекстное меню
                    showContextMenu(touchPositions[1].Position)
                    isLongPressing = false
                    longPressConnection:Disconnect()
                end
            end
        end)
    elseif state == Enum.UserInputState.End then
        isLongPressing = false
        longPressDuration = 0.5  -- Сброс длительности нажатия
        if longPressConnection then
            longPressConnection:Disconnect()
        end
    end
end)

Interface.Name = HttpService:GenerateGUID(false)
if getHui then
    Interface.Parent = getHui()
else
    if syn then
        syn.protect_gui(Interface)
    end

    Interface.Parent = CoreGui
end

return Interface
