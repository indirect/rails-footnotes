Footnotes plugin for Rails
--------------------------

If you are developing in Rails you should know the plugin!

It displays footnotes in your application for easy debugging, such as sessions, request parameters, cookies, log tail, filter chain and routes. 

Even more, it contain links to open files directly in textmate and if Rails get an error you can click in the backtrace lines to open the clicked file line in TextMate also.

Installation
============

If you just want a static copy of the plugin:

    cd myapp
    git clone git://github.com/drnic/rails-footnotes.git vendor/plugins/footnotes
    rm -rf vendor/plugins/footnotes/.git
    
If you are using Git for your own app, then you could use Git sub-modules or the
tool [Braid](http://github.com/evilchelu/braid/tree/master).

Original Author
===============

Duane Johnson (duane.johnson@gmail.com)

Maintainer
==========

José Valim (jose.valim@gmail.com)

License
=======

See MIT License.