abbr -a v nvim
abbr -a g git
abbr -a c cargo
abbr -a k kubectl
abbr -a kx kubectx
abbr -a ks kubens
abbr -a ls exa

# Fish git prompt
set -g __fish_git_prompt_show_informative_status
# set -g __fish_git_prompt_hide_untrackedfiles 1

set -g __fish_git_prompt_showupstream "informative"
set -g __fish_git_prompt_char_upstream_ahead "↑"
set -g __fish_git_prompt_char_upstream_behind "↓"
set -g __fish_git_prompt_char_upstream_prefix ""

set -g __fish_git_prompt_char_dirtystate "●"
set -g __fish_git_prompt_char_stagedstate "✚"
set -g __fish_git_prompt_char_untrackedfiles "●"
set -g __fish_git_prompt_char_conflictedstate "✖"
set -g __fish_git_prompt_char_cleanstate "✔"

set -g __fish_git_prompt_color_dirtystate blue
set -g __fish_git_prompt_color_stagedstate yellow
set -g __fish_git_prompt_color_invalidstate red
set -g __fish_git_prompt_color_untrackedfiles $fish_color_normal

set -g fish_prompt_pwd_dir_length 1
set -g fish_color_valid_path --underline

set -e fish_user_paths
set -U fish_user_paths /usr/local/sbin /usr/local/bin /usr/bin /bin /usr/local/go/bin /usr/share/rvm/bin $HOME/.local/bin $HOME/.cargo/bin $HOME/.krew/bin $HOME/go/bin

# colored man output
# from http://linuxtidbits.wordpress.com/2009/03/23/less-colors-for-man-pages/
setenv LESS_TERMCAP_mb \e'[01;31m'       # begin blinking
setenv LESS_TERMCAP_md \e'[01;38;5;74m'  # begin bold
setenv LESS_TERMCAP_me \e'[0m'           # end mode
setenv LESS_TERMCAP_se \e'[0m'           # end standout-mode
setenv LESS_TERMCAP_so \e'[38;5;246m'    # begin standout-mode - info box
setenv LESS_TERMCAP_ue \e'[0m'           # end underline
setenv LESS_TERMCAP_us \e'[04;38;5;146m' # begin underline

setenv RUST_SRC_PATH (rustc --print sysroot)"/lib/rustlib/src/rust/library"
setenv RUSTC_WRAPPER sccache
setenv KUBECONFIG $HOME/.kube/config
setenv KUBECTX_IGNORE_FZF 1
setenv GOPATH $HOME/go
setenv NVM_DIR $HOME/.nvm

function fish_prompt
  set last_command_status $status

	set_color yellow
	echo -n (prompt_pwd)

	set_color green
	printf '%s ' (__fish_git_prompt)

  if [ $last_command_status -eq 0 ]
	  set_color green
  else
	  set_color red
  end

	echo -n '| '
	set_color normal
end

function fish_right_prompt
	set_color brblack
	echo -n "["(date "+%H:%M")"] "
  # echo (grep "current-context" "$KUBECONFIG" | cut -d ' ' -f 2)
	set_color normal
end

if status is-interactive
and not set -q TMUX
  exec tmux -u
end
