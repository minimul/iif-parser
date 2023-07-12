$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'awesome_print'
require 'tabulo'
require_relative '../lib/iif/parser'

def find_all_transactions_by_amount(transactions, amount_in_string)
  transactions.flat_map { |tran| tran.entries.select { |entry| format("%.2f", entry.amount.truncate(2).to_s('F')) == amount_in_string } }
end
