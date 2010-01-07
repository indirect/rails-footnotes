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
        links = partials.map do |file|
          href = Footnotes::Filter.prefix(file,1,1)
          "<tr><td><a href=\"#{href}\">#{file.gsub(File.join(Rails.root,"app/views/"),"")}</td><td>#{@partial_times[file].sum}ms</a></td><td>#{@partial_counts[file]}</td></tr>"
        end
        "<table><thead><tr><th>Partial</th><th>Time</th><th>Count</th></tr></thead><tbody>#{links.join}</tbody></table>"
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
                files = Dir.glob("#{Rails.root}/app/views/#{partial}*")
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
            partials.reverse
          end
        end
    end    
  end
end
