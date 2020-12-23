This is an attempt to make the original Perl Kit Version 1.0 to build on
"modern" Linux and BSD. The original README file shipped with Perl has been
moved to README.perl.txt.

we try our best to minimize the diff with the original source code and build
system, because building is half of the fun :) Changes are limited to pure
refactoring allowing to compile and run Perl1 successfully. We keep the bugs
and the building issues, because they're part of history as much as features.

- [Building](#building)
  - [undefined reference to \`crypt'](#undefined-reference-to-crypt)
  - [perl.y:73.1-5: error: syntax error, unexpected %type, expecting string or character literal or identifier](#perly731-5-error-syntax-error-unexpected-type-expecting-string-or-character-literal-or-identifier)
  - [error: conflicting types for 'memcpy'](#error-conflicting-types-for-memcpy-and-a-lot-of-noise)
  - [What is the full name of your C library?](#what-is-the-full-name-of-your-c-library)
- [Not Building](#not-building)
  - [Vagrant](#vagrant)
  - [Docker](#docker)
- [Testing](#testing)
  - [Can't open /etc/termcap.](#cant-open-etctermcap)

Building
========
The building process has three steps:

1. `./Configure` (answer all the questions)
2. `make depend` (maybe a lot of warnings)
3. `make` (expect a lot of warnings)

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

If you still get the same error, your compiler / linker is picky about flags
order. The `-lcrypt` flag must be added to the **libs** variable in the
Makefile:

	 % sed -i.bak -e '/^libs =/ s/$/ -lcrypt/' Makefile

perl.y:73.1-5: error: syntax error, unexpected %type, expecting string or character literal or identifier
---------------------------------------------------------------------------------------------------------
Your `yacc(1)` is incompatible with Perl1, it is probably GNU bison.

### Fix:
Install a Berkley Yacc (for example byacc under Debian) and then edit the
**Makefile** in order to use it:

	% sed -i.bak -e 's/yacc/byacc/' Makefile

make: yacc: Command not found
-----------------------------
You need `yacc(1)` to build Perl1.

### Fix:
Install a Berkley Yacc (for example byacc under Debian).

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

Not Building
============
Not in the mood to answer questions from 1987? You'll miss a good chunk of the
fun, but we got you.

Vagrant
-------
There is a [Vagrant](https://www.vagrantup.com/) VM based on [Alpine
Linux](https://alpinelinux.org/) with a provision step building the latest
release:

```console
$ vagrant up
$ vagrant ssh
```

Once inside the VM, you can freely enjoy the Perl Kit experience. The build
directory is at /usr/src/perl1.

```console
alpine312:~$ which perl
/bin/perl
alpine312:~$ perl -v
$Header: perly.c,v 1.0.1.3 88/01/28 10:28:31 root Exp $
Patch level: 10
alpine312:~$ sudo make -C /usr/src/perl1 test
alpine312:~$ man perl
```

Note that /bin/perl in the VM is statically linked. Consequently, if your are
running linux on x86-64 you can copy /bin/perl from the VM and it should run
just fine from your host:

```console
alpine312:~$ file /bin/perl
/bin/perl: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, with debug_info, not stripped
alpine312:~$ sudo cp /bin/perl /vagrant/
alpine312:~$ exit
$ ./perl -e 'print "Hello from the 21th century!\n";'
Hello from the 21th century!
```

Docker
------
There is a Perl Kit 1.0 [Docker](https://www.docker.com/) image available at
[ghcr.io/kaworu/perl1-alpine](ghcr.io/kaworu/perl1-alpine), ideal if you are
planning to run in The Cloud:

```console
$ docker run --rm ghcr.io/kaworu/perl1-alpine perl -e 'print "Hello from Docker!\n";'
Hello from Docker!
$ docker run -it --rm ghcr.io/kaworu/perl1-alpine sh
/ # man perl
```

Testing
=======
Perl1 comes with some tests, see the t/ directory. You can run the tests from
the project's directory with:

	% make test

Can't open /etc/termcap.
------------------------
Your system doesn't provide a termcap file, but the tests assume that it exist.

### Fix:
You can either get a termcap file and install it as /etc/termcap, or edit the
tests to check for another file:

	% sed -i -e 's/termcap/fstab/g' t/*
