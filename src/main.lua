---@module "src.def"

local font_size = 16
local font = draw.CreateFont("TF2 BUILD", font_size, 600)

local utils = require("src.utils")
assert(utils, "Utils file could not be found! WTF")

local spectate = require("src.spectate")
assert(spectate, "Spectate file could not be found! WTF")

local chat = require("src.chat")
assert(chat, "Chat file could not be found! WTF")

local generic = require("src.classes.generic")
assert(generic, "Generic file could not be found! WTF")

local panel = require("src.panel")
assert(panel, "Info panel file could not be found! WTF")

local classes = {
	[1] = require("src.classes.scout"),
	[2] = require("src.classes.sniper"),
	[3] = require("src.classes.soldier"),
	[4] = require("src.classes.demoman"),
	[5] = require("src.classes.medic"),
	[6] = require("src.classes.heavy"),
	[7] = require("src.classes.pyro"),
	[8] = require("src.classes.spy"),
	[9] = require("src.classes.engineer"),
}

local function DrawDebugInfo()
	utils.DrawText(nil, 10, 10, "luahud - latest commit: 3d07070cb78bc5f290f64c2b6ddf76d641085021")
end

local function Draw()
	if client.GetConVar("_cl_classmenuopen") == 1 then
		if client.GetConVar("cl_drawhud") == 0 then
			client.SetConVar("cl_drawhud", 1)
		end
		return
	end

	local plocal = entities.GetLocalPlayer()
	if not plocal then
		return
	end

	local current_weapon = plocal:GetPropEntity("m_hActiveWeapon")
	if not current_weapon then
		return
	end

	if engine.IsTakingScreenshot() and client.GetConVar("cl_drawhud") == 0 then
		client.SetConVar("cl_drawhud", 1)
		return
	elseif engine.IsTakingScreenshot() then
		return
	end

	if engine.IsChatOpen() and client.GetConVar("cl_drawhud") == 0 then
		client.SetConVar("cl_drawhud", 1)
		return
	elseif engine.IsChatOpen() then
		return
	end

	if engine.IsGameUIVisible() and client.GetConVar("cl_drawhud") == 0 then
		client.SetConVar("cl_drawhud", 1)
		return
	elseif engine.IsGameUIVisible() then
		return
	end

	if gamerules.GetRoundState() == E_RoundState.ROUND_GAMEOVER and client.GetConVar("cl_drawhud") == 0 then
		client.SetConVar("cl_drawhud", 1)
		return
	elseif gamerules.GetRoundState() == E_RoundState.ROUND_GAMEOVER then
		return
	end

	if client.GetConVar("cl_drawhud") == 1 then
		client.SetConVar("cl_drawhud", 0)
	end

	--- somehow Lua is complaining that i am comparing a string to be less  or equal to 0
	--- wtf
	if gui.GetValue("crit hack") ~= 0 and gui.GetValue("crit hack indicator size") > 0 then
		gui.SetValue("crit hack indicator size", 0)
	end

	draw.SetFont(font)

	local screen_w, screen_h = draw.GetScreenSize()
	local center_x, center_y = screen_w // 2, screen_h // 2

	---@type Info
	local info = {
		start_y = center_y + 20,
		center_x = center_x,
		center_y = center_y,
		screen_w = screen_w,
		screen_h = screen_h,
		font_size = font_size,
	}

	chat:Run(utils)

	--- we are dead and spectate did the job
	--- no need to continue
	if spectate:Run(plocal, info, utils) then
		return
	end

	local m_iClass = plocal:GetPropInt("m_iClass")

	--- Handles health and ammo
	generic:Run(plocal, current_weapon, info, utils)
	panel:Run(info, utils)

	DrawDebugInfo()

	if classes[m_iClass] then
		classes[m_iClass]:Run(plocal, current_weapon, info, utils)
	end

	utils:DrawCrosshair(current_weapon, center_x, center_y)
end

local function Unload()
	callbacks.Unregister("Draw", "LuaHud Draw")

	callbacks.Unregister("SendNetMsg", "LuaHud Chat Message")
	chat:Unload()

	classes = nil
end

callbacks.Register("Draw", "LuaHud Draw", Draw)
callbacks.Register("DispatchUserMessage", "LuaHud Chat Message", chat.DispatchUserMessage)
callbacks.Register("Unload", Unload)
