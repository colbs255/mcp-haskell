module MatrixSpec (spec) where

import Test.Hspec
import Matrix

spec :: Spec
spec = describe "Matrix" $ do
  describe "backSolve" $ do
    it "solves a simple 2x2 system" $ do
      let matrix = [
                    [1, 0, 2],
                    [0, 1, 1]
                  ] :: Matrix
          initial = [Nothing, Nothing] :: [Maybe Rational]
      backSolve matrix initial `shouldBe` [2, 1]

    it "solves system with a free variable" $ do
      let matrix = [
                    [1, 0, 0, 2],
                    [0, 1, 1, 3]
                  ] :: Matrix
          initial = [Nothing, Nothing, Just 1] :: [Maybe Rational]
      backSolve matrix initial `shouldBe` [2, 2, 1]

    it "solves a 4x7 system with free variables" $ do
      let matrix = [ [1, 0, 0, 1, 0, -1, 2]
                   , [0, 1, 0, 0, 0,  1, 5]
                   , [0, 0, 1, 1, 0, -1, 1]
                   , [0, 0, 0, 0, 1,  1, 3]
                   ] :: Matrix
          initial = [Nothing, Nothing, Nothing, Just 0, Nothing, Just 0] :: [Maybe Rational]
      backSolve matrix initial `shouldBe` [2, 5, 1, 0, 3, 0]

    it "solves system with a zero row" $ do
      let matrix = [[1, 2, 5], [0, 0, 0]] :: Matrix
          initial = [Nothing, Just 1] :: [Maybe Rational]
      backSolve matrix initial `shouldBe` [3, 1]

  describe "rref" $ do
    it "reduces a simple matrix to RREF" $ do
      let matrix = [[2, 4, 10], [1, 2, 5]] :: Matrix
      rref matrix `shouldBe` [[1, 2, 5], [0, 0, 0]]
