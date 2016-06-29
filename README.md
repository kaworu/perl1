This is an attempt to make the original Perl Kit, Version 1.0 to build on
recent Linux and \*BSD. The original README file shipped with Perl has been
moved to README.perl.txt.

This project is a remake of https://github.com/rhaamo/perl1. In this branch
(**minimal-changes**) we try harder not to modify the original source code and
keep the original build system, because building is half of the fun :) Source
changes are limited to pure refactoring allowing to compile Perl1 successfully.
We keep the bugs and the building issues, because they're part of history as
much as features.

Building
========
The building process has three steps:

1. ./Configure (answer all the questions)
2. make depend (maybe a lot of warnings)
3. make (expect a lot of warnings)

On success the last line should be

	touch all

You can then enjoy `./perl`.

But most of the time you'll run into errors depending on your system and how
clever were your answers in the *Configure* step. Instead of trying to give
fixes for every system, here is a list of solutions for the most common errors
(in order from the most expected to the least).

**IMPORTANT**: If you intent to run the tests or actually use Perl1, be sure to
build it with its own malloc. Answer `y` to the following question during the
*Configure* step:

	Do you wish to attempt to use the malloc that comes with perl? [n]


undefined reference to \`crypt'
------------------------------
Perl1 use `crypt(3)` which is not in your libc, it's probably in `libcrypt`.

### Fix:
At the *Configure* step try to add `-lcrypt` to the additional ld flags:

	Any additional ld flags? [none] -lcrypt

If you still get the error, your compiler / linker is picky about flags order.
The `-lcrypt` flag must be added to the **libs** variable in the Makefile:

	 % sed -i.bak -e '/^libs =/ s/$/ -lcrypt/' Makefile

perl.y:73.1-5: error: syntax error, unexpected %type, expecting string or char or identifier
--------------------------------------------------------------------------------------------
Your `yacc(1)` is incompatible with Perl1, it is probably GNU bison.

### Fix:
Install a Berkley Yacc (for example byacc under Debian) and then edit the
**Makefile** in order to use it:

	% sed -i.bak -e 's/yacc/byacc/' Makefile

error: conflicting types for 'memcpy' (and a lot of noise)
----------------------------------------------------------
perl.h #define bcopy which means trouble if a header (like good ol'
`strings.h`) try to declare it.

### Fix:
In the *Configure* step add the `-DBCOPY` to additional cc flags:

	Any additional cc flags? [none] -DBCOPY

What is the full name of your C library?
----------------------------------------
the *Configure* step might fail to locate your C library. It happens for
example on Ubuntu x86\_64 because of their
[Multiarch](https://wiki.ubuntu.com/MultiarchSpec) design.

### Fix:
Just figure out where is your system's libc and tell *Configure*.


Testing
=======
Perl1 comes with some tests, see the **t** directory. You can launch the tests
from the project's directory with:

	% make test

Can't open /etc/termcap.
------------------------
Your system doesn't provide a termcap file, but the tests assume that it exist.

### Fix:
You can either get a termcap file and install it as /etc/termcap, or edit the
tests to check for another file:

	% sed -i.bak -e 's/termcap/fstab/' t/*
