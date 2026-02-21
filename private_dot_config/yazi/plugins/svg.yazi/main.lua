local M = {}

function M:peek(job)
	local cache = ya.file_cache(job)
	if not cache then
		return
	end

	-- Convert SVG to PNG using magick
	local child = Command("magick")
		:arg(tostring(job.file.url))
		:arg("-resize")
		:arg(tostring(job.area.w * 2) .. "x" .. tostring(job.area.h * 2))
		:arg("-background")
		:arg("none")
		:arg(tostring(cache))
		:spawn()

	local status = child:wait()
	if status and status.success then
		ya.image_show(cache, job.area)
		ya.preview_widget(job, {})
	else
		ya.preview_widget(job, ui.Text("Failed to render SVG"):area(job.area))
	end
end

function M:seek(job)
end

return M
