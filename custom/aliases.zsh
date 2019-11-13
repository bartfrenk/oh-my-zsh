#!/bin/zsh

alias ls="ls --color=auto --group-directories-first --classify"
alias xcb='xclip -selection clipboard'

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
      echo "!aws/secret prod/shared/rds-restricted" | miniscule
      ;;
  esac
}

