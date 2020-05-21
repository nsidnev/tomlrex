defmodule Tomlrex.Decoder do
  def decode(bin) when is_binary(bin) do
    with {:ok, result} <- Tomlrex.Native.decode(bin) do
      {:ok, replace_datetime(result)}
    end
  end

  def decode!(bin) when is_binary(bin) do
    with {:ok, result} <- decode(bin) do
      result
    else
      {:error, reason} ->
        raise Tomlrex.Error, message: "unable to decode toml: #{inspect(reason)}"
    end
  end

  def decode_file(path) when is_binary(path) do
    with {:ok, bin} <- File.read(path) do
      decode(bin)
    else
      {:error, reason} ->
        {:error, "unable to open file '#{Path.relative_to_cwd(path)}': #{inspect(reason)}"}
    end
  end

  def decode_file!(path) when is_binary(path) do
    with bin <- File.read!(path) do
      decode!(bin)
    end
  end

  def decode_stream(stream), do: decode(Enum.into(stream, <<>>))

  def decode_stream!(stream), do: decode!(Enum.into(stream, <<>>))

  defp replace_datetime(result = %{}) do
    Enum.reduce(result, %{}, fn {key, value}, acc ->
      Map.put(acc, key, replace_datetime(value))
    end)
  end

  defp replace_datetime([result_head | result_tail]) do
    [replace_datetime(result_head)] ++ replace_datetime(result_tail)
  end

  defp replace_datetime({:datetime, date_str}) do
    cond do
      not (date_str =~ "T") ->
        date_or_time_from_str(date_str)

      true ->
        datetime_from_str(date_str)
    end
  end

  defp replace_datetime(item) do
    item
  end

  defp date_or_time_from_str(date_or_time_str) do
    with {:ok, date} <- Date.from_iso8601(date_or_time_str) do
      date
    else
      {:error, :invalid_format} ->
        Time.from_iso8601!(date_or_time_str)
    end
  end

  defp datetime_from_str(datetime_str) do
    naive_dt = NaiveDateTime.from_iso8601!(datetime_str)

    cond do
      datetime_str =~ "Z" ->
        DateTime.from_naive!(naive_dt, "Etc/UTC")

      true ->
        with {:ok, _dt, offset} <- DateTime.from_iso8601(datetime_str) do
          cond do
            offset == 0 ->
              naive_dt

            true ->
              DateTime.from_naive!(NaiveDateTime.add(naive_dt, offset), "Etc/UTC")
          end
        else
          {:error, :missing_offset} -> naive_dt
        end
    end
  end
end
