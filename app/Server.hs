{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE OverloadedRecordDot #-}

module Server (handleRequest) where

import Data.Aeson
import qualified Data.Text as T
import Rpc (RpcRequest (..), RpcResponse (..))
import Tools (toolListResponse, handleToolCall)

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
