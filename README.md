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

## To create a basket on spreadshirt

Create your own basket Model:

```bash
$ rails generate Basket user_id:integer token:string spreadshirt_id:string shop_id:integer
$ rake db:migrate
```

```ruby
# An example of a basket model
class Basket < ActiveRecord::Base
  before_create :generate_token
  
  # has_many :basket_items, :dependent => :destroy
  
  private
    def generate_token
      # Generate a uniq token that may be used instead of the spreadshirt_basket_id to retrieve a basket
      # The generated token must have 40 characters according to the spreadshirt API documentation.
      begin
        self.token = SecureRandom.hex(20)
      end while self.class.exists?(token: token)
    end
end
```

In your controller, generate the xml for the basket from your own Basket Model, using REXML (for instance): 

```ruby
basket     = Basket.find(params[:basket_id])
# Or using the token as a stored cookie: 
#     basket = Basket.find_by_token(cookies[:basket_token]) if cookies[:basket_token]

basket_xml = REXML::Document.new('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')

basket_tag = basket_xml.add_element("basket")
basket_tag.attributes["xmlns:xlink"] = "http://www.w3.org/1999/xlink"
basket_tag.attributes["xmlns"]       = "http://api.spreadshirt.net"

if basket.spreadshirt_id.blank?
  basket_tag.add_element("token").text = basket.token 
else
  basket_tag.attributes["id"] = basket.spreadshirt_id.to_s
  basket_tag.attributes["xlink:href"] = "#{SpreadshirtClient.base_url}/baskets/#{basket.spreadshirt_id}"
end

basket_tag.add_element("shop", 
    {"id" => basket.shop_id, "xlink:href" => "#{SpreadshirtClient.base_url}/shops/#{basket.shop_id}"})

```

Then, post the basket to the Spreadshirt API: 

```ruby
spreadshirt_response = SpreadshirtClient.post("/baskets", basket_xml.to_s, :authorization => true)
```

And finally, store the spreadshirt_id of the basket from the spreadshirt API response: 

```ruby
basket_id = spreadshirt_response.headers[:location].split("/").last
basket.update_attribute(:spreadshirt_id, basket_id)
```

You can then add basket items, update the basket... 

## Documentations
Spreadshirt Documentations: 
- [Spreadshirt API Documentations](http://developer.spreadshirt.net/display/API/API)
- [Spreadshirt API Documentations - Basket resources](http://developer.spreadshirt.net/display/API/Basket+Resources)
- [Spreadshirt API Browser - DemoApp](http://demoapp.spreadshirt.net/apibrowser/)

SpreadshirtClient uses the RestClient gem to send requests to the SpreadshirtAPI. 
- Look at the [RestClient gem documentations](https://github.com/rest-client/rest-client) to see how to handle the Spreadshirt API responses.

Using REXML: 
- [REXML tutorial](http://www.germane-software.com/software/rexml/docs/tutorial.html)
- [REXML RubyDocs](http://ruby-doc.org/stdlib-2.0/libdoc/rexml/rdoc/REXML.html)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

