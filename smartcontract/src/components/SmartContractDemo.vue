<script setup>
    import { onMounted, ref } from 'vue';
    import { ethers } from 'ethers';
    import Contract from '../artifacts/contracts/Escrow.sol/Escrow.json'

    const contractAddress = '0x5f7AfdCDdaDB44C5Ef04E82BE172A9985204CC73';

    // const provider = new ethers.providers.Web3Provider(window.ethereum)
    // await provider.send("eth_requestAccounts", [])
    // const signer = provider.getSigner()
    // const contract = new ethers.Contract(contractAddress, Contract.abi, signer)

    const currentParty = ref('Seller')
    const stateRefs = ['Sale', 'Locked', 'Release', 'Closed', 'Complete']

    const mycontract = ref({
        itemName: 'Car',
        price: 0,
        seller: '',
        buyer: '',
        visitor: '',
        balance: 0,
        state: '',
        totalSales: 0,
        prevBuyers: []
    })

    const getContractInfo = async () => {
        const contract = await getContract()
        mycontract.value.seller = (await contract.seller()).toUpperCase()
        mycontract.value.buyer = (await contract.buyer()).toUpperCase()
        mycontract.value.state = stateRefs[await contract.state()]
        mycontract.value.itemName = await contract.itemSale()
        mycontract.value.price = ethers.utils.formatEther(await contract.price())
        mycontract.value.balance = ethers.utils.formatEther(await contract.provider.getBalance(contractAddress))
        mycontract.value.totalSales = await contract.totalSales()
        mycontract.value.prevBuyers = await contract.listPreviousBuyers()

        const curAccount = (await contract.provider.getSigner().getAddress()).toUpperCase()

    
        if (mycontract.value.seller == curAccount) {
            currentParty.value = 'Seller'
        }else if (mycontract.value.buyer == curAccount) {
            currentParty.value = 'Buyer'
        }else {
            currentParty.value = 'Visitor'
            mycontract.value.visitor = curAccount
        }

    }

    onMounted(async () => {
        const contract = await getContract()

        await getContractInfo()

        contract.on("Closed", async (when, event) => {
            await getContractInfo()
        })

        contract.on("ConfirmPurchase", async (when, by, event) => {
            await getContractInfo()
        })

        contract.on("ConfirmReceived", async (when, by, event) => {
            await getContractInfo()
        })

        contract.on("SellerRefundBuyer", async (when, event) => {
            await getContractInfo()
        })

        contract.on("SellerRefunded", async (when, event) => {
            await getContractInfo()
        })

        contract.on("Started", async (when, event) => {
            await getContractInfo()
        })
    })

    window.ethereum.on('accountsChanged', (accounts) => {
        if (mycontract.value.seller == accounts[0].toUpperCase()) {
            currentParty.value = 'Seller'
        }else if (mycontract.value.buyer == accounts[0].toUpperCase()) {
            currentParty.value = 'Buyer'
        }else {
            currentParty.value = 'Visitor'
            mycontract.value.visitor = accounts[0].toUpperCase()
        }
    })

    const getContract = async () => {
        if (typeof window.ethereum == 'undefined') return 'undefined'
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        await provider.send("eth_requestAccounts", [])
        const signer = provider.getSigner()
        const _contract = new ethers.Contract(contractAddress, Contract.abi, signer)
        return _contract
    }

    const createContract = async (price) => {
        try {
            const contract = await getContract()
            const data = await contract.startContract(
                mycontract.value.itemName,
                ethers.utils.parseEther(price), 
                {value: ethers.utils.parseEther(price)})
            console.log(data)
        }catch (err) {
            console.log(err)
        }
    }

    const confirmPurchase = async () => {
        try {
            const contract = await getContract()
            const data = await contract.confirmPurchase({value: ethers.utils.parseEther(mycontract.value.price)})
            console.log(data)
        }catch (err) {
            console.log(err)
        }
    }

    const confirmReceived = async () => {
        try {
            const contract = await getContract()
            const data = await contract.confirmReceived()
            console.log(data)
        }catch (err) {
            console.log(err)
        }
    }


    const closeContract = async () => {
        try {
            const contract = await getContract()
            const data = await contract.close()
            console.log(data)
        }catch (err) {
            console.log(err)
        }
    }

    const refundBuyer = async () => {
        try {
            const contract = await getContract()
            const data = await contract.refundBuyer()
            console.log(data)
        }catch (err) {
            console.log(err)
        }
    }

    const refundSeller = async () => {
        try {
            const contract = await getContract()
            const data = await contract.refundSeller()
            console.log(data)
        }catch (err) {
            console.log(err)
        }
    }


    // const getParty = async (party) => {
    //     const contract = getContract()

    //     if (party == "buyer") parties.value.buyer = await contract.buyer()
    //     if (party == "seller") parties.value.seller = await contract.seller()
    //     if (party == "shipper") parties.value.shipper = await contract.shippingManager()
    // }

    // const contractInfo = ref({})

    const imgPath = (itemName) =>  new URL('../assets/pic' + (itemName || 'Car') + '.jpeg', import.meta.url)
</script>

<template>
<table border-1 ma-2>
    <tr>
        <td text-left> Item To Sale:</td>
        <td text-left>
        <select v-model="mycontract.itemName" :disabled="!['Closed', 'Complete'].includes(mycontract.state)">
            <option value="Car">Car</option>
            <option value="Vacum">Vacum</option>
            <option value="Clock">Clock</option>
        </select>
        </td>
    </tr>
    <tr>
        <td text-left> Price:</td>
        <td text-left><input type="text" v-model="mycontract.price" :disabled="!['Closed', 'Complete'].includes(mycontract.state)"></td>
    </tr>
    <tr>
        <td colspan="2"><button @click="createContract(mycontract.price)" :disabled="!['Closed', 'Complete'].includes(mycontract.state)">Create A Sale</button></td>
    </tr>
</table>

<table>
    <tr>
        <td text-left border-1>
            <div text-5 text-center> Buy A {{mycontract.itemName}} With {{mycontract.price}} Ethers</div>
            <div text-center><img :src="imgPath(mycontract.itemName)" height="150" alt=""></div>
            <div>The contract: {{contractAddress}}</div>
            <div># Solds: {{mycontract.totalSales}}</div>
            <div>The current state: {{mycontract.state}}</div>
            <div>The current balance: {{mycontract.balance}}</div>
        </td>
    </tr>
    <tr>
        <td text-center border-1>
            <div text-5 >You are the {{currentParty}}</div>
            <div v-if="currentParty == 'Seller'">
                <div v-if="mycontract.state == 'Sale'" >
                    <div>You need a buyer to sell this item first</div>
                    <button @click="closeContract">I WANT TO CLOSE THIS AD</button>
                </div>
                <div v-if="mycontract.state == 'Release'">
                    <div>This item has been sold & received by the buyer.</div>
                    <button @click="refundSeller">I WANT TO GET MONEY FROM THIS SOLD ITEM</button>
                </div>
                <div v-if="mycontract.state == 'Locked'">
                    <div>This item has been sold & buyer is waiting for the shipping.</div>                    
                    <button @click="refundBuyer">I WANT TO REFUND BUYER</button>
                </div>
                <div v-if="['Closed', 'Completed'].includes(mycontract.state)">
                    <div>This Ad has been closed. Create another Ad to continue</div>                    
                </div>
            </div>
            <div v-if="currentParty == 'Buyer'">
                <div>Your address: {{ mycontract.visitor }}</div>
                <div>The seller is: {{ mycontract.seller }}</div>
                <button v-if="mycontract.state == 'Locked'" @click="confirmReceived">I HAVE RECEIVED THE ITEM</button>
                <div v-if="mycontract.state == 'Release'">You have confirmed that the item has been received.</div>
            </div>
            <div v-if="currentParty == 'Visitor'">
                <div>Your address: {{ mycontract.visitor }}</div>
                <div>The seller is: {{ mycontract.seller }}</div>
                <div v-if="mycontract.state != 'Sale'">This item is not available for sale.</div>
                <button v-if="mycontract.state == 'Sale'" @click="confirmPurchase">I WANT TO BUY THIS {{ mycontract.itemName }}</button>
            </div>
        </td>
    </tr>
</table>


</template>