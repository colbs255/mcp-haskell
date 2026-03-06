{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}

module Main (main) where

import Data.Aeson
import qualified Data.Aeson.KeyMap as KM
import qualified Data.ByteString.Char8 as BS
import qualified Data.ByteString.Lazy.Char8 as BL
import qualified Data.Text as T
import System.IO (hSetBuffering, stdout, BufferMode(LineBuffering))
import Control.Monad (forever)

-- JSON-RPC Request ----------------------------

data RpcRequest = RpcRequest
  { jsonrpc :: T.Text
  , method  :: T.Text
  , params  :: Maybe Value
  , rpcId   :: Maybe Value
  } deriving (Show)

instance FromJSON RpcRequest where
  parseJSON = withObject "RpcRequest" $ \o ->
    RpcRequest
      <$> o .: "jsonrpc"
      <*> o .: "method"
      <*> o .:? "params"
      <*> o .:? "id"

-- JSON-RPC Response ----------------------------

data RpcResponse = RpcResponse
  { jsonrpc :: T.Text
  , result  :: Value
  , rpcId   :: Maybe Value
  } deriving (Show)

instance ToJSON RpcResponse where
  toJSON r = object $
    [ "jsonrpc" .= (r.jsonrpc)
    , "result"  .= (r.result)
    ] <> maybe [] (\i -> ["id" .= i]) (r.rpcId)

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

-- Initialize Response ----------------------------

initializeResponse :: Value
initializeResponse = object
  [ "protocolVersion" .= ("2025-03-26" :: T.Text)
  , "capabilities" .= object
      [ "tools" .= object
          [ "listChanged" .= False
          ]
      ]
  , "serverInfo" .= object
      [ "name" .= ("mcp-haskell" :: T.Text)
      , "version" .= ("0.1.0" :: T.Text)
      ]
  ]

-- Dispatcher ----------------------------

handleRequest :: RpcRequest -> IO (Maybe RpcResponse)
handleRequest req =
  case method req of
    "initialize" ->
      pure $ Just $ RpcResponse "2.0" initializeResponse (req.rpcId)

    "notifications/initialized" ->
      pure Nothing

    "tools/list" ->
      pure $ Just $ RpcResponse "2.0" toolListResponse (req.rpcId)

    "tools/call" ->
      case params req of
        Just p -> do
          resultVal <- handleToolCall p
          pure $ Just $ RpcResponse "2.0" resultVal (req.rpcId)
        Nothing ->
          pure $ Just $ RpcResponse "2.0"
            (object ["error" .= ("Missing params" :: T.Text)])
            (req.rpcId)

    _ ->
      pure $ Just $ RpcResponse "2.0"
        (object ["error" .= ("Unknown method" :: T.Text)])
        (req.rpcId)

-- Main Loop ----------------------------

main :: IO ()
main = do
  hSetBuffering stdout LineBuffering
  let inputLog = "input_log.txt"
  forever $ do
    line <- BS.getLine
    appendFile inputLog (BS.unpack line <> "\n")
    case eitherDecode (BL.fromStrict line) of
      Left err -> BL.putStrLn $ encode $
        RpcResponse "2.0"
          (object ["error" .= T.pack err])
          Nothing
      Right req -> do
        mResp <- handleRequest req
        case mResp of
          Just resp -> BL.putStrLn $ encode resp
          Nothing   -> pure ()
