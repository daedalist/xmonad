#!/bin/sh
WDIR=$(pwd)
PKGS="xmonad stow xsecurelock hsetroot rofi feh compton rxvt-unicode-256color cabal-install fonts-inconsolata dunst fonts-font-awesome xfonts-terminus"
HPKG="yaml xmobar JuicyPixels"
DIRS="xmonad compton x rofi dunst"
SPOTIFY_URL="https://github.com/dasJ/spotifywm"
SPOTIFY_DIR="/tmp/spotifywm"
VIDEO_URL="http://a1.phobos.apple.com/us/r1000/000/Features/atv/AutumnResources/videos"
VIDEO_DIR="$HOME/Videos"
VIDEO_MSG="Download lockscreen videos now? This can take some time. (y/n)"
# Install packages
function install_pkg() {
  sudo apt-get install $PKGS
}

# Update xmonad
function update_xmonad() {
  cabal update
  cabal install -fwith_datezone -fwith_xft -fwith_utf8 $HPKG
}


# Get spotifywm
function get_spotifywm() {
  if [ -d "$SPOTIFY_DIR" ]; then
    rm -vrf $SPOTIFY_DIR
  fi
  git clone $SPOTIFY_URL $SPOTIFY_DIR
  cd /tmp/spotifywm && make
  cp spotifywm.so $WDIR/xmonad/.xmonad/
}


# Stow files
function stow_files() {
  cd $WDIR && stow -v -S $DIRS
}

# Download video wallpapers
function dl_videos() {
  cd $VIDEO_DIR
  for i in b10-1.mov b10-2.mov b10-3.mov b10-4.mov b1-1.mov b1-2.mov b1-3.mov b1-4.mov \
	b2-1.mov b2-2.mov b2-3.mov b2-4.mov b3-1.mov b3-2.mov b3-3.mov b4-1.mov b4-2.mov \
	b4-3.mov b5-1.mov b5-2.mov b5-3.mov b6-1.mov b6-2.mov b6-3.mov b6-4.mov b7-1.mov \
	b7-2.mov b7-3.mov b8-1.mov b8-2.mov b8-3.mov b9-1.mov b9-2.mov b9-3.mov \
	comp_GL_G004_C010_v03_6Mbps.mov comp_DB_D011_D009_SIGNCMP_v15_6Mbps.mov \
	comp_HK_H004_C008_v10_6Mbps.mov comp_LA_A009_C009_t9_6M_tag0.mov \
	comp_C002_C005_0818SC_001_v01_6M_HB_tag0.mov comp_GL_G010_C006_v08_6Mbps.mov \
	comp_LW_L001_C006_t9_6M_tag0.mov comp_DB_D011_C010_v10_6Mbps.mov \
	comp_LA_A005_C009_v05_t9_6M.mov comp_HK_B005_C011_t9_6M_tag0.mov \
	plate_G002_C002_BG_t9_6M_HB_tag0.mov comp_C007_C011_08244D_001_v01_6M_HB_tag0.mov \
	comp_LA_A006_C008_t9_6M_HB_tag0.mov comp_DB_D001_C001_v03_6Mbps.mov \
	comp_HK_H004_C010_4k_v01_6Mbps.mov comp_LA_A008_C004_ALT_v33_6Mbps.mov \
	comp_DB_D002_C003_t9_6M_HB_tag0.mov comp_C007_C004_0824AJ_001_v01_6M_HB_tag0.mov \
	comp_DB_D001_C005_t9_6M_HB_tag0.mov comp_HK_H004_C013_t9_6M_HB_tag0.mov \
	comp_DB_D008_C010_v04_6Mbps.mov; do
	wget "$VIDEO_URL/$i"
	chmod 644 $(pwd)/$i
done
}

function get_conf() {
  read -p "$@" answer
  case ${answer:0:1} in
      y|Y )
          return 0
      ;;
      * )
          return 1
      ;;
  esac
}

echo "sudo apt-get install $PKGS"
install_pkg
echo "cabal update"
update_xmonad
echo "Download spotify window class mod"
get_spotifywm
echo "Create symbolic links"
stow_files
if $(get_conf "$VIDEO_MSG "); then
  dl_videos
fi
