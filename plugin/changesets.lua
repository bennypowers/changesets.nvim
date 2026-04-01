vim.api.nvim_create_user_command('Changeset', function()
  require('changesets').create()
end, { desc = 'Create a new changeset' })

vim.api.nvim_create_user_command('ChangesetAdd', function()
  require('changesets').add_package()
end, { desc = 'Add a package to the current changeset' })
