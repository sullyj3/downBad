{-# language ImportQualifiedPost #-}

-- Server Daemon

module Main (main) where

import Prelude hiding (log)
import Streamly.Prelude qualified as Stream
import Control.Monad
import Streamly.Data.Fold qualified as Fold
import Streamly.Internal.Network.Inet.TCP (acceptOnPortLocal)
import Network.Socket qualified as Socket
import Network.Socket (Socket)
import Network.Socket.ByteString (sendAll, recv)
import System.IO (hSetBuffering, hGetLine, hPutStrLn, BufferMode(..), Handle, stderr)
import Ki.Unlifted
import Data.ByteString.UTF8 qualified as UTF8
import Data.ByteString qualified as BS


port = 6777

log = hPutStrLn stderr

main :: IO ()
main = do
  hPutStrLn stderr $ "Server starting on localhost:" <> show port
  Stream.mapM_ handleClient $
    Stream.unfold acceptOnPortLocal port
  
  where handleClient sock = do
          log $ "Client connected on socket: " <> show sock
          sendAll sock (UTF8.fromString "Hello, client!")
          loop sock

        loop :: Socket -> IO ()
        loop sock = do
          resp <- recv sock 256
          if BS.null resp then do
            Socket.close sock
            log "Client closed the connection"
          else do
            log $ "Client: \"" <> show resp <> "\""
            loop sock
