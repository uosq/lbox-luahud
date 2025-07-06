local panel = {}

---@param info Info
---@param utils Utils
function panel:Run(info, utils)
	local options = {
		"aim bot",
		"backtrack",
		"anti aim",
		"nospread",
		"norecoil",
		"anti backstab",
		"thirdperson",
	}

	--- extra options not in the gui
	local extras = 2

	if gui.GetValue("fake latency") == 1 and gui.GetValue("backtrack") == 1 then
		extras = extras + 1
	end

	if gui.GetValue("fake lag") == 1 then
		extras = extras + 1
	end

	--- calculate the desired y first
	local needed_size = 0
	local counter = 0

	for i = 1, #options + extras do
		if options[i] then
			local value = gui.GetValue(options[i])
			if value == 1 then
				local _, h = draw.GetTextSize(options[i])
				needed_size = needed_size + h
				counter = counter + 1
			end
		else
			needed_size = needed_size + info.font_size
			counter = counter + 1
		end
	end

	local x = 10
	local start_y = info.screen_h - needed_size - 10
	for i = 1, #options do
		if gui.GetValue(options[i]) == 1 then
			utils.DrawText(nil, x, start_y, options[i])
			start_y = start_y + ((needed_size / counter) // 1)
		end
	end

	--[[- choked commands
	local choked_text = string.format("choked commands: %i", clientstate:GetChokedCommands())
	local tw = draw.GetTextSize(choked_text)
	utils.DrawText(nil, x, start_y, choked_text)
	start_y = start_y + info.font_size
	---]]

	--- fake latency
	local fake_latency = false
	if gui.GetValue("fake latency") == 1 and gui.GetValue("backtrack") == 1 then
		local latency_text = string.format("fake latency: %i", gui.GetValue("fake latency value (ms)"))
		utils.DrawText(nil, x, start_y, latency_text)

		start_y = start_y + info.font_size
		fake_latency = true
	end
	---

	if gui.GetValue("fake lag") == 1 then
		local lag_text = string.format(
			"fake lag: %i (Choked: %i)",
			gui.GetValue("fake lag value (ms)") + 15,
			clientstate:GetChokedCommands()
		)
		utils.DrawText(nil, x, start_y, lag_text)
		start_y = start_y + info.font_size
	end

	--- latency
	local netchan = clientstate:GetNetChannel()
	if netchan then
		local score_ping = netchan:GetLatency(E_Flows.FLOW_OUTGOING) + netchan:GetLatency(E_Flows.FLOW_INCOMING) * 1000
		local real_ping = score_ping - (fake_latency and math.min(gui.GetValue("fake latency value (ms)"), 800) or 0)

		utils.DrawText(nil, x, start_y, string.format("real ping: %.0f", real_ping))
		start_y = start_y + info.font_size

		utils.DrawText(nil, x, start_y, string.format("scoreboard ping: %.0f", score_ping))
		start_y = start_y + info.font_size
	end
	---
end

return panel
