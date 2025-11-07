-- // RESIDENCE MASSACRE — FULL SCRIPT v1.2 (NO SPAM + INSTANT RETURN)
-- INFO + MONSTER RADAR + AUTOMATIC — FINAL & LAG-FREE

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Residence Massacre",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Initializing",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "RMConfig",
        FileName = "Settings"
    }
})

--------------------------------------------------------------------
-- // ICONS
--------------------------------------------------------------------
local ICON_INFO    = 6031094667   -- Info
local ICON_RADAR   = 4483362458   -- Warning
local ICON_SUCCESS = 6031094667   -- Checkmark

--------------------------------------------------------------------
-- // INFO TAB
--------------------------------------------------------------------
local InfoTab = Window:CreateTab("Info", ICON_INFO)

InfoTab:CreateSection("About")

InfoTab:CreateParagraph({
    Title = "Residence Massacre \"Spirit Helper\"",
    Content = "A clean, modular script built step by step.\n\nFeatures:\n# ESP + Alerts (Door/Closet/Vent/Window)\n# Closet = Red at Stage 1\n# Auto Close Door (No Spam + Instant Return)"
})

InfoTab:CreateParagraph({
    Title = "Status",
    Content = "All systems online. Lag-free."
})

--------------------------------------------------------------------
-- // MONSTER RADAR TAB
--------------------------------------------------------------------
local RadarTab = Window:CreateTab("Monster Radar", ICON_RADAR)

RadarTab:CreateSection("[ # ] Door / Closet / Ventilation / Window")

-- ESP + Notification Toggle
local ESPEnabled = false
local connections = {}
local highlights = {}

-- Standard Stage Colors
local STAGE_COLORS = {
    [1] = { Outline = Color3.fromRGB(0, 255, 0),   Fill = Color3.fromRGB(100, 255, 100) },  -- Green
    [2] = { Outline = Color3.fromRGB(255, 255, 0), Fill = Color3.fromRGB(255, 255, 150) },  -- Yellow
    [3] = { Outline = Color3.fromRGB(255, 0, 0),   Fill = Color3.fromRGB(255, 100, 100) }   -- Red
}

-- Closet Special: Stage 1 = RED
local CLOSET_SPECIAL = {
    [1] = { Outline = Color3.fromRGB(255, 0, 0),   Fill = Color3.fromRGB(255, 100, 100) }
}

local function getStageColor(modelName, stage)
    if modelName == "Closet" and CLOSET_SPECIAL[stage] then
        return CLOSET_SPECIAL[stage]
    end
    return STAGE_COLORS[stage] or STAGE_COLORS[1]
end

local function setupESP()
    local monsterFolder = workspace:FindFirstChild("Monster")
    if not monsterFolder then warn("Monster folder not found!") return end

    local models = {"Door", "Closet", "Vent", "Window"}
    for _, modelName in ipairs(models) do
        local model = monsterFolder:FindFirstChild(modelName)
        if not model or not model:IsA("Model") then continue end

        local progress = model:FindFirstChild("Progress")
        if not progress or not progress:IsA("NumberValue") then continue end

        local lastValue = progress.Value

        local conn = progress:GetPropertyChangedSignal("Value"):Connect(function()
            local newValue = progress.Value
            if newValue == lastValue or not ESPEnabled then return end

            if (lastValue == 0 and newValue == 1) or
               (lastValue == 1 and newValue == 2) or
               (lastValue == 2 and newValue == 3) then

                local stage = newValue
                local colors = getStageColor(modelName, stage)

                Rayfield:Notify({
                    Title = modelName:upper() .. " ALERT",
                    Content = "Stage " .. stage .. " detected!",
                    Duration = 4,
                    Image = ICON_INFO
                })

                local h = highlights[model]
                if not h then
                    h = Instance.new("Highlight")
                    h.Parent = model
                    h.Adornee = model
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.FillTransparency = 0.5
                    h.OutlineTransparency = 0
                    highlights[model] = h
                end

                h.OutlineColor = colors.Outline
                h.FillColor = colors.Fill

            elseif (lastValue == 1 or lastValue == 2 or lastValue == 3) and newValue == 0 then
                local h = highlights[model]
                if h and h.Parent then h:Destroy() end
                highlights[model] = nil
            end

            lastValue = newValue
        end)

        table.insert(connections, conn)
    end
end

local function clearESP()
    for _, conn in ipairs(connections) do
        if conn.Connected then conn:Disconnect() end
    end
    connections = {}

    for model, h in pairs(highlights) do
        if h and h.Parent then h:Destroy() end
    end
    highlights = {}
end

RadarTab:CreateToggle({
    Name = "Enable ESP + Notification",
    CurrentValue = false,
    Flag = "ESPNotify",
    Callback = function(v)
        ESPEnabled = v
        if v then
            clearESP()
            setupESP()
            Rayfield:Notify({
                Title = "ESP ACTIVE",
                Content = "Tracking all sources. Closet = Red at Stage 1.",
                Duration = 4,
                Image = ICON_INFO
            })
        else
            clearESP()
            Rayfield:Notify({
                Title = "ESP OFF",
                Content = "Tracking stopped.",
                Duration = 2,
                Image = ICON_INFO
            })
        end
    end
})

RadarTab:CreateParagraph({
    Title = "Usage",
    Content = "# When enabled it does the following...\n\nRED == FINAL PHASE | 3 |\nYELLOW == SECOND PHASE | 2 |\nGREEN == FIRST PHASE | 1 |\n\n# Turns on notification for alerts."
})

--------------------------------------------------------------------
-- // AUTOMATIC TAB
--------------------------------------------------------------------
local AutoTab = Window:CreateTab("Automatic", ICON_SUCCESS)

AutoTab:CreateSection("[ # ] Door")

local AutoCloseEnabled = false
local autoCloseConn = nil
local hasTriggered = false  -- Prevents spam

-- FINAL TELEPORT POSITION
local DOOR_POS = Vector3.new(15.509483337402344, 5.000003337860107, -2.6445071697235107)

local function startAutoClose()
    if autoCloseConn then return end

    autoCloseConn = game:GetService("RunService").Heartbeat:Connect(function()
        if not AutoCloseEnabled then return end

        local bed = workspace:FindFirstChild("Bed")
        local doorModel = workspace:FindFirstChild("Door")
        local monsterDoor = workspace:FindFirstChild("Monster") and workspace.Monster:FindFirstChild("Door")

        if not bed or not doorModel or not monsterDoor then return end

        local hidden = bed:FindFirstChild("Hidden")
        local progress = monsterDoor:FindFirstChild("Progress")
        if not hidden or not hidden:IsA("BoolValue") or not progress or not progress:IsA("NumberValue") then return end

        if hidden.Value == true and progress.Value == 3 and not hasTriggered then
            hasTriggered = true  -- Block spam

            -- Wait for player to exit bed
            repeat task.wait() until hidden.Value == false or not AutoCloseEnabled
            if not AutoCloseEnabled then hasTriggered = false; return end

            task.wait(0.7)

            local player = game.Players.LocalPlayer
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then hasTriggered = false; return end

            local originalCFrame = hrp.CFrame

            -- TELEPORT TO DOOR
            hrp.CFrame = CFrame.new(DOOR_POS)
            task.wait(0.3)

            -- CLICK DETECTOR
            local clickDetector = doorModel:FindFirstChild("Detector") 
                and doorModel.Detector:FindFirstChild("ClickDetector")

            if clickDetector then
                for i = 1, 3 do
                    pcall(fireclickdetector, clickDetector)
                    task.wait(0.05)
                end
            end

            task.wait(0.6)

            -- TELEPORT BACK + SUCCESS NOTIFY
            if hrp and hrp.Parent then
                hrp.CFrame = originalCFrame
                task.wait(0.1)

                Rayfield:Notify({
                    Title = "SUCCESS",
                    Content = "Door was automatically closed.",
                    Duration = 4,
                    Image = ICON_SUCCESS
                })
            end

            -- Reset trigger after full cycle
            task.delay(2, function()
                hasTriggered = false
            end)
        end
    end)
end

local function stopAutoClose()
    if autoCloseConn then
        autoCloseConn:Disconnect()
        autoCloseConn = nil
    end
    hasTriggered = false
end

AutoTab:CreateToggle({
    Name = "Auto Close Door",
    CurrentValue = false,
    Flag = "AutoClose",
    Callback = function(v)
        AutoCloseEnabled = v
        if v then
            stopAutoClose()
            startAutoClose()
            Rayfield:Notify({
                Title = "WARNING",
                Content = "Auto Close Door Enabled!",
                Duration = 3,
                Image = ICON_RADAR
            })
        else
            stopAutoClose()
            Rayfield:Notify({
                Title = "WARNING",
                Content = "Auto Close Door Disabled!",
                Duration = 2,
                Image = ICON_INFO
            })
        end
    end
})
AutoTab:CreateParagraph({
    Title = "Usage",
    Content = "Automatically closes door upon enabling the toggle above."
})

--------------------------------------------------------------------
-- // AUTOMATIC TAB — AUTO TURN OFF ALARM (FINAL + SAFETY)
--------------------------------------------------------------------
AutoTab:CreateSection("[ # ] Alarm")

local AutoAlarmEnabled = false
local alarmConn = nil
local hasTriggered = false

local ALARM_POS = Vector3.new(-10.691389083862305, 5.000003337860107, 17.10317611694336)

local function startAutoAlarm()
    if alarmConn then return end

    alarmConn = game:GetService("RunService").Heartbeat:Connect(function()
        if not AutoAlarmEnabled or hasTriggered then return end

        local radio = workspace:FindFirstChild("Radio")
        if not radio then return end

        local main = radio:FindFirstChild("Main")
        if not main then return end

        local alarmSound = main:FindFirstChild("Alarm")
        local clickDetector = radio:FindFirstChild("ClickDetector")

        if not alarmSound or not alarmSound:IsA("Sound") or not clickDetector then return end

        if not alarmSound.IsPlaying then return end

        hasTriggered = true

        -- === IF: Player in Bed ===
        local bed = workspace:FindFirstChild("Bed")
        if bed then
            local hidden = bed:FindFirstChild("Hidden")
            if hidden and hidden:IsA("BoolValue") and hidden.Value == true then
                repeat task.wait() until hidden.Value == false or not AutoAlarmEnabled
                if not AutoAlarmEnabled then hasTriggered = false; return end
                task.wait(0.4)
            end
        end

        -- === IF: Door at Stage 3 → Wait for Auto Close Door SUCCESS ===
        local monsterFolder = workspace:FindFirstChild("Monster")
        if monsterFolder then
            local doorModel = monsterFolder:FindFirstChild("Door")
            if doorModel then
                local progress = doorModel:FindFirstChild("Progress")
                if progress and progress:IsA("NumberValue") and progress.Value == 3 then
                    local successReceived = false
                    local notifyConn
                    notifyConn = Rayfield.Notifications.ChildAdded:Connect(function(notif)
                        if notif.Title == "SUCCESS" and notif.Content == "Door was automatically closed." then
                            successReceived = true
                            if notifyConn then notifyConn:Disconnect() end
                        end
                    end)

                    repeat task.wait() until successReceived or not AutoAlarmEnabled
                    if notifyConn then notifyConn:Disconnect() end
                    if not AutoAlarmEnabled then hasTriggered = false; return end
                end
            end
        end

        -- === SAFETY: Wait for Door, Vent, Window Progress = 0 ===
        if monsterFolder then
            local models = {"Door", "Vent", "Window"}
            local allSafe = false

            repeat
                allSafe = true
                for _, name in ipairs(models) do
                    local model = monsterFolder:FindFirstChild(name)
                    if model then
                        local prog = model:FindFirstChild("Progress")
                        if prog and prog:IsA("NumberValue") and prog.Value == 3 then
                            allSafe = false
                            break
                        end
                    end
                end
                task.wait(0.1)
            until allSafe or not AutoAlarmEnabled

            if not AutoAlarmEnabled then hasTriggered = false; return end
        end

        -- === EXECUTE TURN-OFF ===
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then hasTriggered = false; return end

        local originalCFrame = hrp.CFrame

        hrp.CFrame = CFrame.new(ALARM_POS)
        task.wait(0.3)

        for i = 1, 3 do
            pcall(fireclickdetector, clickDetector)
            task.wait(0.05)
        end

        task.wait(0.6)

        if hrp and hrp.Parent then
            hrp.CFrame = originalCFrame
            task.wait(0.1)

            Rayfield:Notify({
                Title = "SUCCESS",
                Content = "Alarm was automatically turned off.",
                Duration = 4,
                Image = ICON_SUCCESS
            })
        end

        task.delay(3, function()
            hasTriggered = false
        end)
    end)
end

local function stopAutoAlarm()
    if alarmConn then
        alarmConn:Disconnect()
        alarmConn = nil
    end
    hasTriggered = false
end

AutoTab:CreateToggle({
    Name = "Auto Turn off Alarm",
    CurrentValue = false,
    Flag = "AutoAlarm",
    Callback = function(v)
        AutoAlarmEnabled = v
        if v then
            stopAutoAlarm()
            startAutoAlarm()
            Rayfield:Notify({
                Title = "WARNING",
                Content = "Auto Turn off Alarm Enabled!",
                Duration = 3,
                Image = ICON_INFO
            })
        else
            stopAutoAlarm()
            Rayfield:Notify({
                Title = "WARNING",
                Content = "Auto Turn off Alarm Disabled!",
                Duration = 2,
                Image = ICON_INFO
            })
        end
    end
})
AutoTab:CreateParagraph({
    Title = "Usage",
    Content = "Automatically turns off the Alarm when it's safe."
})

--------------------------------------------------------------------
-- // TEDDY BEAR AUTO-CLICK — 8s INTERVAL + WAITS FOR DOOR/ALARM SUCCESS
--------------------------------------------------------------------
AutoTab:CreateSection("[ # ] Teddy Bear")

local TeddyAutoEnabled = false
local teddyLoop = nil
local TEDDY_POS = Vector3.new(-8.735569953918457, 5.000003337860107, -8.874606132507324)

-- Track if waiting for Door/Alarm success
local waitingForSuccess = false
local successConn = nil

-- Connect listener for SUCCESS notifications
local function connectSuccessListener()
    if successConn then successConn:Disconnect() end
    successConn = Rayfield.Notifications.ChildAdded:Connect(function(notif)
        if notif.Title == "SUCCESS" and (
            notif.Content == "Door was automatically closed." or
            notif.Content == "Alarm was automatically turned off."
        ) then
            waitingForSuccess = false
            if successConn then successConn:Disconnect() end
            successConn = nil
        end
    end)
end

-- Safety: No monster at stage 3
local function isSafeToAct()
    local monster = workspace:FindFirstChild("Monster")
    if not monster then return true end
    for _, name in {"Door", "Vent", "Window"} do
        local model = monster:FindFirstChild(name)
        if model then
            local prog = model:FindFirstChild("Progress")
            if prog and prog:IsA("NumberValue") and prog.Value == 3 then
                return false
            end
        end
    end
    return true
end

local function waitForSafety()
    repeat task.wait(0.2) until isSafeToAct() or not TeddyAutoEnabled
end

local function clickTeddyBear()
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Hiding check
    local bed = workspace:FindFirstChild("Bed")
    local hidden = bed and bed:FindFirstChild("Hidden")
    local isHiding = hidden and hidden:IsA("BoolValue") and hidden.Value

    -- Door stage 3 check
    local monster = workspace:FindFirstChild("Monster")
    local doorModel = monster and monster:FindFirstChild("Door")
    local doorProgress = doorModel and doorModel:FindFirstChild("Progress")
    local doorAtStage3 = doorProgress and doorProgress:IsA("NumberValue") and doorProgress.Value == 3

    -- Skip if hiding + door at 3
    if isHiding and doorAtStage3 then
        task.wait(1)
        return
    end

    -- Wait until exit bed
    if isHiding then
        repeat task.wait() until (not hidden.Value) or not TeddyAutoEnabled
        if not TeddyAutoEnabled then return end
    end

    -- Wait for Door/Alarm success
    if waitingForSuccess then
        repeat task.wait(0.1) until not waitingForSuccess or not TeddyAutoEnabled
        if not TeddyAutoEnabled then return end
    end

    -- Wait for monster safety
    if not isSafeToAct() then
        waitForSafety()
        if not TeddyAutoEnabled then return end
    end

    -- Teddy click
    local teddy = workspace:FindFirstChild("Teddy bear")
    local clickDetector = teddy and teddy:FindFirstChild("ClickDetector")
    if not teddy or not clickDetector then return end

    local originalCFrame = hrp.CFrame
    hrp.CFrame = CFrame.new(TEDDY_POS)
    task.wait(0.3)
    pcall(fireclickdetector, clickDetector)
    task.wait(0.1)
    hrp.CFrame = originalCFrame
    task.wait(0.1)

    Rayfield:Notify({
        Title = "SUCCESS",
        Content = "Teddy Bear clicked.",
        Duration = 3
    })
end

local function startTeddyLoop()
    if teddyLoop then return end
    teddyLoop = task.spawn(function()
        while TeddyAutoEnabled do
            waitingForSuccess = false

            -- Detect if Door/Alarm is active
            local monster = workspace:FindFirstChild("Monster")
            local radio = workspace:FindFirstChild("Radio")
            local alarmPlaying = radio and radio:FindFirstChild("Main") and radio.Main:FindFirstChild("Alarm") and radio.Main.Alarm.IsPlaying

            local anyStage3 = false
            if monster then
                for _, name in {"Door", "Vent", "Window"} do
                    local model = monster:FindFirstChild(name)
                    if model then
                        local prog = model:FindFirstChild("Progress")
                        if prog and prog:IsA("NumberValue") and prog.Value == 3 then
                            anyStage3 = true
                            break
                        end
                    end
                end
            end

            if anyStage3 or alarmPlaying then
                waitingForSuccess = true
                connectSuccessListener()
            end

            clickTeddyBear()
            task.wait(8)  -- 8 seconds
        end
    end)
end

local function stopTeddyLoop()
    TeddyAutoEnabled = false
    waitingForSuccess = false
    if teddyLoop then task.cancel(teddyLoop); teddyLoop = nil end
    if successConn then successConn:Disconnect(); successConn = nil end
end

AutoTab:CreateToggle({
    Name = "Auto Teddy Bear",
    CurrentValue = false,
    Flag = "AutoTeddy",
    Callback = function(v)
        TeddyAutoEnabled = v
        if v then
            stopTeddyLoop()
            startTeddyLoop()
            Rayfield:Notify({
                Title = "WARNING",
                Content = "Auto Teddy Bear Enabled! (Waits for Door/Alarm)",
                Duration = 3
            })
        else
            stopTeddyLoop()
            Rayfield:Notify({
                Title = "WARNING",
                Content = "Auto Teddy Bear Disabled!",
                Duration = 2
            })
        end
    end
})

AutoTab:CreateSection("Usage")  -- ← REQUIRED BEFORE Paragraph

AutoTab:CreateParagraph({
    Title = "How It Works",
    Content = "Clicks Teddy Bear every 8s when safe.\nWaits for Door/Alarm to finish.\nSkips if hiding + Door Stage 3."
})

--------------------------------------------------------------------
-- // SCRIPT LOADED
--------------------------------------------------------------------
Rayfield:Notify({
    Title = "SUCCESS",
    Content = "Residence Massacre Script v1.2 — No Spam, Instant Return",
    Duration = 6,
    Image = ICON_SUCCESS
})
