module Data.Char.Safe where

foreign import toUpper :: Char -> Char
foreign import toLower :: Char -> Char
foreign import isDigit :: Char -> Boolean
foreign import isAlpha :: Char -> Boolean
foreign import isAlphaNum :: Char -> Boolean
foreign import isUpper :: Char -> Boolean
foreign import isLower :: Char -> Boolean
