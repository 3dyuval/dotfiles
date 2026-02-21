#!/usr/bin/env python3

import sys
import os
from kitty.boss import Boss

def main(args):
    if len(args) < 2:
        return
        
    direction = args[1]
    boss = Boss()
    
    # Get current window
    current_tab = boss.active_tab
    if not current_tab:
        return
        
    current_window = current_tab.active_window
    if not current_window:
        return
    
    # Try to find neighboring window
    neighbor = current_tab.neighboring_window(current_window, direction)
    
    if neighbor:
        # We found a neighbor in current tab, focus it
        current_tab.set_active_window(neighbor)
    else:
        # No neighbor found, try to switch to another kitty instance
        try:
            # Use OS command to find and focus other kitty windows
            import subprocess
            
            # Get list of all windows
            result = subprocess.run([
                'wmctrl', '-l'
            ], capture_output=True, text=True)
            
            kitty_windows = []
            current_window_id = None
            
            for line in result.stdout.strip().split('\n'):
                if 'kitty' in line.lower():
                    window_id = line.split()[0]
                    kitty_windows.append(window_id)
            
            # Focus next kitty window (cycling through them)
            if len(kitty_windows) > 1:
                # Simple approach: just activate next kitty window
                subprocess.run(['wmctrl', '-a', 'kitty'])
                
        except Exception as e:
            # Fallback: do nothing if we can't find other instances
            pass

if __name__ == '__main__':
    main(sys.argv)