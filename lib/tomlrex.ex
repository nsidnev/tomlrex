defmodule Tomlrex do
  @type reason :: {:invalid_toml, binary} | binary
  @type error :: {:error, reason}

  @spec decode(binary) :: {:ok, map} | error
  defdelegate decode(bin), to: __MODULE__.Decoder

  @spec decode!(binary) :: map | no_return
  defdelegate decode!(bin), to: __MODULE__.Decoder

  @spec decode_file(binary) :: {:ok, map} | error
  defdelegate decode_file(path), to: __MODULE__.Decoder

  @spec decode_file!(binary) :: map | no_return
  defdelegate decode_file!(path), to: __MODULE__.Decoder

  @spec decode_stream(Enumerable.t()) :: {:ok, map} | error
  defdelegate decode_stream(stream), to: __MODULE__.Decoder

  @spec decode_stream!(Enumerable.t()) :: map | no_return
  defdelegate decode_stream!(stream), to: __MODULE__.Decoder
end
