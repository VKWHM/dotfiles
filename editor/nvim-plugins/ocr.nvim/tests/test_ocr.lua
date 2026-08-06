-- Unit test suite for ocr.nvim running in headless Neovim

local plugin_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:append(plugin_root)
package.path = plugin_root .. "/lua/?.lua;" .. plugin_root .. "/lua/?/init.lua;" .. package.path

local orig_rtp = vim.opt.rtp:get()
local orig_path = package.path

local ocr = require("ocr")
local config = require("ocr.config")
local parser = require("ocr.parser")
local diagnostics = require("ocr.diagnostics")
local picker = require("ocr.picker")
local copier = require("ocr.copier")

local function assert_eq(actual, expected, msg)
	if actual ~= expected then
		error(string.format("ASSERTION FAILED: %s (Expected %s, got %s)", msg or "", vim.inspect(expected), vim.inspect(actual)))
	end
end

print("=== Running ocr.nvim unit tests ===")

-- Test 1: Setup configuration & modular structure
ocr.setup({ height_ratio = 0.25, diagnostic_namespace = "ocr_test_ns" })
assert_eq(config.options.height_ratio, 0.25, "Setup should set custom height_ratio")

-- Test 2: Parse session list output
local raw_session_list = [[
SESSION ID                            MODE       RANGE  FILES          COMMENTS  STATUS    STARTED
d06f8c5f-e586-4644-b24c-e4c45c1c4839  workspace  -      30 (failed 1)  8         partial   2026-08-06 18:27:44
cbe0e63c-4790-4dd6-9e74-77e98abba4b6  workspace  -      30             16        complete  2026-08-06 18:18:23
]]

local parsed_sessions = picker.parse_session_list(raw_session_list)
assert_eq(#parsed_sessions, 2, "Should parse 2 sessions")
assert_eq(parsed_sessions[1].id, "d06f8c5f-e586-4644-b24c-e4c45c1c4839", "Session ID match")
assert_eq(parsed_sessions[1].status, "partial", "Session status match")

-- Test 3: Security & Path Traversal Rejection
local bad_path_json = [[
[
  {
    "path": "../../../etc/passwd",
    "content": "Malicious path traversal attempt",
    "start_line": 1
  },
  {
    "path": "/dev/zero",
    "content": "Infinite device file attempt",
    "start_line": 1
  }
]
]]
local bad_parsed = parser.parse(bad_path_json)
assert_eq(next(bad_parsed), nil, "Path traversal & device files should be rejected")

-- Test 4: Parse valid file & existing_code line matching
local rel_test_file = "editor/nvim-plugins/ocr.nvim/plugin/ocr.lua"
local cwd = vim.fn.getcwd()
local target_key = rel_test_file

local json_input = string.format([[
[
  {
    "path": "%s",
    "content": "Opts args forwarded verbatim.",
    "existing_code": "vim.api.nvim_create_user_command('OCRReview'",
    "start_line": 1,
    "category": "bug",
    "severity": "high"
  },
  {
    "path": "%s",
    "content": "Deleted code test.",
    "existing_code": "this_code_does_not_exist_anywhere_in_file()",
    "start_line": 5,
    "category": "bug",
    "severity": "low"
  }
]
]], rel_test_file, rel_test_file)

local parsed_diags = parser.parse(json_input)
diagnostics.apply(parsed_diags)

local found_key = nil
for k, _ in pairs(diagnostics.active_diagnostics) do
	if k:find("ocr.lua") then
		found_key = k
		break
	end
end

assert_eq(found_key ~= nil, true, "Should find active diagnostics key for ocr.lua")
local file_diags = diagnostics.active_diagnostics[found_key]
assert_eq(#file_diags, 1, "Should keep 1 matching comment and skip 1 unmatched comment")

-- Test 5: Structured comments formatting for clipboard copying
local structured = copier.format_structured_comments(file_diags)
local has_header = string.find(structured, "# OCR Review Comments") ~= nil
assert_eq(has_header, true, "Structured comments must contain Markdown header")
assert_eq(string.find(structured, "ocr.lua") ~= nil, true, "Structured comments must contain file path")

-- Test 6: Selective clear modes & invalid mode validation
diagnostics.clear("line")
assert_eq(#(diagnostics.active_diagnostics[found_key] or {}), 1, "Line clear on line 1 without cursor on line 1 leaves comment")

diagnostics.clear("all")
assert_eq(next(diagnostics.active_diagnostics), nil, "Clear all should wipe active_diagnostics")

-- Teardown
package.path = orig_path
vim.opt.rtp = orig_rtp

print("=== ALL OCR.NVIM TESTS PASSED SUCCESSFULLY ===")
