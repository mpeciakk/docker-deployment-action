#!/bin/sh
set -eu

execute_ssh() {
  echo "SSH: $@"
  ssh -t -q \
    -i "$HOME/.ssh/id_rsa" \
    -p $INPUT_REMOTE_PORT \
    -o StrictHostKeyChecking=no \
    "$INPUT_REMOTE_HOST" "$@"
}

if [ -z "$INPUT_REMOTE_PORT" ]; then
  INPUT_REMOTE_PORT=22
fi

if [ -z "$INPUT_REMOTE_HOST" ]; then
  echo "Input remote_host is required!"
  exit 1
fi

if [ -z "$INPUT_SSH_KEY" ]; then
  echo "Input ssh_key is required!"
  exit 1
fi

if [ -z "$INPUT_ARGS" ]; then
  echo "Input args is required!"
  exit 1
fi

if [ -z "$INPUT_DEPLOY_PATH" ]; then
  echo "Input deploy_path is required!"
  exit 1
fi

if [ -z "$INPUT_STACK_FILE_NAME" ]; then
  INPUT_STACK_FILE_NAME=docker-compose.yml
fi

STACK_FILE="$INPUT_DEPLOY_PATH/$INPUT_STACK_FILE_NAME"
DEPLOYMENT_COMMAND_OPTIONS=""

INPUT_DEPLOYMENT_MODE="docker compose"
DEPLOYMENT_COMMAND="docker compose $DEPLOYMENT_COMMAND_OPTIONS -f $STACK_FILE"

SSH_HOST=${INPUT_REMOTE_HOST#*@}

echo "Registering SSH keys..."
install -m 600 -D /dev/null $HOME/.ssh/id_rsa
echo "$INPUT_SSH_KEY" > $HOME/.ssh/id_rsa
ssh-keyscan -H $SSH_HOST > $HOME/.ssh/known_hosts

execute_ssh "mkdir -p $INPUT_DEPLOY_PATH/stacks || true"
FILE_NAME="docker-stack-$(date +%Y%m%d%s).yaml"

scp -i "$HOME/.ssh/id_rsa" \
  -P $INPUT_REMOTE_PORT \
  -o StrictHostKeyChecking=no \
  $INPUT_STACK_FILE_NAME "$INPUT_REMOTE_HOST:$INPUT_DEPLOY_PATH/stacks/$FILE_NAME"

execute_ssh "ln -nfs $INPUT_DEPLOY_PATH/stacks/$FILE_NAME $INPUT_DEPLOY_PATH/$INPUT_STACK_FILE_NAME"

if ! [ -z "$INPUT_PULL_IMAGES" ] && [ $INPUT_PULL_IMAGES = 'true' ]; then
  execute_ssh ${DEPLOYMENT_COMMAND} "pull"
fi

execute_ssh ${DEPLOYMENT_COMMAND} "$INPUT_ARGS" 2>&1
