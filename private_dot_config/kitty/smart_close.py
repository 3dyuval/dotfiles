from kitty.options.utils import parse_key_action


def main(args):
    pass


def handle_result(args, answer, target_window_id, boss):
    tm = boss.active_tab_manager
    if tm is None:
        return

    tab = tm.active_tab
    if tab is not None and len(tab.windows) > 1:
        # Multiple windows in tab: just close the window
        boss.dispatch_action(parse_key_action('close_window'))
    elif len(tm.tabs) > 1:
        # Single window, multiple tabs: ask before closing tab
        boss.confirm(
            'Close tab?',
            lambda confirmed, b=boss: b.dispatch_action(parse_key_action('close_tab')) if confirmed else None,
            window=boss.active_window,
        )
    else:
        # Single window, single tab: ask before exiting
        boss.confirm(
            'Close kitty?',
            lambda confirmed, b=boss: b.dispatch_action(parse_key_action('close_os_window')) if confirmed else None,
            window=boss.active_window,
        )


handle_result.no_ui = True
