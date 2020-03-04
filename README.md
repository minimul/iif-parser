# Iif::Parser

The Iif::Parser gem will take Intuit QuickBooks files that are in IIF format and parse out the transactions (`!TRNS` and `!ENDTRNS` blocks) sections into plain Ruby objects.
#### For example, take this IIF formatted file ..
```
!TRNS	TRNSID	TRNSTYPE	DATE	ACCNT	NAME	CLASS	AMOUNT	DOCNUM	MEMO
!SPL	SPLID	TRNSTYPE	DATE	ACCNT	NAME	CLASS	AMOUNT	DOCNUM	MEMO
!ENDTRNS							TEXT		TEXT
TRNS		GENERAL JOURNAL	10/24/14	Prepaid Exp		Midwest:Kansas:Wichita	1000.75		Bank Drafts - 10/24/14 - Midwest:Kansas:Wichita
SPL		GENERAL JOURNAL	10/24/14	ABC Bank		Midwest:Kansas:Wichita	-1000.75		Bank Drafts - 10/24/14 - Midwest:Kansas:Wichita
ENDTRNS							END		TEXT
```
#### .. and then pump it into a new instance of Iif::Parser
```ruby
i = Iif::Parser.new(iif)
p i.transactions.size
# => 1
p i.transactions.first.entries.size
# => 2
```
#### .. and it will be converted into nice Ruby objects!
```ruby
puts i.transactions.first.entries
#<Iif::Entry type="TRNS", 
  trnsid="", 
  trnstype="GENERAL JOURNAL", 
  date=#<Date: 2014-10-24 ((2456955j,0s,0n),+0s,2299161j)>, 
  accnt="Prepaid Exp", 
  name="", 
  class="Midwest:Kansas:Wichita", 
  amount=#<BigDecimal:7fccd1043b20,'0.100075E4',18(18)>, 
  docnum="", 
  memo="Bank Drafts - 10/24/14 - Midwest:Kansas:Wichita">
#<Iif::Entry type="SPL", 
  splid="", 
  trnstype="GENERAL JOURNAL", 
  date=#<Date: 2014-10-24 ((2456955j,0s,0n),+0s,2299161j)>, 
  accnt="ABC Bank", 
  name="", 
  class="Midwest:Kansas:Wichita", 
  amount=#<BigDecimal:7fccd0a09a48,'-0.100075E4',18(18)>, 
  docnum="", 
  memo="Bank Drafts - 10/24/14 - Midwest:Kansas:Wichita">
```
#### See the [specs](https://github.com/minimul/iif-parser/blob/master/spec/iif/parser_spec.rb) for more examples

#### Ruby support is >= 2.4

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'iif-parser'
```

### CSV parse line options

Non tab-delimited IIF files are parsed with `CSV.parse_line`. You can set options for `CSV.parse_line` like this:
```ruby
iif_file = File.read(File.dirname(__FILE__) + "/../fixtures/liberal-parsing.iif")
iif_parser = Iif::Parser.new(iif_file, { csv_parse_line_options: { liberal_parsing: true } })
```
**OR**

```ruby
options = { csv_parse_line_options: { converters: -> (f) { f ? f.strip : nil } } }
i = Iif::Parser.new(iif, options)
```
**OR COMBINE OPTIONS**

```ruby
options = { csv_parse_line_options: { liberal_parsing: true, converters: -> (f) { f ? f.strip : nil } } }
i = Iif::Parser.new(iif, options)
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install iif-parser

## Contributing

1. Fork it ( https://github.com/[my-github-username]/iif-parser/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
