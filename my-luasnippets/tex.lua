-- vim:foldmethod=marker
-- local variables and functions {{{
local ls = require 'luasnip'
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require 'luasnip.util.events'
local ai = require 'luasnip.nodes.absolute_indexer'
local extras = require 'luasnip.extras'
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require('luasnip.extras.fmt').fmt
local fmta = require('luasnip.extras.fmt').fmta
local conds = require 'luasnip.extras.expand_conditions'
local postfix = require('luasnip.extras.postfix').postfix
local types = require 'luasnip.util.types'
local parse = require('luasnip.util.parser').parse_snippet
local ms = ls.multi_snippet
local k = require('luasnip.nodes.key_indexer').new_key

-- }}}

-- used to surround text {{{
local get_visual = function(args, parent)
  if #parent.snippet.env.LS_SELECT_RAW > 0 then
    return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
  else -- If LS_SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end
--- }}}

-- Some LaTeX-specific conditional expansion functions (requires VimTeX) {{{

local tex_utils = {}
tex_utils.in_mathzone = function() -- math context detection
  return vim.fn['vimtex#syntax#in_mathzone']() == 1
end

tex_utils.in_text = function()
  return not tex_utils.in_mathzone()
end

tex_utils.in_comment = function() -- comment detection
  return vim.fn['vimtex#syntax#in_comment']() == 1
end

tex_utils.in_env = function(name) -- generic environment detection
  local is_inside = vim.fn['vimtex#env#is_inside'](name)
  return (is_inside[1] > 0 and is_inside[2] > 0)
end

-- A few concrete environments---adapt as needed
tex_utils.in_equation = function() -- equation environment detection
  return tex_utils.in_env 'equation'
end
tex_utils.in_itemize = function() -- itemize environment detection
  return tex_utils.in_env 'itemize'
end

-- }}}

return {

  -- To return multiple snippets, use one `return` statement per snippet file
  -- and return a table of Lua snippets.

  -- Preamble {{{

  -- documentclass {{{
  s({ trig = 'documentclass', desc = 'documentclass' }, fmta('\\documentclass[<>]{<>}', { i(1, 'options'), i(2, 'class') })),
  -- docuemntclass }}}

  -- usepackage {{{
  s({ trig = 'usepackage', desc = 'usepackage' }, fmta('\\usepackage[<>]{<>}', { i(1, 'options'), i(2, 'package') })),
  -- usepackage }}}

  -- newtheorem {{{
  s({ trig = 'newtheorem', desc = 'used for creating a new theorem' }, fmta('\\newtheorem{<>}{<>}', { i(1, 'name'), i(2, 'Display name') })),
  -- newtheorem }}}

  -- theoremstyle {{{
  s({ trig = 'theoremstyle', desc = 'set theorem style' }, fmta('\\theoremstyle{<>}', { i(1) })),
  -- theoremstyle }}}

  -- Preamble }}}

  -- autosnippets {{{

  -- In Math mode {{{

  -- frac{}{} {{{
  s({ trig = 'ff', snippetType = 'autosnippet' }, { t '\\frac{', d(1, get_visual), t '}{', i(2), t '}' }, { condition = tex_utils.in_mathzone }),
  -- frac{}{} }}}

  -- \text{} {{{
  s({ trig = '"', snippetType = 'autosnippet' }, fmta('\\text{<>}', { d(1, get_visual) }), { condition = tex_utils.in_mathzone }),
  -- \text{} }}}

  -- fonts {{{
  s(
    { trig = 'rm', desc = 'font used for functions like sin or cos', snippetType = 'autosnippet' },
    fmta('\\mathrm{<>}', { d(1, get_visual) }),
    { condition = tex_utils.in_mathzone }
  ),

  s({ trig = 'bf', desc = 'bold font', snippetType = 'autosnippet' }, fmta('\\mathbf{<>}', { d(1, get_visual) }), { condition = tex_utils.in_mathzone }),

  s({ trig = 'it', desc = 'italics', snippetType = 'autosnippet' }, fmta('\\mathit{<>}', { d(1, get_visual) }), { condition = tex_utils.in_mathzone }),

  s({ trig = 'cal', desc = 'fancy font', snippetType = 'autosnippet' }, fmta('\\mathcal{<>}', { d(1, get_visual) }), { condition = tex_utils.in_mathzone }),

  s({ trig = 'bb', desc = 'blackboard bold', snippetType = 'autosnippet' }, fmta('\\mathbb{<>}', { d(1, get_visual) }), { condition = tex_utils.in_mathzone }),

  s(
    { trig = 'tt', desc = 'teletype (monospace font)', snippetType = 'autosnippet' },
    fmta('\\mathtt{<>}', { d(1, get_visual) }),
    { condition = tex_utils.in_mathzone }
  ),
  -- fonts }}}

  -- In Math mode }}}

  -- In text {{{
  --
  -- fonts {{{

  s({ trig = 'bf', desc = 'bold font' }, fmta('\\textbf{<>}', { d(1, get_visual) })),

  s({ trig = 'it', desc = 'italics' }, fmta('\\textit{<>}', { d(1, get_visual) })),

  s({ trig = 'tt', desc = 'teletype (monospace font)' }, fmta('\\texttt{<>}', { d(1, get_visual) })),
  -- fonts }}}

  -- In text }}}

  -- autosnippet }}}

  -- begin / end environments {{{

  -- generic begin / end environment {{{
  s(
    { trig = 'begin' },
    fmta(
      [[
  \begin{<>}
    <>
  \end{<>}
  ]],
      { i(1), d(2, get_visual), rep(1) }
    )
  ),
  -- generic begin / end environment }}}

  -- document begin / end environment {{{
  s(
    { trig = 'document', desc = [[
  \begin{docuemnt}
    <>
  \end{document}
  ]] },
    fmta(
      [[
      \begin{document}
        <>
      \end{document}
      ]],
      d(1, get_visual)
    )
  ),

  -- document begin / end environment }}}

  -- itemize begin / end environment {{{
  s(
    { trig = 'itemize', desc = [[
  \begin{itemize}
    \item <>
  \end{itemize}
  ]] },
    fmta(
      [[
      \begin{itemize}
        \item <>
      \end{itemize}
      ]],
      d(1, get_visual)
    )
  ),

  -- itemize begin / end environment }}}

  -- enumerate begin / end environment {{{
  s(
    { trig = 'enumerate', desc = [[
  \begin{enumerate}
    \item <>
  \end{enumerate}
  ]] },
    fmta(
      [[
      \begin{enumerate}
        \item <>
      \end{enumerate}
      ]],
      d(1, get_visual)
    )
  ),
  -- enumerate begin / end environment }}}

  -- equation begin /end environment {{{
  s(
    { trig = 'equation', desc = [[
  \begin{equation}
    <>
  \end{equation}
  ]] },
    fmta(
      [[
      \begin{equation}
        <>
      \end{equation}
      ]],
      d(1, get_visual)
    )
  ),

  -- equation begin /end environment }}}

  -- begin{split} {{{
  s(
    { trig = 'split', desc = [[
  \begin{split}
    <>
  \end{split}
  ]] },
    fmta(
      [[
  \begin{split}
    <>
  \end{split}
  ]],
      d(1, get_visual)
    )
  ),
  -- end{split} }}}

  -- other language {{{
  s(
    { trig = 'other language', desc = 'use rules for a different language' },
    fmta(
      [[
  \begin{other language}{<>}
    <>
  \end{other language}
  ]],
      {
        i(1, 'english|ngerman'),
        d(2, get_visual),
      }
    )
  ),
  -- other language }}}

  -- begin / end environments }}}

  -- create math environment {{{
  s({ trig = 'll', snippetType = 'autosnippet', desc = 'in-line' }, fmta('\\(<>\\)', d(1, get_visual)), { condition = tex_utils.in_text }),
  s(
    { trig = 'mm', snippetType = 'autosnippet', desc = 'multi-line' },
    fmta(
      [[
  \[
    <>
  \]
      ]],
      d(1, get_visual)
    ),
    { condition = tex_utils.in_text }
  ),
  -- create math environment }}}
}
