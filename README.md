my_env
========

The common bits of my .bashrc, .vimrc, .vim/*, etc that I've accumulated over
the years and find myself scp'ing around every time I'm on a new system.  Time
to put it someplace that makes sense.  :)

Some notable/useful functions and features:

<dl>
<dt><tt>lstd()</tt>, <tt>lstf()</tt>, and <tt>lstl()</tt></dt>
<dd>List all directories, regular files, and symbolic links in whatever
directories are specified (or the current directory, with no arguments).
</dd>
<dt>
<dt><tt>bincidr()</tt></dt>
<dd>Show the binary and dotted-quad representation of the CIDR
block a.b.c.d/m.
</dd>
<dt><tt>i2ip</tt>, <tt>ip2i</tt>, <tt>h2ip</tt>, <tt>ip2h</tt></dt>
<dd>Convert: an integer to a dotted-quad IP, a dotted-quad IP to an integer,
an 8-digit hex number to a dotted-quad IP, and a dotted-quad IP to
an 8-digit hex number.
</dd>
<dt><tt>pmwhich()</tt>, <tt>pd</tt>, <tt>pf</tt></dt>
<dd>Locate a perl module in @INC, short version of 'perldoc', and
'perldoc -f'.
</dd>
<dt><tt>newperl()</tt>, <tt>newpm()</tt></dt>
<dd>Create a new Perl script or module, with some standard boilerplate
and open it in $EDITOR
</dd>
<dt><tt>sp</tt>, <tt>vp</tt></dt>
<dd>Source (&quot;.&quot;) or edit ~/env/.bashrc
</dd>
<dt><tt>syncenv()</tt></dt>
<dd>Synchronize my environment from ~/env to a specified host, or just
to $HOME/, if the target is &quot;local&quot;
</dd>
<dt><tt>reSource()</tt></dt>
<dd>Some of the supporting scripts are set up to avoid potential
recursive inclusion.  This allows me to re-evaluate them.
</dd>
<dt><tt>ftimes()</tt></dt>
<dd>Show the atime, mtime, and ctime of a file or directory.
</dd>
<dt><tt>runon()</tt></dt>
<dd>Grep for a Host pattern (regex) in ~/.ssh/config, and run a given
command on each host found.
</dd>
</dl>
