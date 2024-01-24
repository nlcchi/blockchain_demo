import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import Unocss from 'unocss/vite'
import { presetUno, presetAttributify } from 'unocss'
import { quasar, transformAssetUrls } from '@quasar/vite-plugin'


// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    vue({
      template: { transformAssetUrls }
    }),
    Unocss({
      presets: [
        presetAttributify({ /* preset options */}),
        presetUno(),
      ], // disable default preset
    }),
    quasar({
      sassVariables: 'src/quasar-variables.sass'
    })
  ]
})
