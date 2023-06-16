defmodule LiveDeploy.Variant do
  @callback init(opts :: term) :: {:ok, state :: term} | {:error, reason :: term}
  @callback handle_signal(signal :: term, state :: term) ::
              {:fetch, info :: term, state :: term} | :ignore | {:error, reason :: term}
  @callback check(state :: term) :: {:fetch, info :: term, state :: term} | :nothing
  @callback fetch(info :: term, state :: term) ::
              {:ok, fetched :: term, state :: term} | {:error, reason :: term}
  @callback unwrap(fetched :: term, state :: term) ::
              {:ok, fetched :: term, state :: term} | {:error, reason :: term}
  @callback release_archive_path(fetched :: term) :: binary()
  @callback label(fetched :: term) :: nil | binary()
end
