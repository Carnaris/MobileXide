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
local Status = Base.Status

function oh.setStatus(text)
    Status.Text = '• Status: ' .. text
end

function oh.getStatus()
    return Status.Text:gsub('• Status: ', '')
end

Open.TouchTap:Connect(function()
    Open:TweenPosition(constants.conceal, "Out", "Quad", 0.15)
    Base:TweenPosition(constants.opened, "Out", "Quad", 0.15)
end)

local function addLongPressToItem(item)
    local longPressDuration = 0.5
    local isLongPressing = false
    local longPressConnection

    item.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            isLongPressing = true

            longPressConnection = RunService.Heartbeat:Connect(function(deltaTime)
                if isLongPressing then
                    longPressDuration = longPressDuration - deltaTime
                    if longPressDuration <= 0 then
                        -- Показываем сообщение о дополнительных функциях (аналог контекстного меню)
                        MessageBox.Show("Дополнительные функции", "Выберите действие для этого элемента.", MessageType.OK)
                        isLongPressing = false
                        longPressConnection:Disconnect()
                    end
                end
            end)
        end
    end)

    item.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            isLongPressing = false
            longPressDuration = 0.5
            if longPressConnection then
                longPressConnection:Disconnect()
            end
        end
    end)
end

-- Добавляем долгий тап для всех элементов списка
for _, item in pairs(Base:GetDescendants()) do
    if item:IsA("TextButton") then
        addLongPressToItem(item)
    end
end

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
