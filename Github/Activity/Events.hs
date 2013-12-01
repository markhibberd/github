-- | The Github activity events API, which is described on
-- <http://developer.github.com/v3/activity/events/>
module Github.Activity.Events (
 events
,module Github.Data
) where

import Github.Data
import Github.Private

-- | List public events
--
-- > events
events :: IO (Either Error [Event])
events =
  githubGet ["events"]