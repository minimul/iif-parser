require 'bigdecimal'
require 'csv'
require 'rchardet'
require_relative 'parser/version'
require_relative 'parser/transaction'
require_relative 'parser/entry'

module Iif
  class Parser
    attr_accessor :definitions, :entries, :transactions

    def initialize(resource, opts = {})
      @definitions = {}
      @entries = []
      @transactions = []
      unless resource.force_encoding('UTF-8').valid_encoding?
        cd = CharDet.detect(resource)
        resource.encode!("UTF-8", cd["encoding"])
      end
      resource.gsub!(/\r\n?/, "\n") # dos to unix EOL conversion
      resource = open_resource(resource)
      resource.rewind
      parse_file(resource, opts[:csv_parse_line_options] || {})
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

    def parse_line(line, opts = {})
      ar = line.split(/\t/)
      if ar.size == 1
        ar = CSV.parse_line(line, opts).map { |i| i == nil ? "" : i }
      else
        ar.map! { |value| clean_field(value) }
      end
      ar
    end

    def parse_file(resource, opts = {})
      resource.each_line do |line|
        next if line.strip! == ""
        fields = parse_line(line, opts)
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
        entry.send(definition[idx] + "=", field)
      end
      entry.amount = convert_amount(entry.amount) unless entry.amount.to_s == ""
      entry.date = convert_date(entry.date) if entry.date and not entry.date == ""
      @entries.push(entry)
    end

    def clean_field(field)
      field.gsub!(/\A"|"\Z/, '')
      field.strip! if field.is_a?(String)
      field
    end

    def convert_date(date)
      return Date.parse(date) if date =~ /^\d{4}-[01]\d-[0123]\d$/
      ar = date.split(/[-\/]/).map(&:to_i)
      year = ar[2].to_s.size == 4 ? ar[2] : "20#{ar[2]}"
      Date.new(year.to_i, ar[0], ar[1])
    end

    def convert_amount(amount)
      amount.gsub!(/(,)/,'')
      if amount =~ /^--/
        amount.slice!(0)
      elsif amount =~ /^\(.*\)$/
        amount.gsub!(/[()]/,'')
        amount.prepend("-")
      end
      BigDecimal(amount)
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
