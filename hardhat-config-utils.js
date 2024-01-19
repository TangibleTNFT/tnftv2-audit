require('dotenv').config()


const networkConfig = {
    default: {
        name: 'hardhat',
        usdcAddress: '',
        chainLinkGoldOracle: '',
        chainLinkGBPOracle: '',
        wrappedMatic: "0x0000000000000000000000000000000000000001",
        tokenUrl:"https://onu50475eh.execute-api.us-east-1.amazonaws.com/tnfts",
        fetchExternal: "https://onu50475eh.execute-api.us-east-1.amazonaws.com",
        routerAddress: '0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506',
        tangibleLabs: '0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506',
        tngblAddress:"0xB675259cAF6F5122a9E82493610e6487373D7E98",
        daiAddress:"0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063",
        passiveNftAddress:"0x850c158FF905dE7d2B5166DB08620A0f0fF86816",
        revenueShare:"0xFD5bF91894276E1237c3365DcB7057B2b5732f76",
        rentShare:"0xFD5bF91894276E1237c3365DcB7057B2b5732f76",
        revenueShareAbi: "./abis/mumbai/RevenueShare.json",
        uniswapFactory: "",
        instantTradeEnabled: false,
        feeDistributor: '',
        chainlinkMatrixOracle: "",
        
    },
    31337: {
        name: 'localhost',
        usdcAddress: '',
        chainLinkGoldOracle: '',
        chainLinkGBPOracle: '',
        wrappedMatic: "0x0000000000000000000000000000000000000001",
        tokenUrl:"https://onu50475eh.execute-api.us-east-1.amazonaws.com/tnfts",
        fetchExternal: "https://onu50475eh.execute-api.us-east-1.amazonaws.com",
        routerAddress: '0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506',
        tangibleLabs: '0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506',
        tngblAddress:"0xB675259cAF6F5122a9E82493610e6487373D7E98",
        passiveNftAddress:"0x19C0d076B7a5860C041316fA9750D559bD7eD496",
        passiveNftAbi: "../abis/mumbai/PassiveNFT.json",
        revenueShare:"0x7069Bd636C8Bdb18d78A9dCB9A68593137477772",
        rentShare:"0x539Ca1307fb13d4dDf1b6Fd0f0F23c2b1EB85a34",
        revenueShareAbi: "./abis/mumbai/RevenueShare.json",
        uniswapFactory: "0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac",
        instantTradeEnabled: false,
        feeDistributor: '',
        chainlinkMatrixOracle: "",
    },
    18231: {
        name: 'unreal',
        usdcAddress: '0xabAa4C39cf3dF55480292BBDd471E88de8Cc3C97',
        usdtAddress: '',
        usdrAddress: '',
        ustbAddress: '',
        pearlFactory: "0x6254c71Eae8476BE8fd0B9F14AEB61d578422991",
        tangibleDao:"0xb99468CF65F43A2656280A749A3F092dF54AA58d", //rt deployer
        tangibleLabs:"0x23bfB039Fe7fE0764b830960a9d31697D154F2E4", //goerli test
        tokenUrl:"https://onu50475eh.execute-api.us-east-1.amazonaws.com/tnfts",
        fetchExternal: "https://onu50475eh.execute-api.us-east-1.amazonaws.com",
        tngblAddress:"0x86254FfaA70910447578E4aC37d51624409aeae3",
        daiAddress:"0x665D4921fe931C0eA1390Ca4e0C422ba34d26169",
        passiveNftAddress:"0x131995372479B06532ae2eba3794345CE6EcC2D1",
        revenueShare:"0x177753854F244e08E69Ec199b313c3Ad85652E1c",
        feeDistributor: "0xF8A1aD46057c546D2161198049367E4EDCEA6912" //revenue distributor
    },
    80001: {
        name: 'mumbai',
        usdcAddress: '0x667269618f67f543d3121DE3DF169747950Deb13',
        usdtAddress: '0x98D75A58F5bf3Cac470b6CC886d4F9932dCB5328',
        usdrAddress: '0x8885a6E2f1F4BC383963eD848438A8bEC243886F',
        ustbAddress: '0x71395cC9211dc43220EBe3Bb0466d482D6ef5335',
        pearlRouter: "0xE592427A0AEce92De3Edee1F18E0157C05861564",
        pearlFactory: "0xB4cF5a388778046aAc5fB33AC0e99107a2403Ed7",
        chainLinkGoldOracle: '',
        chainLinkGBPOracle: '',
        wrappedMatic: "0x9c3c9283d3e44854697cd22d3faa240cfb032889",
        tangibleDao:"0xb99468CF65F43A2656280A749A3F092dF54AA58d", //rt deployer
        tangibleLabs:"0x23bfB039Fe7fE0764b830960a9d31697D154F2E4", //goerli test
        //sellFeeAddress: "0x0Ec2cf1bEa8ef02eecA91edD948AAe78ffFd75e8",
        tokenUrl:"https://onu50475eh.execute-api.us-east-1.amazonaws.com/tnfts",
        fetchExternal: "https://onu50475eh.execute-api.us-east-1.amazonaws.com",
        routerAddress: '0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506',
        tngblAddress:"0xC3Cd8cE66D0aa591a75686Ee99BAa7b8667d6EE0",
        daiAddress:"0xf46c460F5B2D33aC5c4cE2aA015c8B5c430231C5",
        passiveNftAddress:"0xa0b08D6BBc11e798177D2E6BF838704c5fDe1401",
        passiveNftAbi: "../abis/mumbai/PassiveNFT.json",
        revenueShare:"0x74c03a9FBEEd64635468b8067A7Eb032ffD3ac25",
        rentShare:"0x8A2baC12fA52Cff055FAc75509bf7aB789089e10",
        revenueShareAbi: "../abis/mumbai/RevenueShare.json",
        uniswapFactory: "0xc35DADB65012eC5796536bD9864eD8773aBc74C4",
        instantTradeEnabled: true,
        chainlinkMatrixOracle: "0xbE2F59A77eb5D38FE4E14c8E5284e72E07f74cee",
        feeDistributor: "0x186661c459f89f3dc2515fcb4a12fa17aCA686A0" //revenue distributor
    },
    137: {
        name: 'polygon',
        usdcAddress: '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174',
        usdrAddress: '0xb5DFABd7fF7F83BAB83995E72A52B97ABb7bcf63',
        pearlRouter: "",
        aavePool:"0x445FE580eF8d70FF569aB36e80c647af338db351",
        ourPool: "0xa138341185a9D0429B0021A11FB717B225e13e1F",
        chainLinkGoldOracle: '0x0c466540b2ee1a31b441671eac0ca886e051e410',
        chainLinkGBPOracle: '0x099a2540848573e94fb1ca0fa420b00acbbc845a',
        wrappedMatic: "0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270",
        tangibleLabs: "0xAF8A1548Fd69a59Ce6A2a5f308bCC4698E1Db2E5", //multi sig for tangible labs
        tangibleDao:"0x100fCC635acf0c22dCdceF49DD93cA94E55F0c71", //multisig for dao
        routerAddress: '0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506',
        pearlRouter: '0xcC25C0FD84737F44a7d38649b69491BBf0c7f083',
        //sellFeeAddress: "0x100fCC635acf0c22dCdceF49DD93cA94E55F0c71",
        tokenUrl:"https://n0iqbl374f.execute-api.us-east-1.amazonaws.com/tnfts", //production branch deployment!
        fetchExternal:"https://n0iqbl374f.execute-api.us-east-1.amazonaws.com",
        tngblAddress:"0x49e6A20f1BBdfEeC2a8222E052000BbB14EE6007",
        daiAddress:"0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063",
        passiveNftAddress:"0xDc7ee66c43f35aC8C1d12Df90e61f05fbc2cD2c1",
        passiveNftAbi: "../abis/polygon/PassiveNFT.json",
        revenueShare:"0x0531Dfd07643B549a07F21dd5BA1Da1e1C43142e",
        rentShare:"0x119775e06Abb7b083ae864C55f8C630d62EC7dF3",
        revenueShareAbi: "../abis/polygon/RevenueShare.json",
        uniswapFactory: "0xc35DADB65012eC5796536bD9864eD8773aBc74C4",
        instantTradeEnabled: false,
        chainlinkMatrixOracle: "0x731209585143011778C56BDfaAf87d341adE7C07",
        feeDistributor: "0x6ceD48EfBb581A141667D7487222E42a3FA17cf7" //revenue distributor
    }
}

const goldBars = [
    {
        gWeight: 100,
        fingerprint: 1,
    },
    {
        gWeight: 250,
        fingerprint: 2,
    },
    {
        gWeight: 500,
        fingerprint: 3,
    },
    {
        gWeight: 1000,
        fingerprint: 4,
    }
]

const gold = {
    name: "TangibleGoldBars",
    symbol: "TanXAU",
    fixedStorageFee: false,
    storageRequired: true,
    sellStock: 43,
    goldBars,
    symbolInUri: true, // means that uri is for example example.com/TanXAU/tokenId
    tnftType: 1, // 1 is for gold
    storagePercentage: 10 // 0.1% in 2 decimals as it is in tnft
}

const realEstate = {
    name: "TangibleREstate",
    symbol: "RLTY",
    //url: "https://mdata.tangible.store/tnfts",
    fixedStorageFee: false,
    storageRequired: false,
    paysRent: true,
    realtyFee: 100, // 1%
    symbolInUri: true, // means that uri is for example example.com/RLTY/tokenId
    tnftType: 2, // 1 is for gold
}

const tnftTypes = [
    {
        id: 1,
        description: "Gold bars",
        paysRent: false
    },
    {
        id: 2,
        description: "Real Estates",
        paysRent: true
    }
]

const gbpConversionFee = 1000000;

const blockConfirmations = process.env.BLOCK_CONFIRMATIONS || 0

const developmentChains = ["hardhat", "localhost", "mumbai", "unreal"]
const developmentChainsLocal = ["hardhat", "localhost"]

const getNetworkIdFromName = async (networkIdName) => {
    for (const id in networkConfig) {
        if (networkConfig[id]['name'] == networkIdName) {
            return id
        }
    }
    return null
}

module.exports = {
    networkConfig,
    getNetworkIdFromName,
    developmentChains,
    developmentChainsLocal,
    gold,
    realEstate,
    gbpConversionFee,
    tnftTypes,
    blockConfirmations
}