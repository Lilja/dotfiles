local ls = require("luasnip")
local lls = require("lsp-luasnip")
local snippet = ls.snippet
local text = ls.text_node
local insert = ls.insert_node
local functionNode = ls.function_node
require("luasnip.loaders.from_vscode").lazy_load()

local function copyNameOfVariable(
	args -- text from i(2) in this example i.e. { { "456" } }
)
	if args[1][1] then
		return args[1][1]:gsub("store", ""):gsub("Store", "")
	end
	return "counter"
end

lls.setup({
	snippets = {
		{
			"typescript",
			"pinia",
			"dependencies",
			"present",
			snippet({
				trig = "Pinia store creation(option)",
				dscr = "Pinia store with vuex/option compatible layout",
			}, {
				text({
					"import { defineStore } from 'pinia'",
					"",
					"export const use"
				}),
				insert(1, "CounterStore"),
				text(" = defineStore('"),
				functionNode(copyNameOfVariable, {1}),
				text({
					"', {",
					"  state: () => ({ count: 0, name: 'Eduardo' }),",
					"  getters: {",
					"    doubleCount: (state) => state.count * 2,",
					"  },",
					"  actions: {",
					"    increment() {",
					"      this.count++",
					"    },",
					"  },",
					"})",
				}),
			}),
		},
		{
			"typescript",
			"pinia",
			"dependencies",
			"present",
			snippet({
				trig = "Pinia store creation(setup)",
				dscr = "Pinia store with new setup store",
			}, {
				text({
					"import { defineStore } from 'pinia'",
					"import { ref, computed } from 'vue'",
					"",
					"export const use"
				}),
				insert(1, "CounterStore"),
				text(" = defineStore('"),
				functionNode(copyNameOfVariable, {1}),
				text({
					"', () => {",
					"  const count = ref(0)",
          "  const name = ref('Eduardo')",
					"  const doubleCount = computed(() => count.value * 2)",
					"  function increment() {",
					"    count.value++",
					"  }",
					"",
					"  return { count, name, doubleCount, increment }",
					"})",
				}),
			}),
		},
		{
			"typescript",
			"fastify",
			"dependencies",
			"present",
			snippet({
				trig = "fastifyScope",
			}, {
				text({
					"import fastify, {",
					"  FastifyError,",
					"  FastifyInstance,",
					"  FastifyPluginOptions,",
					'} from "fastify";',
					"",
					"const ",
				}),
				insert(1, "routes"),
				text({
					" = (",
					"  fastify: FastifyInstance,",
					"  options: FastifyPluginOptions,",
					"  next: (error?: FastifyError) => void",
					") => {",
					"  // Powered by luasnip + custom func",
					"  next();",
					"};",
				}),
			}),
		},
		{
			"vue",
			"vue",
			"dependencies",
			"present",
			snippet({
				trig = "vue 3 script+template",
				dscr = "Vue 3 script(setup)+template",
			}, {
				text({ '<script lang="ts" setup>', 'import {ref, computed, PropType } from "vue"', "", "" }),
				insert(1, ""),
				text({
					"const props = defineProps({",
					"  type: {",
					"    required: true,",
					"    type: String as PropType<string>,",
					"  }",
					"})",
					"</script>",
					"",
					"<template>",
					"  <div>",
					"   ",
					"  </div>",
					"</template>",
				}),
			}),
		},
	},
})
