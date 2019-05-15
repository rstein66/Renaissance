defmodule Renaissance.Helpers.Validators do
  import Ecto.Changeset
  alias Renaissance.{Auctions, Bids, Helpers}
  alias Renaissance.Helpers.Utils

  def validate_starting_amount(changeset) do
    validate_amount(changeset, :starting_amount, Money.new(0))
  end

  def validate_bid_amount(changeset) do
    minimum =
      get_change(changeset, :auction_id)
      |> get_current_amount()
      |> Helpers.Money.to_money()

    validate_amount(changeset, :amount, minimum)
  end

  defp validate_amount(changeset, field, minimum) do
    proposed = get_change(changeset, field)

    if Helpers.Money.compare(proposed, minimum) in [:lt, :eq] do
      add_error(changeset, field, ~s(must be greater than #{minimum}))
    else
      changeset
    end
  end

  def validate_bidder(changeset, field) do
    bidder_id = get_change(changeset, field)

    seller_id =
      get_change(changeset, :auction_id)
      |> Auctions.get_nonpreloaded()
      |> Utils.extract_key(:seller_id)

    if seller_id == bidder_id do
      add_error(changeset, field, "can't bid on an item you're selling")
    else
      changeset
    end
  end

  def validate_open(changeset, field) do
    id = get_change(changeset, :auction_id)

    if Auctions.exists?(id) and !Auctions.open?(id) do
      add_error(changeset, field, "auction is not open")
    else
      changeset
    end
  end

  defp get_current_amount(auction_id) do
    case Bids.get_highest_bid(auction_id) do
      nil -> Auctions.get_nonpreloaded(auction_id) |> Utils.extract_key(:starting_amount)
      bid -> bid.amount
    end
  end
end
