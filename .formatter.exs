# Used by "mix format"
[
  import_deps: [:pluggable],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [rpc: 3],
  export: [
    locals_without_parens: [rpc: 3]
  ]
]
