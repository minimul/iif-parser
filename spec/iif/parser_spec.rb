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
    expect(i.transactions.size).to be 1
    expect(trans.accnt).to eq 'G&A:Auto'
    expect(trans.amount).to eq 200.55 
  end
end
