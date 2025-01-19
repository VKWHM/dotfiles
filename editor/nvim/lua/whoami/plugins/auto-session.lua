return {
    'rmagatti/auto-session',
    config = function()
        local auto_session = require('auto-session')

        auto_session.setup({
            auto_restore = false,
            suppressed_dirs = {
                '~/Downloads', '~/',
                '~/Desktop', '~/Documents',
                '~/Downloads/Github',
            },
            cwd_change_handling = true,
            pre_cwd_changed_cmds = {
                'tabdo NERDTreeClose', -- Close NERDTree before saving session
            },
            post_cwd_changed_cmds = {
                function()
                    local status, message = pcall(require, 'lualine')
                    if status then
                        require('lualine').refresh()
                    end
                end,
                function()
                    local status, message = pcall(require, 'nvim-tree.api')
                    if status then
                        local nvim_tree_api = require('nvim-tree.api')
                        nvim_tree_api.tree.open()
                        nvim_tree_api.tree.change_root(vim.fn.getcwd())
                        nvim_tree_api.tree.reload()
                    end
                end,
            },
            bypass_save_filetypes = {'alpha'},
        })
        
        local keymap = vim.keymap

        keymap.set('n', '<leader>ws', '<cmd>SessionSave<CR>', { desc = 'Saves a session based on the CWD' })
        keymap.set('n', '<leader>wr', '<cmd>SessionRestore<CR>', { desc = 'Restores a session based on the CWD' })
        keymap.set('n', '<leader>wd', '<cmd>SessionDelete<CR>', { desc = 'Deletes a session based on the CWD' })
        keymap.set('n', '<leader>wt', '<cmd>SessionToggleAutoSave<CR>', { desc = 'Toggles Autosave' })
        keymap.set('n', '<leader>wf', '<cmd>SessionSearch<CR>', { desc = 'Open a session picker' })
    end,
}
