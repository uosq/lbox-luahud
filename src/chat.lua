local chat = {}
local messages = {}

--- goes from priority 1 to 10
local priorities = {
	[-1] = "friend", -- -1 (friend)
	--- gap here lol
	[1] = "1", --- 1
	[2] = "2", --- 2
	[3] = "3", --- 3
	[4] = "4", --- 4
	[5] = "5", --- 5
	[6] = "6", --- 6
	[7] = "noob", --- 7
	[8] = "closet", --- 8
	[9] = "bot", --- 9
	[10] = "cheater", --- 10
}

---@param msg UserMessage
function chat.DispatchUserMessage(msg)
	if msg:GetID() == E_UserMessage.SayText2 then
		local bf = msg:GetBitBuffer()
		bf:SetCurBit(8)

		local chatType = bf:ReadString(256)
		chatType = string.sub(chatType, 2) -- skip a useless character
		local playerName = bf:ReadString(256)
		local message = bf:ReadString(256)

		local current_tick = globals.TickCount()
		local hud_saytext_time = client.GetConVar("hud_saytext_time")

		local players = entities.FindByClass("CTFPlayer")
		for _, player in pairs(players) do
			if player:GetName() == playerName then
				messages[#messages + 1] = {
					player = player,
					message = message,
					tick_to_disappear = current_tick + (hud_saytext_time * 66),
					type = chatType,
				}
			end
		end
	end
end

local function CleanChatMessages()
	local current_tick = globals.TickCount()
	local new_messages = {}

	for i = 1, #messages do
		local msg = messages[i]
		if msg.tick_to_disappear > current_tick then
			new_messages[#new_messages + 1] = msg
		end
	end

	messages = new_messages
end

---@param wInfo WindowInfo
---@param utils Utils
local function DrawChatWindow(wInfo, utils)
	draw.Color(76, 86, 106, 200)
	draw.FilledRect(wInfo.x, wInfo.y - 25, wInfo.x + wInfo.width, wInfo.y)

	local chat_name = "chat"
	local text_w, text_h = draw.GetTextSize(chat_name)
	utils.DrawText(nil, wInfo.x + (wInfo.width // 2) - (text_w // 2), wInfo.y - (25 // 2) - (text_h // 2), chat_name)

	draw.Color(67, 76, 94, 200)
	draw.FilledRect(wInfo.x, wInfo.y, wInfo.x + wInfo.width, wInfo.y + wInfo.height)

	wInfo.x = wInfo.x + 3
	wInfo.y = wInfo.y + 3
	wInfo.width = wInfo.width - 6
	wInfo.height = wInfo.height - 6

	draw.Color(46, 52, 64, 200)
	draw.FilledRect(wInfo.x, wInfo.y, wInfo.x + wInfo.width, wInfo.y + wInfo.height)
end

---@param wInfo WindowInfo
---@param utils Utils
local function DrawChatMessages(wInfo, utils)
	local start_y = wInfo.y + 3

	for _, msg in pairs(messages) do
		local color = nil

		if msg.player:GetTeamNumber() == 3 then
			color = "#88c0d0"
		else
			color = "#bf616a"
		end

		--- piss color: #ebcb8b
		if playerlist.GetPriority(msg.player) > 0 then
			local full_msg = string.format(
				"[{#ebcb8b}%s{#e5e9f0}]{%s}%s{#e5e9f0}: %s",
				priorities[playerlist.GetPriority(msg.player)],
				color,
				msg.player:GetName(),
				msg.message
			)
			local height_used = utils.DrawColoredText(wInfo.x + 3, start_y, full_msg, wInfo.width - 6, true)
			start_y = start_y + height_used + 2
		elseif playerlist.GetPriority(msg.player) == -1 then
			local full_msg = string.format(
				"[{#a3be8c}%s{#e5e9f0}]{%s}%s{#e5e9f0}: %s",
				priorities[-1],
				color,
				msg.player:GetName(),
				msg.message
			)
			local height_used = utils.DrawColoredText(wInfo.x + 3, start_y, full_msg, wInfo.width - 6, true)
			start_y = start_y + height_used + 2
		else
			local full_msg = string.format("{%s}%s{#e5e9f0}: %s", color, msg.player:GetName(), msg.message)
			local height_used = utils.DrawColoredText(wInfo.x + 3, start_y, full_msg, wInfo.width - 6, true)
			start_y = start_y + height_used + 2
		end
	end
end

---@param utils Utils
function chat:Run(utils)
	if #messages == 0 then
		return
	end

	CleanChatMessages()

	local screen_w, screen_h = draw.GetScreenSize()

	local wInfo = {}
	wInfo.width = 500
	wInfo.height = 400
	wInfo.margin = 15
	wInfo.x = screen_w - wInfo.width - wInfo.margin
	wInfo.y = (screen_h * 0.6) // 1

	DrawChatWindow(wInfo, utils)
	DrawChatMessages(wInfo, utils)
end

function chat:Unload()
	messages = nil
	chat = nil
end

return chat
