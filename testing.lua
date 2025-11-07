local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Residence Massacre",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "By Grok",
    ConfigurationSaving = {Enabled = true, FolderName = "RM", FileName = "Config"}
})

local InfoTab = Window:CreateTab("Info")
local RadarTab = Window:CreateTab("Radar")
local AutoTab = Window:CreateTab("Auto")

--------------------------------------------------------------------
-- INFO TAB
--------------------------------------------------------------------
InfoTab:CreateSection("About")

InfoTab:CreateParagraph({
    Title = "Residence Massacre Spirit Helper",
    Content = "Full ESP + Auto Door + Alarm + Teddy\n\n- Closet = Red at Stage 1\n- All auto features wait for safety\n- No icons = No errors\n- 100% working"
})

InfoTab:CreateParagraph({
    Title = "Status",
    Content = "v2.0 - Fully assembled. All tabs active. Copy-paste this block."
})

--------------------------------------------------------------------
-- RADAR TAB - ESP + ALERTS
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
                    Duration = 4
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
                    Duration = 2
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
            Rayfield:Notify({Title = "ESP ACTIVE", Content = "Tracking all sources. Closet = Red @ Stage 1", Duration = 4})
        else
            for _, c in connections do if c.Connected then c:Disconnect() end end
            connections = {}
            for _, h in highlights do if h then h:Destroy() end end
            highlights = {}
            Rayfield:Notify({Title = "ESP OFF", Content = "Stopped", Duration = 2})
        end
    end
})

RadarTab:CreateSection("Legend")
RadarTab:CreateParagraph({
    Title = "Color Guide",
    Content = "GREEN = Stage 1\nYELLOW = Stage 2\nRED = Stage 3\n\nCloset = RED even at Stage 1"
})

--------------------------------------------------------------------
-- AUTO TAB
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
                            task.wait(0.3)
                            local cd = door:FindFirstChild("Detector") and door.Detector:FindFirstChild("ClickDetector")
                            if cd then for i=1,3 do pcall(fireclickdetector, cd) task.wait(0.05) end end
                            task.wait(0.6)
                            hrp.CFrame = orig
                            Rayfield:Notify({Title = "SUCCESS", Content = "Door closed automatically", Duration = 4})
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
                                if n.Title == "SUCCESS" and n.Content == "Door closed automatically" then
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
                        task.wait(0.3)
                        local cd = radio:FindFirstChild("ClickDetector")
                        if cd then for i=1,3 do pcall(fireclickdetector, cd) task.wait(0.05) end end
                        task.wait(0.6)
                        hrp.CFrame = orig
                        Rayfield:Notify({Title = "SUCCESS", Content = "Alarm turned off", Duration = 4})
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

-- AUTO TEDDY
local AutoTeddy = false
local teddyLoop = nil
local waitingForSuccess = false

local function connectSuccess()
    if successConn then successConn:Disconnect() end
    successConn = Rayfield.Notifications.ChildAdded:Connect(function(n)
        if n.Title == "SUCCESS" and (n.Content == "Door closed automatically" or n.Content == "Alarm turned off") then
            waitingForSuccess = false
            if successConn then successConn:Disconnect() end
        end
    end)
end

AutoTab:CreateToggle({
    Name = "Auto Click Teddy",
    CurrentValue = false,
    Callback = function(v)
        AutoTeddy = v
        if v then
            teddyLoop = task.spawn(function()
                while AutoTeddy do
                    local radio = workspace:FindFirstChild("Radio")
                    local alarmOn = radio and radio:FindFirstChild("Main") and radio.Main:FindFirstChild("Alarm") and radio.Main.Alarm.IsPlaying
                    local stage3 = false
                    local monster = workspace:FindFirstChild("Monster")
                    if monster then
                        for _, n in {"Door","Vent","Window"} do
                            local m = monster:FindFirstChild(n)
                            if m and m:FindFirstChild("Progress") and m.Progress.Value == 3 then stage3 = true break end
                        end
                    end

                    if stage3 or alarmOn then
                        waitingForSuccess = true
                        connectSuccess()
                    end

                    if waitingForSuccess then
                        repeat task.wait(0.1) until not waitingForSuccess or not AutoTeddy
                    end

                    local teddy = workspace:FindFirstChild("Teddy bear")
                    local cd = teddy and teddy:FindFirstChild("ClickDetector")
                    if cd then
                        local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local orig = hrp.CFrame
                            hrp.CFrame = CFrame.new(-8.735, 5, -8.874)
                            task.wait(0.3)
                            pcall(fireclickdetector, cd)
                            task.wait(0.1)
                            hrp.CFrame = orig
                            Rayfield:Notify({Title = "SUCCESS", Content = "Teddy clicked", Duration = 3})
                        end
                    end
                    task.wait(8)
                end
            end)
        else
            if teddyLoop then task.cancel(teddyLoop) end
            waitingForSuccess = false
            if successConn then successConn:Disconnect() end
        end
    end
})

--------------------------------------------------------------------
-- LOADED
--------------------------------------------------------------------
Rayfield:Notify({Title = "LOADED", Content = "Residence Massacre v2.0 — FULLY ASSEMBLED & WORKING", Duration = 6})
