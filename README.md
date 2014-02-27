This is an attempt to make the original Perl Kit, Version 1.0 to build
correctly on recent Linux and \*BSD. The original README file shipped with Perl
has been moved to README.perl.txt.

This project is a remake of https://github.com/rhaamo/perl1. Here we try harder
not to change the original source code and keep the original build system,
since building is half of the fun :)

Building
========
The building process has three steps:

1. ./Configure (answer all the questions)
2. make depend (maybe a lot of warnings)
3. make (expet a lot of warnings)

On success the last line should be

	touch all

You can then enjoy `./perl`.

But most of the time you'll run into errors depending on your system and how
clever were your answers in the *Configure* step. Instead of trying to give
fixes for every system, here is a list of solutions for the most common errors
(in order from the most expected to the least).

undefined reference to \`crypt'
------------------------------
### Fix:
At the *Configure* step try to add `-lcrypt` to the additional ld flags:

	Any additional ld flags? [none] -lcrypt

If you still get the error, your compiler / linker is picky about flags order.
Edit the Makefile and add `-lcrypt` manually to the **libs** make variable.

perl.y:73.1-5: syntax error, unexpected %type, expecting string or char or identifier
-------------------------------------------------------------------------------------
You're using bison as yacc and it doesn't like perl.y.

### Fix:
Install a Berkley Yacc (for example byacc under Debian) and then modify
**Makefile**:

	% sed -i.bak -e 's/yacc/byacc/' Makefile

error: conflicting types for 'memcpy' (and a lot of noise)
----------------------------------------------------------
perl.h #define bcopy which means trouble if a header (like good ol'
<strings.h>) try to declare it.

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
