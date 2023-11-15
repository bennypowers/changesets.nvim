![Am Yisrael Chai - עם ישראל חי](https://bennypowers.dev/assets/flag.am.yisrael.chai.png)

# changesets.nvim

Easily create [changesets][cs] using your favourite editor.

<figure>

  [screencast][screencast]

  <figcaption>

Screencast showing how to use changesets.nvim to:
1. pick a package from your project repo
2. pick a release type (`patch`, `minor`, or `major`)
3. pick a file name (trivial)
4. write your changeset
5. Add any other packages to the changeset

  </figcaption>
</figure>

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

[cs]: https://github.com/changesets/changesets
[screencast]: https://github.com/bennypowers/changesets.nvim/assets/1466420/ac1e670a-9be9-4177-99d7-8ae7033c2822
