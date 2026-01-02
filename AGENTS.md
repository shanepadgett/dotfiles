# Chezmoi-Managed Files

When modifying config files or user executables under `$HOME`, check if the file is tracked by chezmoi:

1. **Before editing**, run `chezmoi diff` to see if there are pending changes
2. **After editing** a chezmoi-managed file (configs, scripts in `~/.local/bin`, etc.):
   - If the file is a symlink managed by `chezmoi-symlink`, edits go directly to chezmoi source
   - For regular chezmoi-managed files, changes need to be re-added with `chezmoi re-add <file>`
3. **To sync changes to remote**, run:
   ```bash
   chezmoi git -- add -A && chezmoi git -- commit -m "<message>" && chezmoi git -- push
   ```

### Using chezmoi-symlink
For files that apps modify (like settings.json), use the `chezmoi-symlink` script:
```bash
chezmoi-symlink add <file>      # Set up symlink management
chezmoi-symlink remove <file>   # Restore as regular file
chezmoi-symlink edit <file>     # Edit + auto commit/push
```
