# Basic Sample Hardhat Project

This project is used to explain how cryptocurrencies works. including blockchain generation, digital signature and how smart contract works in ethereum blockchain.


1. To run the local ethereun network: npx hardhat node
2. To deploy a contract: npx hardhat run scripts/deploy-lc.js --network localhost
3. Add a few test ether accounts into metamask
3. using vite to run front end:
    - cd <project folder>
    - npx vite --port=4000
4. Note: this front-end is using Vue3, with quasar, unocss, cryptojs, en and ethers.js. Follow steps below for components installation:
    - yarn create vite smartcontract --template vue
    - cd smartcontract
    - yarn add quasar @quasar/vite-plugin sass@1.32.0 unocss
    - yarn add crypto-js @types/crypto-js jsencrypt
    - yarn add ethers hardhat @nomiclabs/hardhat-waffle ethereum-waffle chai @nomiclabs/hardhat-ethers
