if vim.g.loaded_ocr_review == 1 then
	return
end
vim.g.loaded_ocr_review = 1

vim.api.nvim_create_user_command('OCRReview', function(opts)
	require('ocr').review(opts.args)
end, {
	['nargs'] = '*',
	['desc'] = 'Run ocr review in horizontal terminal split and populate diagnostics',
})

vim.api.nvim_create_user_command('OCRReviewClear', function(opts)
	require('ocr').clear(opts.args)
end, {
	['nargs'] = '?',
	['complete'] = function()
		return { 'all', 'buffer', 'function', 'line' }
	end,
	['desc'] = 'Clear OCR Review diagnostics selectively (all | buffer | function | line)',
})

vim.api.nvim_create_user_command('OCRClear', function(opts)
	require('ocr').clear(opts.args)
end, {
	['nargs'] = '?',
	['complete'] = function()
		return { 'all', 'buffer', 'function', 'line' }
	end,
	['desc'] = 'Clear OCR Review diagnostics selectively (all | buffer | function | line)',
})

vim.api.nvim_create_user_command('OCRSessions', function()
	require('ocr').pick_sessions()
end, {
	['nargs'] = 0,
	['desc'] = 'Open fzf-lua picker for previous OCR review sessions',
})

vim.api.nvim_create_user_command('OCRCopy', function(opts)
	require('ocr').copy(opts.args)
end, {
	['nargs'] = '?',
	['complete'] = function()
		return { 'all', 'buffer', 'function', 'line' }
	end,
	['desc'] = 'Copy OCR review comments in structured format (all | buffer | function | line)',
})
