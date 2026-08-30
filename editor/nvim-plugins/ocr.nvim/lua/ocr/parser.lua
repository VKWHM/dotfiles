local M = {}

---Map severity string to vim.diagnostic.severity
---@param sev_str? string
---@return integer
local function map_severity(sev_str)
	if not sev_str then
		return vim.diagnostic.severity.HINT
	end
	local s = string.lower(tostring(sev_str))
	if s == 'critical' or s == 'high' or s == 'error' then
		return vim.diagnostic.severity.ERROR
	elseif s == 'medium' or s == 'warning' or s == 'warn' then
		return vim.diagnostic.severity.WARN
	elseif s == 'low' or s == 'info' then
		return vim.diagnostic.severity.INFO
	else
		return vim.diagnostic.severity.HINT
	end
end

---Normalize line number to positive integer
---@param val any
---@param default integer
---@return integer
local function normalize_line_num(val, default)
	local num = tonumber(val)
	if not num then
		return default
	end
	return math.max(1, math.floor(num))
end

---Extract valid JSON data from text that may contain banner or CLI log prefix lines
---@param text string
---@return table|nil
local function extract_valid_json(text)
	if not text or text == '' then
		return nil
	end

	local ok, data = pcall(vim.json.decode, text)
	if ok and data and type(data) == 'table' then
		return data
	end

	local pos = 1
	while pos <= #text do
		local s = text:find('[%[%{]', pos)
		if not s then
			break
		end
		local chunk = text:sub(s)
		local chunk_ok, chunk_data = pcall(vim.json.decode, chunk)
		if chunk_ok and chunk_data and type(chunk_data) == 'table' then
			return chunk_data
		end
		pos = s + 1
	end

	return nil
end

---Find matching line number in file_lines for existing_code (constrained search)
---@param file_lines string[]
---@param start_line integer
---@param existing_code? string
---@return integer|nil
local function find_matching_line(file_lines, start_line, existing_code)
	if not existing_code or existing_code == '' or not file_lines or #file_lines == 0 then
		return start_line
	end

	local target_pattern = nil
	for raw_line in existing_code:gmatch('[^\r\n]+') do
		local trimmed = raw_line:match('^%s*(.-)%s*$')
		if trimmed and #trimmed >= 5 then
			target_pattern = trimmed
			break
		end
	end

	if not target_pattern then
		return start_line
	end

	-- 1. Check if the line at start_line matches
	if start_line >= 1 and start_line <= #file_lines then
		local current_line_text = file_lines[start_line] or ''
		if current_line_text:find(target_pattern, 1, true) then
			return start_line
		end
	end

	-- 2. Constrained window search (within +/- 30 lines of start_line)
	local window = 30
	local min_line = math.max(1, start_line - window)
	local max_line = math.min(#file_lines, start_line + window)

	for i = min_line, max_line do
		local ltext = file_lines[i] or ''
		if ltext:find(target_pattern, 1, true) then
			return i
		end
	end

	-- 3. Fallback search whole file only if target_pattern is long enough (>= 10 chars)
	if #target_pattern >= 10 then
		for i, ltext in ipairs(file_lines) do
			if ltext:find(target_pattern, 1, true) then
				return i
			end
		end
	end

	return nil
end

---Parse OCR comments JSON string into diagnostics by relative file path
---@param json_text string
---@return table<string, table[]>
function M.parse(json_text)
	if not json_text or json_text == '' then
		return {}
	end

	local data = extract_valid_json(json_text)
	if not data then
		return {}
	end

	local items = {}
	if type(data) == 'table' then
		if data[1] ~= nil then
			items = data
		elseif type(data['comments']) == 'table' then
			items = data['comments']
		elseif type(data['items']) == 'table' then
			items = data['items']
		end
	end

	local diagnostics_by_file = {}
	local cwd = vim.fn.getcwd()
	local file_lines_cache = {}

	for _, item in ipairs(items) do
		if type(item) == 'table' then
			local rel_path = item['path'] or item['file_path'] or item['file']
			if rel_path and rel_path ~= '' then
				rel_path = tostring(rel_path)

				-- Security check: reject paths traversing outside cwd or containing device files
				local is_safe = not rel_path:find('%.%.') and not rel_path:find('^/dev/') and not rel_path:find('^/proc/') and not rel_path:find('^/sys/')
				if is_safe then
					local original_line = normalize_line_num(item['start_line'] or item['line'], 1)
					local end_line = normalize_line_num(item['end_line'], original_line)
					local existing_code = item['existing_code'] and tostring(item['existing_code']) or nil

					local abs_path = rel_path
					if not vim.startswith(rel_path, '/') then
						abs_path = cwd .. '/' .. rel_path
					end
					abs_path = vim.fn.fnamemodify(abs_path, ':p')

					local file_lines = file_lines_cache[abs_path]
					if file_lines == nil then
						if vim.fn.filereadable(abs_path) == 1 then
							file_lines = vim.fn.readfile(abs_path)
						else
							file_lines = false
						end
						file_lines_cache[abs_path] = file_lines
					end

					local matched_line = find_matching_line(file_lines or nil, original_line, existing_code)

					if matched_line ~= nil then
						local line_diff = matched_line - original_line
						local final_end_line = math.max(matched_line, end_line + line_diff)

						local severity = map_severity(item['severity'])
						local category = item['category'] or item['type'] or 'review'
						category = tostring(category)
						local title = item['title'] ~= nil and tostring(item['title']) or nil
						local msg = tostring(item['content'] or item['message'] or item['description'] or 'Issue found')

						if title and title ~= '' and title ~= msg then
							msg = title .. ': ' .. msg
						end

						local suggestion = item['suggestion_code'] and tostring(item['suggestion_code']) or nil
						if suggestion and suggestion ~= '' then
							msg = msg .. '\n\nSuggested Fix:\n' .. suggestion
						end

						local diag = {
							['lnum'] = math.max(0, matched_line - 1),
							['col'] = 0,
							['end_lnum'] = math.max(0, final_end_line - 1),
							['end_col'] = 0,
							['severity'] = severity,
							['message'] = msg,
							['source'] = 'ocr review',
							['code'] = category,
							['raw_suggestion'] = suggestion,
							['raw_content'] = item['content'] or item['message'] or item['description'],
							['rel_path'] = rel_path,
							['abs_path'] = abs_path,
							['line_num'] = matched_line,
						}

						if not diagnostics_by_file[rel_path] then
							diagnostics_by_file[rel_path] = {}
						end
						table.insert(diagnostics_by_file[rel_path], diag)
					end
				end
			end
		end
	end

	return diagnostics_by_file
end

return M
