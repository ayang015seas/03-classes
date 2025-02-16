{-
---
fulltitle: "In class exercise: Semigroup, Monoid and Foldable"
date: September 29, 2019
---
-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE FlexibleInstances #-}

module MonoidFoldable where

import qualified Data.List as List
import Test.HUnit (Test (TestList), runTestTT, (~?=))
import Prelude hiding (all, and, any, or)

{-
Monoids
-------
First, read just the 'Semigroups and Monoids' section of HW 03's
[SortedList](../../../hw/hw03/SortedList.html) module.
Note that this section defines the following function that tailors a fold
operation to a specific instance of the `Monoid` class.
-}

foldList :: Monoid b => [b] -> b
foldList = List.foldr (<>) mempty

{-
For example, because the `String` type is an instance of this class
(using `++` for `mappend`) we can `foldList` a list of `String`s to
a single string.
-}

-- GREEN
-- to summarize, we first defined monoid/semigroups for specific operators
-- foldmap basically turned list elements into these monoids and combined them
-- using the methods we specified
-- we also implemented foldmap for funzies

tm0 :: Test
tm0 = foldList ["C", "I", "S", "5", "5", "2"] ~?= "CIS552"

{-
The assignment shows you that numbers can instantiate this class in multiple
ways.  Like numbers, `Booleans` can be made an instance of the `Monoid` class
in two different ways.
-}

newtype And = And {getAnd :: Bool} deriving (Eq, Show)

newtype Or = Or {getOr :: Bool} deriving (Eq, Show)

{-
Make sure that you understand these type definitions. We are defining a type
`And` with single data constructor (also called `And`). The argument of this
data constructor is a record with a single field, called `getAnd`. What this
means is that `And` and `getAnd` allow us to convert `Bool`s to `And` and
back.
      λ> :t And
      And :: Bool -> And
      λ> :t getAnd
      getAnd :: And -> Bool
Above, `newtype` is like data, but is restricted to a single variant. It is
typically used to create a new name for an existing type. This new name allows
us to have multiple instances for the same type (as below) or to provide type
abstraction (like `SortedList` in the HW).
Your job is to complete these instances that can tell us whether any of the
booleans in a list are true, or whether all of the booleans in a list are
true. (See two test cases below for an example of the behavior.)
-}

anyT1 :: Test
anyT1 = getOr (foldList (fmap Or [True, False, True])) ~?= True

allT2 :: Test
allT2 = getAnd (foldList (fmap And [True, False, True])) ~?= False

instance Semigroup And where
  (<>) x y = And {getAnd = getAnd x && getAnd y}

instance Monoid And where
  mempty = And {getAnd = True}

instance Semigroup Or where
  (<>) x y = Or {getOr = getOr x || getOr y}

instance Monoid Or where
  mempty = Or {getOr = False}

{-
Because `And` and `Or` wrap boolean values, we can be sure that our instances
have the right properties by testing the truth tables.  (There are more
concise to write these tests, but we haven't covered them yet.)
-}

-- >>> runTestTT monoidAnd
-- >>> runTestTT monoidOr
-- Counts {cases = 12, tried = 12, errors = 0, failures = 0}
-- Counts {cases = 12, tried = 12, errors = 0, failures = 0}

monoidAnd :: Test
monoidAnd =
  TestList
    [ And False <> (And False <> And False) ~?= (And False <> And False) <> And False,
      And False <> (And False <> And True) ~?= (And False <> And False) <> And True,
      And False <> (And True <> And False) ~?= (And False <> And True) <> And False,
      And False <> (And True <> And True) ~?= (And False <> And True) <> And True,
      And True <> (And False <> And False) ~?= (And True <> And False) <> And False,
      And True <> (And False <> And True) ~?= (And True <> And False) <> And True,
      And True <> (And True <> And False) ~?= (And True <> And True) <> And False,
      And True <> (And True <> And True) ~?= (And True <> And True) <> And True,
      And True <> mempty ~?= And True,
      And False <> mempty ~?= And False,
      mempty <> And True ~?= And True,
      mempty <> And False ~?= And False
    ]

monoidOr :: Test
monoidOr =
  TestList
    [ Or False <> (Or False <> Or False) ~?= (Or False <> Or False) <> Or False,
      Or False <> (Or False <> Or True) ~?= (Or False <> Or False) <> Or True,
      Or False <> (Or True <> Or False) ~?= (Or False <> Or True) <> Or False,
      Or False <> (Or True <> Or True) ~?= (Or False <> Or True) <> Or True,
      Or True <> (Or False <> Or False) ~?= (Or True <> Or False) <> Or False,
      Or True <> (Or False <> Or True) ~?= (Or True <> Or False) <> Or True,
      Or True <> (Or True <> Or False) ~?= (Or True <> Or True) <> Or False,
      Or True <> (Or True <> Or True) ~?= (Or True <> Or True) <> Or True,
      Or True <> mempty ~?= Or True,
      Or False <> mempty ~?= Or False,
      mempty <> Or True ~?= Or True,
      mempty <> Or False ~?= Or False
    ]

{-
Foldable
--------
Now, read the section marked `The Foldable Typeclass` in the
[MergeSort](../../../hw/hw03/MergeSort.html) module.
We can use your Monoid instances for `Or` and `And` to generalize
operations to any data structure.
For example, we can generalize the `and` operation to any Foldable data
structure using `foldMap`.
-}

and :: Foldable t => t Bool -> Bool
and = getAnd . foldMap And

{-
Your job is to define these three related operations
-}

-- foldable just means that the data structure must have foldMap implemented
-- So that way we know this foldmap is valid
-- we use instance Tree Foldable to make tree be part of the foldable class
-- the foldMap makes use of the monoid mempty and associated operators
-- because And/Or are semigroup/monoids. Since <> only works on semigroups, we need
-- to turn the list elements into semigroups/monoids in order for foldmap to execute

or :: Foldable t => t Bool -> Bool
or x = (getOr . foldMap Or) x

all :: Foldable t => (a -> Bool) -> t a -> Bool
all f = getAnd . foldMap (And . f)

any :: Foldable t => (a -> Bool) -> t a -> Bool
any f = getOr . foldMap (Or . f)

{-
so that the following tests pass
-}

tf0 :: Test
tf0 = or [True, False, False, True] ~?= True

tf1 :: Test
tf1 = all (> 0) [1 :: Int, 2, 4, 18] ~?= True

tf2 :: Test
tf2 = all (> 0) [1 :: Int, -2, 4, 18] ~?= False

tf3 :: Test
tf3 = any (> 0) [1 :: Int, 2, 4, 18] ~?= True

tf4 :: Test
tf4 = any (> 0) [-1 :: Int, -2, -4, -18] ~?= False

{-
Application
-----------
Recall our familiar `Tree` type. Haskell can derive the `Functor` instance for this type so we ask it to do so.
-}

data Tree a = Empty | Branch a (Tree a) (Tree a) deriving (Eq, Functor)

{-
And here is an example `Tree`.
-}

t1 :: Tree String
t1 = Branch "d" (Branch "b" (l "a") (l "c")) (Branch "f" (l "e") (l "g"))
  where
    l x = Branch x Empty Empty

{-
We *could* make this type an instance of `Foldable` using the definition of
`foldrTree` from the TreeFolds module.
But, for practice, complete the instance using `foldMap`.
-}

instance Foldable Tree where
  foldMap f Empty = mempty
  foldMap f (Branch a b c) = foldMap f b <> f a <> foldMap f c

{-
With this instance, we can for example, verify that all of the sample strings
above have length 1.
-}

tt1 :: Test
tt1 = all ((== 1) . length) t1 ~?= True

{-
Finally, look at the documentation for the
[Foldable](https://hackage.haskell.org/package/base-4.14.1.0/docs/Data-Foldable.html)
class and find some other tree operations that we get automatically for
free.
-}

tt2 :: Test
tt2 = undefined

{-
Oblig-main
----------
-}

main :: IO ()
main = do
  _ <- runTestTT $ TestList [tm0, anyT1, allT2, monoidAnd, monoidOr, tf0, tf1, tf2, tf3, tf4, tt1]
  return ()
