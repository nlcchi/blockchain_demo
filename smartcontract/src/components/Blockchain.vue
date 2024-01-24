<script setup>
    import { ref, computed } from 'vue';
    import jscrypto from 'crypto-js'

    const props = defineProps({
        leadingzeros: Number,
        blockId: Number,
        prevHash: String,
        modelValue: {type: String, default: '', required: true}
    })

    const emit = defineEmits(['update:modelValue'])

    const blocknonce = ref('0')
    const blockdata = ref('')

    const colorFail = {"background-color":"#F2C037"}
    const colorSuccess = {"background-color":"#31CCEC"}

    const colorVerify = ref(colorFail)

    const hashingFunc = (str) => jscrypto.SHA256(str).toString().toUpperCase()

    const hashingIt = computed(() => {
        const hashStr = hashingFunc(blocknonce.value + blockdata.value + props.prevHash)
        emit('update:modelValue', hashStr)
        colorVerify.value = (hashStr.substring(0, props.leadingzeros) === ''.padStart(props.leadingzeros,'0'))? colorSuccess : colorFail
        return hashStr
    })

    const blockMining =  () => {
        let checkHashNum = hashingIt.value.substring(0,props.leadingzeros)
        if (checkHashNum == ''.padStart(props.leadingzeros,'0')) return
        do { 
            blocknonce.value = Math.floor(Math.random() * 1000000000)
            checkHashNum = hashingIt.value.substring(0,props.leadingzeros)
        }while (checkHashNum != ''.padStart(props.leadingzeros,'0'))
        // alert('trying to mine')
    }


</script>
<template>
    <table :style="colorVerify">
        <tr>
            <td>Block Number: </td>
            <td><div text-size="1.5rem">{{ props.blockId }}</div></td>
        </tr>
        <tr>
            <td>Nonce:</td>
            <td><input type="text" v-model="blocknonce"></td>
        </tr>
        <tr>
            <td>Data:</td>
            <td><textarea cols="100" rows="10" v-model="blockdata"></textarea></td>
        </tr>
        <tr>
            <td>Previous Hash:</td>
            <td><div w-800px border-1 bg-white>{{ props.prevHash }}</div></td>
        </tr>
        <tr>
            <td>Current Hash:</td>
            <td><div w-800px border-1 bg-white>{{ hashingIt }}</div></td>
        </tr>
        <tr>
            <td colspan="2"><input type="button" value="Mine Me" @click="blockMining"></td>
        </tr>
    </table>
</template>
<style scoped>
    table { 
        border: 1px solid;
    }

    td { 
        text-align: left;
    }
</style>