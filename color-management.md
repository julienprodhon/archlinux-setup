# DMS Color Management

## How It Works

```
Wallpaper → Matugen → Material Design 3 Colors → Dank16 → 16-color palette
                ↓                                    ↓
        GTK/Qt/Apps                           Terminals
```

1. **Matugen** extracts colors from wallpaper using Material Design 3 (k-means clustering)
2. **Dank16** generates 16-color ANSI palette with dark/light/default variants
3. **Templates** write config files for detected apps
4. **Signal handling** reloads running apps (Ghostty: `SIGUSR2`, Kitty: `SIGUSR1`)

---

## Apps by Category

### Terminal Apps (No Changes Needed)

These TUI apps inherit colors from your terminal. Once Ghostty is themed, they're automatically themed:

| App | Type | Notes |
|-----|------|-------|
| lazygit | TUI | Uses terminal ANSI colors |
| lazydocker | TUI | Uses terminal ANSI colors |
| yazi | TUI | Uses terminal ANSI colors |
| bat | TUI | Uses terminal ANSI colors |
| fzf | TUI | Uses terminal ANSI colors |
| starship | Prompt | Uses terminal ANSI colors |

### Auto-Themed by DMS (No Changes Needed)

DMS detects these apps and generates themed config files automatically:

| App | Output File | Reload Method |
|-----|-------------|---------------|
| **Ghostty** | `~/.config/ghostty/themes/dankcolors` | SIGUSR2 signal |
| **Niri** | `~/.config/niri/dms/colors.kdl` | Already integrated |
| **GTK 3/4** | `~/.config/gtk-3.0/dank-colors.css` | Theme cycle |
| **Qt5/Qt6** | Via qt5ct/qt6ct | Settings update |
| **Zen Browser** | Firefox CSS theming (UI only — toolbar, tabs, menus; not website content) | Needs manual userChrome.css templating |
| **dgop** | Has template support | Auto |
| **Neovim** | Template available | Manual reload |

### Apps Requiring Changes

| App | Current State | Action Required |
|-----|---------------|-----------------|
| **Ghostty config** | Static `config-dankcolors` | Change to `theme = dankcolors` and remove static color file |
| **Tmux** | Static colors in config | Keep static OR create custom matugen template. Note: existing sessions don't pick up color changes — only new sessions/windows do. |
| **Neovim colorscheme** | Catppuccin (static) | Keep static OR switch to dynamic theme |

### Not Themed (No DMS Support)

| App | Theming Approach |
|-----|------------------|
| Obsidian | App-managed themes (independent) |
| Signal | GTK themed (covered above) |
| Telegram | GTK themed (covered above) |
| VLC | GTK themed (covered above) |
| Zathura | GTK themed (covered above) |

---

## Ghostty Configuration Change

**Current (static):**
```
config-file = ./config-dankcolors
```

**Recommended (dynamic):**
```
theme = dankcolors
```

Remove your static `config-dankcolors` file - DMS will generate `~/.config/ghostty/themes/dankcolors` automatically.

---

## Custom Templates

To theme additional apps, add to `~/.config/matugen/config.toml`:

```toml
[templates.myapp]
input_path = '~/.config/matugen/templates/myapp.conf'
output_path = '~/.config/myapp/colors.conf'
```

Template variables available:
- `{{dank16.color0.default.hex}}` through `{{dank16.color15.default.hex}}`
- `{{colors.primary.dark.hex}}`, `{{colors.background.default.hex}}`, etc.

---

## Static Color Schemes

If using a static theme instead of dynamic wallpaper-based colors, the most popular choices are: Gruvbox, Catppuccin, Nord, Dracula, and Tokyo Night.

Browse available themes at: https://github.com/topics/color-scheme and https://www.terminal.sexy

---

## DMS Settings

Key settings in `~/.config/DankMaterialShell/settings.json`:

| Setting | Default | Description |
|---------|---------|-------------|
| Scheme | `scheme-tonal-spot` | Color extraction algorithm |
| Terminals Always Dark | false | Force dark palette in terminals |
