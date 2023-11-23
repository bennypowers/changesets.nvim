local Changesets = require'changesets.changesets'

local M = {}

M.create = Changesets.make_operation('create')
M.add_package = Changesets.make_operation('add')

return M
