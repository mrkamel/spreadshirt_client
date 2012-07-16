
# SpreadshirtClient

Use this gem to communicate with the spreadshirt API.
http://developer.spreadshirt.net

## Setup

First, you need to setup your API credentials:

<pre>
SpreadshirtClient.api_key = "..."
SpreadshirtClient.api_secret = "..."
SpreadshirtClient.base_url = "http://api.spreadshirt.net/api/v1" # optional
SpreadshirtClient.timeout = 5 # optional (default: 30)
</pre>

## Usage

The DSL to interact with the spreadshirt API is similar
to RestClient's DSL.

<pre>
# Add an article to a previously created spreadshirt basket.
SpreadshirtClient.post "/baskets/[basket_id]/items", "<basketItem>...</basketItem>", :authorization => true

# To make a request that requires a valid spreadshirt session.
SpreadshirtClient.post "/orders", "<order>...</order>", :authorization => true, :session => "..."

# Update a line item.
SpreadshirtClient.put "/basklets/[basket_id]/items/[item_id]", "<basketItem>...</basketItem>", :authorization => true

# Retrieve the checkout url for a spreadshirt basket.
SpreadshirtClient.get "/baskets/[basket_id]/checkout", :authorization => true

# Retrieve a spreadshirt shop's articles.
SpreadshirtClient.get "/shops/[shop_id]/articles", :params => { :limit => 50 }

...
</pre>

Please take a look into the spreadshirt API docs for more details.

