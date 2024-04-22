defmodule XeoTest do
  use ExUnit.Case
  use Plug.Test
  doctest Xeo

  defmodule MySeo do
    use Xeo, pad: 2

    seo "/" do
      title "some title"
      description "some description"
      canonical "some canonical"

      og_type "website"
      og_title "some title"
      og_description "some description"
      og_image "some image"
      og_site_name "some site_name"
      og_url "some url"

      twitter_card "summary"
      twitter_site "some twitter_site"
      twitter_title "some twitter_title"
      twitter_description "some twitter_description"
      twitter_url "some twitter_url"
      twitter_image "some twitter_image"
    end
  end

  defp trimmed(string) do
    string
    |> String.split("\n")
    |> Enum.filter(fn line -> String.trim(line) != "" end)
    |> Enum.join("\n")
  end

  defp expected() do
    """
      <link rel=\"canonical\" href=\"some canonical\" />
      <meta name=\"description\" content=\"some description\" />
      <meta property=\"og:description\" content=\"some description\" />
      <meta property=\"og:image\" content=\"some image\" />
      <meta property=\"og:site_name\" content=\"some site_name\" />
      <meta property=\"og:title\" content=\"some title\" />
      <meta property=\"og:type\" content=\"website\" />
      <meta property=\"og:url\" content=\"some url\" />
      <title>some title</title>
      <meta property=\"twitter:card\" content=\"summary\" />
      <meta property=\"twitter:description\" content=\"some twitter_description\" />
      <meta property=\"twitter:image\" content=\"some twitter_image\" />
      <meta property=\"twitter:site\" content=\"some twitter_site\" />
      <meta property=\"twitter:title\" content=\"some twitter_title\" />
      <meta property=\"twitter:url\" content=\"some twitter_url\" />
    """
  end

  describe "meta tags" do
    test "good path" do
      {:safe, html} = MySeo.tags(conn(:get, "/"))
      assert trimmed(html) == trimmed(expected())
    end

    test "non-existign path" do
      meta = MySeo.tags(conn(:get, "/bla"))
      assert nil == meta
    end
  end
end
