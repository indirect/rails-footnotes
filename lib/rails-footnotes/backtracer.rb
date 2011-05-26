require 'rails/backtrace_cleaner'
class Rails::BacktraceCleaner
  def replace_filter(index, &block)
    @filters[index] = block
  end

  def clean(backtrace, kind = :silent)
    safe = super.map {|l| l.html_safe}
    def safe.join(*args)
      (joined = super).html_safe
    end
    safe
  end
end

backtrace_cleaner = Rails.backtrace_cleaner
backtrace_cleaner.replace_filter(0) do |line|
  if match = line.match(/^(.+):(\d+):in/) || match = line.match(/^(.+):(\d+)\s*$/)
    file, line_number = match[1], match[2]
    %[<a href="#{Footnotes::Filter.prefix(file, line_number, 1).html_safe}">#{line.sub("#{Rails.root.to_s}/",'').html_safe}</a>].html_safe
  else
    line
  end
end

gems_paths = (Gem.path + [Gem.default_dir]).uniq.map!{ |p| Regexp.escape(p) }
unless gems_paths.empty?
  gems_regexp = %r{\>#{gems_paths.join('|')}/gems/}
  backtrace_cleaner.replace_filter(3) {|line| line.sub(gems_regexp, '>') }
end
backtrace_cleaner.remove_silencers!
backtrace_cleaner.add_silencer { |line| line !~ /\>\/?(app|config|lib|test)/ }
