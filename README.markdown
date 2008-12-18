Footnotes plugin for Rails (v3.3)
---------------------------------

If you are developing in Rails you should know the plugin!

It displays footnotes in your application for easy debugging, such as sessions, request parameters, cookies, filter chain, routes, queries, etc. 

Even more, it contains links to open files directly in your editor (default is textmate). And if Rails get an error, it also appends text editor links to backtrace file lines.

Installation
============

The current version is only Rails Edge (aka Rails 2.2) compatible. Scroll down to check how to install early versions.

If you just want a static copy of the plugin:

    cd myapp
    git clone git://github.com/josevalim/rails-footnotes.git vendor/plugins/footnotes
    rm -rf vendor/plugins/footnotes/.git

Early versions
==============

If you are running on Rails 2.1.x, you should use Footnotes v3.2.2:

    cd myapp
    git clone git://github.com/josevalim/rails-footnotes.git vendor/plugins/footnotes
    cd vendor/plugins/footnotes
    git checkout v3.2.2
    rm -rf ./.git

If you are running on Rails 2.0.x, you should use Footnotes v3.0:

    cd myapp
    git clone git://github.com/josevalim/rails-footnotes.git vendor/plugins/footnotes
    cd vendor/plugins/footnotes
    git checkout v3.0
    rm -rf ./.git

Usage
=====

* Footnotes are applied in all actions under development. If You want to change this behaviour, check the loader.rb file.

* Some features only work by default if you are under MacOSX and using Textmate.
  If your editor supports out-of-the-box opening files like Textmate, e.g. txmt://open?url=file://path/to/file, you can put in your environment file the following line:

  Footnotes::Filter.prefix = "editor://open?file://"

  If it doesn't, you can enable this behavior in few steps. I've written a post about it [here](http://josevalim.blogspot.com/2008/06/textmate-protocol-behavior-on-any.html).

* If you want to use your own stylesheet, you can disable the Footnotes stylesheet with:

  Footnotes::Filter.no_style = true

* Footnotes are appended at the end of the page, but if your page has a div with id "footnotes_holder", Footnotes will be inserted into this div.

* If you want to open multiple notes at the same time, just put in your enviroment:

  Footnotes::Filter.multiple_notes = true

* Finally, you can cherry pick which notes you want to use, simply doing:

  Footnotes::Filter.notes = [:session, :cookies, :params, :filters, :routes, :env, :queries, :log, :general]

Creating your own notes
=======================

Create your notes to integrate with Footnotes is easy.

1. Create a Footnotes::Notes::YourExampleNote class

2. Implement the necessary methods (check abstract_note.rb file in lib/notes)

3. Append your example note in Footnotes::Filter.notes array (usually at the end of your environment file or in an initializer):

  Footnotes::Filter.notes += [:your_example]

For example, to create a note that shows info about the user logged in your application you just have to do:

<pre><code>module Footnotes
  module Notes
    class CurrentUserNote < AbstractNote
      # This method always receives a controller
      #
      def initialize(controller)
        @current_user = controller.instance_variable_get("@current_user")
      end

      # The name that will appear as legend in fieldsets
      #
      def legend
        "Current user: #{@current_user.name}"
      end

      # This Note is only valid if we actually found an user
      # If it's not valid, it won't be displayed
      #
      def valid?
        @current_user
      end

      # The fieldset content
      #
      def content
        escape(@current_user.inspect)
      end
    end
  end
end</code></pre>
  
Then put in your environment:

  Footnotes::Filter.notes += [:current_user]

Who?
====

*Current Developer (v3.0 and above)*

José Valim (jose.valim@gmail.com)
http://josevalim.blogspot.com/


*Original Author (v2.0)*

Duane Johnson (duane.johnson@gmail.com)
http://blog.inquirylabs.com/


*License*

See MIT License.