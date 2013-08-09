# SpreadshirtClient

Use this gem to communicate with the spreadshirt API.
http://developer.spreadshirt.net

## Installation

Add this line to your application's Gemfile:

```
gem 'spreadshirt_client'
```

And then execute:

```
$ bundle
```

Alternatively, you can of course install it without bundler via:

```
$ gem install spreadshirt_client
```

## Setup

First, you need to setup your API credentials:

```ruby
SpreadshirtClient.api_key = "..."
SpreadshirtClient.api_secret = "..."
SpreadshirtClient.base_url = "http://api.spreadshirt.net/api/v1" # optional
SpreadshirtClient.timeout = 5 # optional (default: 30)
```

## Usage

The DSL to interact with the spreadshirt API is similar
to RestClient's DSL.

```ruby
# Add an article to a previously created spreadshirt basket.
SpreadshirtClient.post "/baskets/[basket_id]/items", "<basketItem>...</basketItem>", :authorization => true

# To make a request that requires a valid spreadshirt session.
SpreadshirtClient.post "/orders", "<order>...</order>", :authorization => true, :session => "..."

# Update a line item.
SpreadshirtClient.put "/baskets/[basket_id]/items/[item_id]", "<basketItem>...</basketItem>", :authorization => true

# Retrieve the checkout url for a spreadshirt basket.
SpreadshirtClient.get "/baskets/[basket_id]/checkout", :authorization => true

# Retrieve a spreadshirt shop's articles.
SpreadshirtClient.get "/shops/[shop_id]/articles", :params => { :limit => 50 }

...
```

## Examples

### Creating a basket on spreadshirt

(This example is made for Rails 3.x+ applications)

Create your own basket model:

```bash
$ rails g model Basket spreadshirt_id:string:uniq
```

Run the migration

```
$ rake db:migrate
```

Modify your model:

```ruby
# An example of a basket model

class Basket < ActiveRecord::Base
  before_create :create_spreadshirt_basket

  # Find our stored basket by using the id previously provided by spreadshirt
  def self.find_by_spreadshirt_id(spreadshirt_id)
    basket = where(:spreadshirt_id => spreadshirt_id).first

    return nil unless basket

    begin
      SpreadshirtClient.get "/baskets/#{spreadshirt_id}", :authorization => true
    rescue RestClient::ResourceNotFound
      return nil
    end

    basket
  end

  private

  # Create a spreadshirt basket with minimal payload
  def create_spreadshirt_basket
    xml = Builder::XmlMarkup.new
    xml.instruct!

    xml.basket :xmlns => "http://api.spreadshirt.net" do |basket|
      basket.shop :id => $app_config.shop_id # Your shop id
    end

    self.spreadshirt_id = SpreadshirtClient.post("/baskets", xml.target!, :authorization => true).headers[:location].split("/").last
  end
end
```

Then, in your application, simply retrieve/create your customer's basket:

```ruby
def current_basket
  return @current_basket if @current_basket

  # Use spreadshirt's basket id stored in a cookie to retrieve the basket
  @current_basket = Basket.find_by_spreadshirt_id(cookies[:spreadshirt_basket_id])
  @current_basket ||= Basket.create! # Create the basket as it doesn't exist yet

  cookies[:spreadshirt_basket_id] = @current_basket.spreadshirt_id

  @current_basket
end
```

## Resources

Spreadshirt API Docs:
- [Spreadshirt API Documentation](http://developer.spreadshirt.net/display/API/API)
- [Spreadshirt API Documentation - Basket resource](http://developer.spreadshirt.net/display/API/Basket+Resources)
- [Spreadshirt API Browser - DemoApp](http://demoapp.spreadshirt.net/apibrowser/)

SpreadshirtClient uses the RestClient gem to send requests to the Spreadshirt API:
- Take a look into the [RestClient gem documentation](https://github.com/rest-client/rest-client) to see how to handle the Spreadshirt API responses.

Builder Docs:
- [Github](https://github.com/jimweirich/builder)
- [RDOCS](http://builder.rubyforge.org/)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

