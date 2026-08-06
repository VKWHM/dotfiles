return {
	{
		dir = "~/.whm_shell/editor/nvim-plugins/ocr.nvim",
		cmd = { "OCRReview", "OCRReviewClear", "OCRClear", "OCRSessions", "OCRCopy" },
		keys = {
			{ "<leader>ocr", "<cmd>OCRReview<cr>", desc = "Run OCR Code Review" },
			{ "<leader>ocm", "<cmd>OCRClear<cr>", desc = "Clear OCR Comments (Menu)" },
			{ "<leader>occa", "<cmd>OCRClear all<cr>", desc = "Clear All OCR Comments" },
			{ "<leader>occb", "<cmd>OCRClear buffer<cr>", desc = "Clear Buffer OCR Comments" },
			{ "<leader>occf", "<cmd>OCRClear function<cr>", desc = "Clear Function OCR Comments" },
			{ "<leader>occl", "<cmd>OCRClear line<cr>", desc = "Clear Line OCR Comment" },
			{ "<leader>ocs", "<cmd>OCRSessions<cr>", desc = "OCR Review Sessions" },
			{ "<leader>ocym", "<cmd>OCRCopy<cr>", desc = "Copy OCR Comments (Menu)" },
			{ "<leader>ocya", "<cmd>OCRCopy all<cr>", desc = "Copy All OCR Comments" },
			{ "<leader>ocyb", "<cmd>OCRCopy buffer<cr>", desc = "Copy Buffer OCR Comments" },
			{ "<leader>ocyf", "<cmd>OCRCopy function<cr>", desc = "Copy Function OCR Comments" },
			{ "<leader>ocyl", "<cmd>OCRCopy line<cr>", desc = "Copy Line OCR Comment" },
		},
		opts = {
			['height_ratio'] = 0.2,
		},
		config = function(_, opts)
			require("ocr").setup(opts)
		end,
	},
}
