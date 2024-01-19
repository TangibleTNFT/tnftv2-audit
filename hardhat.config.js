require("dotenv").config();
require("@atixlabs/hardhat-time-n-mine");
require('@openzeppelin/hardhat-upgrades');
require("hardhat-deploy")
require("hardhat-gas-reporter")
require("hardhat-tracer")
require("@nomicfoundation/hardhat-chai-matchers");
require('hardhat-contract-sizer');
require('solidity-docgen')
require('@typechain/hardhat')

module.exports = {
  docgen: {
    pages: "files",
    except: ["contracts/tests/", "contracts/artifacts/", "contracts/exchangeInterfaces"],
  },
  mocha: {
    timeout: 100000000
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      // forking: {
      //   url: process.env.INFURA_URL_MUMBAI,
      //   blockNumber: 39290683
      // }
    },
    localhost: {},
    mumbai: {
      url: process.env.INFURA_URL_MUMBAI,
      accounts: [process.env.PK1, process.env.PK2, process.env.PK2],
      gasPrice: 2000000000
    },
    unreal: {
      chainId: 18231,
      url: "https://rpc.unreal.gelato.digital",
      accounts: [process.env.PK1, process.env.PK2],
      
    },
    polygon: {
      url: process.env.INFURA_URL_POLYGON,
      accounts: [process.env.PK1, process.env.PK2],
      // gasPrice: 30000000000
    },
  },
  namedAccounts: {
    deployer: 0,
    storageFeeAddress: 1,
    sellFeeAddress: 2,
    priceManager: 3,
    randomUser: 4,
    randomUser2: 5,
    randomUser3: 6,
    randomUser4: 7
  },
  solidity: {
    compilers: [
      {
        version: "0.8.23",
        settings: {
          evmVersion: 'shanghai',
          optimizer: {
            enabled: true,
            runs: 2000,
          },
        },
      },
      {
        version: "0.7.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 1000000,
          },
        },
      },
      {
        version: "0.6.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 1000000,
          },
        },
      },
    ]
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: {
      polygon:process.env.POLYGON_EXPLORER_API_KEY,
      mumbai:process.env.POLYGON_EXPLORER_API_KEY,
      unreal:"api-key",
    },
    customChains: [
      {
        network: "unreal",
        chainId: 18231,
        urls: {
          apiURL: "https://unreal.blockscout.com/api",
          browserURL: "https://unreal.blockscout.com"
        }
      }
    ]
  },
  gasReporter: {
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
    currency: "USD",
    enabled: process.env.REPORT_GAS === "true",
    excludeContracts: ["contracts/tests/", "contracts/libraries/"],
  },
  typechain: {
    outDir: "types",
    target: "ethers-v6",
  }
};
