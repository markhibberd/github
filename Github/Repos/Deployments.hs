{-# LANGUAGE OverloadedStrings #-}
-- | The repo starring API as described on
-- <http://developer.github.com/v3/repos/deployments/>.
module Github.Repos.Deployments (
 deployments
,createDeployment
,deploymentStatus
,createDeploymentStatus
,module Github.Data
) where

import Github.Data
import Github.Private

import Data.Aeson (Value(String, Bool))
import Data.Map (fromList)
import Data.Text (pack, Text)

-- | The list of deployments for a repository.
deployments :: Maybe GithubAuth -> String -> String -> IO (Either Error [Deployment])
deployments auth userName repoName =
  githubGet' auth ["repos", userName, repoName, "deployments"]

createDeployment :: GithubAuth -> String -> String -> String
                 -> Maybe Bool -> Maybe String -> Maybe Bool -> Maybe String
                 -> IO (Either Error Deployment)
createDeployment auth userName repoName ref force payload autoMerge desc =
  githubPost auth ["repos", userName, repoName, "deployments"] (fromList (("ref", String (pack ref)): concat
    [ jinB "force" force
    , jinS "payload" payload
    , jinB "auto_merge" autoMerge
    , jinS "description" desc
    ]
  ))

deploymentStatus :: Maybe GithubAuth -> String -> String -> Integer -> IO (Either Error [DeploymentStatus])
deploymentStatus auth userName repoName deployId =
  githubGet' auth ["repos", userName, repoName, "deployments", show deployId, "statuses"]

createDeploymentStatus :: GithubAuth -> String -> String -> Integer -> String
                       -> Maybe String -> Maybe String -> IO (Either Error DeploymentStatus)
createDeploymentStatus auth userName repoName deployId state targetUrl desc =
  githubPost auth ["repos", userName, repoName, "deployments", show deployId, "statuses"] (
    fromList (("state", String (pack state)): concat
    [ jinS "target_url" targetUrl
    , jinS "description" desc
    ]
  ))

-- json kludge
jinS :: String -> Maybe String -> [(Text, Value)]
jinS k (Just x) = [(pack k, String (pack x))]
jinS _ Nothing = []

jinB :: String -> Maybe Bool -> [(Text, Value)]
jinB k (Just x) = [(pack k, Bool x)]
jinB _ Nothing = []

