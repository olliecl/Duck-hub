-- Duck Hub Core Configuration
local GITHUB_USER = "olliecl" 
local REPO_NAME = "Duck-hub"
local BRANCH = "refs/heads/main"
local WHITELIST_FILE = "whitelisted.txt"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-------------------------------------------------------------------------------
-- 1. WHITELIST & DEVELOPER BYPASS SYSTEM
-------------------------------------------------------------------------------
local DeveloperList = {
    ["rggc_holder"] = true, 
    ["xepol1te"] = true, 
    ["o_lliecl"] = true
}

local function CheckWhitelist()
    local usernameStr = string.lower(LocalPlayer.Name)
    
    -- 1. Check if user is a Developer (Instant Local Bypass)
    if DeveloperList[usernameStr] then
        print("Duck Hub: Developer bypass active! Welcome back, " .. LocalPlayer.Name)
        return true
    end
    
    -- 2. Regular User GitHub Whitelist Check (Using whitelisted.txt)
    local whitelistUrl = string.format("https://githubusercontent.com", GITHUB_USER, REPO_NAME, BRANCH, WHITELIST_FILE)
    local success, content = pcall(function()
        return game:HttpGet(whitelistUrl)
    end)
    
    if success then
        local userIdStr = tostring(LocalPlayer.UserId)
        
        for line in string.gmatch(content, "[^\r\n]+") do
            local cleanLine = string.gsub(line, "%s+", "")
            local cleanLineLower = string.lower(cleanLine)
            
            if cleanLine == userIdStr or cleanLineLower == usernameStr then
                return true
            end
        end
    end
    return false
end

if not CheckWhitelist() then
    LocalPlayer:Kick("Duck Hub: You are not whitelisted to access this script.")
    return
end

-------------------------------------------------------------------------------
-- 2. EXTERNAL UI LIBRARY INITIALIZATION (Fluent)
-------------------------------------------------------------------------------
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Create the main window frame
local Window = Fluent:CreateWindow({
    Title = "Duck Hub 🦆",
    SubTitle = "by olliecl & team",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 420),
    Acrylic = true, -- Blur effect background
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Hides/shows UI when Left Control is pressed
})

-- Check if current game map is supported on your GitHub
local checkGameUrl = string.format("https://githubusercontent.com", GITHUB_USER, REPO_NAME, BRANCH, tostring(PlaceId))
local gameCheckSuccess, _ = pcall(function() return game:HttpGet(checkGameUrl) end)
local gameSupportedText = gameCheckSuccess and "✅ Supported" or "❌ Not Supported"

-------------------------------------------------------------------------------
-- TAB 1: HOME TAB
-------------------------------------------------------------------------------
local Tabs = {
    Home = Window:AddTab({ Title = "Home Base", Icon = "home" }),
    Trusted = Window:AddTab({ Title = "Trusted Scripts", Icon = "star" }),
    GameModules = Window:AddTab({ Title = "Game Modules", Icon = "gamepad" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Populate Home Profile Data
Tabs.Home:AddParagraph({
    Title = "Welcome to Duck Hub Profile Mapping",
    Content = "User: " .. LocalPlayer.Name .. "\nPlace ID: " .. tostring(PlaceId) .. "\nGame Status: " .. gameSupportedText
})

Tabs.Home:AddParagraph({
    Title = "Credits",
    Content = "Developed exclusively by and for: ollie"
})

-------------------------------------------------------------------------------
-- TAB 2: TRUSTED SCRIPTS TAB
-------------------------------------------------------------------------------
Tabs.Trusted:AddButton({
    Title = "Loads Nothing",
    Description = "Just a placeholder",
    Callback = function()
        loadstring(game:HttpGet("https://githubusercontent.com"))()
    end
})

-------------------------------------------------------------------------------
-- TAB 3: GAME SPECIFIC MODULES TAB
-------------------------------------------------------------------------------
if gameCheckSuccess then
    Tabs.GameModules:AddParagraph({
        Title = "Game Detected",
        Content = "Executing custom game modules from your repository folder branch..."
    })
    -- Execute your game file script. It runs automatically in this window environment.
    pcall(function()
        loadstring(game:HttpGet(checkGameUrl))()
    end)
else
    Tabs.GameModules:AddParagraph({
        Title = "Environment Unsupported",
        Content = "This game does not have an active profile setup within your GitHub 'games/' folder framework."
    })
end

-------------------------------------------------------------------------------
-- TAB 4: DEVELOPER MANAGEMENT MATRIX (Only visible to developers)
-------------------------------------------------------------------------------
if DeveloperList[string.lower(LocalPlayer.Name)] then
    Tabs.Developer = Window:AddTab({ Title = "Dev Matrix", Icon = "shield" })
    
    Tabs.Developer:AddParagraph({
        Title = "Developer Mode Active",
        Content = "Access granted to admin execution tools."
    })
    
    Tabs.Developer:AddButton({
        Title = "Disconnect Client Instance",
        Description = "Gracefully triggers an administrative self-kick action.",
        Callback = function()
            LocalPlayer:Kick("Developer console shutdown executed.")
        end
    })
end

-------------------------------------------------------------------------------
-- TAB 5: THEMES & SETTINGS TAB
-------------------------------------------------------------------------------
local Options = Fluent.Options

local ThemeDropdown = Tabs.Settings:AddDropdown("ThemeDropdown", {
    Title = "Interface Theme Profile",
    Description = "Switch between built-in layout framework styles.",
    Values = {"Dark", "Light", "Amethyst", "Aqua"},
    CurrentValue = "Dark",
    Callback = function(Value)
        Window:SetTheme(Value)
    end
})

-- Automatically load the home page first on startup
Window:SelectTab(1)

Fluent:Notify({
    Title = "Duck Hub",
    Content = "The system layout initialized successfully!",
    Duration = 5
})
