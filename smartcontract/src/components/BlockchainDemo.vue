<script setup>
import { ref } from 'vue'
import Blockchain from './Blockchain.vue'


const blockProps = ref([
  {prevHash:''.padStart(64,'0'), curHash: ''},
])

const leadingzeros = ref(0)

const addNewBlock = () => {
  const num_block = blockProps.value.length
  let prevHash = ''.padStart(64, '0')
  if (num_block>0) prevHash = blockProps.value[num_block-1].curHash
  blockProps.value.push({prevHash: prevHash, curHash: ''})
}


</script>

<template>

<div text-left>
  <div> number of leading zeros for Hash: <input type="text" v-model="leadingzeros"></div>
  <div><input type="button" value="Add A New Block" @click="addNewBlock"></div>
  <div v-for="(blockProp,index) in blockProps" :key="index" m-2>
    <Blockchain :leadingzeros="leadingzeros" :blockId="index" v-if="index==0" :prevHash="blockProp.prevHash" v-model="blockProp.curHash"/>
    <Blockchain :leadingzeros="leadingzeros" :blockId="index" v-else :prevHash="blockProps[index-1].curHash" v-model="blockProp.curHash"/>
  </div>
</div>

</template>

<style scoped>
a {
  color: #42b983;
}
</style>
