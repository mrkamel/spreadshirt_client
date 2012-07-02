
# SpreadshirtClient

Use this gem to communicate with the spreadshirt API.
http://developer.spreadshirt.net

## Setup

First, you need to setup your API credentials:

<pre>
SpreadshirtClient.api_key = "..."
SpreadshirtClient.api_secret = "..."
SpreadshirtClient.base_url = "http://api.spreadshirt.net/api/v1"
</pre>

## Usage

The DSL to interact with the spreadshirt API is similar
to RestClient's DSL.

<pre>
# Add an article to a previously created spreadshirt basket
SpreadshirtClient.post "/baskets/.../items", "<basketItem>...</basketItem>", :authorization => true

# Retrieve the checkout url for a spreadshirt basket
SpreadshirtClient.get "/baskets/.../checkout", :authorization => true

...
</pre>

Please take a look into the spreadshirt API docs for more details.

