{-# language ImportQualifiedPost #-}
{-# language OverloadedStrings #-}
{-# LANGUAGE LambdaCase #-}

module Command where

import Data.ByteString (ByteString)
import Data.ByteString.UTF8 qualified as UTF8
import qualified Data.ByteString.Char8 as Char8

data Command
  = CmdDownload {cmdDownloadUrl :: String}
  | CmdLs
  deriving (Show)

toByteString :: Command -> ByteString
toByteString = \case
  CmdDownload url -> "download " <> UTF8.fromString url
  CmdLs -> "ls"

fromByteString :: ByteString -> Maybe Command
fromByteString bs = case Char8.words bs of
  ["ls"] -> Just CmdLs
  ["download", url] -> Just $ CmdDownload (UTF8.toString url)
  _ -> Nothing

