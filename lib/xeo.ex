defmodule Xeo do
  @moduledoc """
  Elegantly generate seo and social tags for your Phoenix app.

  When used, this module will inject the `seo/1` and other macros in your module,
  which you can then use to elegantly define the tags for your pages.

  ## Usage

      defmodule MySeo
        use Xeo
        # OR
        use Xeo, opts
      end

  ### Use Options

    * `:router` (optional):
      Your app's router name which will be used to verify the routes
      if the `:warn` options is set to `true`
      (the defaults to `YourAppsName.Router`)

    * `:warn` (optional):
      A boolean flag which specifies whether to emit compile time warnings
      if the seo macro was not defined for some path. (defaults to `true`)

    * `:pad` (optional):
      An option for formatting the final HTML tags. This option
      specifies how much leading space to add prior to each meta tag
      (defaults to `4` spaces)

  ## Example

      defmodule MyApp.Seo do
          use Xeo
          # use Xeo, warn: false, pad: 2

          seo "/" do
            title "Some page"
            description "Some SEO description"

            og_title "Welcome"
            og_image "https://example.com/image.jpg"
            og_description "Some SEO description"
            ...
          end

          seo "/contact" do
            title: "Contact Us"
            description "Our contact page is awesome"

            og_title "Contact us"
            og_image fn -> Routes.static_path(Endpoint, "/images/image.jpg") end
            og_description "Our contact page"
            ...

            twitter_title: "Contact us"
          end
      end
  """
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      import Xeo
      alias Xeo.Page

      # How much leading whitespace padding to add
      # before each HTML tag line
      @pad Keyword.get(opts, :pad, 4)

      # A flag to emit compile time warnings whenever
      # the `seo/1` function is not implemented for a given path
      @warn Keyword.get(opts, :warn, true)

      # The router used to verify routes
      @router Keyword.get(
                opts,
                :router,
                # Default
                __MODULE__
                |> Module.split()
                |> List.first(1)
                |> Module.concat(Router)
              )

      # We inject a hook to `check_routes/2` after the module
      # is fully compiled.
      Module.register_attribute(__MODULE__, :after_compile, [])
      @after_compile {Xeo, :check_routes}

      @doc false
      def router(), do: @router

      @doc false
      def warn(), do: @warn

      @doc false
      def pad(), do: @pad

      @doc """
      Inject the meta attributes for the current connection's page.
      """
      def tags(conn) do
        try do
          apply(__MODULE__, :seo_for_path, [conn.request_path])
        rescue
          FunctionClauseError ->
            :skip
        end
        |> case do
          %Page{} = page ->
            page
            |> Page.html(pad())
            |> Phoenix.HTML.raw()

          :skip ->
            # No tags will be generated
            nil
        end
      end
    end
  end

  alias Xeo.Page

  @doc """
  A macro for generating a function (named `seo_for_path`)
  that will match on `conn.request_path` and will generate the corresponding meta tags.
  """
  defmacro seo(path, do: tag_macros) do
    quote do
      # Here we define a function that will pattern match
      # against a request path string.
      # --
      # Note that this function will be tried/rescued inside `tags/1`,
      # and when no pattern is matched we will output nothing.
      def seo_for_path(unquote(path)) do
        var!(page) = %Page{}
        unquote(tag_macros)
      end
    end
  end

  # This macro generates the code required to update the `tag` field
  # of a %Page{} struct
  defmacrop gen_page_update_code(tag, value) do
    quote bind_quoted: [tag: tag, value: value] do
      if not is_binary(value) do
        raise "Tag #{tag} has a bad value: `#{inspect(Macro.to_string(value))}`. Value must be known at compile time."
      end

      case __CALLER__.function do
        {:seo_for_path, 1} ->
          quote do
            var!(page) = Map.put(var!(page), unquote(tag), unquote(value))
            var!(page)
          end

        _ ->
          # Tag macro must be used inside `seo/1` macro, the latter which
          # defines a function called `seo_for_path/1`.
          raise "Macro #{inspect(tag)}/1 must be used inside :seo/1 macro."
      end
    end
  end

  # HTML

  @doc false
  defmacro title(value),
    do: gen_page_update_code(:title, value)

  @doc false
  defmacro description(value),
    do: gen_page_update_code(:description, value)

  @doc false
  defmacro canonical(value),
    do: gen_page_update_code(:canonical, value)

  ## TWITTER

  @twitter_cards [
    "summary",
    "summary_large_image",
    "app",
    "player",
    "gallery",
    "product",
    "lead_generation",
    "website"
  ]

  @doc false
  for name <- @twitter_cards do
    defmacro twitter_card(unquote(name)),
      do: gen_page_update_code(:twitter_card, unquote(name))
  end

  defmacro twitter_card(value),
    do:
      raise(%ArgumentError{
        message:
          "Twitter card `#{value}` " <>
            "is an invalid. Supported: #{inspect(@twitter_cards)}."
      })

  @doc false
  defmacro twitter_site(value),
    do: gen_page_update_code(:twitter_site, value)

  @doc false
  defmacro twitter_title(value),
    do: gen_page_update_code(:twitter_title, value)

  @doc false
  defmacro twitter_description(value),
    do: gen_page_update_code(:twitter_description, value)

  @doc false
  defmacro twitter_url(value),
    do: gen_page_update_code(:twitter_url, value)

  @doc false
  defmacro twitter_image(value),
    do: gen_page_update_code(:twitter_image, value)

  ## OPEN GRAPH

  @og_types [
    "music.song",
    "music.album",
    "music.playlist",
    "music.radio_station",
    "video.movie",
    "video.episode",
    "video.tv_show",
    "video.other",
    "article",
    "book",
    "profile",
    "website"
  ]

  @doc false
  for name <- @og_types do
    defmacro og_type(unquote(name)),
      do: gen_page_update_code(:og_type, unquote(name))
  end

  defmacro og_type(value),
    do:
      raise(%ArgumentError{
        message:
          "Open graph type `#{value}` " <>
            " is an invalid. Supported: #{inspect(@og_types)}"
      })

  @doc false
  defmacro og_title(value),
    do: gen_page_update_code(:og_title, value)

  @doc false
  defmacro og_description(value),
    do: gen_page_update_code(:og_description, value)

  @doc false
  defmacro og_image(value),
    do: gen_page_update_code(:og_image, value)

  @doc false
  defmacro og_site_name(value),
    do: gen_page_update_code(:og_site_name, value)

  @doc false
  defmacro og_url(value),
    do: gen_page_update_code(:og_url, value)

  @doc """
  Step over each `GET` route and and check if an seo function was
  defined for it, and if not, optionally show a compilation warning.
  """
  def check_routes(env, _bytecode) do
    try do
      router = apply(env.module, :router, [])
      _check_routes(env, router)
    rescue
      UndefinedFunctionError ->
        nil
    end
  end

  require Logger

  defp _check_routes(env, router) do
    routes =
      router
      # Retrieve the current app's routes
      |> Phoenix.Router.routes()

      # Only look at GET paths
      |> Enum.filter(fn r -> r.verb == :get end)

      # Ignore paths with patterns
      |> Enum.filter(fn r -> not String.contains?(r.path, ":") end)

    # We iterate over each route and perform check the definition
    # and return type
    for route <- routes do
      try do
        try do
          %Page{} = apply(env.module, :seo_for_path, [route.path])
        rescue
          MatchError ->
            raise %CompileError{description: "seo_for_path/1 must return a Page struct."}
        end
      rescue
        FunctionClauseError ->
          case apply(env.module, :warn, []) do
            true ->
              Logger.warning(
                "Missing seo/1 for path #{route.path} inside " <>
                  "#{inspect(Module.safe_concat([env.module]))}"
              )

            false ->
              nil
          end
      end
    end
  end
end
