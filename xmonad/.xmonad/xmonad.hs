-- IMPORTS

    -- Base
import XMonad
import XMonad.Hooks.EwmhDesktops
import Data.Maybe (isJust)
import Data.List
import XMonad.Config.Azerty
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import XMonad.Hooks.ManageHelpers
import qualified XMonad.StackSet as W

    -- Utilities
import XMonad.Util.EZConfig (additionalKeysP, additionalMouseBindings)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (safeSpawn, unsafeSpawn, runInTerm, spawnPipe)
import XMonad.Util.SpawnOnce

    -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, defaultPP, dzenColor, pad, shorten, wrap, PP(..))
import XMonad.Hooks.ManageDocks (avoidStruts, ToggleStruts(..))
import XMonad.Hooks.Place (placeHook, withGaps, smart)
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.FloatNext (floatNextHook, toggleFloatNext, toggleFloatAllNew)

    -- Actions
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.CopyWindow (kill1, copyToAll, killAllOtherCopies, runOrCopy)
import XMonad.Actions.WindowGo (runOrRaise, raiseMaybe)
import XMonad.Actions.WithAll (sinkAll, killAll)
import XMonad.Actions.CycleWS (moveTo, shiftTo,prevWS, nextWS, WSType(..))
import XMonad.Actions.GridSelect (GSConfig(..), goToSelected, bringSelected, colorRangeFromClassName, buildDefaultGSConfig)
import XMonad.Actions.DynamicWorkspaces (addWorkspacePrompt, removeEmptyWorkspace)
import XMonad.Actions.UpdatePointer
import qualified XMonad.Actions.ConstrainedResize as Sqr

    -- Layouts modifiers
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.Renamed (renamed, Rename(CutWordsLeft, Replace))
import XMonad.Layout.WorkspaceDir
import XMonad.Layout.Spacing (spacing)
import XMonad.Layout.Minimize
import XMonad.Layout.Maximize
import XMonad.Layout.BoringWindows (boringWindows)
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), Toggle(..), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))

    -- Layouts
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.NoBorders
import XMonad.Hooks.ManageDocks
import XMonad.Layout.ComboP
import XMonad.Layout.Tabbed
import XMonad.Layout.TwoPane
import XMonad.Actions.CopyWindow
import XMonad.Layout.Gaps
import XMonad.Layout.Spacing
import XMonad.Layout.Column
import XMonad.Layout.BoringWindows
import XMonad.Layout.IfMax
import XMonad.Layout.Minimize


    -- Prompts
import XMonad.Prompt (defaultXPConfig, XPConfig(..), XPPosition(Top), Direction1D(..))

    -- YAML
import GHC.Generics
--import Data.Yaml

    -- Styles
myFont          = "terminus"
myBorderWidth   = 5
myColorBG       = "#1f1f1f"
myColorWhite    = "#ffc500"
myColorRed      = "#ff7322"
myColorBrown    = "#c0b18b"

myTabConfig = def { 
                      activeColor = myColorWhite
                    , activeTextColor = myColorBG
                    , activeBorderColor = myColorWhite
                    , inactiveColor = myColorBG
                    , inactiveTextColor = myColorWhite
                    , inactiveBorderColor = myColorBG}

    -- Settings
myModMask       = mod4Mask
myTerminal      = "urxvt"
myMusic         = "LD_PRELOAD=/usr/lib/libcurl.so.3:~/.xmonad/spotifywm.so $(which spotify)"
myBrowser       = "google-chrome-stable"
myLauncher      = "rofi -show run"
myLock          = "env XSECURELOCK_SAVER=saver_mplayer xsecurelock"
myBG            = "hsetroot -solid '" ++ myColorBG ++ "' &"
myCompositor    = "ps aux |grep '[c]ompton' ||compton &"
myChat          =  myBrowser ++ " --app='https://chat.google.com/'"
myNotes         =  myBrowser ++ " --app='https://keep.google.com/'"


-- For key codes see:
-- http://hackage.haskell.org/package/xmonad-contrib-0.14/docs/XMonad-Util-EZConfig.html

myKeys =
    -- XMonad
    [ ("M-M1-q", io exitSuccess)

    -- Windows
    , ("M-q",            kill1)
    , ("M-z",            windows W.swapUp)
    , ("M-<Tab>",        windows W.focusDown)
    , ("M-a" ,           sendMessage NextLayout)
    , ("M-x",            sendMessage Shrink)
    , ("M-s",            sendMessage Expand)
    , ("M-w",            withFocused $ windows . W.sink)
    , ("M-,",            prevWS)
    , ("M-.",            nextWS)
    , ("M-S-,",          prevWS)
    , ("M-S-.",          nextWS)


    -- Apps
    , ("M-<Return>",     spawn myTerminal)
    , ("M-S-<Return>",   spawn myBrowser)
    , ("M-<Space>",      spawn myLauncher)
    , ("M-l",            spawn myLock)

    -- Scratchpads
    , ("M-`",            namedScratchpadAction scratchpads "music")
    , ("M-<Page_Up>",    namedScratchpadAction scratchpads "notes")
    , ("M-<Page_Down>",  namedScratchpadAction scratchpads "chat")
    ]

-- Scratchpad
scratchpads = [ NS "notes" spawnNotes findNotes nonFloating
              , NS "music" spawnMusic findMusic nonFloating
              , NS "chat" spawnChat findChat nonFloating
              ]

-- Notepad
  where
    spawnNotes  = myNotes
    findNotes   = resource =? "keep.google.com"
    -- Music
    spawnMusic  = myMusic
    findMusic   = resource =? "spotify"
    -- Chat
    spawnChat   = myChat
    findChat    = resource =? "chat.google.com"

    -- workspaces
myWorkspaces = ["-", "--", "---" ]

myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Rofi"           --> doFloat
    ]  <+>  namedScratchpadManageHook scratchpads

myStartupHook = do
    spawn myCompositor
    spawn myBG
    spawn "unclutter &"

myLayoutHook =  combineTwoP two (gapB $ bar) (gapS $ grid) clss |||
                combineTwoP two (gapB $ bar) (gapS $ vertical) clss |||
                combineTwoP two (gapB $ bar) (gapS $ tabs) clss |||
                combineTwoP two (gapB $ bar) (gapL $ tabs) clss |||
                full
    where
        full = smartBorders $ Full
        grid = padS $ Grid (4/4)
        vertical = padS $ Tall 3 (5/100) (50/100)
        display = gapL $ Full
        bar =  noBorders (IfMax 2 (Column 1) tabs)
        tabs = tabbed shrinkText myTabConfig
        two = Tall 1 (1/50) (1/4)

        gapS =  gaps [(U,40), (D,10), (L,20), (R,20)]
        gapM = gaps [(U,60), (D,60), (L,30), (R,30)]
        gapL = gaps [(U,100), (D,100), (L,100), (R,100)]
        gapB =  gaps [(U,40), (D,10), (L,0), (R,0)]
        padS = spacing 10
        padL = spacing 20
        keep = Title "Google Keep" `Or` Role "pop-up"
        spotify = ClassName "Spotify"
        clss = keep `Or` spotify

main = xmonad  $ ewmh  $  azertyConfig
    { modMask            = myModMask
    , terminal           = myTerminal
    , manageHook         = myManageHook
    , layoutHook         = myLayoutHook
    , startupHook        = myStartupHook
    , workspaces         = myWorkspaces
    , borderWidth        = myBorderWidth
    , normalBorderColor  = myColorBG
    , focusedBorderColor = myColorWhite
    } `additionalKeysP`    myKeys
