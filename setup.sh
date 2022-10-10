# usage: 
# 1) attach ssd to old machine and start running backup.sh
# 2) grab the latest version of this file from 	
#   https://gist.github.com/jsundram/eeca472a8929bfab27209783b16bd6d9
# 3) copy this script onto the new machine and start running it
#   sh setup.sh
#   you will need to add homebrew to your .zprofile path
#   PATH=$PATH:/opt/homebrew/bin
#   echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zprofile
#   rerun script
# 4) Sign in to the Apple store and download purchased apps. See more details in "instructions.md"
# 5) Sign into iCloud
# 6) When Dropbox is installed, sign in and set up selective sync; pause sync until after restore.sh runs
# 7) when backup.sh is done, attach the ssd to the new machine, run restore.sh from the backup/settings directory

echo "Installing xcode-stuff"
xcode-select --install

# Check for Homebrew,
# Install if we don't have it
if test ! $(which brew); then
  echo "Installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Update homebrew recipes
echo "Updating homebrew..."
brew update
# Sonos is considered a "driver"
brew tap homebrew/cask-drivers

echo "Installing Git..."
brew install git

echo "Git config"
git config --global user.name "Jason Sundram"
git config --global user.email jsundram@gmail.com

echo "setting brew directory permissions..."
# to prevent chef from reverting the permissions`
# https://www.internalfb.com/intern/qa/5789/got-error-usrlocallib-is-not-writable-when-running
sudo chown $(whoami) /usr/local/lib /usr/local/sbin /usr/local/bin
sudo touch /Library/CPE/tags/homebrew 

echo "Installing other brew stuff..."
brew install atomicparsley
brew install autojump
brew install coreutils
brew install ffmpeg
brew install gh
brew install graphviz
brew install imagemagick
brew install --cask julia
brew install node@12 &&  brew link --force node@12
brew install unrar
brew install wget
brew install youtube-dl

#imgcat is perhaps useful?
brew install eddieantonio/eddieantonio/imgcat

brew install anaconda # .zshrc will take care of the rest
conda remove -y curl  # conda's curl shadows the system curl, which ... can cause problems

# echo "Installing homebrew cask"
# brew install caskroom/cask/brew-cask

# Install apps 
echo "installing apps..."

brew install aerial
brew install atext
brew install caffeine
brew install dropbox
brew install duet
brew install expressvpn
brew install flux
brew install google-chrome
brew install istat-menus 
brew install iterm2
brew install keepassx
brew install mactex
brew install macvim
brew install metaz
brew install plex-media-server
brew install Processing 
brew install qbittorrent 
brew install qgis 
brew install sonos 
brew install spotify
brew install transmission
brew install typora
brew install vlc
brew install zoom

echo "Cleaning up brew"
brew cleanup

# NEW: not sure if we should try to do pip stuff here.
pip3 install jupyter-console
julia -e "using Pkg; Pkg.add(\"IJulia\")"

# https://pawelgrzybek.com/change-macos-user-preferences-via-command-line/
echo "Setting some Mac settings..."

# Keystone Agent seems to take a constant 10% of CPU for update checking.
# Use Brave instead of Chrome and disable keystone (can't remove Chrome
# from fb laptop due to chef.
defaults write com.google.Keystone.Agent checkInterval 0

#"Disabling automatic termination of inactive apps"
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

#"Allow text selection in Quick Look"
defaults write com.apple.finder QLEnableTextSelection -bool TRUE

#"Disabling OS X Gate Keeper"
#"(You'll be able to install any app you want from here on, not just Mac App Store apps)"
sudo spctl --master-disable
sudo defaults write /var/db/SystemPolicy-prefs.plist enabled -string no
defaults write com.apple.LaunchServices LSQuarantine -bool false

#"Expanding the save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

#"Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

#"Saving to disk (not to iCloud) by default"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

#"Check for software updates daily, not just once per week"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

#"Disable smart quotes and smart dashes as they are annoying when typing code"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

#"Enabling full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

#"Disabling press-and-hold for keys in favor of a key repeat"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

#"Setting trackpad & mouse speed to a reasonable number"
defaults write -g com.apple.trackpad.scaling 2
defaults write -g com.apple.mouse.scaling 2.5

#"Enabling subpixel font rendering on non-Apple LCDs"
defaults write NSGlobalDomain AppleFontSmoothing -int 2

#"Showing icons for hard drives, servers, and removable media on the desktop"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

#"Showing all filename extensions in Finder by default"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

#"Disabling the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

#"Use column view in all Finder windows by default"
defaults write com.apple.finder FXPreferredViewStyle Clmv

#"Avoiding the creation of .DS_Store files on network volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

#"Enabling snap-to-grid for icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

#"Setting the icon size of Dock items to 36 pixels for optimal size/screen-realestate"
defaults write com.apple.dock tilesize -int 36

#"Speeding up Mission Control animations and grouping windows by application"
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock "expose-group-by-app" -bool true

#"Setting Dock to auto-hide and removing the auto-hiding delay"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0

#"Prevent Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

#"Setting screenshot format to PNG"
defaults write com.apple.screencapture type -string "png"

#"Enabling Safari's debug menu"
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

#"Making Safari's search banners default to Contains instead of Starts With"
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

#"Removing useless icons from Safari's bookmarks bar"
defaults write com.apple.Safari ProxiesInBookmarksBar "()"

#"Enabling the Develop menu and the Web Inspector in Safari"
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true

#"Adding a context menu item for showing the Web Inspector in web views"
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

#"Use `~/Downloads/Incomplete` to store incomplete downloads"
defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Downloads/Incomplete"

#"Don't prompt for confirmation before downloading"
defaults write org.m0k.transmission DownloadAsk -bool false

#"Trash original torrent files"
defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

#"Hide the donate message"
defaults write org.m0k.transmission WarningDonate -bool false

#"Hide the legal disclaimer"
defaults write org.m0k.transmission WarningLegal -bool false

#"Disable 'natural' (Lion-style) scrolling"
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# "increase key repeat rate" https://apple.stackexchange.com/questions/10467/
defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)

# "Tap to Click" https://osxdaily.com/2014/01/31/turn-on-mac-touch-to-click-command-line/
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
sudo defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
sudo defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
sudo defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# "Play user interface sound effects OFF" https://www.maketecheasier.com/disable-sound-effects-mac/
defaults write com.apple.systemsound "com.apple.sound.uiaudio.enabled" -int 0

#  Text https://www.reddit.com/r/MacOS/comments/boggdj/anyway_to_disable_the_spellchecking_in_mac_os/
# Correct spelling automatically
# disable for system, enable for web input fields (check also with Safari configuration script!)
defaults write -globalDomain "NSAutomaticSpellingCorrectionEnabled" -bool false
defaults write -globalDomain "WebAutomaticSpellingCorrectionEnabled" -bool true

# Capitalise words automatically OFF
defaults write -globalDomain "NSAutomaticCapitalizationEnabled" -bool false

#  Undocumented:  Offer Text Replacement/Completion (enable)
defaults write -globalDomain "NSAutomaticTextCompletionEnabled" -bool true

# turn down alert volume to 0
defaults write com.apple.systemsound com.apple.sound.beep.volume -float 0

# "Play feedback when volume is changed as the logged in user OFF" 
defaults write -g com.apple.sound.beep.feedback -integer 0

# Finder > View > As List
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Finder > View > Show Path Bar
defaults write com.apple.finder ShowPathbar -bool true

# Turn off Siri (TODO: test)
defaults write com.apple.systemuiserver "NSStatusItem Visible Siri" -bool false

# Settings > Bluetooth -- check "show bluetooth in menu bar"
defaults write com.apple.systemuiserver menuExtras -array-add "/System/Library/CoreServices/Menu Extras/Bluetooth.menu"

# Settings > Date & Time > Clock: Show date and time in menu bar
defaults write com.apple.systemuiserver menuExtras -array-add "/System/Library/CoreServices/Menu Extras/Clock.menu"

# Include date in the menu bar (System Preferences | Date & Time | Clock)
# https://apple.stackexchange.com/questions/180847/wrong-date-format-in-the-menu-bar
defaults write com.apple.menuextra.clock "DateFormat" 'EEE MMM d  h:mm a'

# Show volume in menu bar
defaults write com.apple.systemuiserver menuExtras -array-add "/System/Library/CoreServices/Menu Extras/Volume.menu"

# Touch Bar -> Control Strip 
defaults write com.apple.touchbar.agent PresentationModeGlobal fullControlStrip

# Need to restart touchbar to have an effect
pkill "Touch Bar agent"; killall "ControlStrip";

# * General | use font smoothing when available: set to OFF (https://tonsky.me/blog/monitors/)
# TODO: make sure this works
defaults write -g CGFontRenderingFontSmoothingDisabled -bool NO

# Finder changes also require a restart
killall Finder

# refresh the menu bar
killall -KILL SystemUIServer

# TODO:
# * associate VLC with AVI, MPG, MP4, etc
#   see https://apple.stackexchange.com/questions/49532/change-the-default-application-for-a-file-extension-via-script-command-line
# * Make list view Default in finder
# * Disable spotlight indexing for Downloads?
# * General | use font smoothing when available: set to OFF (https://tonsky.me/blog/monitors/)
# * Displays | Scaled (make sure it is 2x the native resolution reported here: https://www.sven.de/dpi/)
# * hotcorner to lock screen
# * no recent: https://ccm.net/faq/37203-mac-os-x-turn-off-the-recent-items-list.
#   * also need to remove the recents shortcut from finder (still populated for some reason)
# * set user profile photo to my usual avatar by dragging a photo into the users/photo setting.

# Finder: Easier to do these manually I think?
echo "1. Finder: drag home directory to the 'Favorites' on the side"
echo "2. Finder: Add date modified column"
# https://apple.stackexchange.com/questions/13598/
echo "3. Preferences > Keyboard > Modifier Keys... remap caps lock -> escape"
echo "4. Use Apple Watch to unlock your mac (Settings | Security and Privacy)"
echo "5. Remove unused apps from dock (news photos maps safari etc)"
echo "6. Deal with your dotfiles (may be able to edit, then use restore.sh)"
echo "7. Change the computer hostname (if desired) under System Preferences | Sharing."
echo "8. See instructions.md to install and register other software"

echo "Done!"
