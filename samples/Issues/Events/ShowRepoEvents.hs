module ShowRepoEvents where

import qualified Github.Issues.Events as Github
import Data.List (intercalate)
import Data.Maybe (fromJust)

main = do
  possibleEvents <- Github.eventsForRepo "thoughtbot" "paperclip"
  case possibleEvents of
       (Left error) -> putStrLn $ "Error: " ++ show error
       (Right events) -> do
         putStrLn $ intercalate "\n" $ map formatEvent events

formatEvent event =
  "Issue #" ++ issueNumber event ++ ": " ++
    formatEvent' event (Github.repositoryEventType event)
  where
  formatEvent' event Github.Closed =
    "closed on " ++ createdAt event ++ " by " ++ loginName event ++
      withCommitId event (\commitId -> " in the commit " ++ commitId)
  formatEvent' event Github.Reopened =
    "reopened on " ++ createdAt event ++ " by " ++ loginName event
  formatEvent' event Github.Subscribed =
    loginName event ++ " is subscribed to receive notifications"
  formatEvent' event Github.Unsubscribed =
    loginName event ++ " is unsubscribed from notifications"
  formatEvent' event Github.Merged =
    "merged by " ++ loginName event ++ " on " ++ createdAt event ++
      (withCommitId event $ \commitId -> " in the commit " ++ commitId)
  formatEvent' event Github.Referenced =
    withCommitId event $ \commitId ->
      "referenced from " ++ commitId ++ " by " ++ loginName event
  formatEvent' event Github.Mentioned =
    loginName event ++ " was mentioned in the issue's body"
  formatEvent' event Github.Assigned =
    "assigned to " ++ loginName event ++ " on " ++ createdAt event

loginName = Github.githubOwnerLogin . Github.repositoryEventActor
createdAt = show . Github.fromGithubDate . Github.repositoryEventCreatedAt
withCommitId event f = maybe "" f (Github.repositoryEventCommitId event)
issueNumber = show . Github.issueNumber . fromJust . Github.repositoryEventIssue
