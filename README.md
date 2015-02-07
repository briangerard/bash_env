# My Home Environment

All of the creature comforts I've accrued over the years.  Functions, aliases,
scripts, vim configs, etc.

To spin up a new environment:

```sh
git clone https://github.com/briangerard/my_env.git env
cd env
./initialize
exec bash -l
```

Some of my more commonly-used commands:

* Environment management
   * `syncenv` - Synchronizes my environment from ~/env to a specified host, or
     just to $HOME/, if the target is "local"
   * `reSource` - Some of the supporting scripts are set up to avoid potential
     recursive inclusion.  This allows me to re-evaluate them.
   * `sp`, `vp` - Source ("."), or edit ~/env/.bashrc
* Various informative networking-related utilities
   * `bincidr` - Show the binary and dotted-quad representation of the CIDR
     block a.b.c.d/m.
   * `i2ip`, `ip2i`, `h2ip`, `ip2h` - Convert: an integer to a dotted-quad IP, a
     dotted-quad IP to an integer, an 8-digit hex number to a dotted-quad IP,
     and a dotted-quad IP to an 8-digit hex number.
* Development
   * `ga`, `gc`, `gpl`, `gps` - git add, commit, pull --rebase, and push.
   * `gd`, `gdc`, `gs`, `gsl` - git diff, diff --cached, status, and short log
     (with the options I like).
   * `newperl`, `newpm` - Create a new Perl script or module, with some standard
     boilerplate and open it in $EDITOR
* Other favorites
   * `lstd`, `lstf`, `lstl` - List all directories, regular files, or symbolic
     links in whatever directories are specified (or the current directory, with
     no arguments).
   * `pmwhich`, `pd`, `pf` - Locate a perl module in @INC, and an abbreviation
     for 'perldoc', and 'perldoc -f'.
   * `ftimes` - Show the atime, mtime, and ctime of a file or directory.
   * `runon` - Grep for a Host pattern (regex) in ~/.ssh/config, and run a given
     command on each host found.
