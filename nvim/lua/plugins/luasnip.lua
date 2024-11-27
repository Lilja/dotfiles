return {
	{
		"L3MON4D3/LuaSnip",
		-- follow latest release.
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		-- install jsregexp (optional!).
		build = "make install_jsregexp",
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
			local ls = require("luasnip")
			local snippet = ls.snippet
			local text = ls.text_node
			local insert = ls.insert_node

			local vue3_component_creation_snippet = snippet({
				trig = "vue 3 script+template",
				dscr = "Vue 3 script(setup)+template",
			}, {
				text({
					'<script lang="ts" setup>',
					'import {ref, computed, PropType } from "vue"',
					"",
					"",
				}),
				insert(1, ""),
				text({
					"const props = defineProps({",
					"  type: {",
					"    required: true,",
					"    type: String as PropType<string>,",
					"  }",
					"})",
					"",
					'const count = defineModel<number>("count", {',
					"  type: Number as PropType<number>,",
					"  required: true,",
					"})",
					"",
					"</script>",
					"",
					"<template>",
					"  <div>",
					"   ",
					"  </div>",
					"</template>",
				}),
			})
			local vue_define_model_snippet = snippet({
				trig = "vue define model",
				dscr = "Vue define model(v-model)",
			}, {
				text({
					'const count = defineModel<number>("count", {',
					"  type: Number as PropType<number>,",
					"  required: true,",
					"})",
				}),
			})
			local vitest_test_case = snippet({
				trig = "vitest test case pattern",
				dscr = "Vitest test case",
			}, {
				text({
					'import { expect, test } from "vitest";',
					"",
					'test("1+1=2", () => {',
					"  expect(",
				}),
				insert(1, "1+1"),
				text({ ").toBe(2);", "});" }),
			})
			ls.add_snippets("vue", { vue3_component_creation_snippet, vue_define_model_snippet })
			ls.add_snippets("typescript", { vitest_test_case })
		end,
	},
}
