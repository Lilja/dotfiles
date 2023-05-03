--[[
local ls = require("luasnip")
local lls = require('lsp-luasnip')
local snippet = ls.snippet
local text = ls.text_node
local insert = ls.insert_node

lls.setup({
	snippets = {
	{
    "typescript",
    "fastify",
    "dependencies",
    "present",
		snippet({
			trig = "fastifyScope",
		}, {
			text({"import fastify, {",
			"  FastifyError,",
			"  FastifyInstance,",
			"  FastifyPluginOptions,",
			"} from \"fastify\";",
			"",
			"const "
			}),
			insert(1, "routes"),
			text({" = (",
			"  fastify: FastifyInstance,",
			"  options: FastifyPluginOptions,",
			"  next: (error?: FastifyError) => void",
			") => {",
			"  // Powered by luasnip + custom func",
			"  next();",
			"};"})
		})
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
			text({"<script lang=\"ts\" setup>",
      "import {ref, computed, PropType } from \"vue\"",
			"",
			""
			}),
			insert(1, ""),
			text({
			"const props = defineProps({",
      "  type: {",
      "    required: true,",
      "    type: String as PropType<string>,",
      "  }",
      "})",
			"</script>",
			"<template>",
      "  <div></div>",
			"</template>",
      })
    })
  }
	}
})
--]]
