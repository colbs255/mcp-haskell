{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}

module Rpc (RpcRequest (..), RpcResponse (..)) where

import Data.Aeson
import qualified Data.Text as T

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
