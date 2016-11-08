module ARD.ViewPlane where

import ARD.Ray
import ARD.Sampler
import ARD.Vector

data ViewPlane
  = ViewPlane
  { horizontalResolution :: Int
  , verticalResolution :: Int
  , pixelSize :: Double
  , pixelSampler :: Sampler
  }

