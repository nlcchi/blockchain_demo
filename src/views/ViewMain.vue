<script setup>
    import { ref } from "vue"
    import BlockchainDemo from '../components/BlockchainDemo.vue'
    import PublicPrivateKey from "../components/PublicPrivateKey.vue"
    import SmartContractDemo from "../components/SmartContractDemo.vue"

    const tab = ref('blockchain')
</script>

<template>
<div class="q-pa-md">
    <div class="q-gutter-y-md" style="max-width: 1200px">
      <q-card>
        <q-tabs
          v-model="tab"
          dense
          class="bg-grey-3"
          active-color="primary"
          indicator-color="primary"
          align="justify"
          narrow-indicator
        >
          <q-tab name="blockchain" label="Blockchain" />
          <q-tab name="eSignature" label="Digital Signature" />
          <q-tab name="others" label="Others" />
        </q-tabs>

        <q-separator />

        <q-tab-panels v-model="tab" animated>
          <q-tab-panel name="blockchain">
            <div class="text-h6">Blockchain - How it works</div>
            <BlockchainDemo/>
          </q-tab-panel>

          <q-tab-panel name="eSignature">
            <div class="text-h6">Digital Signature - How it work</div>
            <PublicPrivateKey/>
          </q-tab-panel>

          <q-tab-panel name="others">
            <div class="text-h6">Others</div>
            <SmartContractDemo/>
          </q-tab-panel>
        </q-tab-panels>
      </q-card>

    </div>
  </div>
</template>