#!/usr/bin/env zsh

#======================================================================#
#    _        _                _ _ _         _____ _                   #
#   /_\  _ __| |_  _ _ ___  __| (_) |_ ___  |_   _| |_  ___ _ __  ___  #
#  / _ \| '_ \ ' \| '_/ _ \/ _` | |  _/ -_)   | | | ' \/ -_) '  \/ -_) #
# /_/ \_\ .__/_||_|_| \___/\__,_|_|\__\___|   |_| |_||_\___|_|_|_\___| #
#       |_|                                                            #
#                                                                      #
#                       Aphrodite Terminal Theme                       #
#                 by Sergei Kolesnikov a.k.a. win0err                  #
#                                                                      #
#                        https://kolesnikov.se                         #
#                                                                      #
#======================================================================#


export VIRTUAL_ENV_DISABLE_PROMPT=true
setopt PROMPT_SUBST


aphrodite_get_prompt() {
	if (( ${+VIRTUAL_ENV} )); then
		echo -n "%F{7}["$(basename "$VIRTUAL_ENV")"]%f "
	fi

	echo -n "%F{6}%n"
	echo -n "%F{8}@"
	echo -n "%F{12}%m"
	echo -n "%F{8}:"
	echo -n "%f%~"
	echo -n " "

	local git_branch
	git_branch=$(git --no-optional-locks rev-parse --abbrev-ref HEAD 2> /dev/null)
	if [[ -n "$git_branch" ]]; then
		local should_disable_git_status=0

		if (( ${+APHRODITE_THEME_DISABLE_GIT_STATUS} )); then
			should_disable_git_status=1
		elif (( ${+APHRODITE_THEME_GIT_STATUS_BLACKLIST} )); then
			local repo_name
			repo_name=$(basename "$(git --no-optional-locks remote get-url origin 2>/dev/null)" .git)
			if [[ -n "$repo_name" ]]; then
				local -a blacklist
				blacklist=("${(@s/:/)APHRODITE_THEME_GIT_STATUS_BLACKLIST}")
				if (( ${blacklist[(Ie)$repo_name]} )); then
					should_disable_git_status=1
				fi
			fi
		fi

		if (( should_disable_git_status )); then
			echo -n "%F{166}"
		else
			local git_status
			git_status=$(git --no-optional-locks status --porcelain 2> /dev/null | tail -n 1)
			[[ -n "$git_status" ]] && echo -n "%F{11}" || echo -n "%F{10}"
		fi
		echo -n "‹${git_branch}›%f"
	fi

	if (( ${+APHRODITE_THEME_SHOW_TIME} )); then
		echo -n "%F{8} [%D{%H:%M:%S}]%f"
	fi

	echo  # new line

	echo -n "%(?.%f.%F{1})"  # if retcode == 0 ? reset : red
	echo -n "%(!.#.$)%f "  # if is_root_user ? # : $
}

aphrodite_get_simple_right_side_prompt() {
  local return_code
  return_code="%(?..%{$fg_bold[red]%}:( %?%{$reset_color%})"
  echo -n "${return_code}"
}

aphrodite_get_right_side_prompt() {
  echo -n "$(aphrodite_get_simple_right_side_prompt) %D - %*"
}

export PROMPT='$(aphrodite_get_prompt)'
if (( ${+APHRODITE_THEME_SIMPLE_RIGHT_PROMPT} )); then
  export RPS1='$(aphrodite_get_simple_right_side_prompt)'
else
  export RPS1='$(aphrodite_get_right_side_prompt)'
fi
