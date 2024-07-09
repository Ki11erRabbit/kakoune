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


# number
add-highlighter shared/koka/code/ regex -?(?:0[xX][\da-fA-F]+(?:_[\da-fA-F]+)*(\.[\da-fA-F]+(?:_[\da-fA-F]+)*)?([pP][\-+]?\\d+)?|0[bB][01][01_]*|(?:0|[1-9]\d*)(?:_\d+)*(\.\d+(?:_\d+)*([eE][\-+]?\d+)?)?) 0:value

# wildcard
add-highlighter shared/koka/code/ regex @?_[\w\-@]*[']* 0:Default

# operator
add-highlighter shared/koka/code/ regex [$%&\*\+@!/\\\\^~=\.:\-?\|<>]+ 0:keyword

# minus
add-highlighter shared/koka/code/ regex -(?![$%&\*\+@!/\\\\^~=\.:\-\?\|<>]) 0:keyword

# special
add-highlighter shared/koka/code/ regex %{[{}\(\)\[\];,]} 0:Default

# constructor
add-highlighter shared/koka/code/ regex [@A-Z][\w\-@]*[']* 0:keyword

# identifier
add-highlighter shared/koka/code/ regex @?[a-z][\w\-@]*[']* 0:Default

# qualified identifier
add-highlighter shared/koka/code/ regex ([\\?]?(?:[@a-z][\w\-@]*/#?)+)(@?[a-z][\w\-@]*[']*) 0:Default 1:type

# qualified operator
add-highlighter shared/koka/code/ regex ([\\?]?(?:[@a-z][\w\-@]*/#?)+)(\([^\n\r\)]+\)) 0:keyword 1:type

# qualified constructor
add-highlighter shared/koka/code/ regex ((?:[@a-z][\w\-@]*/#?)+)(@?[A-Z][\w\-@]*[']*) 0:keyword 1:type

# extern id
#add-highlighter shared/koka/code/ regex '(?:c|cs|js|inline)\s+(?:inline\s+)?(?:(?:file|header-file|header-end-file)\s+)?(?=[\\"{]|r#*")' 0:keyword
# broken for some reason

# library id
add-highlighter shared/koka/code/ regex (resume|resume-shallow|rcontext)(?![\w\-?']) 0:keyword

# reserved operator
add-highlighter shared/koka/code/ regex (=|=>|\||\.|:|:=)(?![$%&\*\+!/\\\\^~=\.:\-?\|<>]) 0:keyword
add-highlighter shared/koka/code/ regex (<)(-)(?![$%&\*\+!/\\^~=\.:\-?\|<>]) 1:red 2:blue
add-highlighter shared/koka/code/ regex (-)(>)(?![$%&\*\+!/\\^~=\.:\-?\|<>]) 1:blue 2:red

# reserved control
add-highlighter shared/koka/code/ regex (if|then|else|elif|match|return)(?![\w\-']) 0:keyword

# reserved id
add-highlighter shared/koka/code/ regex %{(return(?:\s*\(?\w[\w\-]*\s*\)?[^;]|)|infix|infixr|infixl|type|co|rec|struct|alias|forall|exists|some|extern|fun|fn|val|var|con|with(?:\s+override)?|module|import|as|in|ctx|hole|pub|abstract|effect|named|(?:raw\s+|final\s+)ctl|break|continue|unsafe|mask(?:\s+behind)?|handle|handler)(?![\w\-'])} 0:keyword

# dot
add-highlighter shared/koka/code/ regex \. 0:Default

# branch
#add-highlighter shared/koka/code/ regex '(finally|initially)\s*(?=->|[{\(])' 0:keyword
# above is broken for some reason

# import id2
add-highlighter shared/koka/code/ regex (import)(\s+(([a-z][\w\-]*/)*[a-z][\w\-]*)) 0:keyword 2:type

# import id
add-highlighter shared/koka/code/ regex (import)(\s+(([a-z][\w\-]*/)*[a-z][\w\-]*)(\s+(=)(\s+(([a-z][\w\-]*/)*[a-z][\w\-]*))?)) 0:orange 2:type 5:red 7:green

# module id
add-highlighter shared/koka/code/ regex (module)\s*((interface)?)\s*(([a-z][\w\-]*/)*[a-z][\w\-]*) 0:type 1:blue 2:type

# decl param
add-highlighter shared/koka/code/ regex ([a-z][\w\-]*[']*)\s*(?=:) 0:type

# decl hover implicit
#add-highlighter shared/koka/code/ regex (\?(?:[@a-z][\w\-@]*/#?)*)([@a-z][\w\-@]*[']*|\([$%&\*\+@!/\\\\^~=\.:\-?\|<>]+\))(?=\s*[=]) 1:red 2:green

# decl hover expr
#add-highlighter shared/koka/code/ regex ^expr 0:Default

# decl var
add-highlighter shared/koka/code/ regex (var)\s+([a-z][\w\-]*[']*|\([$%&\*\+@!/\\\\^~=\.:\-?\|<>]+\)) 1:keyword 2:type 3:type

# decl val
add-highlighter shared/koka/code/ regex ((?:(?:inline|noinline)\s+)?val)\s+((?:[@a-z][\w\-@]*/#?)*)([@a-z][\w\-@]*[']*|\([$%&\*\+@!/\\\\^~=\.:\-?\|<>]+\))? 1:keyword 2:type 3:type

# decl toplevel val
add-highlighter shared/koka/code/ regex (^(?:(?:inline|noinline)\s+)?val)\s+((?:[@a-z][\w\-@]*/#?)*)([@a-z][\w\-@]*[']*|\([$%&\*\+@!/\\\\^~=\.:\-?\|<>]+\))? 1:keyword 2:type 3:type

# decl external
add-highlighter shared/koka/code/ regex ((?:(?:inline|noinline)\s+)?(?:(?:fip|fbip)\s+)?extern)\s+((?:[@a-z][\w\-@]*/#?)*)([@a-z][\w\-@]*[']*|\([$%&\*\+@!/\\\\^~=\.:\-?\|<>]+\)|\[\]|"[^\s"]+")? 1:keyword 2:type 3:magenta

# decl external import
add-highlighter shared/koka/code/ regex (extern\s+import) 0:keyword

# decl function
add-highlighter shared/koka/code/ regex ((?:(?:inline|noinline)\s+)?(?:tail\s+)?(?:(?:fip|fbip)(?:\(\d+\))?\s+)?(?:fun|fn|ctl|ret))\s+((?:[@a-z][\w\-@]*/#?)*)([@a-z][\w\-@]*[']*|\([$%&\*\+@!/\\\\^~=\.:\-?\|<>]+\)|\[\]|"[^\s"]+") 0:keyword 1:orange 2:type 3:magenta

# top type quantifier
# TODO add

# top type struct
# TODO add

# top type type
#add-highlighter shared/koka/top_type_type region %<(alias)\s+([a-z][\w\-]+)> (?=[,\){}\[\];"`A-Z]|(infix|infixr|infixl|inline|noinline|fip|fbip|tail|type|co|rec|linear|alias|effect|context|ambient|extern|fn|fun|function|val|var|con|if|then|else|elif|match|inject|mask|named|handle|handler|return|module|import|as|pub|abstract)(?![\w\-?'])) group
#add-highlighter shared/koka/top_type_type/ fill error

# type app
# TODO add

# character escape
add-highlighter shared/koka/code/ regex (')(\\([abfnrtv0"'\?]|x[\da-fA-F]{2}|u[\da-fA-F]{4}|U[\da-fA-F]{6}))(') 1:string 2:value 3:value 4:string

# character
add-highlighter shared/koka/code/ regex "'[^'\\$]'" 0:string

# raw string2
add-highlighter shared/koka/rawstring2 region r##" %{"##} group
add-highlighter shared/koka/rawstring2/ fill string
add-highlighter shared/koka/rawstring2/ regex [^"]+ 0:string
add-highlighter shared/koka/rawstring2/ regex %{"(?!##)} 0:string

# raw string1
add-highlighter shared/koka/rawstring1 region r#" %{"#} group
add-highlighter shared/koka/rawstring1/ fill string
add-highlighter shared/koka/rawstring1/ regex [^"]+ 0:string
add-highlighter shared/koka/rawstring1/ regex %{"(?!#)} 0:string

# raw strings
add-highlighter shared/koka/rawstring region r" %{"} group
add-highlighter shared/koka/rawstring/ fill string
add-highlighter shared/koka/rawstring/ regex [^"]+ 0:string

# string
add-highlighter shared/koka/string region '"' '"|$' group
add-highlighter shared/koka/string/ fill string
add-highlighter shared/koka/string/ regex ([^"\\\\]|\\\\.)+$ 0:string
add-highlighter shared/koka/string/ regex [^"\\\\]+ 0:string
add-highlighter shared/koka/string/ regex \\\\([abfnrtvz0\\\\"'\?]|x[\da-fA-F]{2}|u[\da-fA-F]{4}|U[\da-fA-F]{6}) 0:string

# block comment
add-highlighter shared/koka/block_comment region /\* \*/ group
add-highlighter shared/koka/block_comment/ fill comment
add-highlighter shared/koka/block_comment/ regex `(:[^`\n]+)` 0:type
add-highlighter shared/koka/block_comment/ regex %{`(module [^`\n]+)`} 0:meta
add-highlighter shared/koka/block_comment/ regex `+([^`\n]*)`+ 0:comment
add-highlighter shared/koka/block_comment/ regex \*([^\*]*)\* 0:meta
add-highlighter shared/koka/block_comment/ regex _([^_]*)_ 0:meta

# line directive
add-highlighter shared/koka/code/ regex ^\s*#.*$ 0:meta

# line comment
add-highlighter shared/koka/comment region '//' '$' group
add-highlighter shared/koka/comment/ fill comment
add-highlighter shared/koka/comment/ regex `(:[^`\n]+)` 0:type
add-highlighter shared/koka/comment/ regex %{`(module [^`\n]+)`} 0:meta
add-highlighter shared/koka/comment/ regex `+([^`\n]*)`+ 0:comment
add-highlighter shared/koka/comment/ regex \*([^\*]*)\* 0:meta
add-highlighter shared/koka/comment/ regex _([^_]*)_ 0:meta




# invalid character
#add-highlighter shared/koka/code/ regex %{'([^'\\\\\n]|\\\\(.|x..|....|U......))'|'$|''?} 1:error

# library operator
#add-highlighter shared/koka/code/ regex (!)(?![$%&\*\+@!/\\^~=\.:\-?\|<>]) 0:red


# param identifier
#add-highlighter shared/koka/code/ regex ([^]\s+)?(\?[?]?\s*)?([@a-z][\w\-@]*[']*)\s*(?=[:,\)]) 0:Default 1:Default 2:Default 3:type

# type variable
#add-highlighter shared/koka/code/ regex ([_]?[a-z][0-9]*|_[\w\-]*[']*|self)(?!\w) 0:red
# seems to be highlighting the wrong areas

# type identifier
#add-highlighter shared/koka/code/ regex [$]?[@a-z][\w\-@]*[']* 0:keyword

# type qualified identifier
#add-highlighter shared/koka/code/ regex ([@a-z][\w\-@]*[']*/#?)+ 0:type

# type parameter
#add-highlighter shared/koka/code/ regex ([\^]\s+)?((?:\?\??\s*)?[@a-z][\w\-@]*'*)\s*(?=:[^:]) 0:red 1:red 2:type

# type implicit parameter
#add-highlighter shared/koka/code/ regex (\?(?:[@a-z][\w\-@]*/#?)*)(([@a-z][\w\-@]*'*|\([$%&\*\+@!/\\^~=.\-?\|<>]+\)))\s*(?=:[^:]) 1:Default 2:type

# type kind
#add-highlighter shared/koka/code/ regex [A-Z](?![\w\-]) 0:red

# top type
#add-highlighter shared/koka/top_type region (:(?![$%&\*\+@!\\^~=\.:\-\|<>]))|(where|iff|when)(?![\w\-]) %<(?=[,\({}\[\]=;"A-Z]|  |(infix|infixr|infixl|inline|noinline|fip|fbip|tail|value|ref|open|extend|rec|co|type|linear|effect|context|ambient|alias|extern|fn|fun|function|val|raw|final|ctl|var|con|if|then|else|elif|match|inject|mask|named|handle|handler|return|module|import|as|pub|abstract)(?![\w\-?']))> group
#add-highlighter shared/koka/top_type/ fill red
#add-highlighter shared/koka/top_type/ regex # put type_content_top here

# top type struct args
# TODO add

# top type quantifier
# TODO add

# type content
# TODO add



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
