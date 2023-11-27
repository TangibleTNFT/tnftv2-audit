const ethAbi = require('ethereumjs-abi')
const ethUtil = require('ethereumjs-util')

const SIGNING_DOMAIN = "TNFT-Voucher";
const SIGNATURE_VERSION = "1";
const DOMAIN_TYPE = [
    {type: 'string', name: 'name'},
    {type: 'string', name: 'version'},
    {type: 'uint256', name: 'chainId'},
    {type: 'address', name: 'verifyingContract'},
];

const _signingDomain = async (contract) => {
    const chainId = (await contract._chainId()).valueOf().toString()
    return {
        name: SIGNING_DOMAIN,
        version: SIGNATURE_VERSION,
        verifyingContract: contract.address,
        chainId,
    }
}

const signTypedData = (message, signer) => {
    return new Promise(async (resolve, reject) => {
        function cb(err, result) {
            if (err) {
                return reject(err);
            }
            if (result.error) {
                return reject(result.error);
            }

            const sig = result.result;
            const sig0 = sig.substring(2);
            const r = '0x' + sig0.substring(0, 64);
            const s = '0x' + sig0.substring(64, 128);
            const v = parseInt(sig0.substring(128, 130), 16);

            resolve({
                message,
                sig,
                v,
                r,
                s,
            });
        }

        let send = web3.currentProvider.sendAsync;
        if (!send) send = web3.currentProvider.send;
        send.bind(web3.currentProvider)(
            {
                jsonrpc: '2.0',
                method: 'eth_signTypedData',
                params: [signer, message],
                from: signer,
                id: new Date().getTime(),
            },
            cb
        );
    });
};

module.exports = {
    createMintVoucher: async (contract, signer, token, tokenId, price, storageYears, mintingFee,
                              amount, mintCount, vendor, brand) => {
        const voucher = {
            token, tokenId, price, storageYears, mintingFee,
            amount, mintCount, vendor, brand,
        }
        const domain = await _signingDomain(contract)
        const mintVoucher = [
            {name: "token", type: "address"},
            {name: "tokenId", type: "uint256"},
            {name: "price", type: "uint256"},
            {name: "storageYears", type: "uint256"},
            {name: "mintingFee", type: "uint256"},
            {name: "amount", type: "uint256"},
            {name: "mintCount", type: "uint256"},
            {name: "vendor", type: "address"},
            {name: "brand", type: "string"},
        ];

        const signature = await signTypedData({
            domain, types: {
                EIP712Domain: DOMAIN_TYPE,
                MintVoucher: mintVoucher
            }, message: voucher, primaryType: 'MintVoucher'
        }, signer)

        return {
            ...voucher,
            signature: signature.sig,
        }
    },
    createBurnVoucher: async (contract, signer, token, tokenId, amount, from) => {
        const voucher = {token, tokenId, amount, from}
        const domain = await _signingDomain(contract)
        const burnVoucher = [
            {name: "token", type: "address"},
            {name: "tokenId", type: "uint256"},
            {name: "amount", type: "uint256"},
            {name: "from", type: "address"},
        ];

        const signature = await signTypedData({
            domain, types: {
                EIP712Domain: DOMAIN_TYPE,
                BurnVoucher: burnVoucher
            }, message: voucher, primaryType: 'BurnVoucher'
        }, signer)

        return {
            ...voucher,
            signature: signature.sig,
        }
    }

}