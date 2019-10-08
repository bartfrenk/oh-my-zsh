#!/usr/bin/zsh

git_segment() {
  echo -n "$(git_prompt_info)"
}

aws_segment() {
  local SEGMENT=""
  if (( ${+AWS_VAULT} )); then
    SEGMENT="${SEGMENT}${AWS_VAULT}"
  fi

  if (( ${+AWS_EXPIRATION} )); then
    SEGMENT="${SEGMENT}$(date --date=${AWS_EXPIRATION} +%H:%M)"
  fi

  if [ -z "$SEGMENT" ]; then
    echo -n ""
  else
    echo -n "%{$fg[red]%}(aws|$SEGMENT)%{$reset_color%} "
  fi
}

base_segment() {
  echo -n "%{$fg[yellow]%}%n@%m:%{$fg_bold[blue]%}%d%{$reset_color%} "
}

date_segment() {
  echo -n "%{$fg[white]%}[$(date +%H:%M:%S)]%{$reset_color%} "
}

linebreak() {
  echo ""
}

prompt() {
  base_segment
  git_segment
  aws_segment
  linebreak
  date_segment
}

setopt prompt_subst

PROMPT=$'$(prompt)%{$fg_bold[white]%}$%{$reset_color%} '

PROMPT2="%{$fg_blod[black]%}%_> %{$reset_color%}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}(git|"
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}*%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
