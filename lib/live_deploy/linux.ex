defmodule LiveDeploy.Linux do
  def find_processes!(install_dir) do
    {processes, 0} = System.cmd("ps", ["-a -u -o pid= -o command="])

    processes
    |> Stream.map(fn proc ->
      [pid, command] = String.split(proc, " ", parts: 2)
      {dir, 0} = Sytem.cmd("readlink", ["/proc/#{pid}/cwd"])
    end)
    |> Stream.filter(fn [pid, command] ->
      String.contains?(command, install_dir)
    end)
    |> Map.new()
  end
end
