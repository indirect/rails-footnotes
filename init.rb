# Footnotes is divided in three main files:
#
#  * loader.rb: Initialize the plugin and apply the footnotes as an after_filter;
#
#  * footnotes.rb: Is the core and adds the debug options at the bottom of each page;
#
#  * backtracer.rb: Append links to your favorite editor in backtraces.
#
if RAILS_ENV == 'development'
  dir = File.dirname(__FILE__)
  require File.join(dir,'lib','footnotes')
  require File.join(dir,'lib','loader')
  require File.join(dir,'lib','backtracer')
end