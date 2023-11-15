# changesets.nvim

Easily create changesets using your favourite editor

[changesets.nvim.webm](https://github.com/bennypowers/changesets.nvim/assets/1466420/ac1e670a-9be9-4177-99d7-8ae7033c2822)

## 🛌 Installation (Lazy)

```lua
return { 'bennypowers/changesets.nvim',
  dependencies = { 'lspconfig' },
  keys = {
    { '<leader>cs',
      function() require'changesets'.create() end,
      mode = 'n',
      desc = 'Create a changeset',
    },
    { '<leader>ca',
      function() require'changesets'.add_package() end,
      mode = 'n',
      desc = 'Add a package to the changeset in the current buffer',
    },
  },
}
```

