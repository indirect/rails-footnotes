module Footnotes
  module QueryAnalyzer
    def self.columnized_row(fields, sized)
      row = []
      fields.each_with_index do |f, i|
        row << sprintf("%0-#{sized[i]}s", f.to_s)
      end
      row.join(' | ')
    end

    def self.columnized(array)
      sized = {}
      array.each do |row|
        row.values.each_with_index do |value, i|
          sized[i] = [sized[i].to_i, row.keys[i].length, value.to_s.length].max
        end
      end

      table = []
      table << columnized_row(array.first.keys, sized)
      table << '-' * table.first.length
      array.each { |row| table << columnized_row(row.values, sized) }
      table.join("\n  ") # Spaces added to work with format_log_entry
    end
    
    def self.included(base)
      base.class_eval do
        alias_method :select_without_analyzer, :select
        alias_method :select, :select_with_analyzer
      end
    end

    private
    def select_with_analyzer(sql, name = nil)
      query_results = select_without_analyzer(sql, name)

      if @logger && @logger.level <= Logger::INFO
        @logger.debug(
          @logger.silence do
            "\nAnalyzing #{name}\n  #{Footnotes::QueryAnalyzer.columnized(select_without_analyzer("explain #{sql}", name))}\n\n"
          end
        ) if sql =~ /^select/i
      end          
      query_results
    end
  end
end

ActiveRecord::ConnectionAdapters::MysqlAdapter.send :include, Footnotes::QueryAnalyzer