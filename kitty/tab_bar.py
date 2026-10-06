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
    # Shells
    'zsh': '',
    'bash': '',
    'fish': '',
    'sh': '',
    # Editors
    'nvim': '',
    'vim': '',
    'nano': '',
    'emacs': '',
    'code': '󰨞',
    # Git & Version Control
    'git': '󰊢',
    'lazygit': '󰊢',
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
    'tmux': '',
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

    exe_lower = exe.lower()
    icon = ICON_MAP.get(exe_lower, '' if not exe else '󰄛')

    if exe_lower in ('zsh', 'bash', 'fish', 'sh', ''):
        if tab.title and tab.title not in ('zsh', 'bash', 'fish', 'sh'):
            label = tab.title
        elif not cwd or cwd == HOME:
            label = '~'
        else:
            label = os.path.basename(cwd.rstrip('/')) or '/'
    elif exe_lower in ('nvim', 'vim'):
        t = tab.title.replace(' - NVIM', '').replace(' [No Name]', '').strip()
        parts = t.split()
        cand = parts[-1] if parts else ''
        cand_base = os.path.basename(cand)
        if cand_base and cand_base.lower() != exe_lower:
            label = cand_base
        else:
            label = os.path.basename(cwd.rstrip('/')) if cwd and cwd != HOME else '~'
    else:
        label = exe

    if len(label) > 14:
        label = label[:13] + '…'

    win_badge = f' 󰖲{tab.num_windows}' if tab.num_windows > 1 else ''
    layout_badge = ' 󰖯' if tab.layout_name == 'stack' else ''
    alert_badge = ' ' if tab.needs_attention else (' ●' if tab.has_activity_since_last_focus else '')

    return f'{icon} {label}{win_badge}{layout_badge}{alert_badge}'


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
    default_bg = as_rgb(int(draw_data.default_bg))

    if tab.is_active:
        bg = as_rgb(int(draw_data.active_bg))
        fg = as_rgb(int(draw_data.active_fg))
    else:
        bg = as_rgb(int(draw_data.inactive_bg))
        fg = as_rgb(int(draw_data.inactive_fg))

    # Left rounded cap ()
    screen.cursor.bg = default_bg
    screen.cursor.fg = bg
    screen.cursor.bold = False
    screen.draw('')

    # Pill body
    screen.cursor.bg = bg
    screen.cursor.fg = fg
    if tab.is_active:
        screen.cursor.bold = True
        screen.draw(f' {index} ')
        screen.cursor.bold = False
    else:
        screen.cursor.bold = False
        screen.draw(f' {index} ')

    content = get_tab_title(tab)
    screen.draw(f'{content} ')

    # Right rounded cap ()
    screen.cursor.bg = default_bg
    screen.cursor.fg = bg
    screen.cursor.bold = False
    screen.draw('')

    # Floating spacing between pills
    if not is_last:
        screen.cursor.bg = default_bg
        screen.cursor.fg = default_bg
        screen.draw(' ')

    return screen.cursor.x
