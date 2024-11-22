local CoreGui = game:GetService("CoreGui")
local UserInput = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

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

-- Поддержка начала перетаскивания с использованием мыши
Drag.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        beginDrag(input)
    end
end)

-- Поддержка начала перетаскивания с использованием сенсорного экрана
Drag.TouchTap:Connect(function(input)
    beginDrag(input)
end)

-- Функция для обработки изменения позиции при перетаскивании
oh.Events.Drag = UserInput.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        local delta = input.Position - dragStart
        Base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Open.MouseButton1Click:Connect(function()
    Open:TweenPosition(constants.conceal, "Out", "Quad", 0.15)
    Base:TweenPosition(constants.opened, "Out", "Quad", 0.15)
end)

Collapse.MouseButton1Click:Connect(function()
    Base:TweenPosition(constants.closed, "Out", "Quad", 0.15)
    Open:TweenPosition(constants.reveal, "Out", "Quad", 0.15)
end)

-- Добавляем поддержку долгого нажатия для мобильных устройств
UserInput.TouchLongPress:Connect(function(touchPositions, state)
    if state == Enum.UserInputState.Begin then
        -- Обрабатываем удержание кнопки для открытия дополнительных функций
        if #touchPositions == 1 then
            local touch = touchPositions[1]
            if touch and Open and Open.AbsolutePosition and Open.AbsoluteSize then
                local withinButton = (touch.X >= Open.AbsolutePosition.X and touch.X <= Open.AbsolutePosition.X + Open.AbsoluteSize.X) and
                                     (touch.Y >= Open.AbsolutePosition.Y and touch.Y <= Open.AbsolutePosition.Y + Open.AbsoluteSize.Y)
                if withinButton then
                    -- Выполняем действия, аналогичные правому клику
                    MessageBox.Show("Дополнительные функции", "Здесь можно открыть дополнительные функции.", MessageType.OK)
                end
            end
        end
    end
end)

-- Добавляем поддержку двойного нажатия
local lastClickTime = 0
local doubleClickThreshold = 0.3  -- Время (в секундах) между двойными нажатиями

Open.MouseButton1Click:Connect(function()
    local currentTime = tick()
    if currentTime - lastClickTime <= doubleClickThreshold then
        -- Выполнить действие для двойного нажатия
        MessageBox.Show("Двойное нажатие", "Вы выполнили двойное нажатие!", MessageType.OK)
    else
        -- Выполнить обычное действие
        Open:TweenPosition(constants.conceal, "Out", "Quad", 0.15)
        Base:TweenPosition(constants.opened, "Out", "Quad", 0.15)
    end
    lastClickTime = currentTime
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
