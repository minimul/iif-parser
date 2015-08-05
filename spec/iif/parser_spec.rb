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
end
