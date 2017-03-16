# Sugarcrb

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/sugarcrb`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sugarcrb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sugarcrb

## Usage

Login

```ruby
sugarcrb = Sugarcrb.new(<host>,<username>,<password>,<platform>,<client id>,<client secret>)

sugarcrb = Sugarcrb.new("https://instance.sugarondemand.com","admin","xxxxxx","test","sugar","")
```

Call endpoint

```ruby
response = sugarcrb.call "<method>", "<url endpoint>", <data>
```

Create a bean

```ruby
response = sugarcrb.call "post", "<module>", <data>
response = sugarcrb.call "post", "Accounts", {
    "name" => "My Account"
}
account_data = JSON.load(response)
```

List beans

```ruby
response = sugarcrb.call "get", "<module>"

response = sugarcrb.call "get", "Accounts"
accounts_data = JSON.load(response)
accounts_data['records']
```

Get a bean

```ruby
response = sugarcrb.call "get", "<module>/<id>"

response = sugarcrb.call "get", "Accounts/dffe626e-08d2-11e7-9113-06b20b8677ed"
account_data = JSON.load(response)
```

Update a bean

```ruby
response = sugarcrb.call "put", "<module>/<id>", <data>

response = sugarcrb.call "put", "Accounts/dffe626e-08d2-11e7-9113-06b20b8677ed", {
    "name" => "My Favorite Account"
}
account_data = JSON.load(response)
```

Delete a bean

```ruby
response = sugarcrb.call "delete", "<module>/<id>"

response = sugarcrb.call "delete", "Accounts/dffe626e-08d2-11e7-9113-06b20b8677ed"
if response.code == 200 then
    puts "deleted"
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sugarcrb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

