{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Data.Aeson
import qualified Data.ByteString.Char8 as BS
import qualified Data.ByteString.Lazy.Char8 as BL
import qualified Data.Text as T
import System.IO (hSetBuffering, stdout, BufferMode(LineBuffering))
import Control.Monad (forever)
import Rpc (RpcResponse (..))
import Server (handleRequest)

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
