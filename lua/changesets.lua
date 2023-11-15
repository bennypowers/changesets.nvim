local M = {}

local map = vim.tbl_map
local filter = vim.tbl_filter
local flatten = vim.tbl_flatten

---@alias Release 'patch'|'minor'|'major'
---@alias Operation 'add'|'create'


--- Concatenate directories and/or file into a single path with normalization
--- (e.g., `"foo/"` and `"bar"` get joined to `"foo/bar"`)
--- TODO: remove for >=0.10
---@param ... string
---@return string
local joinpath = vim.fs.joinpath or function(...)
  return (table.concat({ ... }, '/'):gsub('//+', '/'))
end

local function get_name(manifest)
  return manifest.name
end

local function get_workspace_paths(workspace_or_glob)
  return vim.split(vim.fn.expand(workspace_or_glob), '\n')
end

local function find_package_json_ancestors(startpath)
  startpath = vim.fs.normalize(startpath or vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
  local result = vim.fs.find('package.json', {
    upward = true,
    stop = vim.loop.os_homedir(),
    path = startpath,
  })
  return result
end

local function json_read_and_parse(path)
  local lines = vim.fn.readfile(path)
  return vim.fn.json_decode(table.concat(lines))
end

local function get_pkg_manifests(relative_path)
  local path = relative_path and joinpath(vim.fn.getcwd(), relative_path)
  local pkg_paths = find_package_json_ancestors(path)
  return map(json_read_and_parse, pkg_paths)
end

local function resolve_relative_pkg_json_path(path)
  return joinpath(vim.fn.getcwd(), path, 'package.json')
end

local function get_workspaces_manifest_paths(manifest)
  local paths = { }
  local workspace_paths = flatten(map(get_workspace_paths, manifest.workspaces or {}))
  for _, path in ipairs(map(resolve_relative_pkg_json_path, workspace_paths)) do
    table.insert(paths, path)
  end
  return paths
end

local function is_not_private(manifest)
  return not manifest.private
end

local function on_enter_name(lines)
  return function(filename)
    -- TODO: get real dir, verify
    vim.cmd('e ' .. '.changeset/' .. filename)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.api.nvim_win_set_cursor(0, { 4, 0 })
    vim.cmd'startinsert'
  end
end

---@param name string
---@param type Release
local function format(name, type)
  return '"' .. name .. '": ' .. type
end

---@param name string
---@param operation Operation
local function on_select_release(name, operation)
  ---@param type Release
  return function(type)
    if operation == 'create' then
      vim.ui.input({
        prompt = 'Enter changeset name',
        default = name .. '-' .. os.date'%y-%m-%d' .. '.md'
      }, on_enter_name({
        '---',
        format(name, type),
        '---',
        ''
      }))
    else
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
      local frontmatter_end_line = 0
      for i, line in ipairs(lines) do
        if i ~= 0 and line == '---' then
          frontmatter_end_line = i
        end
      end
      table.insert(lines, frontmatter_end_line, format(name, type))
      vim.api.nvim_buf_set_lines(0, 0, -1, true, lines)
    end
  end
end

---@param operation Operation
local function on_select_package(operation)
  return function (manifest)
    if not manifest then return end
    local name = get_name(manifest)
    vim.ui.select({
      'patch',
      'minor',
      'major',
    }, {
      prompt = 'Select release type',
    }, on_select_release(name, operation))
  end
end

local function get_public_workspace_packages()
  local manifests = get_pkg_manifests('.')
  local all_manifests = manifests
  for _, path in ipairs(flatten(map(get_workspaces_manifest_paths, manifests))) do
    table.insert(all_manifests, json_read_and_parse(path))
  end
  local public_manifests = filter(is_not_private, all_manifests)
  return public_manifests
end

---@param operation Operation
local function make_operation(operation)
  local select = on_select_package(operation)
  return function()
    if operation == 'add' and vim.bo.filetype ~= 'markdown' then
      print('Current buffer is not a changeset')
    else
      local packages = get_public_workspace_packages()
      if #packages == 1 then
        select(packages[1])
      else
        vim.ui.select(packages, {
          prompt = 'Select Package',
          format_item = get_name
        }, select)
      end
    end
  end
end

M.create = make_operation('create')
M.add_package = make_operation('add')

return M
