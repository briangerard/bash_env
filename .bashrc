# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Source global definitions
if   [[ -f /etc/bashrc ]]
then
    . /etc/bashrc
fi

# Grab any local settings
if [[ -f ${HOME}/.bash_local ]]
then
    . ${HOME}/.bash_local
fi

# Tools for syncing and maintaining the local environment
if [[ -f ${HOME}/.bash_env_mgmt ]]
then
    reload_bash_env_mgmt=RELOAD
    . ${HOME}/.bash_env_mgmt
else
    ###
    # Standard directories I always use; just in case the file
    # above goes missing.
    export BIN_DIR=0
    export DEVEL_DIR=1
    export ENV_DIR=2
    export PERSONAL_DIR=3
    export TMP_DIR=4
    export WORK_DIR=5
    function myPath() {
        local thePaths=( "${HOME}/bin" "${HOME}/devel"
                         "${HOME}/env" "${HOME}/personal"
                         "${HOME}/tmp" "${HOME}/workstuff" )
        if [[ -n $1 ]]; then case $1 in
                    all) echo ${thePaths[*]} ;;
            ''|*[!0-9]*) ;;
                      *) if [[ $1 -le ${#thePaths} ]]; then
                             echo ${thePaths[$1]}
                         fi ;;
            esac
        fi
    }
fi

if [[ -d "${HOME}/.anyenv" ]]
then
    if [[ $(type -t uniqPath) ]]
    then
        export PATH=$(uniqPath "${HOME}/.anyenv/bin:$PATH")
    else
        export PATH=${HOME}/.anyenv/bin:${PATH}
    fi

    eval "$(anyenv init -)"
fi

umask 022

##
# This should be set in .bash_local; setting a default (though bogus)
# value so I have something to use in comparisons.
HOME_HOST=${HOME_HOST:-NOT_HERE}

##
# One-stop shop for info about the host I'm on.  An array consisting of:
# ( fqdn,
#   fqdn minus top-level domain,
#   hostname up to the first ".",
#   where the host is (corp, prod, or grid),
#   "IsVM" if this host is actually a vm, or "NotVM" if not
# )
THIS_HOST=($( perl -e 'use Sys::Hostname;
                       my $ThisHost  = hostname();         # "foo.bar.gorp.com"

                       my $ShortHost = $ThisHost;
                       $ShortHost   =~ s/(?:\.[^.]+){2}\Z//; # "foo.bar"

                       my $NodeName  = $ThisHost;
                       $NodeName    =~ s/\..*//;           # "foo"

                       my @host      = ( $ThisHost, $ShortHost, $NodeName );

                       # "Type" of host, by location.
                       push @host, ( $ThisHost =~ /\.(office\.|local\Z)/ ? "corp" : "prod" );
                       
                       # Are we inside a vm?  Trivial check.
                       push @host, ( (-f glob("/var/run/vmware[-_]guestd.pid"))   ? "IsVM" : "NotVM" );
                       
                       print STDOUT join(" ", @host);
                      '
          ))

# Clearly, these field numbers need to be kept up-to-date if anything changes above
FULLNAME=0
SHORTNAME=1
NODENAME=2
LOCATION=3
VMSTATUS=4
if [[ ${THIS_HOST[$VMSTATUS]} = "IsVM" ]]
then
    IS_VM=1
fi

###
# Only need the rest of this if I'm working interactively ($PS1 is set)
if [[ -n "$PS1" ]] # { INTERACTIVE_COND
then

    #####
    #
    # General shell options {
    #
    ###

    # Don't put duplicate lines or lines starting with space in the history.
    # See bash(1) for more options.
    HISTCONTROL=ignoreboth

    # Setting history length; see HISTSIZE and HISTFILESIZE in bash(1).
    HISTSIZE=1000
    HISTFILESIZE=2000

    # Append to the history file, don't overwrite it
    shopt -s histappend

    # Check the window size after each command and, if necessary,
    # update the values of LINES and COLUMNS.
    shopt -s checkwinsize

    # This option isn't available until bash-4.x
    if [[ $BASH_VERSION = "4" || $BASH_VERSION > "4" ]]
    then
        # If set, the pattern "**" used in a pathname expansion context will
        # match all files and zero or more directories and subdirectories.
        shopt -s globstar
    fi

    # Match case-insensitively in [[ ]] regexes
    shopt -s nocasematch

    # Allow me to cd using variables... 
    shopt -s cdable_vars
    
    # ...and without the fully qualified path, in some cases
    export CDPATH=.:$HOME:/usr:/usr/local

    ###
    # Get the old "dot files then caps then lowercase files" sort order on 'ls'
    export LC_COLLATE=POSIX
    export PAGER=less

    ###
    # Where to find the One True Editor(tm)...
    EDITOR=$(which vim 2> /dev/null)
    if [[ $? -ne 0 ]]
    then
        EDITOR=$(which vi)
    else
        alias vi=$EDITOR
        alias view="$EDITOR -R"
    fi
    export EDITOR
    export EXINIT='set autoindent'
    set -o vi

    ###
    # less.sh is a script which gives all the syntax highlighting and
    # other goodies of vim in a pager interface.  It's almost a drop-in
    # replacement for less, but it's missing enough that it can't really
    # be set as $PAGER.
    #
    # Selecting the one from the highest version of vim that's installed.
    unalias l 2> /dev/null
    LESS_SH=$( perl -e \
                'print +(sort {
                               $a =~ /vim(\d+)/;
                               $aVersion =  $1;

                               $b =~ /vim(\d+)/;
                               $bVersion =  $1;
                               
                               $bVersion <=> $aVersion
                              }
                              glob(q|{/usr,/usr/local}/share/vim/vim[0-9]*/macros/less.sh|)
                        )[0],
                        "\n"'
             )
    if [[   -n "$LESS_SH" \
         && -x "$LESS_SH" ]]
    then
        alias l=$LESS_SH
    else
        /usr/bin/which less > /dev/null 2>&1
        case $? in
            0) alias l=`which less` ;;
            1) alias l=`which more` ;;
            *) ;;
        esac
    fi

    # make less more friendly for non-text input files, see lesspipe(1)
    if [[ -x /usr/bin/lesspipe ]]
    then
        eval "$(SHELL=/bin/sh lesspipe)"
    fi

    # Enable programmable completion features (no need to enable this
    # here if it's already enabled in /etc/bash.bashrc and /etc/profile
    # sources /etc/bash.bashrc).
    shopt -oq posix
    if [[ -f /etc/bash_completion && $? -ne 0 ]]
    then
        . /etc/bash_completion
    fi

    export PERLDOC=-oman

    ###
    #
    # /General shell options }
    #
    #####


    ######
    #
    # ssh stuff.  Run in an ssh-agent context, if possible {
    #
    ###
    MYSSH=`/usr/bin/which ssh`
    MYSSHADD=`/usr/bin/which ssh-add`
    MYSSHAGENT=`/usr/bin/which ssh-agent`

    ###
    # Let's see what the state of the ssh-agent is.  Only to be done on
    # the home host, and only assuming we can get ssh-agent stuff going.
    if [[    "${THIS_HOST[$NODENAME]}" = "$HOME_HOST" \
         && -x "$MYSSHADD"   \
         && -x "$MYSSHAGENT" \
       ]] # { SSHAGENT_COND
    then
        $MYSSHADD -l > /dev/null 2>&1
        case $? in
            0) ;;
            1) echo "There is an ssh-agent running but no keys are loaded.  Loading...";
               $MYSSHADD;;
            2) echo "No ssh-agent running - respawning under ssh-agent...";
               exec $MYSSHAGENT /bin/bash --login;;
            *) ;;
        esac
    fi # End - SSHAGENT_COND }
    ###
    #
    # /ssh stuff }
    #
    ######


    ######
    #
    # Prompt section.  Setting up a bunch of metadata and colors I use
    # in my $PS1. {
    #
    ###
    
    ###
    # This is included in the default Ubuntu .bashrc; holding it here
    # in anticipation of eventually figuring out what I want to do with
    # it.  :)
    #
    # set variable identifying the chroot you work in (used in the prompt below)
    ##if [[ -z "$debian_chroot" && -r /etc/debian_chroot ]]
    ##then
    ##    debian_chroot=$(cat /etc/debian_chroot)
    ##fi

    ###
    # See if I'm inside a screen or tmux session.
    if [[ ${TERM:-NO_TERM} = "screen" ]]
    then
        if [[ -n "$STY" ]]
        then
            ScreenName="screen:$(echo $STY | cut -d. -f2)"
        elif [[ -n "$TMUX" ]]
        then
            # For starters, just grab the tmux socket name.
            ScreenName=$(basename $TMUX | cut -d, -f1)

            # If it's the default socket, there's really no need to call that
            # out in the prompt; otherwise add it in.  Note that this tmux
            # display-message command is only available in tmux-1.2 and later.
            if [[ $ScreenName = "default" ]]
            then
                ScreenName="tmux:$(tmux display-message -p '#S')"
            else
                ScreenName="tmux:${ScreenName}:$(tmux display-message -p '#S')"
            fi
        else
            ScreenName="unknown"
        fi
    fi

    ###
    # Set up colors, if the file is there
    if [[ -f "$HOME/.bash_colors" ]]
    then
        . $HOME/.bash_colors
    else
        # If there's no .bash_colors, just define the ones I need in the prompt
        # I'm setting $Esc to <ctrl>-v<esc> because I've run into environments
        # where '\e' and '\033' haven't worked, and I haven't been motivated
        # enough to track down why.
        Esc=''
        Color_Off="${Esc}[0m"

        # Regular colors
        Green="${Esc}[0;32m"
        Purple="${Esc}[0;35m"
        Cyan="${Esc}[0;36m"

        # Intense colors
        IGreen="${Esc}[0;92m"
        IBlue="${Esc}[0;94m"
        IPurple="${Esc}[0;95m"

        # Bold colors
        BRed="${Esc}[1;31m"
        BWhite="${Esc}[1;37m"

        # Bold Intense colors
        BIRed="${Esc}[1;91m"
        BIGreen="${Esc}[1;92m"
        BIYellow="${Esc}[1;93m"
        BIBlue="${Esc}[1;94m"
    fi

    ###
    # These are characters used to construct and decorate the
    # git-related portions of the prompt.
    #
    # A good list of UTF-8 characters I found is at
    # http://www.fileformat.info/info/charset/UTF-8/list.htm
    #
    # First, the fancy characters.  I have not yet found a Linux
    # font that includes all of these.  They work on Mac Terminals,
    # but not on Linux.  The search continues.
    #
    # The following characters can be found on
    # http://www.fileformat.info/info/charset/UTF-8/list.htm?start=50176
    # 
    # ...except for the 'lightning bolt', which can be seen on
    # http://www.fileformat.info/info/charset/UTF-8/list.htm?start=8192
    #
    if [[ ${GitStatusFont:-NOT_SET} =~ "fancy" ]]
    then
        # UTF-8 glowing star
        RepoClean='\xf0\x9f\x8c\x9f '
        # UTF-8 lightning bolt
        RepoChanged='\xe2\x9a\xa1 '

        # UTF-8 small up arrow
        LocalAhead='\xf0\x9f\x94\xbc '
        # UTF-8 small down arrow
        LocalBehind='\xf0\x9f\x94\xbd '
        # UTF-8 wrench
        Divergent='\xf0\x9f\x94\xa7 '

        # UTF-8 no entry sign
        NotARepo='\xf0\x9f\x9a\xab '
        # UTF-8 no entry sign
        GitNotInstalled='\xf0\x9f\x9a\xab '
        # UTF-8 no entry sign
        GitPromptDisabled='\xf0\x9f\x9a\xab '

    # The rest of these seem to be more universally available; if
    # I don't get my fancy eye candy, I'll at least have something.  :)
    #
    # These can be found on the 'lightning bolt' page listed above,
    # as well as on
    # http://www.fileformat.info/info/charset/UTF-8/list.htm?start=9216
    # 
    else
        # UTF-8 heavy checkmark, in bold intense green
        RepoClean="${BIGreen} \xe2\x9c\x94"
        # UTF-8 heavy ballot x, in bold intense red
        RepoChanged="${BIRed} \xe2\x9c\x98"

        # UTF-8 North East Black Arrow, in bold intense yellow
        LocalAhead="${BIYellow} \xe2\xac\x88 "
        # UTF-8 South West Black Arrow, in bold intense yellow
        LocalBehind="${BIYellow} \xe2\xac\x8b "
        # UTF-8 Radioactive sign, in bold intense yellow
        Divergent="${BIYellow} \xe2\x98\xa2 "

        # UTF-8 N-Ary circled dot operator, in bold intense green
        NotARepo="${BIGreen} \xe2\xa8\x80 "
        # UTF-8 N-Ary circled times operator, in bold intense blue
        GitNotInstalled="${BIBlue} \xe2\xa8\x82 "
        # UTF-8 N-Ary circled plus operator, in bold intense yellow
        GitPromptDisabled="${BIYellow} \xe2\xa8\x81 "

    fi

    ###
    # Sometimes having to check git for status every time I hit <enter>
    # slows things down.  In a very large, or very dirty repo, for instance,
    # or when the code lives on a sluggish NFS share.  This gives me a
    # way to turn it off when needed.
    function gitprompt () {
        # Pretend we're just logging in
        if [[ $# -eq 1 && $1 =~ reset ]]
        then
            GITPROMPTSTATUS=UNINITIALIZED
        fi

        # The first time the function is called, we find git and
        # default to enabling the git-aware prompt.
        if [[ ${GITPROMPTSTATUS:-UNINITIALIZED} = "UNINITIALIZED" ]]
        then
            # See if there's a git somewhere about.
            GIT=$(which git 2> /dev/null)
            GIT=${GIT:-NO_GIT}
    
            GITPROMPTSTATUS=enabled
        fi

        if [[ $# -eq 0 ]]
        then
            echo $GITPROMPTSTATUS
        else
            if [[ $1 =~ (on|enable|reset) ]]
            then
                GITPROMPTSTATUS=enabled
            else
                GITPROMPTSTATUS=disabled
            fi
        fi
    }

    ###
    # Actually turn the prompt on, for starters.  :)
    gitprompt enable

    ###
    # Credit where credit is due here.
    #
    # I first saw this in John Fowler's (fowler at TEH webassignZ DOTZ net) bash
    # prompt.  He passed along the original notes he received from Chris Kershaw
    # (ckershaw at TEH webassignZ DOTZ net).
    #
    # Chris credited the following sites:
    #   http://gist.github.com/31934
    #   http://henrik.nyh.se/2008/12/git-dirty-prompt
    #   http://www.simplisticcomplexity.com/2008/03/13/show-your-git-branch-name-in-your-prompt/
    #
    # I modified it to always decorate the prompt even when git isn't present,
    # and tracked down the UTF-8 chars used above to make it all purty.  Aside
    # from that, it's just some coloring and aesthetic tweaks to suit me.
    #
    function gitStatusTag () {
        if [[ $(gitprompt) = "disabled" ]]
        then
            echo -e "$GitPromptDisabled"
        elif [[ $GIT = "NO_GIT" ]]
        then
            echo -e "$GitNotInstalled"
        else
            # Are we even in a git repo?
            $GIT rev-parse --is-inside-git-repository &> /dev/null
            if [[ $? = 0 ]]
            then
                GitStatus="$($GIT status 2> /dev/null)"
                RemotePattern="(# )?Your branch is ([^ ]+) "
                DivergePattern="(# )?Your branch and (.*) have diverged"

                if [[ ! ( ${GitStatus} =~ "working directory clean" ) ]]
                then
                    State=$RepoChanged
                else
                    State=$RepoClean
                fi

                # Add an else if or two here if you want to get more specific
                if [[ $GitStatus =~ $RemotePattern ]]
                then
                    if   [[ ${BASH_REMATCH[2]} == "ahead" ]]
                    then
                        Remote=$LocalAhead
                    elif [[ ${BASH_REMATCH[2]} == "behind" ]]
                    then
                        Remote=$LocalBehind
                    fi
                fi

                # Thing have gone sideways.  Someone needs to fix it.
                if [[ $GitStatus =~ $DivergePattern ]]
                then
                    Remote=$Divergent
                fi

                # Let me know what branch I'm on.  Formerly handled with a regex,
                # as with $RemotePattern and $DivergePattern, above.  Unfortunately,
                # virtualenvwrapper clobbers $IFS under certain conditions, preventing
                # the pattern from matching and the branch name from being captured.
                # Without matching against $IFS, or perhaps only when $IFS has been so
                # clobbered, no amount of expansion of the original value seemed
                # to match correctly.  Moving to a quick-n-dirty awk command for
                # now.
                Branch="${BIGreen}$(echo $GitStatus | awk '{print $3}')${Color_Off}"

                echo -e " (${Branch})${Remote}${State}"
            else
                echo -e " $NotARepo"
            fi
        fi
    }

    ###
    # Determine if I'm in a virtualenv and return the formatted name if so.
    function venvString() {
        if [[ -n ${VIRTUAL_ENV} ]]
        then
            echo -e " ${IBlue}{$(basename $VIRTUAL_ENV)}${Color_Off}"
        fi
    }

    ###
    # 
    # This color scheme is largely designed to go well on a terminal with a
    # black (or all-but-black) background and yellow-ish foreground (text).
    # The best one I've found so far is something closely akin to the color
    # used for unique items in Diablo II: RGB:#D49E43 / HSV:37,175,212
    # 
    # Minimally, my prompt will look like this, in color:
    # 
    # host.im.on - /my/current/working/direcotory <"not a repo" icon> : 1234
    # Yes, My Liege? $
    # 
    # However, potentially, the prompt could end up looking like all of this
    # (also colorized, of course):
    #
    # #screensession:0# host.im.on[VM] - /my/current/working/directory {virtualenv} (git branch)<status icon(s)> : 1234
    # Yes, My Liege? $ 
    #
    # The screen session name is only filled in when I can tell I'm inside a
    # screen/tmux session, and I can tell what the name is.
    #
    # The [VM] tag is only applied when I can determine that I'm in a virtual
    # machine.
    #
    # The {virtualenv} will only show up when I'm working in a virtualenv.
    #
    # '1234' will be the current history number (useful for repeating commands,
    # etc).
    #
    # Wrapping all of this in a function so I can use PROMPT_COMMAND (see
    # bash(1)).  That means the git status will be refreshed as I go.
    # 
    function currentPrompt () {
        PS1="${IGreen}${ScreenName:+"#${ScreenName}# "}${BWhite}${THIS_HOST[$SHORTNAME]}${Color_Off}\
${IS_VM:+${BRed}[VM]${Color_Off}}${Yellow} - ${Color_Off}\
${IPurple}\w${Color_Off}$(venvString)$(gitStatusTag)${Yellow} : ${Color_Off}\
${Cyan}\!${Color_Off}\
\nYes, My Liege? \$ "
}
    PROMPT_COMMAND=currentPrompt

    ###
    #
    # /Prompt section. }
    #
    ######

    ######
    #
    # Aliases and functions. {
    #
    ###

    # enable color support of ls and also add handy aliases
    if [[ -x /usr/bin/dircolors ]]
    then
        test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
        alias la='ls --color=auto -A'
        alias ls='ls --color=auto -AFC'
        alias ll='ls --color=auto -AFls'

        alias grep='grep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias egrep='egrep --color=auto'
    else
        # non-colorized versions
        alias la='ls -A'
        alias ls="ls -AFC"
        alias ll="ls -ls"
    fi

    # Add an "alert" alias for long running commands.  Use like so:
    #   sleep 10; alert
    alias alert='notify-send --urgency=low -i "$([[ $? = 0 ]] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

    # Laziness, puuure laziness.  :)
    alias a=alias
    alias agent="exec $MYSSHAGENT /bin/bash"
    alias c=clear
    alias cdb="cd ~/bin"
    alias cdd="cd ~/devel"
    alias cde="cd ~/env"
    alias cdp="cd ~/personal"
    alias cdt="cd ~/tmp"
    alias cdw="cd ~/workstuff"
    alias gzcat="gzip -dc"
    alias h="history 25"
    alias m=make
    alias mailfile="vim -c 'set filetype=mail'"
    alias pd=perldoc
    alias pf="perldoc -f"
    alias psme="ps auxww | egrep \"^(USER|${USER})\" | sort"
    # Safety first
    alias rm="rm -i"
    alias sp=". $(myPath $ENV_DIR)/.bashrc"
    alias vp="vi $(myPath $ENV_DIR)/.bashrc"

    # Git shortcuts (see "lazy", above :)
    alias ga='git add'
    alias gc='git commit'
    alias gd='git diff'
    alias gdc="git diff --cached"
    alias gpl='git pull --rebase'
    alias gps='git push'
    alias gs='git status'
    alias gsl="git log --format='%C(yellow)%h%Creset %C(white)[%Cgreen%an%C(white)]%Creset %s'"

    # Something to let me see what *would* have been done, if I had merged.
    function gitpremerge() {
        if [[ ! -z $1 ]]
        then
            git pull --rebase
            git merge-tree $(git merge-base FETCH_HEAD $1) FETCH_HEAD $1
        else
            echo "Usage: gitpremerge <branch>"
        fi
    }

    ###
    # IP transforms
    #
    # integer to ip: 16909060 -> 1.2.3.4
    alias i2ip="perl -MSocket -e 'print +inet_ntoa(pack(q{N}, shift)), qq{\n}'"
    #
    # ip to integer:  1.2.3.4 -> 16909060
    alias ip2i="perl -MSocket -e 'print +unpack(q{N}, inet_aton(shift)), qq{\n}'"
    #
    # hex to ip:     01020304 -> 1.2.3.4
    alias h2ip="perl -MSocket -e 'print +inet_ntoa(pack(q{N}, hex(shift))), qq{\n}'"
    #
    # ip to hex:      1.2.3.4 -> 01020304
    alias ip2h="perl -MSocket -e 'print +sprintf(q{%0.8x}, unpack(q{N}, inet_aton(shift))), qq{\n}'"

    ###
    # Functional equivalents to old tcsh aliases and miscellaneous
    # other functions.

    # 'du -sk' on a directory (or the current directory, if unspecified)
    function dusk () { du -sk "$@"; }

    # List files owned by me in the specified directory (or the current directory, if unspecified)
    function lme  () { ls -ls "$@" | grep $USER; }

    # List only regular files in the specified directory (or the current directory, if unspecified)
    function lstf () { ls -l  "$@" | grep "^-";  }

    # List only directories in the specified directory (or the current directory, if unspecified)
    function lstd () { ls -l  "$@" | grep "^d";  }

    # List only symlinks in the specified directory (or the current directory, if unspecified)
    function lstl () { ls -l  "$@" | grep "^l";  }

    # On some hosts, sometimes, connections to technobrat
    # will hang.  This is just a simple wrapper to let
    # me kill them with a bit less typing.
    function killtb () { 
        tbproc=`ps auxww | grep "[s]sh.*[t]b"`
        if [[ -n $tbproc ]]
        then
            tbpid=`echo $tbproc | awk '{print $2}'`
            /bin/echo "Found $tbpid (from - $tbproc)"
            /bin/echo -n "Kill? y/[n] "
            read yeanay
            if [[ ${yeanay:-N} =~ ^y(es)?$ ]]
            then
                /bin/kill $tbpid
            else
                /bin/echo "Nothing to do."
            fi
        else
            echo "No ssh sessions to technobrat detected."
        fi
    }

    ###
    # Found a set of diff args that I like  :)
    function mydiff () {
        cols=`stty size | awk '{print $2}'`
        diff --side-by-side --left-column --width=$cols --ignore-all-space $1 $2
    }

    # t2d -> time2date
    function t2d () {
        perl -e 'use POSIX qw{ :time_h };
                 my $epoch = shift;
                 $epoch =~ s/^0//;
                 print +strftime("%Y/%m/%d - %H:%M:%S", localtime($epoch)), "\n"' $1
    }

    # d2t -> date2time
    function d2t () {
        perl -e 'use POSIX qw{ :time_h };
                 my $yyyymmdd = shift;
                 ($y,$m,$d) = ($yyyymmdd =~ /(\d{4})(\d{2})(\d{2})/);
                 @lt = localtime(time);
                 @lt[0..5] = (0,0,0,$d,$m-1,$y-1900);
                 print +strftime("%s",@lt), "\n"' $1
    }

    # For some reason, I can't seem to get modelines to work
    # all the time on some bash files.  This makes sure I get
    # the right syntax highlighting.
    function vish () {
        vi -c "set filetype=sh" "$@"
    }

    # New perl script, with the basics in place.
    function newperl () {
        WRITE="no"
        if [[ -f "$1" ]]
        then
            echo -n "$1 exists.  Overwrite? [y/N] "
            read WRITE
            WRITE=`echo $WRITE | /usr/bin/env perl -pe 's/(.*)/\L$1/'`
        else
            WRITE="yes"
        fi
        if [[ ! ( $WRITE =~ ^y(es)?$ ) ]] 
        then
            echo "Not writing $1"
        else
            echo "#!/usr/bin/env perl"  >  $1
            echo ""                     >> $1
            echo "use strict;"          >> $1
            echo "use warnings;"        >> $1
            echo ""                     >> $1
            echo ""                     >> $1
            echo ""                     >> $1
            echo "__END__"              >> $1
            chmod 700 $1
            $EDITOR +6 $1
        fi
    }

    # Likewise, for a new package.
    function newpm () {
        WRITE="no"
        NEWFILE=${1:-NO_FILENAME_GIVEN}
        PM_PATTERN='[^.]\.pm$'
        if [[ ! ( $NEWFILE =~ $PM_PATTERN ) ]]
        then
            echo "Bad filename (must end in '.pm'): $NEWFILE"
        else
            if [[ -f $NEWFILE ]]
            then
                echo -n "$NEWFILE exists.  Overwrite? [y/N] "
                read WRITE
                WRITE=`echo $WRITE | perl -pe 's/(.*)/\L$1/'`
            else
                WRITE="yes"
            fi
            if [[ ! ( $WRITE =~ ^y(es)?$ ) ]]
            then
                echo "Not writing $NEWFILE"
            else
                echo "package CHANGE_ME;" > $NEWFILE
                echo ""                   >> $NEWFILE
                echo "use strict;"        >> $NEWFILE
                echo "use warnings;"      >> $NEWFILE
                echo ""                   >> $NEWFILE
                echo ""                   >> $NEWFILE
                echo ""                   >> $NEWFILE
                echo "1;"                 >> $NEWFILE
                chmod 600 $NEWFILE
                $EDITOR +6 $NEWFILE
            fi
        fi
    }

    # Takes a pattern (that should match Hosts in ~/.ssh/config)
    # and a command to run.  Runs the command on matching Hosts.
    function runon () {
        if [[ $# -ne 1 && $# -ne 2 ]]
        then
            echo "Usage: runon <pattern> [command]"
            echo "got $@ ($#)"
        else
            if [[ ! -f ${HOME}/.ssh/config ]]
            then
                echo "ERROR: ${HOME}/.ssh/config: No such file."
            else
                pattern=$1
                if [[ $# -eq 2 ]]
                then
                    command=$2
                else
                    command=''
                fi
                for host in $(grep "^Host .*${pattern}" ${HOME}/.ssh/config | awk '{print $2}')
                do
                    echo -e "${BIBlue}${On_White}$host :${Color_Off}"
                    ssh $host $command
                done
            fi
        fi
    }

    ###
    #
    # /Aliases and functions. }
    #
    ######

    ###
    # Random tagline generator - disabled for now.
    if [ 0 ] # { RANDSIG_COND
    then

        alias resig='/bin/kill -HUP `cat $HOME/randsig.pid`'
        alias seti="screen -dr seti"
        alias smutt="screen -S mutt mutt"

        if [[ -s $HOME/randsig.pid ]] # { RANDSIGPID_COND
        then
            echo Not starting randsig : Already running.
        elif [[ -x "$HOME/bin/randsig" ]] # } Else - RANDSIGPID_COND {
        then
            echo -n "Starting randsig... "
            /bin/rm -f $HOME/randsig.pid &> /dev/null
            $HOME/bin/randsig &
            echo Done\!
        fi # End - RANDSIGPID_COND }

    fi # End - RANDSIG_COND }

    # Final de-duping of the path, after anyenv and friends get finished with it.
    if [[ $(type -t uniqPath) ]]
    then
        export PATH=$(uniqPath $PATH)
    fi

    # Set up the environment for Go, if available
    if [[ -r ${HOME}/.go_dev_env ]]
    then
        source ${HOME}/.go_dev_env
    fi

    # Set up for virtualenvwrapper, if available
    if [[ -r ${HOME}/.virtualenvwrapper_env ]]
    then
        source ${HOME}/.virtualenvwrapper_env
    fi

fi # End if - INTERACTIVE_COND }
