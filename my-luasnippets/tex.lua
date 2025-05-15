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

  -- In Math mode {{{

  -- frac{}{} and sqrt[n]{} {{{
  s({ trig = 'ff', snippetType = 'autosnippet' }, { t '\\frac{', d(1, get_visual), t '}{', i(2), t '}' }, { condition = tex_utils.in_mathzone }),
  s({ trig = 'sq', snippetType = 'autosnippet' }, fmta('\\sqrt[<>]{<>}', { i(1, 'n'), d(2, get_visual) }), { condition = tex_utils.in_mathzone }),
  -- frac{}{} and sqrt[n]{} }}}

  -- Funktionen {{{
  s({ trig = 'mod', snippetType = 'autosnippet' }, { t '\\mod' }, { condition = tex_utils.in_mathzone }),
  s({ trig = 'sin', desc = 'sin', snippetType = 'autosnippet' }, fmta('\\sin(<>)', { d(1, get_visual) }), { condition = tex_utils.in_mathzone }),
  s({ trig = 'cos', desc = 'cos', snippetType = 'autosnippet' }, fmta('\\cos(<>)', { d(1, get_visual) }), { condition = tex_utils.in_mathzone }),
  s({ trig = 'log', desc = 'log', snippetType = 'autosnippet' }, fmta('\\log(<>)', { d(1, get_visual) }), { condition = tex_utils.in_mathzone }),
  -- Funktionen}}}

  -- \text{} {{{
  s({ trig = '""', snippetType = 'autosnippet' }, fmta('\\text{<>}', { d(1, get_visual) }), { condition = tex_utils.in_mathzone }),
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

  -- dots {{{
  s({ trig = '...', snippetType = 'autosnippet' }, { t '\\dots' }, { condition = tex_utils.in_mathzone }),
  -- dots }}}

  -- cdots{{{
  s({ trig = 'cdot', snippetType = 'autosnippet' }, { t '\\cdot' }, { condition = tex_utils.in_mathzone }),
  -- cdots}}}

  -- FZ Notation und Mengen (sets) und "gleichheitszeichen" {{{
  s({ trig = 'forall', snippetType = 'autosnippet' }, { t '\\forall' }, { condition = tex_utils.in_mathzone }),
  s({ trig = 'exists', snippetType = 'autosnippet' }, { t '\\exists' }, { condition = tex_utils.in_mathzone }),
  s({ trig = 'inn', snippetType = 'autosnippet' }, { t '\\in' }, { condition = tex_utils.in_mathzone }),
  s({ trig = 'to', snippetType = 'autosnippet' }, { t '\\to' }, { condition = tex_utils.in_mathzone }),
  s({ trig = '->', snippetType = 'autosnippet' }, { t '\\to' }, { condition = tex_utils.in_mathzone }),
  s({ trig = '=>', snippetType = 'autosnippet' }, { t '\\implies' }, { condition = tex_utils.in_mathzone }),
  s({ trig = '<=', snippetType = 'autosnippet' }, { t '\\leq' }, { condition = tex_utils.in_mathzone }),
  s({ trig = '>=', snippetType = 'autosnippet' }, { t '\\geq' }, { condition = tex_utils.in_mathzone }),
  s({ trig = 'iff', snippetType = 'autosnippet' }, { t '\\iff' }, { condition = tex_utils.in_mathzone }),
  s({ trig = 'set', snippetType = 'autosnippet' }, { t '\\{', d(1, get_visual), t '\\}' }, { condition = tex_utils.in_mathzone }),
  s({ trig = '===', snippetType = 'autosnippet' }, { t '\\equiv' }, { condition = tex_utils.in_mathzone }),
  s({ trig = '\\\\\\', snippetType = 'autosnippet' }, { t '\\setminus' }, { condition = tex_utils.in_mathzone }),

  s({ trig = 'underline', desc = 'underline' }, fmta('\\underline{<>}', { d(1, get_visual) })),
  s({ trig = 'overline', desc = 'overline' }, fmta('\\overline{<>}', { d(1, get_visual) })),
  s({ trig = 'underset', desc = 'underset' }, fmta('\\underset{<>}{<>}', { i(1), d(2, get_visual) })),
  s({ trig = 'overset', desc = 'overset' }, fmta('\\overset{<>}{<>}', { i(1), d(2, get_visual) })),

  -- FZ Notation und Mengen (sets)  und "gleichheitszeichen" }}}

  -- Bools{{{
  s({ trig = 'lor', snippetType = 'autosnippet' }, { t '\\lor' }, { condition = tex_utils.in_mathzone }),
  s({ trig = 'land', snippetType = 'autosnippet' }, { t '\\land' }, { condition = tex_utils.in_mathzone }),
  -- }}}

  -- x^{y} und x_{y} {{{
  s({ trig = '_', desc = 'subscript', snippetType = 'autosnippet', wordTrig = false }, fmta('_{<>}', { i(1) }), { condition = tex_utils.in_mathzone }),
  s({ trig = '^', desc = 'hoch', snippetType = 'autosnippet', wordTrig = false }, fmta('^{<>}', { i(1) }), { condition = tex_utils.in_mathzone }),
  -- x^{y} und x_{y} }}}

  -- delimiters {{{
  s({ trig = 'lr()', snippetType = 'autosnippet' }, fmta('\\left(  <>\\right)', { d(1, get_visual) }), { condition = tex_utils.in_mathzone }),
  s({ trig = 'lr[]', snippetType = 'autosnippet' }, fmta('\\left[  <>\\right]', { d(1, get_visual) }), { condition = tex_utils.in_mathzone }),
  s({ trig = 'lr{}', snippetType = 'autosnippet' }, fmta('\\left{  <>\\right}', { d(1, get_visual) }), { condition = tex_utils.in_mathzone }),
  s({ trig = 'lr|', snippetType = 'autosnippet' }, fmta('\\left|  <>\\right|', { d(1, get_visual) }), { condition = tex_utils.in_mathzone }),
  s({ trig = 'ceil', snippetType = 'autosnippet' }, fmta('\\lceil  <>\\rceil', { d(1, get_visual) }), { condition = tex_utils.in_mathzone }),
  s({ trig = 'floor', snippetType = 'autosnippet' }, fmta('\\lfloor  <>\\rfloor', { d(1, get_visual) }), { condition = tex_utils.in_mathzone }),
  --  delimiters }}}

  -- In Math mode }}}

  -- autosnippets {{{
  -- In text {{{
  --

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

  -- description environment{{{
  s(
    { trig = 'description', desc = [[
  \begin{description}
    \item[<>] <>
  \end{description}
  ]] },
    fmta(
      [[
      \begin{description}
        \item[<>] <>
      \end{description}
      ]],
      { i(1), i(2) }
    )
  ),
  -- description}}}

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

  -- begin{align} {{{
  s(
    { trig = 'align', desc = [[
  \begin{align*}
    <>
  \end{align*}
  ]] },
    fmta(
      [[
  \begin{align*}
    <>
  \end{align*}
  ]],
      d(1, get_visual)
    )
  ),

  s(
    { trig = 'alignat', desc = [[
  \begin{alignat*}
    <>
  \end{alignat*}
  ]] },
    fmta(
      [[
  \begin{alignat*}{<>}
    <>
  \end{alignat*}
  ]],
      { i(1, 'num of collumns'), d(2, get_visual) }
    )
  ),
  -- end{align} }}}

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

  -- begin{listings} {{{
  s(
    { trig = 'listings', desc = 'Code Environment/Code Block' },
    fmta(
      [[
  \begin{listings}
    <>
  \end{listings}
  ]],
      d(1, get_visual)
    )
  ),
  -- end{listings} }}}

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

  -- section {{{
  s({ trig = 'section', desc = 'section' }, fmta('\\section{<>}', { i(1) })),
  s({ trig = 'subsection', desc = 'subsection' }, fmta('\\subsection{<>}', { i(1) })),
  s({ trig = 'subsubsection', desc = 'subsubsection' }, fmta('\\subsubsection{<>}', { i(1) })),

  -- section }}}

  -- fonts {{{

  s({ trig = 'textbf', desc = 'bold font' }, fmta('\\textbf{<>}', { d(1, get_visual) })),

  s({ trig = 'textit', desc = 'italics' }, fmta('\\textit{<>}', { d(1, get_visual) })),

  s({ trig = 'texttt', desc = 'teletype (monospace font)' }, fmta('\\texttt{<>}', { d(1, get_visual) })),

  s({ trig = 'emph', desc = 'emphasize' }, fmta('\\emph{<>}', { d(1, get_visual) })),

  s({ trig = 'large', desc = 'text size' }, fmta('{\\large <>}', { d(1, get_visual) })),

  s({ trig = 'Large', desc = 'text size' }, fmta('{\\Large <>}', { d(1, get_visual) })),

  s({ trig = 'LARGE', desc = 'text size' }, fmta('{\\LARGE <>}', { d(1, get_visual) })),

  s({ trig = 'huge', desc = 'text size' }, fmta('{\\huge <>}', { d(1, get_visual) })),

  s({ trig = 'Huge', desc = 'text size' }, fmta('{\\Huge <>}', { d(1, get_visual) })),

  s({ trig = 'normalsize', desc = 'text size' }, fmta('{\\normalsize <>}', { d(1, get_visual) })),

  -- fonts }}}

  -- formatting {{{
  s({ trig = 'smallskip', desc = 'vertical spacing' }, { t '\\smallskip' }),
  s({ trig = 'medskip', desc = 'vertical spacing' }, { t '\\medskip' }),
  s({ trig = 'bigskip', desc = 'vertical spacing' }, { t '\\bigskip' }),
  s({ trig = 'noindent', desc = 'prevent indenting' }, { t '\\noindent' }),
  -- }}}

  s({ trig = 'hrule', desc = 'horizontal line' }, { t '\\hrule' }),
  s({ trig = 'hline', desc = 'horizontal line' }, { t '\\hline' }),

  s({ trig = 'footnote', desc = 'footnote' }, fmta('\\footnote{<>}', { d(1, get_visual) })),
}
