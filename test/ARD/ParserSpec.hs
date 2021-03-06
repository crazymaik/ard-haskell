module ARD.ParserSpec where

import qualified ARD.Camera as Camera
import qualified ARD.Color as Color
import qualified ARD.Parser as Parser
import qualified ARD.Ray as Ray
import qualified ARD.Vector as V

import Control.Monad
import qualified Data.Either as Either
import qualified Data.Maybe as Maybe
import Test.Hspec
import Text.ParserCombinators.Parsec

spec :: Spec
spec = describe "Parser" $ do
  it "parses empty scene" $
    void (pSuccess "")
  it "parses lines with comment" $
    void (pSuccess "#c1\n#c2\n#c3")
  it "parses lines with comments appended" $ do
    context <- pSuccess "backgroundColor 0 0.5 1 # A comment\n"
    Parser.backgroundColor context `shouldBe` (Just $ Color.RGB 0 0.5 1)
  it "parses perspective camera split over multiple lines" $ do
    let
      scene =
        "camera { \
          \pinhole \
          \eye 0 1 2 \
          \lookAt 1 2 3 \
          \up 2 3 4 \
          \distance 1 \
        \}"
    context <- pSuccess scene
    let
      camera = Parser.camera context
    Maybe.isJust camera `shouldBe` True
  it "parses construct with minimum spaces" $ do
    context <- pSuccess "light{ambient color 0 0 0 ls 1}"
    length (Parser.lights context) `shouldBe` 1
  it "needs space after symbol" $
    pFail "light{ambientcolor 0 0 0 ls 1}"
  it "needs space after value" $
    pFail "light{ambient color 0 0 0ls 1}"
  it "let statement with material and color" $ do
    let
      input =
        "let mat = material { matte cd 1 1 1 kd 1 ka 1 }\n\
        \let col = color 0 0 0\n\
        \sphere { center 0 0 0 radius 1 material mat }"
    context <- pSuccess input
    let
      objects = Parser.sceneObjects context
      globals = Parser.globals context
      globalColors = Parser.globalColors globals
      globalMaterials = Parser.globalMaterials globals
    length globalColors `shouldBe` 1
    length globalMaterials `shouldBe` 1
    length objects `shouldBe` 1
  it "disallows declaring name twice" $ do
    let
      input =
        "let m = color 0 1 0\n\
        \let m = material { matte cd 1 1 1 kd 1 ka 1 }\n"
    pFail input

pSuccess :: String -> IO Parser.Context
pSuccess input =
  case Parser.parseScene "" input of
    Left err -> fail ("Expected success but failed with:\n" ++ show err)
    Right context -> return context

pFail :: String -> Expectation
pFail input =
  case Parser.parseScene "" input of
    Left _ -> return ()
    _ -> expectationFailure "Expected parse failure but succeeded"

