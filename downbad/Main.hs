{-# language ImportQualifiedPost #-}

-- client

module Main (main) where

import Network.Socket qualified as Socket
import System.IO (hSetBuffering, hGetLine, hPutStrLn, BufferMode(..), Handle)
import Ki.Unlifted


port = 6776

main :: IO ()
main = pure ()
