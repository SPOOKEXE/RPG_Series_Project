
warn([[
																	   
	.oooooo..o ooooooooo.     .oooooo.     .oooooo.   oooo    oooo     
	d8P'    `Y8 `888   `Y88.  d8P'  `Y8b   d8P'  `Y8b  `888   .8P'     
	Y88bo.       888   .d88' 888      888 888      888  888  d8'       
	 `"Y8888o.   888ooo88P'  888      888 888      888  88888[         
		 `"Y88b  888         888      888 888      888  888`88b.       
	oo     .d8P  888         `88b    d88' `88b    d88'  888  `88b.     
	8""88888P'  o888o         `Y8bood8P'   `Y8bood8P'  o888o  o888o    
																	   
]])

task.delay(3, warn, "Anything errors/warns is considered a bug/problem.\nPlease report it to the developers via discord!")

-- // MAIN // --
local ParentCache = {}

local function HasInitMethod(tbl)
	return tbl.Init or (getmetatable(tbl) and getmetatable(tbl).Init)
end

local function RequireModules(Parent, CacheTable)
	for _, ModuleScript in ipairs( Parent:GetChildren() ) do
		if ModuleScript:IsA('ModuleScript') then
			-- print(ModuleScript:GetFullName())
			CacheTable[ModuleScript.Name] = require(ModuleScript)
		end
	end
end

local function Initialize(Parent, preLoadedName, preLoaded, CacheTable)
	if preLoaded.Initialised or (not HasInitMethod(preLoaded)) then
		return
	end
	local accessibles = { ParentSystems = CacheTable[Parent.Parent] }
	for otherLoadedName, differentLoaded in pairs( CacheTable ) do
		if preLoadedName ~= otherLoadedName then
			accessibles[otherLoadedName] = differentLoaded
		end
	end
	preLoaded.Initialised = true
	preLoaded:Init(accessibles)
end

local function SetupConnections(Parent, CacheTable)
	Parent.ChildAdded:Connect(function( ModuleScript )
		local Module = require(ModuleScript)
		CacheTable[ModuleScript.Name] = Module
		Initialize(Parent, ModuleScript.Name, Module, CacheTable)
	end)
	Parent.ChildRemoved:Connect(function( ModuleScript )
		if CacheTable[ModuleScript.Name] then
			CacheTable[ModuleScript.Name] = nil
		end
	end)
end

return function(Parent)
	if ParentCache[Parent] then
		return ParentCache[Parent]
	end
	local Cache = {}
	RequireModules(Parent, Cache)
	for LoadedName, Loaded in pairs( Cache ) do
		Initialize(Parent, LoadedName, Loaded, Cache)
	end
	SetupConnections(Parent, Cache)
	-- print(Parent:GetFullName(), Cache)
	return Cache
end
