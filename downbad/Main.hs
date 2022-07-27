{-# LANGUAGE ImportQualifiedPost #-}

-- client

module Main (main) where

import Data.ByteString qualified as BS
import Data.ByteString.UTF8 qualified as UTF8
import Network.Run.TCP (runTCPClient)
import Network.Socket (Socket)
import Network.Socket qualified as Socket
import Network.Socket.ByteString (recv, sendAll)
import System.IO (BufferMode (..), Handle, hGetLine, hPutStrLn, hSetBuffering)

port = "6777"

main :: IO ()
main = do
  runTCPClient "127.0.0.1" port $ \sock -> do
    sendAll sock (UTF8.fromString "Hello, server!")
