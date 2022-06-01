var HDWalletProvider = require("truffle-hdwallet-provider")
var mnemonic = "Seed_words_cac_ban_da_luu_lai";

module.exports = {
    networks: {
        development: {
            host: 'localhost',
            port: 7545,
            network_id: '*' // Match any network id
        },
        ropsten: {
            provider: function() {
                return new HDWalletProvider(mnemonic, "https://ropsten.infura.io/Infura_key_nhan_trong_email")
            },
            network_id: 3,
            gas: 3000000,
            gasPrice: 21
        }
    }
}