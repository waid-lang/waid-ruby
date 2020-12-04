syntax keyword waidKeywords
    \ while
    \ endwl
    \ func
    \ endfn
    \ if
    \ else
    \ endif
    \ record
    \ endrc
    \ instance
    \ and
    \ or
    \ not
    \ true
    \ false
    \ null


syntax keyword waidInclude include

syn keyword waidBuiltin length toStr toNum

syntax match waidNumber "\v<\d+>"
syntax match waidNumber "\v<\d+\.\d+>"

syntax match waidOperator "@\|[/=<>]=\|<\|[=]^>\|\.\|\'\|::\|[!*/%+-]"
syntax match waidComment "#.*$"

syntax region waidString start=+[uU]\=\z(["]\)+ end="\z1" skip="\\\\\|\\\z1"
syntax match waidFunction "!\((\)\=\w*" contains=waidFunctionId,waidFunctionCallOperator
syntax match waidFunctionId "\w*" contained
syntax match waidFunctionCallOperator  "!" contained

syntax match waidFunction "!{\w*" contains=waidRecordId,waidFunctionCallOperator
syntax match waidRecordId "\w*" contained

syntax match waidFunctionDeclaration "\w*: [func\|record]" contains=waidFunctionDeclarationId,waidKeywords
syntax match waidFunctionDeclarationId "\w*:" contained contains=waidFunctionId

highlight default link waidNumber Number
highlight default link waidKeywords Keyword
highlight default link waidInclude Include
highlight default link waidOperator Operator
highlight default link waidFunctionCallOperator Operator
highlight default link waidComment Comment
highlight default link waidString String
highlight default link waidBuiltin Function
highlight default link waidFunctionId Function
highlight default link waidRecordId Function
