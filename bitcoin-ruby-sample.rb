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

@walletinfo = bitcoinRPC('getwalletinfo',[])
txcount = @walletinfo["txcount"]
puts @walletinfo
puts txcount
@listtransactions = bitcoinRPC('listtransactions',["*", txcount])
txids = []
for i in 0..txcount-1 do
    txid = @listtransactions[i]["txid"]
    if ((txid !=  @listtransactions[i-1]["txid"]) && txid != nil) 
        @txids = txids.push(txid)
    end
end

puts @txids
