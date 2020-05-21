defmodule Tomlrex.Native do
  use Rustler, otp_app: :tomlrex, crate: :tomlrex

  def decode(_bin), do: error()

  defp error, do: :erlang.nif_error(:nif_not_loaded)
end
