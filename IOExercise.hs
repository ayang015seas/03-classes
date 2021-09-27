{-
---
fulltitle: "In class exercise: IOExercise"
---

In-class exercise (IO Monad)
-}

module IOExercise where

import System.FilePath

{-
Rewrite these programs so that they do not use 'do'.
(Make sure that you do not change their behavior!)
-}

simpleProgram :: IO ()
simpleProgram = do
  putStrLn "This is a simple program that does IO."
  putStrLn "What is your name?"
  inpStr <- getLine
  putStrLn $ "Welcome to Haskell, " ++ inpStr ++ "!"

simpleProgram1 =
  putStrLn "This is a simple program that does IO."
    >> ( putStrLn "asdf"
           >> (getLine >>= (\y -> putStrLn $ "Welcome to haskell, " ++ y ++ "!"))
       )

lengthProgram :: IO Int
lengthProgram = do
  let x = length [1, 2, 3, 4, 5, 6]
  putStrLn $ "The length of the list is" ++ show x
  return x

lengthProgram1 :: IO Int
lengthProgram1 =
  return (length [1, 2, 3, 4, 5, 6]) >>= \x ->
    putStrLn ("The length of the list is " ++ show x) >> return x

anotherProgram :: IO ()
anotherProgram = do
  putStrLn "What is your name?"
  inpStr <- getLine
  if inpStr == "Haskell"
    then do
      putStrLn "You rock!"
      return ()
    else putStrLn $ "Hello " ++ inpStr
  putStrLn "That's all!"

anotherProgram1 :: IO ()
anotherProgram1 =
  putStrLn "What is your name?"
    >> ( getLine
           >>= ( \x ->
                   if x == "Haskell"
                     then putStrLn "You rock!"
                     else putStrLn ("Hello " ++ x)
               )
       )
    >> putStrLn "That's all"
