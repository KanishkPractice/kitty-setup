#!/usr/bin/env python3
"""
Custom Kitty tab bar drawing script: Floating Rounded Pills
Provides elegant, floating isolated capsule tabs with:
- True rounded pill ends ( and )
- Smart process & file/directory detection with Nerd Font icons
- Multi-window split count badges (󰖲)
- Zoom/stack layout indicator (󰖯)
- Bell & activity notifications ( / ●)
- High contrast, glitch-free rendering
"""

import os
from kitty.fast_data_types import Screen, get_boss
from kitty.tab_bar import DrawData, TabBarData, ExtraData, as_rgb

ICON_MAP = {
    # Shells (idle in directory)
    'zsh': '󰉋',
    'bash': '󰉋',
    'fish': '󰉋',
    'sh': '󰉋',
    # AI & Agents
    'agy': '󰚩',
    'antigravity': '󰚩',
    'claude': '󰚩',
    # Editors
    'nvim': '',
    'vim': '',
    'helix': '󰈺',
    'hx': '󰈺',
    'nano': '',
    'emacs': '',
    'code': '󰨞',
    # Git & Version Control
    'git': '󰊢',
    'lazygit': '󰊢',
    'gh': '',
    # File Managers & Multiplexers
    'yazi': '󰇥',
    'tmux': '',
    # System & Monitoring
    'btop': '󰄯',
    'htop': '󰄯',
    'top': '󰄯',
    'fastfetch': '󰄛',
    'cmatrix': '󰘨',
    # Languages & Runtimes
    'python': '',
    'python3': '',
    'ipython': '',
    'node': '󰎙',
    'npm': '󰎙',
    'pnpm': '󰎙',
    'yarn': '󰎙',
    'bun': '󰎙',
    'cargo': '󱘗',
    'rustc': '󱘗',
    'go': '󰟓',
    'ruby': '',
    'lua': '',
    # Tools & Network
    'docker': '󰡨',
    'docker-compose': '󰡨',
    'ssh': '󰣀',
    'fzf': '',
    'man': '󰈙',
    'less': '󰈙',
}

HOME = os.path.expanduser('~')


def get_tab_title(tab: TabBarData) -> str:
    boss = get_boss()
    tab_obj = boss.tab_for_id(tab.tab_id) if boss else None

    cwd = ''
    exe = ''
    if tab_obj:
        try:
            cwd = tab_obj.get_cwd_of_active_window() or ''
        except Exception:
            pass
        try:
            exe = os.path.basename(tab_obj.get_exe_of_active_window() or '')
        except Exception:
            pass

    raw_title = (tab.title or '').strip()
    exe_lower = (exe or '').lower()

    # Extract command name from title if running a command
    cmd_token = raw_title.split()[0] if raw_title else exe_lower
    cmd_name = os.path.basename(cmd_token).lower()

    # 1. Active CLI command / application detection
    if cmd_name in ICON_MAP and cmd_name not in ('zsh', 'bash', 'fish', 'sh'):
        icon = ICON_MAP[cmd_name]
        label = cmd_name
    # 2. Editors: show clean file name if available
    elif cmd_name in ('nvim', 'vim', 'helix', 'hx'):
        icon = ICON_MAP.get(cmd_name, '')
        parts = raw_title.replace(' - NVIM', '').replace(' [No Name]', '').split()
        if len(parts) > 1 and not parts[-1].startswith('-'):
            file_name = os.path.basename(parts[-1])
            label = file_name if file_name and file_name.lower() != cmd_name else cmd_name
        else:
            label = cmd_name
    # 3. Path in title (~/Desktop, /etc, etc.)
    elif raw_title.startswith('~') or raw_title.startswith('/'):
        clean_path = raw_title.rstrip('/')
        folder = os.path.basename(clean_path) if clean_path not in ('~', '/') else '~'
        icon = '󰉋'
        label = folder
    # 4. Idle in shell: show current working directory folder
    elif not raw_title or raw_title.lower() in ('zsh', 'bash', 'fish', 'sh') or exe_lower in ('zsh', 'bash', 'fish', 'sh'):
        if not cwd or cwd == HOME:
            folder = '~'
        else:
            folder = os.path.basename(cwd.rstrip('/')) or '~'
        icon = '󰉋'
        label = folder
    # 5. Fallback: clean command name without raw flags
    else:
        icon = ICON_MAP.get(cmd_name, '󰆍')
        label = cmd_name or raw_title

    if len(label) > 18:
        label = label[:17] + '…'

    win_badge = f' 󰖲{tab.num_windows}' if tab.num_windows > 1 else ''
    layout_badge = ' 󰖯' if tab.layout_name == 'stack' else ''
    alert_badge = ' ' if tab.needs_attention else (' ●' if tab.has_activity_since_last_focus else '')

    return f'{icon} {label}{win_badge}{layout_badge}{alert_badge}'


INDEX_BADGES = ('➊', '➋', '➌', '➍', '➎', '➏', '➐', '➑', '➒', '➓')


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    if tab.is_active:
        bg = as_rgb(int(draw_data.active_bg))
        fg = as_rgb(int(draw_data.active_fg))
    else:
        bg = as_rgb(int(draw_data.inactive_bg))
        fg = as_rgb(int(draw_data.inactive_fg))

    badge = INDEX_BADGES[index - 1] if 1 <= index <= len(INDEX_BADGES) else str(index)
    content = get_tab_title(tab)

    # Left rounded cap () with 0 background for seamless transparency
    screen.cursor.bg = 0
    screen.cursor.fg = bg
    screen.cursor.bold = False
    screen.draw('')

    # Pill body (index badge + icon + label)
    screen.cursor.bg = bg
    screen.cursor.fg = fg
    screen.cursor.bold = tab.is_active
    screen.draw(f'{badge}  {content}')

    # Right rounded cap () with 0 background for seamless transparency
    screen.cursor.bg = 0
    screen.cursor.fg = bg
    screen.cursor.bold = False
    screen.draw('')

    # Generous floating spacer between dock pills
    if not is_last:
        screen.cursor.bg = 0
        screen.cursor.fg = 0
        screen.draw('  ')

    screen.cursor.bg = 0
    screen.cursor.fg = 0
    return screen.cursor.x
