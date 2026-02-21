local function on_file_created(path)
	local rules = {
		["%.md$"] = "nvim",
		["%.py$"] = "nvim",
		["%.sh$"] = "nvim && chmod +x",
		["/$"] = "cd",
	}

	for pattern, cmd in pairs(rules) do
		if path:match(pattern) then
			if cmd == "cd" then
				ya.manager_emit("cd", { path })
			else
				ya.manager_emit("shell", { cmd .. " '" .. path .. "'", block = true })
			end
			break
		end
	end
end

-- Hook into yazi's create event
ps.sub("create", function(event)
	on_file_created(event.url:name())
end)
