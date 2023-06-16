defmodule LiveDeploy do
  use GenServer

  require Logger

  @interval 30_000

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  @impl true
  def init(opts) do
    interval = opts[:interval] || @interval
    variant = opts[:variant]
    install_dir = opts[:install_dir]
    {:ok, poll(%{interval: interval, variant: variant, install_dir: install_dir})}
  end

  @impl true
  def handle_info(:poll, state) do
    case state.variant.check() do
      :nothing ->
        {:noreply, poll(state)}

      {:fetch, data, state} ->
        state = do_fetch(data, state)
        {:noreply, state}
    end
  end

  defp do_fetch(data, state) do
    case state.variant.fetch(data, state) do
      {:ok, fetched, state} ->
        do_unwrap(fetched, state)

      {:error, reason} ->
        Logger.error("Error occurred during fetching: #{inspect(reason)}")
        state
    end
  end

  defp do_unwrap(fetched, state) do
    case state.variant.unwrap(fetched, state) do
      {:ok, fetched, state} ->
        do_unpack_release(fetched, state)

      {:error, reason} ->
        Logger.error("Error occurred during unpacking release: #{inspect(reason)}")
        state
    end
  end

  defp do_unpack_release(fetched, state) do
    path = state.variant.release_archive_path(fetched)

    with {:ok, binary} <- File.read(path),
         {:ok, files} <- :erl_tar.extract({:binary, binary}, [:memory, :compressed]) do
      hash = :crypto.hash(:sha256, binary) |> Base.encode16() |> String.downcase()

      dir_name =
        case state.variant.label(fetched) do
          nil ->
            hash

          label ->
            "#{label}-#{hash}"
        end

      target_dir = Path.join(state.install_dir, dir_name)

      files
      |> Enum.map(fn {filename, content} ->
        filepath = Path.join(target_dir, to_string(filename))

        filepath
        |> Path.dirname()
        |> File.mkdir_p!()

        File.write!(filepath, content)
      end)
    end
  end

  defp poll(state) do
    Process.send_after(self(), :poll, state.interval)
  end
end
