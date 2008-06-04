module Footnotes
  module QueryAnalyzer
    def self.parse_explain(results)
      table = []
      table << results.fetch_fields.map(&:name)
      results.each{|row| table << row}
      table
    end

    def self.included(base)
      base.class_eval do
        alias_method_chain :execute, :analyzer
      end
    end

    def execute_with_analyzer(sql, name = nil)
      query_results = nil
      time = Benchmark.realtime { query_results = execute_without_analyzer(sql, name) }

      if sql =~ /^(select)|(create)|(update)|(delete)\b/i
        operation = $&.downcase.to_sym
        explain = nil

        if adapter_name == 'MySQL' && operation == :select
          log_silence do
            explain = execute_without_analyzer("explain #{sql}", name)
          end
          explain = Footnotes::QueryAnalyzer.parse_explain(explain)
        end
        Footnotes::Filter.sql << [operation, name, time, sql, explain]
      end

      query_results
    end
  end

  module AbstractAdapter
    def log_silence
      result = nil
      if @logger
        @logger.silence do
          result = yield
        end        
      else
        result = yield
      end
      result
    end
  end
end

ActiveRecord::ConnectionAdapters::AbstractAdapter.send :include, Footnotes::AbstractAdapter
ActiveRecord::ConnectionAdapters.local_constants.each do |adapter|
  next unless adapter =~ /.*[^Abstract]Adapter$/
  eval("ActiveRecord::ConnectionAdapters::#{adapter}").send :include, Footnotes::QueryAnalyzer
end