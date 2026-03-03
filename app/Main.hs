{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}

module Main where

import GHC.Generics
import Data.Aeson
import qualified Data.Aeson as A
import qualified Data.ByteString.Char8 as BS
import qualified Data.ByteString.Lazy as BLS
import qualified Data.ByteString.Lazy.Char8 as BL
import qualified Data.Text as T
import System.IO
import Control.Monad (forever)

-- JSON-RPC Request ----------------------------

data RpcRequest = RpcRequest
  { jsonrpc :: T.Text
  , method  :: T.Text
  , params  :: Maybe Value
  , rpcId      :: Maybe Value
  } deriving (Show, Generic)

instance FromJSON RpcRequest

-- JSON-RPC Response ----------------------------

data RpcResponse = RpcResponse
  { jsonrpc :: T.Text
  , result  :: Value
  , rpcId      :: Maybe Value
  } deriving (Show, Generic)

instance ToJSON RpcResponse

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
      ]
  ]

-- Tool Implementation ----------------------------

handleToolCall :: Value -> IO Value
handleToolCall (Object o) =
  case (lookup "name" o, lookup "arguments" o) of
    (Just (String "add_numbers"), Just (Object args)) ->
      case (lookup "a" args, lookup "b" args) of
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

-- Dispatcher ----------------------------

handleRequest :: RpcRequest -> IO RpcResponse
handleRequest req =
  case method req of
    "tools/list" ->
      pure $ RpcResponse "2.0" toolListResponse (req.rpcId)

    "tools/call" ->
      case params req of
        Just p -> do
          resultVal <- handleToolCall p
          pure $ RpcResponse "2.0" resultVal (req.rpcId)
        Nothing ->
          pure $ RpcResponse "2.0"
            (object ["error" .= ("Missing params" :: T.Text)])
            (req.rpcId)

    _ ->
      pure $ RpcResponse "2.0"
        (object ["error" .= ("Unknown method" :: T.Text)])
        (req.rpcId)

-- Main Loop ----------------------------

main :: IO ()
main = do
  hSetBuffering stdout LineBuffering
  forever $ do
    line <- BS.getLine
    case eitherDecode (BL.fromStrict line) of
      Left err -> BL.putStrLn $ encode $
        RpcResponse "2.0"
          (object ["error" .= T.pack err])
          Nothing
      Right req -> do
        resp <- handleRequest req
        BL.putStrLn $ encode resp
