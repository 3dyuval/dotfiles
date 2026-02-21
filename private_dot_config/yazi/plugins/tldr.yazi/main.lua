local M = {}

function M:peek(job)
	local filename = tostring(job.file.name)
	local cmd_name = filename:gsub("%.md$", "")

	local child = Command("tldr")
		:arg(cmd_name)
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()

	local limit = job.area.h
	local lines = ""
	local i = 0

	repeat
		local next, event = child:read_line()
		if event ~= 0 then break end
		i = i + 1
		if i > job.skip then
			lines = lines .. next
		end
	until i >= job.skip + limit

	child:start_kill()

	if job.skip > 0 and #lines == 0 then
		ya.manager_emit("peek", { math.max(0, job.skip - limit), only_if = job.file.url, upper_bound = false })
		return
	end

	ya.preview_widget(job, ui.Text.parse(lines):area(job.area))
end

function M:seek(job)
	local h = cx.active.current.hovered
	if h and h.url == job.file.url then
		ya.manager_emit("peek", {
			math.max(0, cx.active.preview.skip + job.units),
			only_if = job.file.url,
		})
	end
end

return M
