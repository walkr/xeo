# Xeo

A small library to help with the generation of SEO, Open Graph and Twitter Cards HTML meta tags for [Phoenix](https://www.phoenixframework.org/)-powered apps.

```elixir
  seo "/some-url" do
    description "Some seo-friendly description"

    og_type "website"
    og_title "Some title"
    og_image "/images/some-image.jpg"
    og_site_name "example.com"
    og_description "Some description"
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
    description "Some seo-friendly description"

    og_type "website"
    og_title "Some title"
    og_image "/images/some-image.jpg"
    og_site_name "example.com"
    og_description "Some description"
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
</html>
```

Now let's check if it works:

```sh
$ curl localhost:4000/awesome
...
<html>
  <meta name="description" content="Some seo-friendly description" />
  <meta property="og:type" content="website" />
  <meta property="og:title" content="Some title" />
  <meta property="og:image" content="/images/some-image.jpg" />
  <meta property="og:site_name" content="example.com" />
  <meta property="og:description" content="Some description" />
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

### Limitations

- Xeo does not work with dynamic paths, e.g `/resources/:id`, only with static paths which are known at compile time.

## License

Xeo is open source under the MIT license. See LICENSE for more details.
