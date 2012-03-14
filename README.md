RubyPw: it handles your password!
=============

Dangerous-Dont-Ever-Use!!1!
-------
Just testing it out. I'm not shure it's cryptographically secure/reliable.
Just DONT entrust it your passwords at the moment.

Wat
-------
Just a script to save all your passwords in a crypted db.

How to
-------
First you add manually users and their passwords:

    $ rubypw add [username]

or import them

    $ rubypw file [filename]

from a file like this:

    username1 password1
    username2 password2

Then you get the password you need with:

    $ rubypw get [username]

Moreover you can:

list all your users and passwords:

    rubypw list

delete an user:

    rubypw del [username]

just generate a random password:

    rubypw generate [password lenght]

and dump your db to a qrcode png file:

    rubypw dump [filename]
