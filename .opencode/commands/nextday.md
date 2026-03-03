---
description: Add next day
agent: build
---

Generate the module for the next day. Add the module to the `aoc25.cabal` file and the `app/Main.hs`.
For example, if the latest day is `app/Day11.hs`, then generate a `app/Day12.hs`.

The new day module should look like this:

```
module DayXX (run) where

import Text.Parsec qualified as P

solveA :: [String] -> Int
solveA = length

solveB :: [String] -> Int
solveB = length

run :: String -> IO ()
run input = case P.parse inputP "" input of
  Left err -> print err
  Right parsedInput -> do
    putStrLn $ "A: " <> show (solveA parsedInput)
    putStrLn $ "B: " <> show (solveB parsedInput)
  where
    inputP = P.many1 P.letter `P.sepEndBy` P.newline
```

Just replace the `XX` with the actual day
