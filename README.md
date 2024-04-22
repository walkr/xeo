# Xeo

Easily and elegantly generate various seo and social sharing html tags
for your [Phoenix](https://www.phoenixframework.org/)-powered web pages.

```
  seo "/my-page" do
    og_title "My Awesome Page"
    og_image "/images/some-image.jpg"
  end
```

#### Tags Macro Reference

Here are the macros automatically injected, which you can use inside the block supplied
to the `seo` macro:

- `title`
- `description`
- `canonical`
- `og_type`
- `og_title`
- `og_description`
- `og_image`
- `og_site_name`
- `og_url`
- `twitter_card`
- `twitter_site`
- `twitter_title`
- `twitter_description`
- `twitter_url`
- `twitter_image`


## Installation

Add the `xeo` package to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:xeo, "~> 0.1.0"}
  ]
end
```

## Usage

The typical flow involes (1) using the `Xeo` module, (2) invoking the `Xeo.seo/2` macro
to define the tags for each page based on its path, and (3) injecting
the `MyModule.tags(@conn)` function in the root template, inside the `<head>...</head>` tag.

### Example

```elixir
defmodule MyApp.Seo do
  use Xeo
  # Alternatively, `use Xeo, warn: false, pad: 2`

  seo "/awesome" do
    og_title "My Awesome Page"
    og_image "/images/awesome.jpg"
    ...
  end

  seo "/another-page" ...
end
```

Update your `root.html.heex`:

```html
<html lang="en">
  <head>
    ...
    <%= MyApp.Seo.tags(@conn) %>
  </head>
```

Now let's check if it works:

```sh
$ curl localhost:4000/awesome
...
<html>
  <meta property="og:title" content="My Awesome Page" />
  <meta property="og:image" content="/images/awesome.jpg" />
...
```

In the example above we used the `og_title` and `og_image` macros to define the open graph tags for our `/contact` page.

Do note that the above module will contain a `tags/1` function, which accepts
a phoenix connection and returns the tags associated with the page identified
by the connection's path.

### Use Options

When invoking `use Xeo` you can supply additional options:

- `:warn` (boolean) - show compilation time warnings (default true)
- `:pad` (integer) - how much whitespace padding to use for html tags (default 4)


### Formatting

For elegant formatting when using the supplied macros,
you can import `:xeo` in your project's formatter file:


```elixir
# .formatter.exs
[
  ...
  import_deps: [:xeo],
  ...
]
```

## License

Copyright (c) 2024 Tony Walker – MIT License
