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

        for k in 0..transactions.length-1 do  # mwU3UJ1VXX3GxKKQHdscw1TvWSrMKdtymR
            if transactions[k]
                for l in 0..transactions[k]["vout"].length-1 do
                     if transactions[k]["vout"][l]["scriptPubKey"]["addresses"]
                        for m in 0..transactions[k]["vout"][l]["scriptPubKey"]["addresses"].length-1 do
                            if transactions[k]["vout"][l]["scriptPubKey"]["addresses"][m] == target_address
                                 for n in 0..transactions[k]["vin"].length-1 do
                                     vin_rawtx = bitcoinRPC('getrawtransaction',[transactions[k]["vin"][n]["txid"]])
                                     vin_tx = bitcoinRPC('decoderawtransaction',[vin_rawtx])
                                     num = transactions[k]["vin"][n]["vout"]
                                     addresses = vin_tx["vout"][num]["scriptPubKey"]["addresses"]
                                     txrecords.push([transactions[k]["txid"],l, num, addresses, target_address])
                                 end
                            end
                        end
                    end
                end
            end
        end

        @msg = txrecords

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
