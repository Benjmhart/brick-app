{-# LANGUAGE OverloadedStrings #-}

module Tui where

import System.Directory
import System.Exit (die)

import Data.List.NonEmpty (NonEmpty (..))
import qualified Data.List.NonEmpty as NE

import qualified Cursor.Simple.List.NonEmpty as NEC

import Brick.AttrMap
import Brick.Main
import Brick.Types
import Brick.Util (fg)
import Brick.Widgets.Core
import Graphics.Vty.Attributes (red)
import Graphics.Vty.Input.Events

tui :: IO ()
tui = do
  initialState <- buildInitialState
  endState <- defaultMain tuiApp initialState
  print endState

data TuiState =
  TuiState { tuiStatePaths :: NEC.NonEmptyCursor FilePath }
  deriving (Show, Eq)

data ResourceName =
  ResourceName
  deriving (Show, Eq, Ord)

data Selected = NotSel | Sel
  deriving Eq

tuiApp :: App TuiState e ResourceName
tuiApp =
  App
    { appDraw = drawTui
    , appChooseCursor = showFirstCursor
    , appHandleEvent = handleTuiEvent
    , appStartEvent = pure
    , appAttrMap = const $ attrMap mempty [("selected", fg red)]
    }

buildInitialState :: IO TuiState
buildInitialState = do
  here <- getCurrentDirectory
  contents <- getDirectoryContents here
  case NE.nonEmpty contents of
    Nothing -> die "There are no directory contents"
    Just ne -> pure $ TuiState $ NEC.makeNonEmptyCursor ne

drawTui :: TuiState -> [Widget ResourceName]
drawTui (TuiState tuiStatePaths) 
  = [ vBox $ mconcat 
      [ map (drawPath NotSel) $ reverse $ NEC.nonEmptyCursorPrev tuiStatePaths
      , [drawPath Sel $ NEC.nonEmptyCursorCurrent tuiStatePaths]
      , map (drawPath NotSel) $ NEC.nonEmptyCursorNext tuiStatePaths
      ]
    ]

drawPath :: Selected -> FilePath -> Widget n
drawPath NotSel fp = str fp
drawPath Sel fp = withAttr "selected" $ str fp

handleTuiEvent :: TuiState -> BrickEvent n e -> EventM n (Next TuiState)
handleTuiEvent s e =
  case e of
    VtyEvent vtye ->
      case vtye of
        EvKey (KChar 'q') [] -> halt s
        EvKey KDown [] -> do
          let nec = tuiStatePaths s
          case NEC.nonEmptyCursorSelectNext nec of
            Nothing -> continue s
            Just nec' -> continue $ s { tuiStatePaths = nec'}
        EvKey KUp [] -> do
          let nec = tuiStatePaths s
          case NEC.nonEmptyCursorSelectPrev nec of
            Nothing -> continue s
            Just nec' -> continue $ s { tuiStatePaths = nec'}
        _ -> continue s
    _ -> continue s
