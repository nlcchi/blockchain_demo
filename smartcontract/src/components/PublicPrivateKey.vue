<script setup>
    import {ref} from 'vue'
    import CryptoJS from 'crypto-js'
    import jsEncrypt from 'jsencrypt'

    const DEFAULT_KEY_SIZE = 512;
    const keypairs = ref({
        privateKey: 'ABC',
        publicKey: 'ABC'
    })

    const generateKeys = () => {
        const jsencrypt = new jsEncrypt({default_key_size:DEFAULT_KEY_SIZE})
        keypairs.value.publicKey = jsencrypt.getPublicKey()
        keypairs.value.privateKey = jsencrypt.getPrivateKey()
    }

    const signing = ref({
        signingData: '',
        privateKeyToSign: '',
        signature: '',
        publicKeyToVerify: '',
        verifyOutcome: 'NA'

    })

    const signIt = (str, key) => {
        if (str === '' || key === '') {
            alert('Enter both data & private key to sign')
            return ''
        }
        const jsencrypt = new jsEncrypt({default_key_size:DEFAULT_KEY_SIZE})
        jsencrypt.setPrivateKey(key)
        return jsencrypt.sign(str,CryptoJS.SHA256, "sha256")
    }

    const verifySignature = (str, signature, key) => {
        if (str === '' || signature==='' || key === '') {
            alert('Enter data, signature & public key to verify')
            return ''
        }

        const jsencrypt = new jsEncrypt({default_key_size:DEFAULT_KEY_SIZE})
        jsencrypt.setPublicKey(key)
        return jsencrypt.verify(str, signature, CryptoJS.SHA256)? 'Verified' : 'Failed'

    }

    const tab = ref('publicPrivateKey');

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
          <q-tab name="publicPrivateKey" label="Public/Private Keys" />
          <q-tab name="eSignature" label="Digital Signature" />
          <q-tab name="verifySignature" label="Verify Signature" />
        </q-tabs>

        <q-separator />

        <q-tab-panels v-model="tab" animated>
          <q-tab-panel name="publicPrivateKey">
            <table border-1 m-1>
                <tr>
                    <td colspan="2"><input type="button" value="Click To Generate Key Pairs" @click="generateKeys"></td>
                </tr>
                <tr>
                    <td>This is your private key:</td>
                    <td text-align-left><textarea cols="100" rows="10" v-model="keypairs.privateKey"></textarea></td>
                </tr>
                <tr>
                    <td>This is your public key:</td>
                    <td text-align-left><textarea cols="100" rows="5" v-model="keypairs.publicKey"></textarea></td>
                </tr>
            </table>
          </q-tab-panel>

          <q-tab-panel name="eSignature">
                <table border-1 m-2>
                    <tr>
                        <td>Data:</td>
                        <td><textarea cols="100" rows="5" v-model="signing.signingData"></textarea></td>
                    </tr>
                    <tr>
                        <td>Private key:</td>
                        <td><textarea cols="100" rows="10" v-model="signing.privateKeyToSign"></textarea></td>
                    </tr>
                    <tr>
                        <td colspan="2"><input type="button" value="Click to digital sign your data" @click="() => signing.signature = signIt(signing.signingData, signing.privateKeyToSign)"></td>
                    </tr>
                    <tr>
                        <td>Your Signature:</td>
                        <td><textarea cols="100" rows="2" v-model="signing.signature"></textarea></td>
                    </tr>
                </table>
          </q-tab-panel>

          <q-tab-panel name="verifySignature">
            <table border-1 m-2>
                <tr>
                    <td w-50px>Data:</td>
                    <td><textarea cols="100" rows="5" v-model="signing.signingData"></textarea></td>
                </tr>
                <tr>
                    <td>Signature:</td>
                    <td><textarea cols="100" rows="2" v-model="signing.signature"></textarea></td>
                </tr>
                <tr>
                    <td>Public Key:</td>
                    <td><textarea cols="100" rows="10" v-model="signing.publicKeyToVerify"></textarea></td>
                </tr>
                <tr>
                    <td colspan="2">
                        <div pa-2>
                            <input type="button" value="Click to verify your digital signature" @click="() => signing.verifyOutcome = verifySignature(signing.signingData, signing.signature, signing.publicKeyToVerify)">
                            <div border-1 bg-yellow inline m-2>{{ signing.verifyOutcome }}</div>
                        </div>
                    </td>
                </tr>

            </table>
          </q-tab-panel>
        </q-tab-panels>
      </q-card>

    </div>
  </div>


</template>

<style scoped>
    td {
        text-align: left;
    }
</style>