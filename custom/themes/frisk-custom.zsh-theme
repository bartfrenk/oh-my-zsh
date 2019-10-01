#!/usr/bin/zsh

git_prompt() {
  echo -n "$(git_prompt_info)"
}

aws_vault_prompt() {
  echo -n "%{$fg[red]%}[$AWS_VAULT]"
}

base_segment() {
  echo -n "%{$fg[yellow]%}%n@%m:%{$fg[blue]%}%d"
}

prompt() {
  base_segment
  git_prompt
  aws_vault_prompt
}

setopt prompt_subst

PROMPT=$'$(prompt)
%{$fg[white]%}> '

PROMPT2="%{$fg_blod[black]%}%_> %{$reset_color%}"

ZSH_THEME_SCM_PROMPT_PREFIX="%{$fg[green]%}("
ZSH_THEME_GIT_PROMPT_PREFIX=$ZSH_THEME_SCM_PROMPT_PREFIX
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}*%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
