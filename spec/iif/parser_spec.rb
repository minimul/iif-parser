require 'spec_helper'

describe Iif::Parser do

  it 'parses multi transaction with numeric chart of account references iif' do
    iif = File.read(File.dirname(__FILE__) + "/../fixtures/num-accounts-multi.iif")
    i = Iif::Parser.new(iif)
    trans = i.transactions.first.entries[0]
    trans2 = i.transactions[1].entries[1]
    expect(trans.accnt).to eq '13200'
    expect(trans.amount).to eq 1000.75 
    expect(trans2.accnt).to eq '40000'
    expect(trans2.amount).to eq -200.65
  end

  it 'parses multi transaction with alphanumeric chart of account references iif' do
    iif = File.read(File.dirname(__FILE__) + "/../fixtures/alpha-accounts-multi.iif")
    i = Iif::Parser.new(iif)
    trans = i.transactions[0].entries[0]
    trans2 = i.transactions[1].entries[2]
    expect(trans.accnt).to eq 'Prepaid Exp'
    expect(trans.amount).to eq 1000.75 
    expect(trans2.accnt).to eq 'Sales:Retail'
    expect(trans2.amount).to eq -300.35
  end

  it 'parses single transaction with alphanumeric chart of account references iif' do
    iif = File.read(File.dirname(__FILE__) + "/../fixtures/alpha-accounts-single.iif")
    i = Iif::Parser.new(iif)
    trans = i.transactions[0].entries[4]
    trans2 = i.transactions[0].entries[5]
    expect(i.transactions.size).to be 1
    expect(trans.accnt).to eq 'G&A:Auto'
    expect(trans.date).to eq Date.new(2014, 10, 24)
    expect(trans2.date).to eq Date.new(2014, 10, 24)
    expect(trans.amount).to eq 200.55 
  end

  it 'parses entity sub accounts' do
    iif = File.read(File.dirname(__FILE__) + "/../fixtures/sub-entities.iif")
    i = Iif::Parser.new(iif)
    trans = i.transactions[0].entries[0]
    expect(i.transactions.size).to be 2
    expect(trans.name).to eq "Customer 1000:Job 100"
  end

  it 'parses many distribution lines' do
    iif = File.read(File.dirname(__FILE__) + "/../fixtures/many-dist-lines.iif")
    i = Iif::Parser.new(iif)
    entries = i.transactions[0].entries
    expect(entries.size).to be 102
    expect(entries.first.date).to eq Date.new(2015, 5, 1)
    expect(entries.last[:class]).to eq "HRC:Ramp/Accessibility"
  end

  it 'parses a comma delimitated file' do
    iif = File.read(File.dirname(__FILE__) + "/../fixtures/comma-delim.iif")
    i = Iif::Parser.new(iif)
    expect(i.transactions.size).to eq 2
    entries = i.transactions[1].entries
    expect(entries.size).to eq 2
    expect(entries.first.name).to eq "Bridgitte, Halifax"
  end

  it 'parses a comma delimitated files with blank rows and blank header values' do
    iif = File.read(File.dirname(__FILE__) + "/../fixtures/blank-rows-and-comma-header-blanks.iif")
    i = Iif::Parser.new(iif)
    expect(i.transactions.size).to eq 2
    entries = i.transactions[0].entries
    expect(entries.size).to eq 6
    expect(entries[3][:amount]).to eq 137.63
  end

  it 'skip values that do not have corresponding header values' do
    iif = File.read(File.dirname(__FILE__) + "/../fixtures/no-matching-header-for-value.iif")
    i = Iif::Parser.new(iif)
    expect(i.transactions.size).to eq 1
    entries = i.transactions[0].entries
    expect(entries[0].amount).to eq 20000
    expect(entries[1].amount).to eq -20000
  end

  it 'parses a file with blank date rows' do
    iif = File.read(File.dirname(__FILE__) + "/../fixtures/blank-date.iif")
    i = Iif::Parser.new(iif)
    expect(i.transactions.size).to eq 1
    entries = i.transactions[0].entries
    expect(entries.size).to eq 6
    expect(entries[0].date).to_not eq ""
    expect(entries[2].date).to eq ""
  end

  it 'parses amounts with commas' do
    iif = File.read(File.dirname(__FILE__) + "/../fixtures/commas-in-amounts.iif")
    i = Iif::Parser.new(iif)
    entries = i.transactions[0].entries
    expect(entries.first.amount).to eq -5712.93
  end

  it 'memo should not have starting and ending double quotes and not process blank or nil amounts' do
    iif = File.read(File.dirname(__FILE__) + "/../fixtures/memo-quotes.iif")
    i = Iif::Parser.new(iif)
    entries = i.transactions[0].entries
    expect(entries[2].memo).to_not match /\"/
    expect(entries[3].memo).to match /\"/
    expect(entries[0].amount).to_not eq 0.0
    expect(entries[1].amount).to_not eq 0.0
  end

  it 'parse amounts that are double quoted' do
    iif = File.read(File.dirname(__FILE__) + "/../fixtures/quoted-amounts.iif")
    i = Iif::Parser.new(iif)
    entries = i.transactions[0].entries
    e = entries.first
    expect(e.amount).to eq 1776.23
  end

  it 'handles dos ^M carriage returns' do
    iif = File.read(File.dirname(__FILE__) + "/../fixtures/dos-carriage-returns.iif")
    i = Iif::Parser.new(iif)
    expect(i.transactions.size).to eq 13
    entries = i.transactions[0].entries
    expect(entries.size).to eq 2
  end

  it 'skip definitions that do not match like VTYPE' do
    iif = File.read(File.dirname(__FILE__) + "/../fixtures/vtype.iif")
    expect { i = Iif::Parser.new(iif) }.to_not raise_error
  end

  it 'parse tab deliminated file which fields are all double quoted' do
    iif = File.read(File.dirname(__FILE__) + "/../fixtures/tab-delim-all-quoted.iif")
    i = Iif::Parser.new(iif)
    entries = i.transactions[1].entries
    e = entries[1]
    expect(e.name).to eq "Peter Blue"
    expect(e.amount).to eq 2300.00
  end

  it 'parses invalid encodings' do
    iif = File.read(File.dirname(__FILE__) + "/../fixtures/windows-1252.iif")
    i = Iif::Parser.new(iif)
    entries = i.transactions[2].entries
    expect(entries[0].memo).to eq "1 Ticket for “ACME ‘School’ Beans\"\" Symposium |"
  end

  it 'parses values using a csv parser coverter option to strip leading a trailing white space' do
    iif = File.read(File.dirname(__FILE__) + "/../fixtures/comma-delim-squish.iif")
    options = { csv_parse_line_options: { converters: -> (f) { f ? f.strip : nil } } }
    i = Iif::Parser.new(iif, options)
    entries = i.transactions.first.entries
    expect(entries[0].accnt).to eq "100000"
    expect(entries[1].memo).to eq "46137 : Bill : Final Billing for 9640-2 ACME Office Bldg"
  end

  it 'parses all values quoted' do
    iif = File.read(File.dirname(__FILE__) + "/../fixtures/header-quotes.iif")
    i = Iif::Parser.new(iif)
    entries = i.transactions.first.entries
    expect(entries.size).to eq 62
    entry = entries[47]
    expect(entry.accnt).to eq "90035"
    expect(entry.memo).to match /^Payroll entry/
  end

  if RUBY_VERSION =~ /^2\.4/

    it 'parses using Ruby 2.4 liberal_parsing option' do
      iif = File.read(File.dirname(__FILE__) + "/../fixtures/liberal-parsing.iif")
      i = Iif::Parser.new(iif, { csv_parse_line_options: { liberal_parsing: true } })
      entries = i.transactions.first.entries
      expect(entries[0].memo).to match "6\" wrap around"
    end
  end
end
