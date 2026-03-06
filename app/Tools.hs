{-# LANGUAGE OverloadedStrings #-}

module Tools (toolListResponse, handleToolCall) where

import Data.Aeson
import qualified Data.Aeson.KeyMap as KM
import qualified Data.Text as T

-- Tool Description ----------------------------

toolListResponse :: Value
toolListResponse = object
  [ "tools" .=
      [ object
          [ "name" .= ("add_numbers" :: T.Text)
          , "description" .= ("Add two numbers" :: T.Text)
          , "inputSchema" .= object
              [ "type" .= ("object" :: T.Text)
              , "properties" .= object
                  [ "a" .= object ["type" .= ("number" :: T.Text)]
                  , "b" .= object ["type" .= ("number" :: T.Text)]
                  ]
              , "required" .= ["a", "b" :: T.Text]
              ]
          ]
      , object
          [ "name" .= ("subtract_numbers" :: T.Text)
          , "description" .= ("Subtract two numbers" :: T.Text)
          , "inputSchema" .= object
              [ "type" .= ("object" :: T.Text)
              , "properties" .= object
                  [ "a" .= object ["type" .= ("number" :: T.Text)]
                  , "b" .= object ["type" .= ("number" :: T.Text)]
                  ]
              , "required" .= ["a", "b" :: T.Text]
              ]
          ]
      ]
  ]

-- Tool Implementation ----------------------------

handleToolCall :: Value -> IO Value
handleToolCall (Object o) =
  case (KM.lookup "name" o, KM.lookup "arguments" o) of
    (Just (String "add_numbers"), Just (Object args)) ->
      case (KM.lookup "a" args, KM.lookup "b" args) of
        (Just (Number a), Just (Number b)) ->
          let sumResult = a + b
          in pure $ object
              [ "content" .=
                  [ object
                      [ "type" .= ("text" :: T.Text)
                      , "text" .= T.pack (show sumResult)
                      ]
                  ]
              ]
        _ -> errorResponse "Invalid arguments"
    (Just (String "subtract_numbers"), Just (Object args)) ->
      case (KM.lookup "a" args, KM.lookup "b" args) of
        (Just (Number a), Just (Number b)) ->
          let diffResult = a - b
          in pure $ object
              [ "content" .=
                  [ object
                      [ "type" .= ("text" :: T.Text)
                      , "text" .= T.pack (show diffResult)
                      ]
                  ]
              ]
        _ -> errorResponse "Invalid arguments"
    _ -> errorResponse "Unknown tool"
handleToolCall _ = errorResponse "Invalid params"

errorResponse :: T.Text -> IO Value
errorResponse msg =
  pure $ object
    [ "content" .=
        [ object
            [ "type" .= ("text" :: T.Text)
            , "text" .= msg
            ]
        ]
    ]
