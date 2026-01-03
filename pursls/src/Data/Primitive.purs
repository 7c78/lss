module Data.Primitive where

class Primitive :: forall k. k -> Constraint
class Primitive a

instance Primitive Int
instance Primitive Number
instance Primitive String
instance Primitive Char
instance Primitive Boolean
