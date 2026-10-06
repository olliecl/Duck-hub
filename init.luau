
-- Duck Hub Core Configuration
local GITHUB_USER = "olliecl" 
local REPO_NAME = "Duck-hub"
local BRANCH = "refs/heads/main"
local WHITELIST_FILE = "whitelisted.txt" -- Updated to match your exact file name

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

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
            -- Clean up trailing spaces or hidden characters from GitHub file formatting
            local cleanLine = string.gsub(line, "%s+", "")
            local cleanLineLower = string.lower(cleanLine)
            
            -- Checks if the line matches UserID OR Username
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


local CurrentPlaceId = game.PlaceId
local IsGameSupported = false
local GameScriptSource = nil

-- Attempt to pull down a script dedicated to this exact Game ID
local checkSuccess, checkResponse = pcall(function()
    return game:HttpGet(RAW_BASE_URL .. "games/" .. tostring(CurrentPlaceId) .. ".luau")
end)

if checkSuccess and checkResponse and not string.find(checkResponse, "404: Not Found") then
    IsGameSupported = true
    GameScriptSource = checkResponse
end

local DuckHubUI = {}
DuckHubUI.__index = DuckHubUI

local function create(className, properties)
    local instance = Instance.new(className)
    for prop, val in pairs(properties) do
        instance[prop] = val
    end
    return instance
end

function DuckHubUI.InitWindow()
    local self = setmetatable({}, DuckHubUI)
    
    -- Main Container Gui
    self.ScreenGui = create("ScreenGui", {
        Name = "DuckHub_CoreUI",
        Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui"),
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })
    
    -- Main Layout Frame
    self.MainFrame = create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 650, 0, 420),
        Position = UDim2.new(0.5, -325, 0.5, -210),
        BackgroundColor3 = Color3.fromRGB(24, 24, 28),
        BorderSizePixel = 0,
        Active = true,
        Parent = self.ScreenGui
    })
    
    create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.MainFrame })
    create("UIStroke", { Color = Color3.fromRGB(45, 45, 52), Thickness = 1, Parent = self.MainFrame })
    
    -- Smooth Dragging System Configuration
    local dragging, dragInput, dragStart, startPos
    self.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    self.MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    self.Sidebar = create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 70, 1, 0),
        BackgroundColor3 = Color3.fromRGB(18, 18, 22),
        BorderSizePixel = 0,
        Parent = self.MainFrame
    })
    create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.Sidebar })
    
    create("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Color3.fromRGB(35, 35, 40),
        BorderSizePixel = 0,
        Parent = self.Sidebar
    })
    
    self.SidebarLayout = create("UIListLayout", {
        Parent = self.Sidebar,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center
    })
    
    self.PageContainer = create("Frame", {
        Name = "PageContainer",
        Size = UDim2.new(1, -85, 1, -20),
        Position = UDim2.new(0, 80, 0, 10),
        BackgroundTransparency = 1,
        Parent = self.MainFrame
    })
    
    self.Pages = {}
    self.ActivePage = nil
 
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
            self.MainFrame.Visible = not self.MainFrame.Visible
        end
    end)
    
    return self
end

function DuckHubUI:CreatePage(name, buttonText)
    local pageFrame = create("ScrollingFrame", {
        Name = name .. "_Page",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(240, 180, 20),
        Visible = false,
        Parent = self.PageContainer
    })
    
    local layout = create("UIListLayout", {
        Parent = pageFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pageFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    local navButton = create("TextButton", {
        Name = name .. "_Nav",
        Size = UDim2.new(0, 48, 0, 48),
        BackgroundColor3 = Color3.fromRGB(30, 30, 36),
        Text = buttonText or name:sub(1,2),
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.SourceSansBold,
        TextSize = 14,
        Parent = self.Sidebar
    })
    create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = navButton })
    
    navButton.MouseButton1Click:Connect(function()
        self:SelectPage(name)
    end)
    
    self.Pages[name] = { Frame = pageFrame, NavButton = navButton }
    
    if not self.ActivePage then
        self:SelectPage(name)
    end
    
    return pageFrame
end

function DuckHubUI:SelectPage(name)
    for pageName, target in pairs(self.Pages) do
        if pageName == name then
            target.Frame.Visible = true
            target.NavButton.BackgroundColor3 = Color3.fromRGB(240, 180, 20) -- Yellow Duck Theme
            target.NavButton.TextColor3 = Color3.fromRGB(20, 20, 20)
            self.ActivePage = name
        else
            target.Frame.Visible = false
            target.NavButton.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
            target.NavButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
end

function DuckHubUI.CreateHeader(parent, title, desc)
    local headerFrame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = parent
    })
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20,
        Font = Enum.Font.SourceSansBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = headerFrame
    })
    if desc then
        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, 22),
            BackgroundTransparency = 1,
            Text = desc,
            TextColor3 = Color3.fromRGB(150, 150, 160),
            TextSize = 13,
            Font = Enum.Font.SourceSansItalic,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = headerFrame
        })
    end
end

function DuckHubUI.AddButton(parent, labelText, callback)
    local btn = create("TextButton", {
        Size = UDim2.new(1, -10, 0, 38),
        BackgroundColor3 = Color3.fromRGB(35, 35, 42),
        Text = "   " .. labelText,
        TextColor3 = Color3.fromRGB(235, 235, 240),
        Font = Enum.Font.SourceSans,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = parent
    })
    create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = btn })
    
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
end

function DuckHubUI.AddToggle(parent, labelText, defaultState, callback)
    local toggleFrame = create("Frame", {
        Size = UDim2.new(1, -10, 0, 38),
        BackgroundColor3 = Color3.fromRGB(35, 35, 42),
        Parent = parent
    })
    create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = toggleFrame })
    
    create("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = labelText,
        TextColor3 = Color3.fromRGB(235, 235, 240),
        Font = Enum.Font.SourceSans,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toggleFrame
    })
    
    local state = defaultState or false
    local indicator = create("TextButton", {
        Size = UDim2.new(0, 40, 0, 22),
        Position = UDim2.new(1, -52, 0.5, -11),
        BackgroundColor3 = state and Color3.fromRGB(240, 180, 20) or Color3.fromRGB(60, 60, 68),
        Text = state and "ON" or "OFF",
        TextColor3 = state and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(180, 180, 180),
        Font = Enum.Font.SourceSansBold,
        TextSize = 12,
        Parent = toggleFrame
    })
    create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = indicator })
    
    indicator.MouseButton1Click:Connect(function()
        state = not state
        indicator.BackgroundColor3 = state and Color3.fromRGB(240, 180, 20) or Color3.fromRGB(60, 60, 68)
        indicator.Text = state and "ON" or "OFF"
        indicator.TextColor3 = state and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(180, 180, 180)
        pcall(callback, state)
    end)
end

function DuckHubUI.AddDropdown(parent, labelText, itemsList, callback)
    local dropFrame = create("Frame", {
        Size = UDim2.new(1, -10, 0, 38),
        BackgroundColor3 = Color3.fromRGB(35, 35, 42),
        ClipsDescendants = false,
        Parent = parent
    })
    create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = dropFrame })
    
    local titleLbl = create("TextLabel", {
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = labelText,
        TextColor3 = Color3.fromRGB(235, 235, 240),
        Font = Enum.Font.SourceSans,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropFrame
    })
    
    local triggerBtn = create("TextButton", {
        Size = UDim2.new(0, 130, 0, 26),
        Position = UDim2.new(1, -142, 0.5, -13),
        BackgroundColor3 = Color3.fromRGB(50, 50, 58),
        Text = itemsList[1] or "Select...",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.SourceSans,
        TextSize = 13,
        Parent = dropFrame
    })
    create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = triggerBtn })
    
    local itemsContainer = create("Frame", {
        Size = UDim2.new(1, 0, 0, #itemsList * 25),
        Position = UDim2.new(0, 0, 1, 2),
        BackgroundColor3 = Color3.fromRGB(30, 30, 36),
        Visible = false,
        ZIndex = 10,
        Parent = triggerBtn
    })
    create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = itemsContainer })
    create("UIListLayout", { Parent = itemsContainer, SortOrder = Enum.SortOrder.LayoutOrder })
    
    triggerBtn.MouseButton1Click:Connect(function()
        itemsContainer.Visible = not itemsContainer.Visible
    end)
    
    for idx, itemValue in ipairs(itemsList) do
        local entry = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 25),
            BackgroundTransparency = 1,
            Text = tostring(itemValue),
            TextColor3 = Color3.fromRGB(200, 200, 200),
            Font = Enum.Font.SourceSans,
            TextSize = 13,
            ZIndex = 11,
            Parent = itemsContainer
        })
        entry.MouseButton1Click:Connect(function()
            triggerBtn.Text = tostring(itemValue)
            itemsContainer.Visible = false
            pcall(callback, itemValue)
        end)
    end
end

local UI = DuckHubUI.InitWindow()

local HomePage = UI:CreatePage("Home", "🏠")
DuckHubUI.CreateHeader(HomePage, "Duck Hub Home Base 🦆", "Universal setup status profile mapping")

local statusString = IsGameSupported and "🟢 Supported Map" or "🔴 Game Map Not Supported"
local infoBox = create("Frame", {
    Size = UDim2.new(1, -10, 0, 140),
    BackgroundColor3 = Color3.fromRGB(30, 30, 36),
    Parent = HomePage
})
create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = infoBox })

local infoText = create("TextLabel", {
    Size = UDim2.new(1, -20, 1, -20),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1,
    Text = string.format(
        "Welcome back, %s!\n\n• Hub Status: %s\n• Active System Version: %s\n• Game Tracker Inventory: %s Loaded Profiles\n• Framework Keybind: [H] Hide Menu Panel",
        LocalPlayer.Name, statusString, DUCK_HUB_VERSION, tostring(SUPPORTED_GAMES_COUNT)
    ),
    TextColor3 = Color3.fromRGB(220, 220, 230),
    TextSize = 14,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    Parent = infoBox
})

-- PAGE 2: HUB SCRIPTS ICON TAB
local HubScriptsPage = UI:CreatePage("HubScripts", "🚀")
DuckHubUI.CreateHeader(HubScriptsPage, "Trusted Scripts Library", "Instantly inject curated third-party components")

DuckHubUI.AddButton(HubScriptsPage, "Load Infinite Yield (Admin Console)", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

DuckHubUI.AddButton(HubScriptsPage, "Load Dex Explorer (V4 Suite)", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end)

-- PAGE 3: DYNAMIC GAME EXPLOITS TAB
local GameScriptsPage = UI:CreatePage("GameScripts", "🎮")
if IsGameSupported then
    DuckHubUI.CreateHeader(GameScriptsPage, "Game System Controls (" .. tostring(CurrentPlaceId) .. ")", "Custom commands specifically mapped to this framework file.")
    -- Inject the downloaded external specific Luau script module
    local loadSuccess, executionErr = pcall(function()
        -- Expecting the script to dynamically build elements onto GameScriptsPage
        -- We pass GameScriptsPage and DuckHubUI framework components as runtime context parameters
        local compiledScript = loadstring(GameScriptSource)
        compiledScript(GameScriptsPage, DuckHubUI)
    end)
    if not loadSuccess then
        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Text = "Runtime Configuration Error: " .. tostring(executionErr),
            TextColor3 = Color3.fromRGB(255, 100, 100),
            Font = Enum.Font.SourceSansBold,
            Parent = GameScriptsPage
        })
    end
else
    DuckHubUI.CreateHeader(GameScriptsPage, "Game Configuration", "Checking mapping databases...")
    local warnBox = create("TextLabel", {
        Size = UDim2.new(1, -10, 0, 80),
        BackgroundColor3 = Color3.fromRGB(42, 28, 28),
        Text = "❌ This game map is not supported by Duck Hub explicitly.\nExplore custom configuration components using the Universal fallback menu or Hub Tab.",
        TextColor3 = Color3.fromRGB(255, 180, 180),
        Font = Enum.Font.SourceSansBold,
        TextSize = 14,
        Parent = GameScriptsPage
    })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = warnBox })
end

-- PAGE 4: SYSTEM SETTINGS 
local SettingsPage = UI:CreatePage("Settings", "⚙️")
DuckHubUI.CreateHeader(SettingsPage, "Duck Hub Configuration", "Fine-tune interface controls and local options")

DuckHubUI.AddToggle(SettingsPage, "Toggle UI Panel Top Accent Bar Animation", false, function(state)
    print("Accent theme option modified to: ", state)
end)

DuckHubUI.AddDropdown(SettingsPage, "Interface Palette Layout Theme", {"Dark Charcoal 🦆", "Cyberpunk Neon", "Deep Midnight Blue"}, function(selectedTheme)
    if selectedTheme == "Dark Charcoal 🦆" then
        UI.MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    elseif selectedTheme == "Cyberpunk Neon" then
        UI.MainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
    else
        UI.MainFrame.BackgroundColor3 = Color3.fromRGB(10, 15, 30)
    end
end)

-- PAGE 5: DEVELOPER MANAGEMENT TAB (RESTRICTED ACCESS CONTROL)
if DEV_USERS[LocalPlayer.Name] then
    local DevPage = UI:CreatePage("Developer", "🛠️")
    DuckHubUI.CreateHeader(DevPage, "Duck Hub Executive Console", "Privileged environment manipulation pipeline")
    
    local targetSelection = "All Users"
    
    DuckHubUI.AddDropdown(DevPage, "Target Executive Manipulation Field", {"All Users", "Random Target Server Player"}, function(selection)
        targetSelection = selection
    end)
    
    DuckHubUI.AddButton(DevPage, "Execute Environmental Chaos: Fling Target", function()
        print("Developer Command Executed: Fling -> " .. targetSelection)
        -- Safe Abstract Example Action: local thrust body velocity modifications
        local chr = LocalPlayer.Character
        if chr and chr:FindFirstChild("HumanoidRootPart") then
            chr.HumanoidRootPart.Velocity = Vector3.new(0, 250, 0) -- Launcher preview mechanism
        end
    end)
    
    DuckHubUI.AddButton(DevPage, "Execute Environmental Chaos: Teleport Baseplate", function()
        print("Developer Command Executed: TP -> " .. targetSelection)
        local chr = LocalPlayer.Character
        if chr and chr:FindFirstChild("HumanoidRootPart") then
            chr.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
        end
    end)
    
    DuckHubUI.AddButton(DevPage, "Force Terminate Workspace (Kick Option Preview)", function()
        print("Developer Action Trace: Local System Interface Closed Safely.")
        UI.ScreenGui:Destroy()
    end)
end
