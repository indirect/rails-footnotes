require "#{File.dirname(__FILE__)}/log_note"

module Footnotes
  module Notes
    class PartialsNote < LogNote
      def initialize(controller)
        super
        @controller = controller
      end
      def row
        :edit
      end
      def title
        "Partials (#{partials.size})"
      end
      def content
        rows = partials.map do |filename|
          href = Footnotes::Filter.prefix(filename,1,1)
          shortened_name=filename.gsub(File.join(RAILS_ROOT,"app/views/"),"")
          [%{<a href="#{href}">#{shortened_name}</a>},"#{@partial_times[filename].sum}ms",@partial_counts[filename]]
        end
        mount_table(rows.unshift(%w(Partial Time Count)), :summary => "Partials for #{title}")
      end

      protected
        #Generate a list of partials that were rendered, also build up render times and counts.
        #This is memoized so we can use its information in the title easily.
        def partials
          @partials ||= begin
            partials = []
            @partial_counts = {}
            @partial_times = {}
            log_lines = log
            log_lines.split("\n").each do |line|
              if line =~ /Rendered (\S*) \(([\d\.]+)\S*?\)/
                partial = $1
                @controller.view_paths.each do |view_path|
                  path = File.join(view_path, "#{partial}*")
                  files = Dir.glob(path)
                  for file in files
                    #TODO figure out what format got rendered if theres multiple
                    @partial_times[file] ||= []
                    @partial_times[file] << $2.to_f
                    @partial_counts[file] ||= 0
                    @partial_counts[file] += 1
                    partials << file unless partials.include?(file)
                  end
                end
              end
            end
            partials.reverse
          end
        end
    end    
  end
end
