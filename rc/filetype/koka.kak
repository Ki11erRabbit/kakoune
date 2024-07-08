# koka syntax highlighting for kakoune ()
#
# based off of https://koka-lang.github.io/koka/doc/book.html#sec:full-lexical
# as well as the Zig syntax highlight

# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*[.](kk) %{
  set-option buffer filetype koka
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=koka %<
    require-module koka
    hook window ModeChange pop:insert:.* -group koka-trim-indent koka-trim-indent
    hook window InsertChar \n -group koka-insert koka-insert-on-new-line
    hook window InsertChar \n -group koka-indent koka-indent-on-new-line
    hook window InsertChar \} -group koka-indent koka-indent-on-closing

    hook -once -always window WinSetOption filetype=.* %< remove-hooks window koka-.+ >
>

hook -group koka-highlight global WinSetOption filetype=koka %{
    require-module koka
    add-highlighter window/koka ref koka
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/koka }
}

provide-module koka %§

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter shared/koka regions
add-highlighter shared/koka/code default-region group

add-highlighter shared/koka/comment region '//' '$' fill comment
add-highlighter shared/koka/block_comment   region -recurse /\*\*\* /\*\*\* \*/            fill comment

# strings and characters
add-highlighter shared/koka/string region '"' (?<!\\)(\\\\)*" group
add-highlighter shared/koka/string/ fill string
add-highlighter shared/koka/string/ regex '(?:\\n|\\r|\\t|\\\\|\\''|\\"|\\x[0-9a-fA-F]{2}|\\u\{[0-9a-fA-F]+\})' 0:meta

add-highlighter shared/koka/character region "'" (?<!\\)(\\\\)*' group
add-highlighter shared/koka/character/ fill string
add-highlighter shared/koka/character/ regex '(?:\\n|\\r|\\t|\\\\|\\''|\\"|\\x[0-9a-fA-F]{2}|\\u\{[0-9a-fA-F]+\})' 0:meta

# operators
add-highlighter shared/koka/code/ regex '(?:\+|-|\*|/|%|=|<|>|&|\||\^|~|\?|!|:)' 0:operator
#identifiers
add-highlighter shared/koka/code/ regex %{\b[^\s\d!<>]+(?:\d+[^\s\d!^<^>]*)*'?\b} 0:Default
add-highlighter shared/koka/code/ regex \b([^/^\s]+/) 0:type
# keywords
add-highlighter shared/koka/code/ regex '\b(?:infix|infixr|infixl)\b' 0:keyword
add-highlighter shared/koka/code/ regex '\b(?:module|import|pub|abstract|as)\b' 0:keyword
add-highlighter shared/koka/code/ regex '\b(?:type|struct|alias)\b' 0:keyword
add-highlighter shared/koka/code/ regex '\b(?:effect|ctl|named)\b' 0:keyword
add-highlighter shared/koka/code/ regex '\b(?:fun|fn|unsafe|extern)\b' 0:keyword
add-highlighter shared/koka/code/ regex '\b(?:as|con|with|in|interface|raw|some|override)\b' 0:keyword
add-highlighter shared/koka/code/ regex '\b(?:forall|exists)\b' 0:type
add-highlighter shared/koka/code/ regex '\b(?:val|var)\b' 0:keyword
add-highlighter shared/koka/code/ regex '\b(?:if|then|else|elif|match|return|handle|handler|mask|final|break|continue)\b' 0:keyword

# types
add-highlighter shared/koka/code/ regex '\b(?:int|float32|float64|int8|int16|int32|int64|char|list|vector)\b' 0:type

# primitive values
add-highlighter shared/koka/code/ regex '\b(?:True|False)\b' 0:value

# integer literals
add-highlighter shared/koka/code/ regex '\b[0-9](_?[0-9])*\b' 0:value
add-highlighter shared/koka/code/ regex '\b0x[0-9a-fA-F](_?[0-9a-fA-F])*\b' 0:value
add-highlighter shared/koka/code/ regex '\b0o[0-7](_?[0-7])*\b' 0:value
add-highlighter shared/koka/code/ regex '\b0b[01](_?[01])*\b' 0:value

# float literals
add-highlighter shared/koka/code/ regex '\b[0-9]+\.[0-9]+(?:[eE][-+]?[0-9]+)?\b' 0:value
add-highlighter shared/koka/code/ regex '\b0x[0-9a-fA-F]+\.[0-9a-fA-F]+(?:[pP][-+]?[0-9a-fA-F]+)?\b' 0:value
add-highlighter shared/koka/code/ regex '\b[0-9]+\.?[eE][-+]?[0-9]+\b' 0:value
add-highlighter shared/koka/code/ regex '\b0x[0-9a-fA-F]+\.?[eE][-+]?[0-9a-fA-F]+\b' 0:value


# builtin functions

# Commands
# ‾‾‾‾‾‾‾‾

define-command -hidden koka-trim-indent %{
    # delete trailing whitespace
    try %{ execute-keys -draft -itersel x s \h+$ <ret> d }
}

define-command -hidden koka-insert-on-new-line %<
    try %[
        evaluate-commands -draft -save-regs '/"' %[
            # copy // or /// comments prefix or \\ string literal prefix and following whitespace
            execute-keys -save-regs '' k x1s^\h*((///?|\\\\)+\h*)<ret> y
            try %[
                # if the previous comment isn't empty, create a new one
                execute-keys x<a-K>^\h*//+\h*$<ret> jxs^\h*<ret>P
            ] catch %[
                # if there is no text in the previous comment, remove it completely
                execute-keys d
            ]
        ]

        # trim trailing whitespace on the previous line
        try %[ execute-keys -draft k x s\h+$<ret> d ]
    ]
>

define-command -hidden koka-indent-on-new-line %<
    evaluate-commands -draft -itersel %<
        # preserve indent level
        try %< execute-keys -draft <semicolon> K <a-&> >
        try %<
            # only if we didn't copy a comment or multiline string
            execute-keys -draft x <a-K> ^\h*(//|\\\\) <ret>
            # indent after lines ending in {
            try %< execute-keys -draft k x <a-k> \{\h*$ <ret> j <a-gt> >
            # deindent closing } when after cursor
            try %< execute-keys -draft x <a-k> ^\h*\} <ret> gh / \} <ret> m <a-S> 1<a-&> >
        >
        # filter previous line
        try %< execute-keys -draft k : koka-trim-indent <ret> >
    >
>

define-command -hidden koka-indent-on-closing %<
    # align lone } to indent level of opening line
    try %< execute-keys -draft -itersel <a-h> <a-k> ^\h*\}$ <ret> h m <a-S> 1<a-&> >
>

§
