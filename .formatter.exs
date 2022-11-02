[
  import_deps: [:ecto, :phoenix, :ash_postgres],
  inputs: [
    "*.{ex,exs}",
    "priv/*/seeds.exs",
    "{config,lib,test}/**/*.{ex,exs}",
    import_deps: [:ash]
  ],
  subdirectories: ["priv/*/migrations"]
]
