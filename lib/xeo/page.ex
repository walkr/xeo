defmodule Xeo.Page do
  @moduledoc """
  A structure to hold the html data for a given page.

  ## Page Fields

  ### Basic Tags

  - :title
  - :description
  - :canonical

  ### Open Graph Tags

  - :og_type
  - :og_title
  - :og_description
  - :og_image
  - :og_site_name
  - :og_url

  ### Twitter Cards

  - :twitter_card
  - :twitter_site
  - :twitter_title
  - :twitter_description
  - :twitter_url
  - :twitter_image

  """

  @typedoc """
  The content for a given tag
  """
  @type tag_content :: nil | String.t()

  @type t :: %__MODULE__{
          title: tag_content(),
          description: tag_content(),
          canonical: tag_content(),
          og_type: tag_content(),
          og_title: tag_content(),
          og_description: tag_content(),
          og_image: tag_content(),
          og_site_name: tag_content(),
          og_url: tag_content(),
          twitter_card: tag_content(),
          twitter_site: tag_content(),
          twitter_title: tag_content(),
          twitter_description: tag_content(),
          twitter_url: tag_content(),
          twitter_image: tag_content()
        }

  defstruct [
    # HTML title
    title: nil,

    # HTML meta tags
    description: nil,

    # Canonical link tag
    canonical: nil,

    # Open Graph
    og_type: nil,
    og_title: nil,
    og_description: nil,
    og_image: nil,
    og_site_name: nil,
    og_url: nil,

    # Twitter Card
    twitter_card: nil,
    twitter_site: nil,
    twitter_title: nil,
    twitter_description: nil,
    twitter_url: nil,
    twitter_image: nil
  ]

  defp cleanup(string) when is_binary(string) do
    string
    # Remove whitespace at ends
    |> String.trim()

    # Replace one or more spaces (including new lines) with a single regular whitespace.
    |> (fn s -> Regex.replace(~r/[[:space:]]{1,}/s, s, " ") end).()
  end

  defp pad(count),
    do: String.duplicate(" ", count)

  ## Markup Generators

  defp markup("title", value, pads) when not is_nil(value),
    do: pad(pads) <> "<title>#{cleanup(value)}</title>"

  defp markup("description", value, pads) when not is_nil(value),
    do: pad(pads) <> "<meta name=\"description\" content=\"#{cleanup(value)}\" />"

  defp markup("canonical", value, pads) when not is_nil(value),
    do: pad(pads) <> "<link rel=\"canonical\" href=\"#{cleanup(value)}\" />"

  defp markup("og_" <> key, value, pads) when not is_nil(value),
    do: pad(pads) <> "<meta property=\"og:#{key}\" content=\"#{cleanup(value)}\" />"

  defp markup("twitter_" <> key, value, pads) when not is_nil(value),
    do: pad(pads) <> "<meta property=\"twitter:#{key}\" content=\"#{cleanup(value)}\" />"

  defp markup(_, _, _),
    do: nil

  @doc """
  Generate html tags from the given struct
  """
  @spec html(t(), pos_integer()) :: String.t()
  def html(%__MODULE__{} = page, pad) do
    %__MODULE__{}
    |> Map.keys()
    |> Enum.sort()
    |> Enum.reduce("", fn key, html ->
      line = markup("#{key}", Map.get(page, key), pad)
      if line != nil, do: html <> "\n" <> line, else: html
    end)
  end
end
