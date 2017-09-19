require 'bitcoin'
require 'openassets'
require 'net/http'
require 'json'
Bitcoin.network = :testnet3
RPCUSER = "<user>"
RPCPASSWORD = "<pass>"
HOST="localhost"
PORT=18332

class BitcoinController < ApplicationController


    def index
      logger.debug  openassetsRPC()
      render plain: openassetsRPC()
    end

    def view
#        puts "Enter Bitcoin Address"
#        target_address = gets.chop
#        puts target_address
        target_address = "<address>"
        
        listreceivedbyaddress = bitcoinRPC('listreceivedbyaddress',[])
        address_count = listreceivedbyaddress.length
        
        txids = []
        target_txids = []
        addresses_txid = []
        for i in 0..address_count-1 do
            address = listreceivedbyaddress[i]["address"]
            if address == target_address
                target_txids = listreceivedbyaddress[i]["txids"]
            end
        end

        txcount = target_txids.length

        for u in 0..txcount-1 do
            if (u == 0 || target_txids[u] != target_txids[u-1])
                @txids = txids.push(target_txids[u])
            end
        end
 
        for j in 0..@txids.length-1 do
            vin_flg = 0
            vout_flg = 0

            logger.debug @txids[j] 
            if rawtransaction = bitcoinRPC('getrawtransaction',[@txids[j]])
                @decodedtransaction = bitcoinRPC('decoderawtransaction',[rawtransaction])
                vin_number = @decodedtransaction["vin"].length
                for k in 0..vin_number-1 do
                    vin_txid = @decodedtransaction["vin"][k]["txid"]
                    vin_tx_vout = @decodedtransaction["vin"][k]["vout"]
                    vin_rawtransaction = bitcoinRPC('getrawtransaction',[vin_txid])
                    @vin_decodedtransaction = bitcoinRPC('decoderawtransaction',[vin_rawtransaction])
                    vin_address = @vin_decodedtransaction["vout"][vin_tx_vout]["scriptPubKey"]["addresses"][0]
                    if (vin_address == target_address)
                        vin_flg += 1
                    end  
                end
        
                vout_number =  @decodedtransaction["vout"].length
                for l in 0..vout_number-1 do
                    if (@decodedtransaction["vout"][l]["scriptPubKey"]["type"] != "nulldata")
                        vout_address = @decodedtransaction["vout"][l]["scriptPubKey"]["addresses"][0]
                        if (vout_address == target_address)
                            vout_flg += 1
                        end
                    end
                end
                if (vin_flg >= 1 || vout_flg >= 1)
#               puts vin_flg
#               puts vout_flg
                
                @addresses_txid = addresses_txid.push(@txids[j])
                end
            end
        end

        @msg = @addresses_txid

    end
    
    private
      def bitcoinRPC(method,param)
          http = Net::HTTP.new(HOST, PORT)
          request = Net::HTTP::Post.new('/')
          request.basic_auth(RPCUSER,RPCPASSWORD)
          request.content_type = 'application/json'
          request.body = {method: method, params: param, id: 'jsonrpc'}.to_json
          JSON.parse(http.request(request).body)["result"]
      end

      def openassetsRPC()
        api = OpenAssets::Api.new({
            network:           'testnet',
            rpc: {
                user:              '<user>',
                password:          '<pass>',
                schema:            'http',
                port:               18332,
                host:              'localhost'}
        }) 
        utxo_list = api.list_unspent
        JSON.pretty_generate(utxo_list)
      end
end
