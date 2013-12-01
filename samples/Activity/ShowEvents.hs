module ShowEvents where

import qualified Github.Activity.Events as Github
import Data.List (intercalate)

main = do
  possibleEvents <- Github.events
  case possibleEvents of
       (Left error) -> putStrLn $ "Error: " ++ show error
       (Right events) -> do
         putStrLn $ intercalate "\n" $ map formatEvent events

formatEvent event =
  show (Github.eventActor event) ++ ": " ++ show (Github.eventPayload event)
