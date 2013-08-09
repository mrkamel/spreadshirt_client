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
$ rails generate Basket user_id:integer spreadshirt_id:string
```

In your migration, don't forget the indexes:

```ruby
class CreateBaskets < ActiveRecord::Migration
  def change
    create_table :baskets do |t|
      t.string :spreadshirt_id
      t.references :user
      t.timestamps
    end
    
    add_index :baskets, :spreadshirt_id, :unique => true
    add_index :baskets, :user_id
  end
end

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
  
  # Find our stored basket by using the uuid of the spreadshirt's basket
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
    # Create spreadshirt basket with minimal payload.
    def create_spreadshirt_basket
      # Prefer to use your own XML generator library
      payload =<<EOF
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <basket xmlns="http://api.spreadshirt.net">
          <shop id="#{$app_config.shop_id}" /> # Your shop id
        </basket>
EOF
      
      begin
        self.spreadshirt_id = SpreadshirtClient.post("/baskets", payload, :authorization => true).headers[:location].split("/").last
      rescue => e
        errors.add(:spreadshirt_id, "hasn't be generated, error code: #{e.response}")
        return false
      end
    end
end
```

Then, in your application, simply retrieves/creates your customer's basket: 

```ruby
def current_basket
  return @current_basket if @current_basket
  
  # Use the spreadshirt's basket uuid as a cookie to retrieve the basket
  @current_basket = Basket.find_by_spreadshirt_id(cookies[:spreadshirt_basket_id])
  @current_basket ||= Basket.create! # Create the basket if it does not exist

  cookies[:spreadshirt_basket_id] = @current_basket.spreadshirt_id

  @current_basket
end
```


## Documentations
Spreadshirt Documentations: 
- [Spreadshirt API Documentations](http://developer.spreadshirt.net/display/API/API)
- [Spreadshirt API Documentations - Basket resources](http://developer.spreadshirt.net/display/API/Basket+Resources)
- [Spreadshirt API Browser - DemoApp](http://demoapp.spreadshirt.net/apibrowser/)

SpreadshirtClient uses the RestClient gem to send requests to the SpreadshirtAPI. 
- Look at the [RestClient gem documentations](https://github.com/rest-client/rest-client) to see how to handle the Spreadshirt API responses.

As hardcoding XML isn't a good practice, we advice you to use existing Ruby libraries: 
- REXML
  - [REXML tutorial](http://www.germane-software.com/software/rexml/docs/tutorial.html)
  - [REXML RubyDocs](http://ruby-doc.org/stdlib-2.0/libdoc/rexml/rdoc/REXML.html)
- Builder:
  - [Github](https://github.com/jimweirich/builder)
  - [RDOCS](http://builder.rubyforge.org/)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

