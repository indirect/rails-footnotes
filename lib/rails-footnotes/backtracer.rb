if Rails.version < '3.0'
  module Footnotes
    module Extensions
      module Exception
        def self.included(base)
          base.class_eval do
            alias_method_chain :clean_backtrace, :links
          end
        end

        def add_links_to_backtrace(lines)
          lines.collect do |line|
            expanded = line.gsub('#{RAILS_ROOT}', Rails.root)
            if match = expanded.match(/^(.+):(\d+):in/) || match = expanded.match(/^(.+):(\d+)\s*$/)
              file = File.expand_path(match[1])
              line_number = match[2]
              html = %[<a href="#{Footnotes::Filter.prefix(file, line_number, 1)}">#{line}</a>]
            else
              line
            end
          end
        end

        def clean_backtrace_with_links
          unless ::Footnotes::Filter.prefix.blank?
            add_links_to_backtrace(clean_backtrace_without_links)
          else
            clean_backtrace_without_links
          end
        end
      end
    end
  end

  Exception.send :include, Footnotes::Extensions::Exception
elsif defined?(Rails) && Rails.respond_to?(:backtrace_cleaner)
  require 'rails/backtrace_cleaner'
  class Rails::BacktraceCleaner
    def replace_filter(index, &block)
      @filters[index] = block
    end

    def clean(backtrace, kind = :silent)
      safe = super.map {|l| l.html_safe}
      def safe.join(*args)
        joined=super
        joined.html_safe
      end
      safe
    end

    # private
    # def add_gem_filters
    #   return unless defined?(Gem)
    #
    #   gems_paths = (Gem.path + [Gem.default_dir]).uniq.map!{ |p| Regexp.escape(p) }
    #   return if gems_paths.empty?
    #
    #   gems_regexp = %r{(#{gems_paths.join('|')})/gems/([^/]+)-([\w\.]+)/(.*)}
    #   add_filter { |line| line.sub(gems_regexp, '\2 (\3) \4') }
    # end


  end

  backtrace_cleaner = Rails.backtrace_cleaner

  backtrace_cleaner.replace_filter(0) { |line|
      if match = line.match(/^(.+):(\d+):in/) || match = line.match(/^(.+):(\d+)\s*$/)
        file = match[1]
        line_number = match[2]
        html = %[<a href="#{Footnotes::Filter.prefix(file, line_number, 1).html_safe}">#{line.sub("#{Rails.root.to_s}/",'').html_safe}</a>].html_safe
        html
      else
        line
      end
    }

    if defined?(Gem)
      gems_paths = (Gem.path + [Gem.default_dir]).uniq.map!{ |p| Regexp.escape(p) }

      unless gems_paths.empty?
        gems_regexp = %r{\>#{gems_paths.join('|')}/gems/}
        backtrace_cleaner.replace_filter(3)  {|line|
          line.sub(gems_regexp, '>')
         }
      end
    end

    backtrace_cleaner.remove_silencers!
    backtrace_cleaner.add_silencer { |line| line !~ /\>\/?(app|config|lib|test)/ }


end