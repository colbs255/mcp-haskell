# AGENTS.md

This file contains guidelines and commands for agentic coding agents working in this Haskell Advent of Code repository.

## Build and Development Commands

### Building and Running
- `cabal build` - Build the project
- `./runday 01` - Shortcut script to run Day 01 (accepts day number as argument)

### Code Formatting
- `just format` - Format all Haskell files using Ormolu (preferred method)
- All code should be formatted with Ormolu before committing

### Linting and Type Checking
- `cabal build` serves as the primary type checker
- The project uses `-Wall` and additional warning flags (see cabal file for complete list)
- Build failures indicate type errors or warnings that must be fixed

### Testing Individual Days
- `./runday XX` where XX is the day number (e.g., `./runday 08`)
- This runs the day with its corresponding input file from `input/dayXX.txt`

## Code Style Guidelines

### Module Structure
- Each day should have its own module: `Day01`, `Day02`, etc.
- Export only the `run` function: `module Day01 (run) where`
- Utility modules like `Util` and `UnionFind` can export more functions
- All day modules should follow the pattern in `app/DayXX.hs`

### Import Style
- Use qualified imports for most modules: `import Text.Parsec qualified as P`
- Import Parsec String type: `import Text.Parsec.String (Parser)`
- Group imports by type (standard library, local modules)
- Keep imports minimal and explicit

### Function Naming
- Main entry point for each day: `run :: String -> IO ()`
- Parser functions: `thingP :: Parser Thing`
- Solver functions: `solveA :: Input -> Output`, `solveB :: Input -> Output`
- Helper functions should be descriptive but concise

### Data Types
- Use record syntax for complex data types with meaningful field names
- Derive `Show`, `Eq`, `Ord` where appropriate
- Keep data types focused on the problem domain
- Example: `data Coord = Coord {x :: Int, y :: Int, z :: Int} deriving (Eq, Ord)`

### Parsing Patterns
- Use Parsec for all input parsing
- Top-level parser: `inputP :: Parser [DataType]`
- Element parser: `dataTypeP :: Parser DataType`
- Always handle parse errors in the `run` function:
  ```haskell
  case P.parse inputP "" input of
    Left err -> print err
    Right parsedInput -> -- process input
  ```

### Error Handling
- Use `error` only for unrecoverable programmer errors
- Handle parse failures gracefully
- Return proper error messages for invalid inputs
- Avoid partial functions when possible

### Code Organization
- Place helper functions close to where they're used
- Group related functionality
- Use where clauses for local helpers
- Keep functions small and focused

### Standard Library Usage
- Use qualified imports for container modules
- Leverage `Data.List` functions before implementing custom logic
- Use `Grid` in `Util.hs` for grid-based problems

### File Structure
- All source code in `app/` directory
- Input files in `input/` directory with naming `dayXX.txt`
- Utility modules in `app/` alongside day modules
- No test files - each day serves as its own test case

### Performance Considerations
- For large inputs, consider using more efficient data structures
- Use `Data.Map` and `Data.Set` for O(log n) operations
- Most Advent of Code problems can be solved with straightforward solutions

### Documentation
- Add type annotations for all top-level functions
- Use comments sparingly - let the code be self-documenting
- Document complex algorithms with brief explanations
- No Haddock documentation required for this project

## Project Configuration

### GHC Options
The project uses these warning flags (enforced via cabal):
- `-Wall` - Enable all warnings
- `-Wmissing-export-lists`
- `-Wmissing-home-modules`
- `-Widentities`
- `-Wredundant-constraints`
- `-Wcpp-undef`
- `-Wpartial-fields`
- `-Wunused-packages`

### Language Extensions
- `GHC2024` - Modern Haskell language features
- No specific extensions are required beyond GHC2024

### Dependencies
- `base` - Standard library
- `array` - Array operations
- `containers` - Data structures (Map, Set)
- `parsec` - Parser combinator library
- `mtl` - Monad transformers

## Development Workflow

1. Create new day module: `app/DayXX.hs`
2. Add module to cabal file's `other-modules` list
3. Add qualified import to `Main.hs`
4. Add entry to `solutions` Map in `Main.hs`
5. Create input file: `input/dayXX.txt`
6. Implement `run` function with parsing and solving
7. Test with `./runday XX`
8. Format code with `just format`
9. Build to check for warnings/errors

## Common Patterns

### Grid Problems
- Use the `Util` module's `Grid` type and helper functions
- Import as `import Util qualified`
- Provides grid parsing, neighbor access, bounds checking

### Union Find Problems
- Use the `UnionFind` module for connectivity problems
- Import as `import UnionFind qualified as UF`
- Provides efficient union-find operations

### Parser Structure
```haskell
module DayXX (run) where

import Text.Parsec qualified as P
import Text.Parsec.String (Parser)

dataTypeP :: Parser DataType
dataTypeP = -- implementation

inputP :: Parser [DataType]
inputP = dataTypeP `P.sepEndBy` P.newline

run :: String -> IO ()
run input = case P.parse inputP "" input of
  Left err -> print err
  Right parsedInput -> do
    putStrLn $ "A: " <> show (solveA parsedInput)
    putStrLn $ "B: " <> show (solveB parsedInput)
```
