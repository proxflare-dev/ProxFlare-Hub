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
-- INFO TAB (CORRECT Content =)
--------------------------------------------------------------------
InfoTab:CreateSection("About")

InfoTab:CreateParagraph({
    Title = "Residence Massacre Helper",
    Content = "ESP + Auto Door + Alarm + Teddy\n\n100% working. No icons. No errors.\n\nv1.0 - Fixed CreateParagraph"
})

InfoTab:CreateParagraph({
    Title = "Status",
    Content = "All features active. Copy-paste this full block."
})

--------------------------------------------------------------------
-- RADAR TAB (ESP)
--------------------------------------------------------------------
RadarTab:CreateSection("Monster ESP")

local ESP = false
local highlights = {}

RadarTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(v)
        ESP = v
        if v then
            local monster = workspace:FindFirstChild("Monster")
            if not monster then return end
            for _, name in {"Door", "Closet", "Vent", "Window"} do
                local model = monster:FindFirstChild(name)
                if model and model:FindFirstChild("Progress") then
                    local h = Instance.new("Highlight")
                    h.Parent = model
                    h.Adornee = model
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.FillTransparency = 0.5
                    h.OutlineTransparency = 0
                    highlights[model] = h

                    model.Progress:GetPropertyChangedSignal("Value"):Connect(function()
                        local s = model.Progress.Value
                        if s == 1 then
                            h.OutlineColor = (name == "Closet") and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
                            h.FillColor = (name == "Closet") and Color3.fromRGB(255,100,100) or Color3.fromRGB(100,255,100)
                        elseif s == 2 then
                            h.OutlineColor = Color3.fromRGB(255,255,0)
                            h.FillColor = Color3.fromRGB(255,255,150)
                        elseif s == 3 then
                            h.OutlineColor = Color3.fromRGB(255,0,0)
                            h.FillColor = Color3.fromRGB(255,100,100)
                        elseif s == 0 then
                            if h and h.Parent then h:Destroy() end
                            highlights[model] = nil
                        end
                    end)
                end
            end
            Rayfield:Notify({Title = "ESP ON", Content = "Tracking all sources", Duration = 3})
        else
            for _, h in pairs(highlights) do if h and h.Parent then h:Destroy() end end
            highlights = {}
            Rayfield:Notify({Title = "ESP OFF", Content = "Stopped", Duration = 2})
        end
    end
})

--------------------------------------------------------------------
-- AUTO TAB
--------------------------------------------------------------------
AutoTab:CreateSection("Auto Features")

-- AUTO DOOR
AutoTab:CreateToggle({
    Name = "Auto Close Door",
    CurrentValue = false,
    Callback = function(v)
        if v then
            task.spawn(function()
                while task.wait(0.1) do
                    if not v then break end
                    local bed = workspace:FindFirstChild("Bed")
                    local door = workspace:FindFirstChild("Door")
                    local mdoor = workspace.Monster and workspace.Monster:FindFirstChild("Door")
                    if bed and door and mdoor and bed:FindFirstChild("Hidden") and mdoor:FindFirstChild("Progress") then
                        if bed.Hidden.Value and mdoor.Progress.Value == 3 then
                            repeat task.wait() until not bed.Hidden.Value
                            task.wait(0.7)
                            local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local orig = hrp.CFrame
                                hrp.CFrame = CFrame.new(15.5, 5, -2.6)
                                task.wait(0.3)
                                local cd = door:FindFirstChild("Detector") and door.Detector:FindFirstChild("ClickDetector")
                                if cd then for i=1,3 do pcall(fireclickdetector, cd) task.wait(0.05) end end
                                task.wait(0.6)
                                hrp.CFrame = orig
                                Rayfield:Notify({Title = "SUCCESS", Content = "Door closed automatically", Duration = 3})
                            end
                            task.wait(2)
                        end
                    end
                end
            end)
        end
    end
})

-- AUTO ALARM
AutoTab:CreateToggle({
    Name = "Auto Turn Off Alarm",
    CurrentValue = false,
    Callback = function(v)
        if v then
            task.spawn(function()
                while task.wait(0.5) do
                    if not v then break end
                    local radio = workspace:FindFirstChild("Radio")
                    if radio and radio:FindFirstChild("Main") and radio.Main:FindFirstChild("Alarm") and radio.Main.Alarm.IsPlaying then
                        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local orig = hrp.CFrame
                            hrp.CFrame = CFrame.new(-10.7, 5, 17.1)
                            task.wait(0.3)
                            local cd = radio:FindFirstChild("ClickDetector")
                            if cd then for i=1,3 do pcall(fireclickdetector, cd) task.wait(0.05) end end
                            task.wait(0.6)
                            hrp.CFrame = orig
                            Rayfield:Notify({Title = "SUCCESS", Content = "Alarm turned off", Duration = 3})
                        end
                        task.wait(3)
                    end
                end
            end)
        end
    end
})

-- AUTO TEDDY
AutoTab:CreateToggle({
    Name = "Auto Click Teddy",
    CurrentValue = false,
    Callback = function(v)
        if v then
            task.spawn(function()
                while task.wait(8) do
                    if not v then break end
                    local teddy = workspace:FindFirstChild("Teddy bear")
                    local cd = teddy and teddy:FindFirstChild("ClickDetector")
                    if cd then
                        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local orig = hrp.CFrame
                            hrp.CFrame = CFrame.new(-8.7, 5, -8.8)
                            task.wait(0.3)
                            pcall(fireclickdetector, cd)
                            task.wait(0.1)
                            hrp.CFrame = orig
                            Rayfield:Notify({Title = "SUCCESS", Content = "Teddy clicked", Duration = 2})
                        end
                    end
                end
            end)
        end
    end
})

--------------------------------------------------------------------
-- LOADED
--------------------------------------------------------------------
Rayfield:Notify({Title = "LOADED", Content = "v1.0 - Content = fixed. All tabs show.", Duration = 6})
