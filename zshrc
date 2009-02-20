# Search path for the cd command
cdpath=()

# Use hard limits, except for a smaller stack and no core dumps
unlimit
limit stack 8192
limit core 0
limit -s

umask 022

eval `dircolors`


# == Title ==
local title_prompt='%n@%m:%~ '

precmd()
{
    [[ -t 1 ]] || return 0 #stdout is tty or gtfo

    [[ -n $DISPLAY ]] && print -Pn "\e]2;$title_prompt\a" #update term emulator title
    [[ $TERM = "screen" ]] && print -Pn "\ek$title_prompt\e\\" # update screen title
}

preexec()
{
    [[ -t 1 ]] || return 0

    if [[ -n $DISPLAY ]];then
        print -nP "\e]2;$title_prompt"
        print -rn $1
        print -n "\a"
    fi
    if [[ $TERM = "screen" ]];then
        print -nP "\ek$title_prompt"
        print -rn $1
        print -n "\e\\"
    fi
}

# == Aliases ==
alias mv='nocorrect mv'       # no spelling correction on mv
alias cp='nocorrect cp'       # no spelling correction on cp
alias mkdir='nocorrect mkdir' # no spelling correction on mkdir
alias j=jobs
alias pu=pushd
alias po=popd
alias d='dirs -v'
alias h=history
alias grep='egrep --color=auto'
alias cal='cal -m'
alias info='info --vi-keys'
alias mpc='mpc --format "[[%name% ][%artist% - ][%album% - ][%title%]]|[%file%]"'
alias linuxdcpp='nice -n19 linuxdcpp'
alias whois='whois -H'
alias youtube-dl='noglob youtube-dl'
alias mysql='mysql -p'
alias skipc="grep '^#|^\s*$' -v"
alias ocaml='ledit ocaml'
alias fumount='fusermount -u'
alias playrbc='mplayer -vf crop=384:238:0:0,pp=tn:50,pp=ac'

# === paludis ===
alias paludis='paludis --log-level warning'
alias pq='paludis -q'
alias pc='paludis --contents'
alias p='paludis'

# === ls ===
alias ls='ls --color=yes'
alias ll='ls -l'
alias la='ls -a'
# List only dirs and symlinks to dirs
alias lsd='ls -ld *(-/DN)'
# List only file beginning with "."
alias lsa='ls -ld .*'

# === Global aliases ===
# These do not have to be
# at the beginning of the command line.
alias -g H='|head'
alias -g T='|tail'
alias -g L='|less'
alias -g WL='|wc -l'
alias -g G='|grep'
alias -g GI='|grep -i'


# == Shell functions ==
autoload -U zmv
#setenv() { typeset -x "${1}${1:+=}${(@)argv[2,$#]}" }  # csh compatibility
freload() { while (( $# )); do; unfunction $1; autoload -U $1; shift; done }

# Where to look for autoloaded function definitions
fpath=($fpath ~/.zfunc)

# Autoload all shell functions from all directories in $fpath (following
# symlinks) that have the executable bit on (the executable bit is not
# necessary, but gives you an easy way to stop the autoloading of a
# particular shell function). $fpath should not be empty for this to work.
for func in $^fpath/*(N-.x:t); autoload $func

# automatically remove duplicates from these arrays
typeset -U path cdpath fpath manpath


# Hosts to use for completion (see later zstyle)
hosts=(`hostname`)

# == Prompts ==
local black="%{"$'\033[01;30m'"%}"
local green="%{"$'\033[01;32m'"%}"
local red="%{"$'\033[01;31m'"%}"
local yellow="%{"$'\033[01;33m'"%}"
local blue="%{"$'\033[01;34m'"%}"
local bold="%{"$'\033[01;39m'"%}"
local norm="%{"$'\033[00m'"%}"

PROMPT="%(!.$red.$green)%n@%m $blue%# $norm" # who@where %
RPROMPT=" $blue%~$norm"                      # cwd on right side

# == Environment ==
export MAIL=/var/spool/mail/$USERNAME
export LESS=-cx4MiR # clear screen, tabstop=4, long prompt, smart ignorecase, accept colors
export HELPDIR=/usr/local/lib/zsh/help  # directory for run-help function to find docs
export EDITOR=vim
export PATH="$HOME/bin:$HOME/local/bin:$PATH"
export MPD_HOST="127.0.0.1"
export GREP_COLOR="0;37;43" # red

# == Local installs ==
if [[ -d ~/local ]];then

    if $( which python &> /dev/null ); then
        python_version=$(python -V 2>& 1| cut -c8-10)

        export PYTHONPATH="${PYTHONPATH}$(find ~/local -path "*/lib*/python${python_version}/site-packages" -type d -printf ':%p')"
    fi

    export PATH="${PATH}$(find ~/local -maxdepth 3 -regex '.*/bin\(32\|64\)?' -type d -printf ':%p')"
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}$(find ~/local -maxdepth 3 -regex '.*/lib\(32\|64\)?' -type d -printf ':%p')"
    export MANPATH="${MANPATH}$( find ~/local -maxdepth 3 -path '*/share/man' -type d -printf ':%p')"
fi


MAILCHECK=300

# == History ==
DIRSTACKSIZE=20
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zhistory

# Watch for my friends
#watch=( $(<~/.friends) )       # watch for people in .friends file
watch=(notme)                   # watch for everybody but me
LOGCHECK=300                    # check every 5 min for login/logout activity
WATCHFMT='%n %a %l from %m at %t.'

# lost's of shell options
setopt   hist_ignore_all_dups append_history hist_reduce_blanks
setopt   notify globdots correct pushdtohome cdablevars autolist
setopt   correctall recexact longlistjobs
setopt   autoresume pushdsilent noclobber
setopt   autopushd pushdminus extendedglob rcquotes mailwarning
unsetopt bgnice autoparamslash

# Autoload zsh modules when they are referenced
zmodload -a zsh/stat stat
zmodload -a zsh/zpty zpty
zmodload -a zsh/zprof zprof
zmodload -ap zsh/mapfile mapfile

# == Keybinds ==
bindkey -v                                          # vi key bindings
bindkey ' '                magic-space              # also do history expansion on space
bindkey '^I'               complete-word            # complete on tab, leave expansion to _expand
bindkey "$terminfo[kbs]"   vi-backward-delete-char  # delete char on backspace
bindkey "$terminfo[khome]" vi-beginning-of-line
bindkey "$terminfo[kend]"  vi-end-of-line

# == Completion ==
# Setup new style completion system. To see examples of the old style (compctl
# based) programmable completion, check Misc/compctl-examples in the zsh
# distribution.
autoload -U compinit
compinit

# list of completers to use
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate

# allow one error for every three characters typed in approximate completer
zstyle -e ':completion:*:approximate:*' max-errors \
    'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'
    
# insert all expansions for expand completer
zstyle ':completion:*:expand:*' tag-order all-expansions

# formatting and messages
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''

# match uppercase from lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# command for process lists, the local web server details and host completion

#zstyle ':completion:*:urls' local 'www' '/var/www/htdocs' 'public_html'
zstyle '*' hosts $hosts

# Filename suffixes to ignore during completion (except after rm command)
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.o' '*?.c~' \
    '*?.old' '*?.pro'
# the same for old style completion
#fignore=(.o .c~ .old .pro)

# ignore completion functions (until the _ignored completer)
zstyle ':completion:*:functions' ignored-patterns '_*'

# color suggested filelist
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# === Processess ===
zstyle ':completion:*:processes' command 'ps -xuf'
zstyle ':completion:*:processes-names' command 'ps xho command' 

# === Caching ===
zstyle ':completion:*' use-cache on
#zstyle ':completion:*' cache-path ~/.zcompcache
