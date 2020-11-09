module Main where

import XMonad
import XMonad.StackSet
import XMonad.Config.Desktop
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig (additionalKeys, additionalKeysP)
import XMonad.Actions.CycleWS (nextWS, prevWS, toggleWS)
-- import XMonad.Layout.IndependentScreens (countScreens)
import XMonad.Layout.Spacing
import XMonad.Hooks.ManageHelpers (doCenterFloat)
import System.IO

-- Solarized colours
base03 =  "#002b36"
base02 =  "#073642"
base01 =  "#586e75"
base00 =  "#657b83"
base0 =   "#839496"
base1 =   "#93a1a1"
base2 =   "#eee8d5"
base3 =   "#fdf6e3"
yellow =  "#b58900"
orange =  "#cb4b16"
red =     "#dc322f"
magenta = "#d33682"
violet =  "#6c71c4"
blue =    "#268bd2"
cyan =    "#2aa198"
green =   "#859900"

dmenuOptions = " -i -fn \"Schumacher Clean-10\"" ++
    " -nb \"" ++ base03 ++ "\" -nf \"" ++ base3 ++ "\"" ++
    " -sf \"" ++ base03 ++ "\" -sb \"" ++ yellow ++ "\""

main = do
    -- nscreen <- countScreens
    xmproc <- spawnPipe "/usr/bin/xmobar -x 0 /home/liam/.xmobarrc"
    xmonad $ desktopConfig
        { modMask     = mod4Mask,
          layoutHook =  avoidStruts $ spacingRaw True (Border 0 5 5 5) True (Border 5 5 5 5) True $ layoutHook def,
          terminal = "urxvt",
          -- terminal = "xterm",
          manageHook = composeAll
            [ manageHook def,
              manageDocks,
              className =? "Gimp"  --> doFloat,
              className =? "feh" --> doCenterFloat,
              className =? "Pavucontrol" --> doCenterFloat,
              className =? "Pinentry" --> doCenterFloat,
              stringProperty "WM_WINDOW_ROLE" =? "Msgcompose" --> doCenterFloat,
              stringProperty "WM_WINDOW_ROLE" =? "AlarmWindow" --> doCenterFloat,
              (className =? "XTerm") <||> (className =? "UXTerm") <||> (className =? "URxvt") --> doTransparent 0.85
            ],
          logHook = dynamicLogWithPP xmobarPP
            { ppOutput = hPutStrLn xmproc,
              ppCurrent = fmtCurrentWS,
              ppHidden = fmtHiddenWS,
              ppTitle = xmobarColor base3 "" . shorten 100
            }
          {-logHook = do
            currentTag <- (get >>= (return . tag . workspace . current . windowset))
            wstags <- (ask >>= (return . XMonad.workspaces . config))
            io $ hPutStrLn xmproc ("Hello " ++ (show wstags) ++ " " ++ (xmobarColor blue base03 currentTag)) -}
        } `additionalKeys` [
            ((mod4Mask, xK_v), spawn ("passmenu" ++ dmenuOptions)),
            ((mod4Mask, xK_p), spawn ("dmenu_run" ++ dmenuOptions))
        ] `additionalKeysP` [
            ("M--", toggleWS),
            ("M-0", toggleWS),
            ("M-i", nextWS),
            ("M-u", prevWS)
        ]

doTransparent :: Float -> ManageHook
doTransparent x = ask >>= (\w -> liftX . spawn $ "transset-df --id " ++ (show w) ++ " " ++ (show x) ++ " >/dev/null") >> idHook

fmtCurrentWS :: String -> String
fmtCurrentWS x = xmobarColor base3 ""  $ "[" ++ x ++ "]"

fmtHiddenWS :: String -> String
fmtHiddenWS x = xmobarColor base0 "" x
