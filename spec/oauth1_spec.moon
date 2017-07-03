oauth1 = require "moonship.oauth1"

describe "moonship.oauth1", ->

  it "correctly generate signature", ->
    expected = 'OAuth oauth_signature="3k0RTj7lPkKG0AEM3KWM1N%2buYSo%3d",oauth_nonce="8ccc8816600bbdfa706f80c087d59fe2",oauth_version="1%2e0",oauth_consumer_key="consumerkey",oauth_timestamp="1499097288",oauth_signature_method="HMAC%2dSHA1"'
    opts = {
        url: 'https://example.com/hello?world'
    }
    oauth = {
        consumerkey: 'consumerkey',
        oauth_token: 'oauth_token',
        consumersecret: 'consumersecret',
        tokensecret: 'tokensecret',
        timestamp: 1499097288
    }
    actual = oauth1.create_signature opts, oauth

    assert.same expected, actual
