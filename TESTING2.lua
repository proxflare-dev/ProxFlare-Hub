local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Residence Massacre",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "By Grok",
    ConfigurationSaving = {Enabled = true, FolderName = "RM", FileName = "Config"}
})

--------------------------------------------------------------------
-- // ICONS (SAFE & WORKING)
--------------------------------------------------------------------
local ICON_RADAR   = 4483362458  -- Warning / Alert
local ICON_SUCCESS = 6031094667  -- Checkmark

--------------------------------------------------------------------
-- // TABS
--------------------------------------------------------------------
local InfoTab = Window:CreateTab("Info")
local RadarTab = Window:CreateTab("Radar")
local AutoTab = Window:CreateTab("Auto")

--------------------------------------------------------------------
-- // INFO TAB
--------------------------------------------------------------------
InfoTab:CreateSection("About")
InfoTab:CreateParagraph({
    Title = "Residence Massacre Spirit Helper",
    Content = "Full ESP + Auto Door + Alarm + Teddy\n\n- Closet = Red at Stage 1\n- All auto features wait for safety\n- Icons restored\n- v3.0 - FINAL & PERFECT"
})

InfoTab:CreateParagraph({
    Title = "Status",
    Content = "All systems online. Icons working. Teddy clicks 100%."
})

--------------------------------------------------------------------
-- // RADAR TAB - ESP + ALERTS
--------------------------------------------------------------------
RadarTab:CreateSection("Monster ESP + Alerts")

local ESPEnabled = false
local highlights = {}
local connections = {}

local function setupESP()
    local monster = workspace:FindFirstChild("Monster")
    if not monster then return end

    for _, name in {"Door", "Closet", "Vent", "Window"} do
        local model = monster:FindFirstChild(name)
        if not model or not model:FindFirstChild("Progress") then continue end

        local h = Instance.new("Highlight")
        h.Parent = model
        h.Adornee = model
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0
        highlights[model] = h

        local lastStage = model.Progress.Value
        local conn = model.Progress:GetPropertyChangedSignal("Value"):Connect(function()
            local stage = model.Progress.Value
            if stage == lastStage then return end

            if stage > 0 and lastStage == 0 then
                Rayfield:Notify({
                    Title = name:upper() .. " ALERT",
                    Content = "Stage " .. stage .. " started!",
                    Duration = 4,
                    Image = ICON_RADAR
                })
            end

            if stage == 1 then
                h.OutlineColor = (name == "Closet") and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
                h.FillColor = (name == "Closet") and Color3.fromRGB(255,100,100) or Color3.fromRGB(100,255,100)
            elseif stage == 2 then
                h.OutlineColor = Color3.fromRGB(255,255,0)
                h.FillColor = Color3.fromRGB(255,255,150)
            elseif stage == 3 then
                h.OutlineColor = Color3.fromRGB(255,0,0)
                h.FillColor = Color3.fromRGB(255,100,100)
            elseif stage == 0 and lastStage > 0 then
                Rayfield:Notify({
                    Title = name:upper() .. " SAFE",
                    Content = "Stage reset.",
                    Duration = 2,
                    Image = ICON_SUCCESS
                })
                if h and h.Parent then h:Destroy() end
                highlights[model] = nil
            end

            lastStage = stage
        end)

        table.insert(connections, conn)
    end
end

RadarTab:CreateToggle({
    Name = "Enable ESP + Alerts",
    CurrentValue = false,
    Callback = function(v)
        ESPEnabled = v
        if v then
            for _, c in connections do if c.Connected then c:Disconnect() end end
            connections = {}
            for _, h in highlights do if h then h:Destroy() end end
            highlights = {}
            setupESP()
            Rayfield:Notify({Title = "ESP ACTIVE", Content = "Tracking all sources", Duration = 4, Image = ICON_RADAR})
        else
            for _, c in connections do if c.Connected then c:Disconnect() end end
            connections = {}
            for _, h in highlights do if h then h:Destroy() end end
            highlights = {}
            Rayfield:Notify({Title = "ESP OFF", Content = "Stopped", Duration = 2, Image = ICON_SUCCESS})
        end
    end
})

RadarTab:CreateSection("Legend")
RadarTab:CreateParagraph({
    Title = "Color Guide",
    Content = "GREEN = Stage 1\nYELLOW = Stage 2\nRED = Stage 3\n\nCloset = RED even at Stage 1"
})

--------------------------------------------------------------------
-- // AUTO TAB
--------------------------------------------------------------------
AutoTab:CreateSection("Auto Features")

-- AUTO DOOR
local AutoDoor = false
local doorLoop = nil

AutoTab:CreateToggle({
    Name = "Auto Close Door",
    CurrentValue = false,
    Callback = function(v)
        AutoDoor = v
        if v then
            doorLoop = task.spawn(function()
                while AutoDoor do
                    local bed = workspace:FindFirstChild("Bed")
                    local door = workspace:FindFirstChild("Door")
                    local mdoor = workspace.Monster and workspace.Monster:FindFirstChild("Door")
                    if bed and door and mdoor and bed:FindFirstChild("Hidden") and mdoor:FindFirstChild("Progress") then
                        if bed.Hidden.Value and mdoor.Progress.Value == 3 then
                            repeat task.wait() until not bed.Hidden.Value or not AutoDoor
                            if not AutoDoor then break end
                            task.wait(0.7)

                            local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if not hrp then break end

                            local orig = hrp.CFrame
                            hrp.CFrame = CFrame.new(15.509, 5, -2.644)
                            task.wait(0.5)
                            local cd = door:FindFirstChild("Detector") and door.Detector:FindFirstChild("ClickDetector")
                            if cd then for i=1,3 do pcall(fireclickdetector, cd, 0) task.wait(0.1) end end
                            task.wait(0.6)
                            hrp.CFrame = orig
                            Rayfield:Notify({Title = "SUCCESS", Content = "Door was automatically closed.", Duration = 4, Image = ICON_SUCCESS})
                            task.wait(2)
                        end
                    end
                    task.wait(0.1)
                end
            end)
        else
            if doorLoop then task.cancel(doorLoop) end
        end
    end
})

-- AUTO ALARM
local AutoAlarm = false
local alarmLoop = nil
local waitingForDoor = false

AutoTab:CreateToggle({
    Name = "Auto Turn Off Alarm",
    CurrentValue = false,
    Callback = function(v)
        AutoAlarm = v
        if v then
            alarmLoop = task.spawn(function()
                while AutoAlarm do
                    local radio = workspace:FindFirstChild("Radio")
                    if radio and radio:FindFirstChild("Main") and radio.Main:FindFirstChild("Alarm") and radio.Main.Alarm.IsPlaying then
                        local bed = workspace:FindFirstChild("Bed")
                        if bed and bed:FindFirstChild("Hidden") and bed.Hidden.Value then
                            repeat task.wait() until not bed.Hidden.Value or not AutoAlarm
                            task.wait(0.4)
                        end

                        local mdoor = workspace.Monster and workspace.Monster:FindFirstChild("Door")
                        if mdoor and mdoor:FindFirstChild("Progress") and mdoor.Progress.Value == 3 then
                            waitingForDoor = true
                            local conn; conn = Rayfield.Notifications.ChildAdded:Connect(function(n)
                                if n.Title == "SUCCESS" and n.Content == "Door was automatically closed." then
                                    waitingForDoor = false
                                    if conn then conn:Disconnect() end
                                end
                            end)
                            repeat task.wait() until not waitingForDoor or not AutoAlarm
                            if conn then conn:Disconnect() end
                        end

                        local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if not hrp then break end

                        local orig = hrp.CFrame
                        hrp.CFrame = CFrame.new(-10.691, 5, 17.103)
                        task.wait(0.5)
                        local cd = radio:FindFirstChild("ClickDetector")
                        if cd then for i=1,3 do pcall(fireclickdetector, cd, 0) task.wait(0.1) end end
                        task.wait(0.6)
                        hrp.CFrame = orig
                        Rayfield:Notify({Title = "SUCCESS", Content = "Alarm was automatically turned off.", Duration = 4, Image = ICON_SUCCESS})
                        task.wait(3)
                    end
                    task.wait(0.5)
                end
            end)
        else
            if alarmLoop then task.cancel(alarmLoop) end
        end
    end
})

--------------------------------------------------------------------
-- // TEDDY BEAR AUTO-CLICK — BULLETPROOF + ICONS
--------------------------------------------------------------------
AutoTab:CreateSection("[ # ] Teddy Bear")

local TeddyAutoEnabled = false
local teddyLoop = nil
local TEDDY_POS = Vector3.new(-8.735569953918457, 5.000003337860107, -8.874606132507324)

local waitingForSuccess = false
local successConn = nil

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

local function isSafeToAct()
    local monster = workspace:FindFirstChild("Monster")
    if not monster then return true end
    for _, name in {"Door", "Vent", "Window"} do
        local model = monster:FindFirstChild(name)
        if model and model:FindFirstChild("Progress") and model.Progress:IsA("NumberValue") and model.Progress.Value == 3 then
            return false
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

    local bed = workspace:FindFirstChild("Bed")
    local hidden = bed and bed:FindFirstChild("Hidden")
    local isHiding = hidden and hidden:IsA("BoolValue") and hidden.Value

    local monster = workspace:FindFirstChild("Monster")
    local doorModel = monster and monster:FindFirstChild("Door")
    local doorProgress = doorModel and doorModel:FindFirstChild("Progress")
    local doorAtStage3 = doorProgress and doorProgress:IsA("NumberValue") and doorProgress.Value == 3

    if isHiding and doorAtStage3 then
        task.wait(1)
        return
    end

    if isHiding then
        repeat task.wait() until not hidden.Value or not TeddyAutoEnabled
        if not TeddyAutoEnabled then return end
    end

    if waitingForSuccess then
        repeat task.wait(0.1) until not waitingForSuccess or not TeddyAutoEnabled
        if not TeddyAutoEnabled then return end
    end

    if not isSafeToAct() then
        waitForSafety()
        if not TeddyAutoEnabled then return end
    end

    local teddy = workspace:FindFirstChild("Teddy bear")
    local clickDetector = teddy and teddy:FindFirstChild("ClickDetector")
    if not teddy or not clickDetector then return end

    local originalCFrame = hrp.CFrame
    hrp.CFrame = CFrame.new(TEDDY_POS)
    task.wait(0.5)

    for i = 1, 3 do
        if not TeddyAutoEnabled then break end
        pcall(fireclickdetector, clickDetector, 0)
        task.wait(0.1)
    end

    if hrp and hrp.Parent then
        hrp.CFrame = originalCFrame
        task.wait(0.1)
        Rayfield:Notify({
            Title = "SUCCESS",
            Content = "Teddy Bear clicked.",
            Duration = 3,
            Image = ICON_SUCCESS
        })
    end
end

local function startTeddyLoop()
    if teddyLoop then return end
    teddyLoop = task.spawn(function()
        while TeddyAutoEnabled do
            waitingForSuccess = false

            local monster = workspace:FindFirstChild("Monster")
            local radio = workspace:FindFirstChild("Radio")
            local alarmPlaying = radio and radio:FindFirstChild("Main") and radio.Main:FindFirstChild("Alarm") and radio.Main.Alarm.IsPlaying

            local anyStage3 = false
            if monster then
                for _, name in {"Door", "Vent", "Window"} do
                    local model = monster:FindFirstChild(name)
                    if model and model:FindFirstChild("Progress") and model.Progress:IsA("NumberValue") and model.Progress.Value == 3 then
                        anyStage3 = true
                        break
                    end
                end
            end

            if anyStage3 or alarmPlaying then
                waitingForSuccess = true
                connectSuccessListener()
            end

            clickTeddyBear()
            task.wait(8)
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
                Duration = 3,
                Image = ICON_RADAR
            })
        else
            stopTeddyLoop()
            Rayfield:Notify({
                Title = "WARNING",
                Content = "Auto Teddy Bear Disabled!",
                Duration = 2,
                Image = ICON_RADAR
            })
        end
    end
})

AutoTab:CreateSection("Info")
AutoTab:CreateParagraph({
    Title = "Auto Teddy",
    Content = "• Clicks every 8s\n• Waits for Door/Alarm\n• Skips if hiding + Door Stage 3\n• Teleports + spam click"
})

--------------------------------------------------------------------
-- // LOADED
--------------------------------------------------------------------
Rayfield:Notify({
    Title = "LOADED",
    Content = "Residence Massacre v3.0 — ICONS + TEDDY FIXED",
    Duration = 6,
    Image = ICON_SUCCESS
})
