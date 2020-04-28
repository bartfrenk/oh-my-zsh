#!/bin/zsh

alias ls="ls --color=auto --group-directories-first --classify"
alias xcb='xclip -selection clipboard'
alias ecs='/opt/bin/ecs-cli-linux-amd64-latest'
alias apr="apparatus"

aws-session() {
  AWS_CONFIG=$HOME/.aws.vault/config /opt/bin/aws-vault exec \
            --session-ttl=8h --assume-role-ttl=1h \
            --server developer --backend=secret-service
}

aws() {
  if (( ${+AWS_VAULT} )); then
    AWS_CONFIG=$HOME/.aws.vault/config /home/bart/.pyenv.overrides/aws ${*:1}
  else
    AWS_CONFIG=$HOME/.aws.vault/config /opt/bin/aws-vault exec developer \
              -- aws ${*:1}
  fi
}

with-aws() {
  AWS_CONFIG=$HOME/.aws.vault/config /opt/bin/aws-vault exec developer \
            -- ${*:1}
}

aws-nrepl() {
  with-aws clj -A:nrepl
}

alert() {
  notify-send --urgency=low "$([ $? -eq 0 ] && echo success || echo failure)"
}

cafe() {
  # Dump random noise to the terminal
  cat /dev/urandom | hexdump -C | grep "ca fe"
}

whatip() {
  # Print your own outgoing IP
  dig +short myip.opendns.com @resolver1.opendns.com
}

become() {
  eval $($HOME/.local/bin/become "$1")
}

py() {
  case $1 in
    "clean")
      find . -name "*.py[c|o]" -o -name __pycache__ | xargs rm -rf
      ;;
    "init")
      pyenv virtualenv 3.6.8 "$2"
      echo "$PWD/src" >> "$HOME/.pyenv/versions/$2/lib/python3.6/site-packages/$2.pth"
      echo "$PWD/test" >> "$HOME/.pyenv/versions/$2/lib/python3.6/site-packages/$2.pth"
      pyenv local "$2"
      pip install pylint==2.4.3
      pip install black==19.3b0
      ;;
  esac
}

cl() {
  # Copy the last command to the clipboard
  history | tail -n 1 | xclip -selection clipboard
}

config() {
  case $1 in
    "db")
      miniscule -c '!aws/secret prod/shared/rds-restricted'
      ;;
  esac
}

json() {
  $HOME/bin/as_json.py
}

ai() {
  local ecs_='/opt/bin/ecs-cli-linux-amd64-latest'
  case $1 in
    "secret")
      echo "!aws/secret $2"
      ;;
    "db")
      local credentials=$(config db | json)
      echo $credentials
      local host=$(echo $credentials | jq .host | tr -d '"')
      local user=$(echo $credentials | jq .username | tr -d '"')
      local password=$(echo $credentials | jq .password | tr -d '"')
      local db=$(echo $credentials | jq .dbname | tr -d '"')
      psql "postgresql://$user:$password@$host/$db"
      ;;
    "logs")
      if [ -z "$2" ]; then
        echo "Usage: $0 logs <env> <namespace>-<name>"
      else
        local cluster="$2-shared-services"
        local uuid='[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}'
        local output=$(with-aws "$ecs_" ps --cluster "$cluster")
        local name=$(echo $output | grep "$3" | head -n 1 | awk '{print $0}')
        local task_id=$(echo $name | grep -Po "$uuid")
        with-aws "$ecs_" logs --task-id="$task_id" --cluster "$cluster" "$argv[4,-1]"
      fi
      ;;
    "services")
      if [ -z "$2" ]; then
        echo "Usage: $0 services <env> <namespace>-<name>"
      fi
      local cluster="$2-shared-services"
      with-aws "$ecs_" ps --cluster "$cluster"
  esac
}


vpn() {
  case $1 in
    "tmp")
      sudo openvpn --client --config "$HOME/.ovpn/ai-ghg-temporary-vpn-client-t3.ovpn"
      ;;
  esac
}

