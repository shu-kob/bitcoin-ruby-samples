require 'bitcoin'
require 'net/http'
require 'json'
Bitcoin.network = :testnet3
RPCUSER = "username"
RPCPASSWORD = "password"
HOST="localhost"
PORT=18332

def bitcoinRPC(method,param)
    http = Net::HTTP.new(HOST, PORT)
    request = Net::HTTP::Post.new('/')
    request.basic_auth(RPCUSER,RPCPASSWORD)
    request.content_type = 'application/json'
    request.body = {method: method, params: param, id: 'jsonrpc'}.to_json
    JSON.parse(http.request(request).body)["result"]
end

bitcoinRPC('getinfo',[])
bitcoinRPC('getnewaddress',["Satoshi-Nakamoto"])
bitcoinRPC('getaddressesbyaccount',["Satoshi-Nakamoto"])