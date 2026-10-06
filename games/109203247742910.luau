local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = workspace:FindFirstChild("DuckHub_Core") or main_window


local GameTab = Fluent.Tabs and Fluent.Tabs.GameModules
local Section = GameTab:AddSection("Main Features")

local AS = false

GameTab:AddToggle("Auto Safezone", {
    Title = "TP's You To Safezone When Holding Egg",
    Description = "Allows you to bypass requried speed needed for any zone",
    Callback = function(Value)
        if Value then 
            AS = true 
        end 

        if not value then 
            AS = false
        end 
    end
})

game:GetService("ProximityPromptService").PromptTriggered:Connect(function(prompt)
    if AS == true then 
        local Plot = game.Workspace:FindFirstChild("Plot_" .. game.Players.LocalPlayer.Name)
        if Plot then 
            local TPSpot = Plot:FindFirstChild("Spawn")
            if TPSpot then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = TPSpot.CFrame
            end
        end
    end

    if AS == false then
        return 
    end 
end)