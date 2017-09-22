class BitcoinController < ApplicationController


    def index
      logger.debug  openassetsRPC()
      render plain: openassetsRPC()
    end

    def view
#        puts "Enter Bitcoin Address" # mpWmiduo6Li1Wx6dY2EwVacqHVw4PbNszN
#        target_address = gets.chop
#        puts target_address
        target_address = "mpWmiduo6Li1Wx6dY2EwVacqHVw4PbNszN"
        
        listtransactions = bitcoinRPC('listtransactions',["*", 99999])

        txids = []

        for i in 0..listtransactions.length-1 do
            if listtransactions[i]["txid"]
                txids.push(listtransactions[i]["txid"])
                txids = txids.uniq
            end 
        end

        transactions = []

        for j in 0..txids.length-1 do
            rawtransaction = bitcoinRPC('getrawtransaction', [txids[j]])
            transaction = bitcoinRPC('decoderawtransaction', [rawtransaction])
            transactions.push(transaction)
        end

        txrecords = []
        for k in 0..transactions.length-1 do
            for l in 0 .. transactions[k]["vin"].length - 1 do
                vin_rawtx = bitcoinRPC('getrawtransaction',[transactions[k]["vin"][l]["txid"]])
                vin_tx = bitcoinRPC('decoderawtransaction',[vin_rawtx])
                num = transactions[k]["vin"][l]["vout"]
                addresses = vin_tx["vout"][num]["scriptPubKey"]["addresses"]
                for m in 0 .. addresses.length - 1 do
                    if addresses[m] == target_address
                        for n in 0 .. transactions[k]["vout"].length - 1 do
                            sent_addresses = transactions[k]["vout"][n]["scriptPubKey"]["addresses"]
                            if sent_addresses
                                txrecords.push([transactions[k]["txid"],"send"])
                            end
                        end
                    else
                        for x in 0..transactions[k]["vout"].length-1 do
                            if transactions[k]["vout"][x]["scriptPubKey"]["addresses"]
                                for y in 0 .. transactions[k]["vout"][x]["scriptPubKey"]["addresses"].length - 1 do
                                    if transactions[k]["vout"][x]["scriptPubKey"]["addresses"][y] == target_address
                                        for z in 0..transactions[k]["vin"].length-1 do
                                            vin_rawtx = bitcoinRPC('getrawtransaction',[transactions[k]["vin"][z]["txid"]])
                                            vin_tx = bitcoinRPC('decoderawtransaction',[vin_rawtx])
                                            num = transactions[k]["vin"][z]["vout"]
                                            addresses = vin_tx["vout"][num]["scriptPubKey"]["addresses"]
                                            txrecords.push([transactions[k]["txid"],"receive"])
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        for a in 0 .. txrecords.length - 1 do
            raw_tx = bitcoinRPC('getrawtransaction',[txrecords[a][0]])
            decoded_tx = bitcoinRPC('decoderawtransaction',[raw_tx])
            
            logger.debug txrecords[a]
            logger.debug decoded_tx

            for b in 0 .. decoded_tx["vin"].length - 1 do
                vin_txid = decoded_tx["vin"][b]["txid"]
                vin_tx_vout = decoded_tx["vin"][b]["vout"]
                vin_rawtx = bitcoinRPC('getrawtransaction',[vin_txid])
                vin_decodedtx = bitcoinRPC('decoderawtransaction',[vin_rawtx])
                vin_address = vin_decodedtx["vout"][vin_tx_vout]["scriptPubKey"]["addresses"][0]
                vin_value = vin_decodedtx["vout"][vin_tx_vout]["value"]
                txrecords[a].push(vin_address, vin_value)
            end
            txrecords[a].push("->")
            for c in 0 .. decoded_tx["vout"].length - 1 do
                if decoded_tx["vout"][c]["scriptPubKey"]["addresses"]
                    vout_address = decoded_tx["vout"][c]["scriptPubKey"]["addresses"][0]
                    vout_value = decoded_tx["vout"][c]["value"]
                    txrecords[a].push(vout_address, vout_value)
                end
            end
        end
        
        @msg = txrecords.uniq
        
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

end
