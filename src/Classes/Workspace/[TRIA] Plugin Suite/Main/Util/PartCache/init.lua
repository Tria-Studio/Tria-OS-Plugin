-- Created by Taveple 11/12/2022
-- Updated 08/04/2023

--[[
	This module aims to solve the issue of needing large amount of parts to be spawned in at once by pre-creating them
	and making it easier to be pulled and used when needed. I have compiled as many methods as I could think of,
	let me know if you can think of any more or find any bugs and message me on devforum. 
	
	!!
		Models are not recommended for object caching as they can contain many parts. However, I have still 
		provided support for it.
	!!
	
	
	vv All Functions vv
	
	
	- Setup -
	
	
	- This function creates a new cache of objects to be used, the main function in this module. It also returns the data key for the Cache.
		CreateCache(CacheName: string, TemplateObject: Instance, StartAmount, RegistryAmount: number, NameObjectsInNumericalOrder: boolean): table
	
	- This function will remove any cache you create using CreateCache.
		RemoveCache(CacheName: string, CacheKey: table)
	
	- This function will remove all caches created.
		CleanupAllCaches()
	
	
	- Usage - 
	
	
	- This function will get a random or specific object from the list of cached objects. If the cache is running lower than the registry amount, it will generate more objects.
		GetObject(CacheName: string): Instance
	
	- This function will cache the object that was pulled out of the cache list.
		CacheObject(CacheName: string, InstanceObject: Instance)
	
	- This function will cache all objects.
		CacheAllObjects(CacheName: string)
	
	- This function will generate more objects based on the registry amount set.
		NewRegistry(CacheName: string)
	
	- This function will remove a specific amount of random objects from the cache.
		RemoveFromCache(CacheName: string, Amount: number)
]]

----------------
--- Services ---
----------------

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-----------------
--- Constants ---
-----------------

-- Forced error message if anything goes wrong.
local ErrorMessage = "Unable to perform task with cache."

-- Moves the object out of render distance when object isnt in use.
local FarCFrame = CFrame.new(0,10e8,0)

-- Going above 200 is not recommended.
local GeneralCacheCap = 20_000

-- The string length if you choose to have objects be a random ID.
local LengthOfRandomID = 6

-- The name of the folder in which the other modules get parented to.
local MainCacheFolderName = "ObjectCaches"

-- You can change this to whatever you want, I like to put objects to ignore in terrain.
local CacheFolderParentLocation = workspace.Terrain

-- If you want to add more to this module, you can add more template types with this.
local TemplateTypeAllowList = {
	"Part",
	"MeshPart",
	"Model",
}

--------------------
--- Module Setup ---
--------------------

local Handler, Cache = {}, {}
Cache.__index = Cache

-- Handler functions is what other scripts will be able to access.
Handler.Caches = {}

local MainCacheFolder

-- Create the cache, I used a table for the info to avoid repeating variables.
function Cache.new(...)
	local Data = {...}
	return setmetatable({
		CacheName = Data[1],
		TemplateObject = Data[2],
		CacheFolder = Data[3],
		RegistryAmount = Data[4] or 10,
		NameObjectsInNumericalOrder = Data[5],
		TotalCacheSize = 0,
		Objects = {},
	}, Cache)
end

---------------
--- Methods ---
---------------

-- Generates a random ID, used for naming objects.
local function GenerateID(Length: number): string -- Generates random ID
	local ID = HttpService:GenerateGUID(false)
	return ID:sub(1, Length)
end

-- Creates a cache folder.
local function CreateCacheFolder(NewFolderName: string, RecursiveCall: boolean): Instance
	local CacheFolder

	if not MainCacheFolder and not RecursiveCall then -- Creates the main folder
		MainCacheFolder = CreateCacheFolder(MainCacheFolderName, true)
	end

	CacheFolder = Instance.new("Folder")
	CacheFolder.Name = NewFolderName
	CacheFolder.Parent = (RecursiveCall and CacheFolderParentLocation) or MainCacheFolder
	
	return CacheFolder
end

-- Gets the objects in the table for the specific CacheType.
function Handler:GetObjects(CacheName: string, CacheType: string): table
	local CacheKey = Handler.Caches[CacheName]
	local FoundObjects = {}
	
	for InstanceObject, CacheState in pairs(CacheKey.Objects) do
		-- Looks for all objects that are Cached with a true value as well as Removed with a false value.
		if (CacheType == "Cached" and CacheState) or (CacheType == "Removed" and not CacheState) then
			table.insert(FoundObjects, InstanceObject)
		end
	end
	
	return FoundObjects
end

-- Fills the cache.
function Cache:FillCache(Amount: number)
	if typeof(Amount) ~= "number" then 
		warn("Fill amount is not a number!")
		return 
	end
	
	for i = 1, Amount do
		if self.TotalCacheSize + 1 >= GeneralCacheCap then 
			warn("Reached maximum object cache amount for  " .. self.CacheName .. "  at  " .. GeneralCacheCap .. " objects!")
			return 
		end
		
		self.TotalCacheSize += 1
		
		local NewInstanceName = (self.NameObjectsInNumericalOrder and self.TotalCacheSize) or GenerateID(LengthOfRandomID)
	
		local InstanceClone = self.TemplateObject:Clone()
		InstanceClone.Name = "Object_" .. NewInstanceName
		InstanceClone.Parent = self.CacheFolder
		
		Handler:CacheObject(self.CacheName, InstanceClone)
		
		-- This will prevent lag from spawning parts too quickly.
		if (i % Amount == 0) then
			RunService.Heartbeat:Wait()
		end
		
	end
end

-- Fills cache with the registry amount.
function Handler:NewRegistry(CacheName: string)
	local CacheKey = Handler.Caches[CacheName]
	assert(CacheKey, ErrorMessage)

	CacheKey:FillCache(CacheKey.RegistryAmount)
end

-- Removes a number of objects from the cache.
function Handler:RemoveFromCache(CacheName: string, Amount: number, Cleanup: boolean)
	local CacheKey = Handler.Caches[CacheName]
	assert(CacheKey or Amount, ErrorMessage)
	
	local CachedObjects = Handler:GetObjects(CacheName, "Cached")
	
	for i = 1, ((Cleanup and #CachedObjects) or Amount) do
		local LastNumber = #CachedObjects
		local InstanceObject = CachedObjects[#CachedObjects]
		
		InstanceObject:Destroy()
		CacheKey.Objects[InstanceObject] = nil
		
		CacheKey.TotalCacheSize -= 1
	end
end

-- Gets an object from the cache.
function Handler:GetObject(CacheName: string): Instance
    if not Handler.Caches[CacheName] then
        Handler:CreateCache("ZiplineCache", script.PartTemplate, 100, 50, false)
    end
	
	local CacheKey = Handler.Caches[CacheName]
	assert(CacheKey, ErrorMessage)
	
	local CachedObjects = Handler:GetObjects(CacheName, "Cached")
	local InstanceObject = CachedObjects[1]
	print(Handler.Caches[CacheName].TotalCacheSize)
	
	if #CachedObjects <= CacheKey.RegistryAmount then 
		Handler:NewRegistry(CacheName)
	end
	
	if not InstanceObject then 
		warn("Unable to find instance object!")
		return 
	end
	
	CacheKey.Objects[InstanceObject] = false
	
	return InstanceObject
end

-- Caches a specific object in use.
function Handler:CacheObject(CacheName: string, InstanceObject: Instance)
	local CacheKey = Handler.Caches[CacheName]
	assert(CacheKey or InstanceObject, ErrorMessage)
	
	CacheKey.Objects[InstanceObject] = true
	
	-- Double check to prevent errors.
	if InstanceObject:IsA("Part") or InstanceObject:IsA("MeshPart") then
		InstanceObject.Anchored = true
		InstanceObject.CFrame = FarCFrame
		
	elseif InstanceObject:IsA("Model") and InstanceObject.PrimaryPart ~= nil then
		InstanceObject.PrimaryPart.Anchored = true
		InstanceObject:PivotTo(FarCFrame)
	end
end

-- Caches all objects being used.
function Handler:CacheAllObjects(CacheName: string)
	local CacheKey = Handler.Caches[CacheName]
	assert(CacheKey, ErrorMessage)
	
	local RemovedObjects = Handler:GetObjects(CacheName, "Removed")
	
	for i = #RemovedObjects, 1, -1 do
		local InstanceObject = RemovedObjects[i]
		Handler:CacheObject(CacheName, InstanceObject)
	end
end

-- Creates a new cache.
function Handler:CreateCache(CacheName: string, TemplateObject: Instance, StartAmount, RegistryAmount: number, NameObjectsInNumericalOrder: boolean): table
	if not CacheName or not TemplateObject then error("Unable to create cache for: " .. CacheName) end
	if Handler.Caches[CacheName] then warn("Cache already in use for name: " .. CacheName) return end

	if not table.find(TemplateTypeAllowList, TemplateObject.ClassName) then
		error("Invalid template object for cache.")
	end

	local CacheFolder = CreateCacheFolder(CacheName)

	local CacheKey = Cache.new(CacheName, TemplateObject, CacheFolder, RegistryAmount, NameObjectsInNumericalOrder)
	Handler.Caches[CacheName] = CacheKey
	
	CacheKey:FillCache(StartAmount)
	
	return CacheKey
end

-- Removes a cache when you are done with it.
function Handler:RemoveCache(CacheName: string, CacheKey: table)
	CacheKey = CacheKey or Handler.Caches[CacheName]
	CacheName = CacheName or CacheKey.CacheName
	assert(CacheKey, ErrorMessage)

	local CacheFolder = CacheKey.CacheFolder
	
	Handler:RemoveFromCache(CacheName, 0, true)

	if CacheFolder then
		CacheFolder:Destroy()
	end

	setmetatable(CacheKey, nil)

	Handler.Caches[CacheName] = nil
end

-- Cleans up all created caches.
function Handler:CleanupAllCaches()
	for CacheName, Key in pairs(self.Caches) do
		self:RemoveCache(CacheName, Key)
	end
end


return Handler
