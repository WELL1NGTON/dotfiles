# Default Keyboard config
# US International
setxkbmap us -variant intl
# # PT-BR ABNT2
# setxkbmap -model pc105 -layout br -variant abnt2

nitrogen --restore

# pcmanfm --daemon-mode

nm-applet &

birdtray &

caffeine start &

/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

picom &

blueman-applet &
