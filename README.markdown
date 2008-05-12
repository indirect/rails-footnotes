Footnotes plugin for Rails
--------------------------

If you are developing in Rails you should know the plugin!

It displays footnotes in your application for easy debugging, such as sessions, request parameters, cookies, log tail, filter chain and routes. 

Even more, it contain links to open files directly in textmate and if Rails get an error, it appends Textmate links to the backtrace file lines.

Installation
============

If you just want a static copy of the plugin:

    cd myapp
    git clone git://github.com/drnic/rails-footnotes.git vendor/plugins/footnotes
    rm -rf vendor/plugins/footnotes/.git
    
If you are using Git for your own app, then you could use Git sub-modules or the
tool [Braid](http://github.com/evilchelu/braid/tree/master).

Known Issues
============

In Rails 1.x, the after_filter appear first than before_filter in the Filters tab. Then the results:

    :c, after_filter
    :d, after_filter
    :e, after_filter
    :a, before_filter
    :b, before_filter

Would exactly mean:

    :a, before_filter
    :b, before_filter
    :c, after_filter
    :d, after_filter
    :e, after_filter

Nonetheless, always consider upgrading Your app to Rails 2.x. =)
    
Original Author
===============

Duane Johnson (duane.johnson@gmail.com)

Maintainer
==========

José Valim (jose.valim@gmail.com)

License
=======

See MIT License.