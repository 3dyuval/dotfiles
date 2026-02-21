#!/usr/bin/env python3

import subprocess
import sys
from kitty.boss import Boss
from kitty.fast_data_types import Screen
from kitty.tab import Tab
from kitty.window import Window

def main(args):
    direction = args[1] if len(args) > 1 else "right"
    
    # First try normal neighboring window navigation
    try:
        # Try to move to neighboring window in current instance
        result = subprocess.run([
            'kitty', '@', 'focus-window', '--match', f'neighbor:{direction}'
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            return  # Successfully moved within current instance
    except:
        pass
    
    # If we reach here, we're at the edge - try to find other kitty instances
    try:
        # List all kitty instances
        result = subprocess.run([
            'ps', 'aux'
        ], capture_output=True, text=True)
        
        # Look for other kitty processes
        kitty_processes = []
        for line in result.stdout.split('\n'):
            if 'kitty' in line and '--listen-on' in line:
                # Extract socket path if possible
                parts = line.split()
                for i, part in enumerate(parts):
                    if part == '--listen-on' and i + 1 < len(parts):
                        socket = parts[i + 1]
                        if socket != 'unix:@mykitty':  # Don't include current instance
                            kitty_processes.append(socket)
        
        # Try to focus first available other instance
        if kitty_processes:
            for socket in kitty_processes:
                try:
                    subprocess.run([
                        'kitty', '@', '--to', socket, 'focus-window'
                    ], check=True)
                    return  # Successfully focused other instance
                except:
                    continue
        
        # Fallback: try to focus any kitty window using wmctrl
        try:
            subprocess.run(['wmctrl', '-a', 'kitty'], check=True)
        except:
            pass
            
    except:
        pass

if __name__ == '__main__':
    main(sys.argv)