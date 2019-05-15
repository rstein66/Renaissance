defmodule Renaissance.Helpers.Utils do
  def extract_key(nil, _), do: nil
  def extract_key(struct, key), do: Map.get(struct, key)
end
