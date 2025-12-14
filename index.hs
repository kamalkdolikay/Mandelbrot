{-# LANGUAGE BangPatterns #-}

import Graphics.Gloss
import Graphics.Gloss.Interface.Pure.Game
import Data.Complex
import Control.Parallel.Strategies

main :: IO ()
main = play (InWindow "Haskell – Parallel Mandelbrot (instant zoom, all cores)" (1000,1000) (100,100))
            black 60 (1.0, 0 :+ 0) render handle (const id)
  where
    render (zoom, center) = Pictures $! parMap rpar (pixel zoom center) pixels
      where
        pixels = [ (x,y) | x <- [-500..499], y <- [-500..499] ]

        pixel !zoom' !center' (x,y) =
          let !c = (fromIntegral x / (300*zoom') + realPart center') :+
                   (fromIntegral y / (300*zoom') + imagPart center')
              !i = mandel c 200
          in Translate (fromIntegral x) (fromIntegral y)
             $ color (rainbow i) $ rectangleUpperSolid 1 1

    mandel !c !maxIt = go 0 0
      where
        go !n !z | n == maxIt                  = n
                 | magnitudeSquared z >= 4.0   = n
                 | otherwise                   = go (n+1) (z*z + c)
        magnitudeSquared !z = let a :+ b = z in a*a + b*b

    rainbow !n = makeColor (0.5 + 0.5*sin(fromIntegral n/5))
                           (0.5 + 0.5*cos(fromIntegral n/7))
                           (0.5 + 0.5*sin(fromIntegral n/11)) 1

    handle (EventKey (MouseButton LeftButton) Down _ (px,py)) (zoom, center) =
      (zoom*2, (realPart center + px/(300*zoom)) :+ (imagPart center + py/(300*zoom)))
    handle _ w = w