# Used by "mix format"
locals_without_parens = [
  title: 1,
  description: 1,
  canonical: 1,
  og_type: 1,
  og_title: 1,
  og_description: 1,
  og_image: 1,
  og_site_name: 1,
  og_url: 1,
  twitter_card: 1,
  twitter_site: 1,
  twitter_title: 1,
  twitter_description: 1,
  twitter_url: 1,
  twitter_image: 1
]

[
  locals_without_parens: locals_without_parens,
  export: [locals_without_parens: locals_without_parens],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
