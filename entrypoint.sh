#!/bin/sh

WORKSPACE=${WORKSPACE:-$PWD}

export CI_BUILD_ID=${GITHUB_RUN_ID:-$CI_BUILD_ID}
export CI_BUILD_NUMBER=${GITHUB_RUN_NUMBER:-$CI_BUILD_NUMBER}
export EVENT_PATH=${GITHUB_EVENT_PATH:-$EVENT_PATH}
export REPOSITORY=${GITHUB_REPOSITORY:-$REPOSITORY}


if [ "$GITHUB_EVENT_NAME" = "pull_request" ]; then
  export COMMIT_REF_NAME=${GITHUB_HEAD_REF:-$COMMIT_REF_NAME}

  if [ -f "$EVENT_PATH" ]; then
    PR_COMMIT_SHA=$(cat $EVENT_PATH | grep -oP '(?<="after": ")[^"]*')
  fi

  if [ -z ${PR_COMMIT_SHA} ] || [ "$PR_COMMIT_SHA" = "null" ]; then
    export COMMIT_HASH=${GITHUB_SHA:-$COMMIT_HASH}
  else
    export COMMIT_HASH=${PR_COMMIT_SHA:-$COMMIT_HASH}
  fi
else
  export COMMIT_REF_NAME=${GITHUB_REF_NAME:-$COMMIT_REF_NAME}
  export COMMIT_HASH=${GITHUB_SHA:-$COMMIT_HASH}
fi


echo Environment:
[ -z ${WORKSPACE} ] || echo "WORKSPACE=$WORKSPACE"
[ -z ${CI_BUILD_ID} ] || echo "CI_BUILD_ID=$CI_BUILD_ID"
[ -z ${CI_BUILD_NUMBER} ] || echo "CI_BUILD_NUMBER=$CI_BUILD_NUMBER"
[ -z ${EVENT_PATH} ] || echo "EVENT_PATH=$EVENT_PATH"
[ -z ${COMMIT_HASH} ] || echo "COMMIT_HASH=$COMMIT_HASH"
[ -z ${COMMIT_REF_NAME} ] || echo "COMMIT_REF_NAME=$COMMIT_REF_NAME"
[ -z ${REPOSITORY} ] || echo "REPOSITORY=$REPOSITORY"
echo

cd $WORKSPACE

if [ "$INPUT_FINALIZE" = "true" ] || [ "$INPUT_FINALIZE" = "1" ]; then
  CI_BUILD_ID=$CI_BUILD_ID \
  CI_BUILD_NUMBER=$CI_BUILD_NUMBER \
  EVENT_PATH=$EVENT_PATH \
  COMMIT_HASH=$COMMIT_HASH \
  COMMIT_REF_NAME=$COMMIT_REF_NAME \
  REPOSITORY=$REPOSITORY \
  lost-pixel finalize $@
else
  CI_BUILD_ID=$CI_BUILD_ID \
  CI_BUILD_NUMBER=$CI_BUILD_NUMBER \
  EVENT_PATH=$EVENT_PATH \
  COMMIT_HASH=$COMMIT_HASH \
  COMMIT_REF_NAME=$COMMIT_REF_NAME \
  REPOSITORY=$REPOSITORY \
  lost-pixel $@
fi
