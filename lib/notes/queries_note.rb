require "#{File.dirname(__FILE__)}/abstract_note"

module Footnotes
  module Notes
    class QueriesNote < AbstractNote
      @@sql = []
      cattr_accessor :sql

      def self.start!(controller)
        @@sql = [] unless controller.instance_variable_get('@parent_controller')
      end

      def self.to_sym
        :queries
      end

      def title
        "Queries (#{@@sql.length})"
      end

      def stylesheet
<<-STYLESHEET
  #queries_debug_info table td, #queries_debug_info table th{border:1px solid #A00; padding:0 3px; text-align:center;}
  #queries_debug_info table thead, #queries_debug_info table tbody {color:#A00;}
  #queries_debug_info p {background-color:#F3F3FF; border:1px solid #CCC; margin:12px; padding:4px 6px;}
  #queries_debug_info a:hover {text-decoration:underline;}
STYLESHEET
      end

      def javascript
<<-JAVASCRIPT
  function queries_toogle(type, id){
    s = document.getElementById('q'+type+'_'+id).style
    s.display = (s.display != 'block') ? 'block' : 'none'
    location.href = '#qtitle_'+id
  }
JAVASCRIPT
      end

      def content
        html = ''

        @@sql.each_with_index do |item, i|
          sql_links = []
          sql_links << "<a href=\"#\" style=\"color:#A00;\" onclick=\"queries_toogle('table',#{i});return false\">explain</a>" if item.explain
          sql_links << "<a href=\"#\" style=\"color:#00A;\" onclick=\"queries_toogle('trace',#{i});return false\">trace</a>" if item.trace

html << <<-HTML
  <b id="qtitle_#{i}">#{escape(item.type.to_s.upcase)}</b> (#{sql_links.join(' | ')})<br />
  #{print_name_and_time(item.name, item.time)}<br />
  #{print_query(item.query)}<br />
  #{print_explain(i, item.explain) if item.explain}
  <p id="qtrace_#{i}" style="display:none;">#{parse_trace(item.trace) if item.trace}</p><br />
HTML
        end

        return html
      end

      protected
        def parse_explain(results)
          table = []
          table << results.fetch_fields.map(&:name)
          results.each{|row| table << row}
          table
        end

        def parse_trace(trace)
          trace.map do |t|
            s = t.split(':')
            "<a href=\"#{escape("#{Footnotes::Filter.prefix}#{RAILS_ROOT}/#{s[0]}&line=#{s[1].to_i}")}\">#{escape(t)}</a><br />"
          end.join
        end

        def print_name_and_time(name, time)
          "#{escape(name || 'SQL')} (#{sprintf('%f', time)}s)"
        end

        def print_query(query)
          escape(query.to_s.gsub(/(\s)+/, ' ').gsub('`', ''))
        end

        def print_explain(i, explain)
          mount_table(parse_explain(explain), :id => "qtable_#{i}", :style => 'margin:10px;display:none;')
        end
    end
  end

  module Extensions
    class Sql
      attr_accessor :type, :name, :time, :query, :explain, :trace

      def initialize(type, name, time, query, explain)
        @type = type
        @name = name
        @time = time
        @query = query
        @explain = explain

        # Strip, select those ones from app and reject first two, because they are from the plugin
        @trace = Kernel.caller.collect(&:strip).select{|i| i.gsub!(/^#{RAILS_ROOT}\//im, '') }[2..-1]
      end
    end

    module QueryAnalyzer
      def self.included(base)
        base.class_eval do
          alias_method_chain :execute, :analyzer
        end
      end

      def execute_with_analyzer(query, name = nil)
        query_results = nil
        time = Benchmark.realtime { query_results = execute_without_analyzer(query, name) }

        if query =~ /^(select|create|update|delete)\b/i
          type = $&.downcase.to_sym
          explain = nil

          if adapter_name == 'MySQL' && type == :select
            log_silence do
              explain = execute_without_analyzer("EXPLAIN #{query}", name)
            end
          end
          Footnotes::Notes::QueriesNote.sql << Footnotes::Extensions::Sql.new(type, name, time, query, explain)
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
end

if Footnotes::Notes::QueriesNote.included?
  ActiveRecord::ConnectionAdapters::AbstractAdapter.__send__ :include, Footnotes::Extensions::AbstractAdapter
  ActiveRecord::ConnectionAdapters.local_constants.each do |adapter|
    next unless adapter =~ /.*[^Abstract]Adapter$/
    next if adapter =~ /SQLite.Adapter$/
    eval("ActiveRecord::ConnectionAdapters::#{adapter}").__send__ :include, Footnotes::Extensions::QueryAnalyzer
  end
end