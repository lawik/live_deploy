defmodule LiveDeployTest do
  use ExUnit.Case
  doctest LiveDeploy

  test "greets the world" do
    assert LiveDeploy.hello() == :world
  end
end
