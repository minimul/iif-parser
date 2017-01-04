require 'bigdecimal'
require 'csv'
require_relative 'parser/version'
require_relative 'parser/transaction'
require_relative 'parser/entry'

module Iif
  class Parser
    attr_accessor :definitions
    attr_accessor :entries
    attr_accessor :transactions

    def initialize(resource)
      @definitions = {}
      @entries = []
      @transactions = []
      resource.gsub!(/\r\n?/, "\n") # dos to unix EOL conversion
      resource = open_resource(resource)
      resource.rewind
      parse_file(resource)
      create_transactions
    end

    def open_resource(resource)
      if resource.respond_to?(:read)
        resource
      else
        open(resource)
      end
    rescue Exception
      StringIO.new(resource)
    end

    def parse_line(line)
      if (ar = line.split(/\t/)).size == 1
        ar = CSV.parse_line(line).map { |i| i == nil ? "" : i }
      end
      ar
    end

    def parse_file(resource)
      resource.each_line do |line|
        next if line.strip! == ""
        fields = parse_line(line)
        if fields[0][0] == '!'
          parse_definition(fields)
        else
          parse_data(fields)
        end
      end
    end
    
    def parse_definition(fields)
      key = fields[0][1..-1]
      values = fields[1..-1]
      @definitions[key] = values.map { |v| v.downcase }
    end

    def parse_data(fields)
      definition = @definitions[fields[0]]
      entry = Entry.new
      entry.type = fields[0]
      fields[1..-1].each_with_index do |field, idx|
        next unless definition and definition[idx]
        entry.send(definition[idx] + "=", clean_field(field))
      end
      entry.amount = BigDecimal.new(entry.amount.gsub(/(,)/,'')) unless entry.amount.to_s == ""
      entry.date = convert_date(entry.date) if entry.date and not entry.date == ""
      @entries.push(entry)
    end

    def clean_field(field)
      field.gsub!(/\A"|"\Z/, '')
      field.strip! if field.is_a?(String)
      field
    end

    def convert_date(date)
      ar = date.split(/[-\/]/).map(&:to_i)
      year = ar[2].to_s.size == 4 ? ar[2] : "20#{ar[2]}"
      Date.new(year.to_i, ar[0], ar[1])
    end

    def create_transactions
      transaction = nil
      in_transaction = false

      @entries.each do |entry|
        
        case entry.type

        when "TRNS"
          if in_transaction
            @transactions.push(transaction)
            in_transaction = false
          end
          transaction = Transaction.new
          in_transaction = true
          
        when "ENDTRNS"
          @transactions.push(transaction)
          in_transaction = false

        end

        transaction.entries.push(entry) if in_transaction
      end
    end
  end
end
