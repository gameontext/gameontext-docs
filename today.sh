#!/bin/bash
# https://gist.github.com/domenic/ec8b0fc8ab45f39403dd
set -x
set -e # Exit with nonzero exit code if anything fails

# Only check for new posts if this is a cron job. Otherwise, GitHub manages build
if [ "$TRAVIS_EVENT_TYPE" != "cron" ]; then
    echo "Skipping rebuild"
    exit 0
fi

DATE=`date +%Y-%m-%d`
if [ -z "$(find _posts -name $DATE-\* -print -quit)" ]; then
  echo "Skipping rebuild: no posts for today"
  exit 0
fi

git config user.name "Travis CI"
git config user.email "$COMMITTER_EMAIL"

# # Save some useful information
REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}

# Get the deploy key by using Travis's stored variables to decrypt deploy_key.enc
if [ -n "$ENCRYPTION_LABEL" ]; then
  ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
  ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
  ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
  ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
  openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in ../deploy_rsa.enc -out ../deploy_rsa -d
  chmod 600 ../deploy_rsa
  eval `ssh-agent -s`
  ssh-add ../deploy_rsa
fi

# Now that we're all set up, we can push.
git commit --allow-empty -m "Trigger notification"
echo git push $SSH_REPO $TARGET_BRANCH
