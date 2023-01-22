AddCSLuaFile()

Plutonic = Plutonic or {} --- Creates the Plutonic table if it doesn't exist.
Plutonic.Enum = Plutonic.Enum or {} --- Creates the Plutonic Enum table if it doesn't exist.
Plutonic.Framework = Plutonic.Framework or {} --- Creates the Plutonic Framework table if it doesn't exist.
Plutonic.Constants = Plutonic.Constants or {} --- Creates the Plutonic Constants table if it doesn't exist.
Plutonic.Interpolation = Plutonic.Interpolation or {} --- Creates the Plutonic Interpolation table if it doesn't exist.
Plutonic.Hooks = Plutonic.Hooks or {} --- Creates the Plutonic Hooks table if it doesn't exist.
Plutonic.FireRate = Plutonic.FireRate or {} --- Creates the Plutonic FireRate table if it doesn't exist.

--- Does a fancy print to the console.
-- @realm shared
-- @string text The text to print.
function Plutonic.Framework.Print(text)
	if SERVER then
		MsgC(Color(10, 120, 255), "[Plutonic] ", Color(255, 200, 0), text .. "\n")
	end
end

--- Builds our module loader.
-- @realm shared
-- @string path The path to the module.
function Plutonic.Framework.Link(path)
	Plutonic.Framework.Print("Loading " .. path .. "...")

	local files, directories = file.Find(path .. "/*", "LUA")

	for _, directory in pairs(directories) do
		Plutonic.Framework.Link(path .. "/" .. directory)
	end

	for _, file in pairs(files) do
		if string.sub(file, 1, 3) == "cl_" then
			if CLIENT then
				include(path .. "/" .. file)
			else
				AddCSLuaFile(path .. "/" .. file)
			end
		elseif string.sub(file, 1, 3) == "sv_" then
			if SERVER then
				include(path .. "/" .. file)
			end
		elseif string.sub(file, 1, 3) == "sh_" then
			include(path .. "/" .. file)

			if SERVER then
				AddCSLuaFile(path .. "/" .. file)
			end
		end
	end
end

--- Builds our module loader. But this one targets specific realms.
-- @realm shared
-- @string path The path to the module.
-- @string realm The realm to target.
function Plutonic.Framework.LinkByRealm(path, realm)

	Plutonic.Framework.Print("Loading " .. path .. "...")

	local files, directories = file.Find(path .. "/*", "LUA")

	for _, directory in pairs(directories) do
		Plutonic.Framework.LinkByRealm(path .. "/" .. directory, realm)
	end

	for _, file in pairs(files) do
		Plutonic.Framework.Print("Including " .. file .. "...")
		if realm == "CLIENT" then
			if CLIENT then
				include(path .. "/" .. file)
			else
				AddCSLuaFile(path .. "/" .. file)
			end
		elseif realm == "SERVER" then
			if SERVER then
				include(path .. "/" .. file)
			end
		elseif realm == "SHARED" then
			include(path .. "/" .. file)

			if SERVER then
				AddCSLuaFile(path .. "/" .. file)
			end
		end
	end
end

Plutonic.Framework.Link("plutonic/framework")
Plutonic.Framework.Link("plutonic/modules")