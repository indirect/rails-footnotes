Footnotes plugin for Rails (v3.2.1)
-----------------------------------

If you are developing in Rails you should know the plugin!

It displays footnotes in your application for easy debugging, such as sessions, request parameters, cookies, log tail, filter chain and routes. 

Even more, it contains links to open files directly in textmate. And if Rails get an error, it appends Textmate links to backtrace file lines.

Installation
============

The newest versions of the plugin only works in Rails 2.1 and above. Scroll down to check how to install early versions.

If you just want a static copy of the plugin:

    cd myapp
    git clone git://github.com/drnic/rails-footnotes.git vendor/plugins/footnotes
    rm -rf vendor/plugins/footnotes/.git

If you are using Git for your own app, then you could use Git sub-modules or the tool [Braid](http://github.com/evilchelu/braid/tree/master).

Early versions
==============

If you are running on Rails 2.0.x or Rails 1.x, you should use Footnotes v3.0:

    cd myapp
    git clone git://github.com/drnic/rails-footnotes.git vendor/plugins/footnotes
    cd vendor/plugins/footnotes
    git checkout v3.0
    rm -rf ./.git

Remember that in Rails 1.x, after filters appear first than before filters in the Filters tab.

Usage notes
===========

* Footnotes are applied in all actions under development. If You want to change this behaviour, check the initializer.rb file.

* Some features only work if you are under MacOSX. But if your editor support opening files like Textmate, e.g. txmt://open?url=file://, you can put in your environment file the following line:

  Footnotes::Filter.prefix = "editor://open?file://"

  Another option is to automatically register the protocol in your browser and/or OS. More information [here](http://kb.mozillazine.org/Register_protocol).

* If you want to use your own stylesheet, you can disable the Footnotes stylesheet with:

  Footnotes::Filter.no_style = true

* Footnotes are appended at the end of the page, but if your page has a div with id "footnotes_holder", Footnotes will be inserted into this div.

* If you want to open multiple notes at the same time, set Footnotes::Filter.multiple_notes = true

* Finally, you can cherry pick which notes you want to use, simply doing:

  Footnotes::Filter.notes = [:session, :cookies, :params, :filters, :routes, :queries, :log, :general]

Creating your own notes
=======================

Create your notes to integrate with Footnotes is easy.

1. Create a Footnotes::Notes::YoursExampleNote class

2. Implement the necessary methods (check abstract_note.rb file in lib/notes)

3. Append yours example note in Footnotes::Filter.notes (usually at the end of your environment file or an initializer):

  Footnotes::Filter.notes += [:yours_example]

To create a note that shows info about the user logged in your application (@current_user) you just have to do:

<pre><code>module Footnotes
  module Notes
    class CurrentUserNote < AbstractNote
      # Always receives a controller
      #
      def initialize(controller)
        @current_user = controller.instance_variable_get("@current_user")
      end

      # Specifies the symbol that represent this note
      # This is the one you will have to add to Footnotes::Filter.notes
      #
      def self.to_sym
        :current_user
      end

      # The name that will appear as link
      # If title is nil, the other methods are not called
      #
      def title
        'Current User' if @current_user
      end

      # The name that will appear as legend in fieldsets
      #
      def legend
        "Current user: #{@current_user.name}"
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