Footnotes plugin for Rails (v3.1)
---------------------------------

If you are developing in Rails you should know the plugin!

It displays footnotes in your application for easy debugging, such as sessions, request parameters, cookies, log tail, filter chain and routes. 

Even more, it contain links to open files directly in textmate and if Rails get an error, it appends Textmate links to the backtrace file lines.

Installation
============

The newest versions of the plugin only works in Rails 2.1 (including its RC). Scroll down to check how to install early versions.

If you just want a static copy of the plugin:

    cd myapp
    git clone git://github.com/drnic/rails-footnotes.git vendor/plugins/footnotes
    rm -rf vendor/plugins/footnotes/.git

If you are using Git for your own app, then you could use Git sub-modules or the
tool [Braid](http://github.com/evilchelu/braid/tree/master).

Early versions
==============

If you are running on Rails 2.0.x or Rails 1.x, you should use Footnotes v3.0:

    cd myapp
    git clone git://github.com/drnic/rails-footnotes.git vendor/plugins/footnotes
    cd vendor/plugins/footnotes
    git checkout v3.0
    rm -rf ./.git

Remember that in Rails 1.x, after filters appear first than before filters in the Filters tab.

Original Author
===============

Duane Johnson (duane.johnson@gmail.com)

Maintainer
==========

José Valim (jose.valim@gmail.com)

License
=======

See MIT License.