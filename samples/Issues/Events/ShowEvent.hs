module ShowEvent where

import qualified Github.Issues.Events as Github
import Data.List (intercalate)
import Data.Maybe (fromJust)

main = do
  possibleEvent <- Github.event "thoughtbot" "paperclip" 5335772
  case possibleEvent of
       (Left error) -> putStrLn $ "Error: " ++ show error
       (Right event) -> do
         putStrLn $ formatEvent event

formatEvent event = formatEvent' event (Github.repositoryEventType event)
  where
  formatEvent' event Github.Closed =
    "Closed on " ++ createdAt event ++ " by " ++ loginName event ++
      withCommitId event (\commitId -> " in the commit " ++ commitId)
  formatEvent' event Github.Reopened =
    "Reopened on " ++ createdAt event ++ " by " ++ loginName event
  formatEvent' event Github.Subscribed =
    loginName event ++ " is subscribed to receive notifications"
  formatEvent' event Github.Unsubscribed =
    loginName event ++ " is unsubscribed from notifications"
  formatEvent' event Github.Merged =
    "Issue merged by " ++ loginName event ++ " on " ++ createdAt event ++
      (withCommitId event $ \commitId -> " in the commit " ++ commitId)
  formatEvent' event Github.Referenced =
    withCommitId event $ \commitId ->
      "Issue referenced from " ++ commitId ++ " by " ++ loginName event
  formatEvent' event Github.Mentioned =
    loginName event ++ " was mentioned in the issue's body"
  formatEvent' event Github.Assigned =
    "Issue assigned to " ++ loginName event ++ " on " ++ createdAt event

loginName = Github.githubOwnerLogin . Github.repositoryEventActor
createdAt = show . Github.fromGithubDate . Github.repositoryEventCreatedAt
withCommitId event f = maybe "" f (Github.repositoryEventCommitId event)
