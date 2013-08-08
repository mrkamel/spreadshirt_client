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
(This example is made for a Rails 3.X application)

Create your own basket Model:

```bash
$ rails generate Basket user_id:integer token:string spreadshirt_id:string shop_id:integer
$ rake db:migrate
```

```ruby
# An example of a basket model

require 'rexml/document'
require 'rexml/element'

class Basket < ActiveRecord::Base
  before_create :generate_token
  
  # Don't forget basket_items when they'll be created:
  # has_many :basket_items, :dependent => :destroy
  
  # Get the spreadshirt basket XML or create it if it does not exist yet.
  def find_or_create_spreadshirt_basket
    # If the spreadshirt id is not defined, create the spreadshirt Basket using the API
    if self.spreadshirt_id.blank?
      # Warning: the spreadshirt response does not include the xml of the created basket,
      # it only has some headers.
      spreadshirt_response = SpreadshirtClient.post("/baskets", generate_payload_xml, :authorization => true)
      spreadshirt_basket_id = spreadshirt_response.headers[:location].split("/").last
      self.update_attribute(:spreadshirt_id, spreadshirt_basket_id)
    else
      # Get the basket XML from the Spreadshirt API:
      SpreadshirtClient.get "/baskets/#{self.spreadshirt_id}", :authorization => true
    end
  end
  
  # Generate the minimal payload expected by the spreadshirt API to create a basket
  def generate_payload_xml
    basket_xml = REXML::Document.new('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
    basket_tag = basket_xml.add_element("basket")
    basket_tag.attributes["xmlns:xlink"] = "http://www.w3.org/1999/xlink"
    basket_tag.attributes["xmlns"]       = "http://api.spreadshirt.net"
    
    # Optionals, but may be useful: 
    basket_tag.add_element("token").text = self.token
    basket_tag.add_element("shop", 
        {"id" => self.shop_id, "xlink:href" => "#{SpreadshirtClient.base_url}/shops/#{self.shop_id}"})
        
    return basket_xml.to_s
  end
  
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

Then, in your application, simply retrieves/creates your customer's basket and then do some fancy stuff: 

```ruby
def current_basket
  return @current_basket unless @current_basket.blank?
  if cookies[:basket_token]
    @current_basket = Basket.find_by_token(cookies[:basket_token].to_s)
  else
    new_basket = current_user.baskets.new
    new_basket.shop_id = 1234 # Your SHOP_ID
    if new_basket.save
      cookies[:basket_token] = new_basket.token
      # Call this function to set the spreadshirt id attribute of the basket
      # This attribute will be needed if you want to add basket items.
      new_basket.find_or_create_spreadshirt_basket()
      @current_basket = new_basket
    end
  end
end
```


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

