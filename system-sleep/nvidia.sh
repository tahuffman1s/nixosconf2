#!/run/current-system/sw/bin/bash
nvidia-settings --assign CurrentMetaMode="DP-4: 2560x1440_165 +0+0 { ForceFullCompositionPipeline = On } , DP-2: 2560x1440_165 +2560+0"
xrandr --output DP-4 --primary
