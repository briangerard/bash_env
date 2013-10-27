# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Source global definitions
if   [[ -f /etc/bashrc ]]
then
	. /etc/bashrc
elif [[ -f /etc/bash.bashrc ]]
then
	. /etc/bash.bashrc
fi

# Grab any local settings
if [[ -f ${HOME}/.bash_local ]]
then
    . ${HOME}/.bash_local
fi

# Tools for syncing and maintaining the local environment
if [[ -f ${HOME}/.bash_env_mgmt ]]
then
    . ${HOME}/.bash_env_mgmt
else
    ###
    # Standard directories I always use; just in case the file
    # above goes missing.
    export MYDIR=("bin" "devel" "env" "personal" "tmp" "workstuff")
    BIN=0
    DEVEL=1
    ENV=2
    PERSONAL=3
    TMP=4
    WORK=5
fi

umask 022

##
# This should be set in .bash_local; setting a default
# so I have a value to use in comparisons.
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
                       $ShortHost   =~ s/\.webassign\.net\Z//; # "foo.bar"

                       my $NodeName  = $ThisHost;
                       $NodeName    =~ s/\..*//;           # "foo"

                       my @host      = ( $ThisHost, $ShortHost, $NodeName );

                       # "Type" of host, by location.
                       push @host, ( $ThisHost =~ /\.(office\.|local\Z)/ ? "corp" : "prod" );
                       
                       # Are we inside a vm?  Trivial check.
                       push @host, ( (-f "/var/run/vmware_guestd.pid")   ? "IsVM" : "NotVM" );
                       
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
# Once you travel down this $PATH, forever will it dominate your destiny
export PATH=/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/sbin:/bin:/usr/X11R6/bin:~/bin:~

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

    # append to the history file, don't overwrite it
    shopt -s histappend

    # check the window size after each command and, if necessary,
    # update the values of LINES and COLUMNS.
    shopt -s checkwinsize

    # If set, the pattern "**" used in a pathname expansion context will
    # match all files and zero or more directories and subdirectories.
    shopt -s globstar

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
            ScreenName=`echo $STY | sed -e 's/[^.][^.]*\.\(.*\)$/\1/'`
        elif [[ -n "$TMUX" ]]
        then
            ScreenName=`echo $TMUX | sed -e 's/.*\/\([^,][^,]*\),[^,][^,]*,\(.*\)/\1:\2/'`
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

        # Bold colors
        BRed="${Esc}[1;31m"
        BWhite="${Esc}[1;37m"

        # Bold Intense colors
        BIGreen="${Esc}[1;92m"
    fi

    ###
    # These are characters used to construct and decorate the
    # git-related portions of the prompt.
    #
    # A good list of UTF-8 characters I found is at
    # http://www.fileformat.info/info/charset/UTF-8/list.htm
    #
    # First, the fancy characters.  I have not yet found a Linux font
    # that includes all of these characters.  They work on Mac Terminals,
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

        # UTF-8 N-Ary circled times operator, in bold intense red
        NotARepo="${BIRed} \xe2\xa8\x82"
        # UTF-8 N-Ary circled times operator, in bold intense blue
        GitNotInstalled="${BIBlue} \xe2\xa8\x82"

    fi

    GIT=$(which git 2> /dev/null)
    GIT=${GIT:-NO_GIT}
    
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
        if [[ $GIT = "NO_GIT" ]]
        then
            echo -e $GitNotInstalled
        else
            # Are we even in a git repo?
            $GIT rev-parse --is-inside-git-repository &> /dev/null
            if [[ $? = 0 ]]
            then
                GitStatus="$($GIT status 2> /dev/null)"
                BranchPattern="^# On branch ([^${IFS}]*)"
                RemotePattern="# Your branch is (.*) of"
                DivergePattern="# Your branch and (.*) have diverged"

                if [[ ! ( ${GitStatus} =~ "working directory clean" ) ]]
                then
                    State=$RepoChanged
                else
                    State=$RepoClean
                fi

                # Add an else if or two here if you want to get more specific
                if [[ $GitStatus =~ $RemotePattern ]]
                then
                    if [[ ${BASH_REMATCH[1]} == "ahead" ]]
                    then
                        Remote=$LocalAhead
                    else
                        Remote=$LocalBehind
                    fi
                fi

                # Thing have gone sideways.  Someone needs to fix it.
                if [[ $GitStatus =~ $DivergePattern ]]
                then
                    Remote=$Divergent
                fi

                # Let me know what branch I'm on.
                if [[ $GitStatus =~ $BranchPattern ]]
                then
                    Branch="${BIGreen}${BASH_REMATCH[1]}${Color_Off}"
                fi

                echo -e " (${Branch})${Remote}${State}"
            else
                echo -e " $NotARepo"
            fi
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
    # #screensession:0# host.im.on[VM] - /my/current/working/directory (git branch)<status icon(s)> : 1234
    # Yes, My Liege? $ 
    #
    # The screen session name is only filled in when I can tell I'm inside a
    # screen/tmux session, and I can tell what the name is.
    #
    # The [VM] tag is only applied when I can determine that I'm in a virtual
    # machine.
    #
    # '1234' will be the current history number (useful for repeating commands,
    # etc).
    #
    # Wrapping all of this in a function so I can use PROMPT_COMMAND (see
    # bash(1)).  That means the git status will be refreshed as I go.
    # 
    function currentPrompt () {
        PS1="${IGreen}${ScreenName:+"#${ScreenName}# "}${BWhite}${THIS_HOST[$SHORTNAME]}${Color_Off}\
${IS_VM:+${BRed}[VM]${Color_Off}} - \
${Purple}\w${Color_Off}$(gitStatusTag) : \
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
    alias cdp="cd ~/personal"
    alias cdt="cd ~/tmp"
    alias cdw="cd ~/workstuff"
    alias dusk="du -sk"
    alias gzcat="gzip -dc"
    alias h="history 25"
	alias m=make
    alias mailfile="vim -c 'set filetype=mail'"
    alias pd=perldoc
    alias pf="perldoc -f"
    alias psme="ps auxww | egrep \"^(USER|${USER})\" | sort"
    # Safety first
    alias rm="rm -i"
    alias sp=". ${MYDIR[$ENV]}/.bashrc"
    alias vp="vi ${MYDIR[$ENV]}/.bashrc"

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

    # Shows an IP and mask in dotted-quad and binary.
    # Example:
    # $ bincidr 1.2.3.4/24
    # 1.2.3.4/24
    # ==========
    #   Dotted Quad:
    #               1.       2.       3.       4
    #      &      255.     255.     255.       0
    #      =        1.       2.       3.       0
    #   Binary:
    #        00000001 00000010 00000011 00000100
    #      & 11111111 11111111 11111111 00000000 
    #      = 00000001 00000010 00000011 00000000
    function bincidr () {
        perl -e '
            use strict;
            use warnings;
            use Socket;
            my $cidr = shift;
            my ($net, $mask);
            my $validBlock = undef;
            if ($cidr && $cidr =~ m|/|) {
                ($net, $mask) = (split /\//, $cidr);
                if ($net =~ /\A(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\Z/) {
                    if (($1<=255) && ($2<=255) && ($3<=255) && ($4<=255)) {
                        if ($mask !~ /\D/) {
                            if ($mask <= 32) {
                                $validBlock = 1;
                            }
                        }
                    }
                }
            }
            die "Invalid cidr block: "
                . ($cidr ? $cidr : "NOT SPECIFIED")
                . " (must be in a.b.c.d/m form)\n"
                unless $validBlock;

            my $net_n   = inet_aton($net);
            my $mask_n  = pack "B32", ("1" x $mask . "0" x (32 - $mask));
            my $final_n = $net_n & $mask_n;

            sub spaceQuad { my $a = shift; return join(".", map {sprintf "%8d", $_} split(/\./, $a)) }
            print "$cidr :\n", "=" x length($cidr), "\n";
            print "    Dotted Quad:\n";
            print " " x 8,            spaceQuad($net), "\n";
            print " " x 6, "\&", " ", spaceQuad(inet_ntoa($mask_n)), "\n";
            print " " x 6,  "=", " ", spaceQuad(inet_ntoa($final_n)), "\n";
            
            sub spaceBin { my $n = shift; return join(" ", unpack("(B8)*", $n)) }
            print "    Binary:\n";
            print " " x 8,            spaceBin($net_n), "\n";
            print " " x 6, "\&", " ", spaceBin($mask_n), "\n";
            print " " x 6,  "=", " ", spaceBin($final_n), "\n";
        ' $1
    }

    ###
    # Functional equivalents to old tcsh aliases and miscellaneous
    # other functions.
    function lme  () { ls -ls $* | grep $USER; }
    function lstf () { ls -l  $* | grep "^-";  }
    function lstd () { ls -l  $* | grep "^d";  }
    function lstl () { ls -l  $* | grep "^l";  }

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
        vi -c "set filetype=sh" $*
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

    ###
    # In case 'perldoc -l <module>' doesn't work.
    function pmwhich () {
        if [[ -n $1 ]]
        then
            perl -e \
               'foreach my $module (@ARGV) {
                    my $fileName;
                    ($fileName = $module) =~ s{::}{/}g;
                    $fileName .= ".pm";

                    my $ok = eval "use $module (); 1";

                    if (defined $ok) {
                        my $fullPath = $INC{$fileName}  || "(path??)";
                        my $version  = $module->VERSION || "(??)";
                        print "$module v$version : $fullPath\n";
                    }
                    else {
                        warn "$module not found or did not load successfully.\n",
                    }
                }' $@
        else
            echo "Usage: pmwhich <module> [module ...]"
        fi
    }

    ###
    # Given an errno.h error number (via syslog or some such)
    # print the associated error message.
    function errno () {
        if [[ -n $1 ]]
        then
            perl -e \
                    'use English;
                     my $errno = shift;
                     if (($errno !~ /\D/) && ($errno >= 0)) {
                        $OS_ERROR = $errno;
                        print "$OS_ERROR\n";
                     }
                     else {
                        print "Invalid error number: $errno\n";
                     }' $1
        else
            echo "Usage: errno N"
        fi
    }

    ###
    # What are the atime, mtime, and ctime for a file or files?
    function ftimes () {
        if [[ -n $* ]]
        then
            for file in $*
            do
                perl -e 'my $File = shift;
                         my ($a, $m, $c) = (stat $File)[8, 9, 10];
                         print "${File}::\n",
                               "atime : ", scalar(localtime($a)), "\n",
                               "mtime : ", scalar(localtime($m)), "\n",
                               "ctime : ", scalar(localtime($c)), "\n";
                        ' $file;
            done
        else 
            echo "Please specify a file or files to examine."
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

		alias	resig='/bin/kill -HUP `cat $HOME/randsig.pid`'
		alias	seti="screen -dr seti"
		alias	smutt="screen -S mutt mutt"

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

fi # End if - INTERACTIVE_COND }
