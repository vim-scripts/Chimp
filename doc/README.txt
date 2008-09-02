                 ______________ _____
                 __  ____/__  /____(_)______ ___________
                 _  /    __  __ \_  /__  __ `__ \__  __ \
                 / /___  _  / / /  / _  / / / / /_  /_/ /
                 \____/  /_/ /_//_/  /_/ /_/ /_/_  .___/
                                                /_/

Chimp uses screen to talk to external interpreters. The basic screen driver
is language agnostic and is intended to be used as backend for filetype
plugins, which comprise the intelligence of the system.

An example filetype plugin for Clojure is included. There are several ways
to extract code and send it to a running Clojure in a screen.

The coupling is very loose on purpose! Eg. one can send from several Vims
to the same screen. However this leads to a certain fragileness. The Clojure
plugin takes care of automatically switching namespaces for the different
files being edited. However, nothing prevents the user from interacting
with the REPL directly messing up the namespace sync between Chimp in Vim
and Clojure.

Chimp should also work on Windows with Cygwin.

For installation put the extracted subdirectory in your .vim directory.
Start your interpreter with the chimp.sh wrapper from the bin/ subdir.
It tells you a "Chimp Id" in the bottom line of the screen. Supply this
to the glue functions. The Clojure plugin will ask you the first time
you send data and will further cache the Id.

This Clojure part of the script needs the VimClojure filetype plugin for
Clojure. It may be found here:

  http://kotka.de/projects/clojure/vimclojure.html

Similar scripts:
 - VILisp
 - Limp
 - http://technotales.wordpress.com/2007/10/03/like-slime-for-vim/

Meikel Brandmeyer <mb@kotka.de>
Frankfurt am Main, September 2nd 2008
