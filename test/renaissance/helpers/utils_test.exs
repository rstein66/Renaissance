defmodule Renaissance.Test.UtilsTest do
  use Renaissance.DataCase
  alias Renaissance.{Auctions, Helpers, Users}
  alias Renaissance.Helpers.Utils

  @seller_params %{email: "seller@seller.com", password: "password"}

  def fixture(:seller) do
    {:ok, seller} = Users.insert(@seller_params)
    seller
  end

  def fixture(:auction, seller_id) do
    auction_params = %{
      "title" => "Test Title",
      "description" => "Test description.",
      "end_auction_at" => %{day: "15", hour: "14", minute: "3", month: "4", year: "3019"},
      "starting_amount" => "10.52"
    }

    {:ok, auction} = Map.put(auction_params, "seller_id", seller_id) |> Auctions.insert()
    auction
  end

  def assert_amount_equal(actual, expected) do
    assert Helpers.Money.compare(actual, expected) == :eq
  end

  describe "extract_key/2" do
    setup do
      seller = fixture(:seller)
      auction = fixture(:auction, seller.id)

      {:ok,
       seller: seller,
       auction: auction,
       retrieved: %{seller: Users.get(seller.id), auction: Auctions.get!(auction.id)}}
    end

    test "returns value when valid key from populated struct", context do
      seller = context[:seller]
      assert Utils.extract_key(seller, :email) == @seller_params.email
      assert Utils.extract_key(seller, :password) == @seller_params.password
    end

    test "returns value when valid key when same struct populated differently ", context do
      auction = context[:auction]
      retrieved = context[:retrieved].auction
      nonpreloaded = Auctions.get_nonpreloaded(context[:auction].id)

      expected_amount = Money.new(10_52)

      assert_amount_equal(Utils.extract_key(auction, :starting_amount), expected_amount)
      assert_amount_equal(Utils.extract_key(retrieved, :starting_amount), expected_amount)
      assert_amount_equal(Utils.extract_key(nonpreloaded, :starting_amount), expected_amount)
    end

    test "returns expected value for valid key in struct retrieved from db", context do
      retrieved_seller = context[:retrieved].seller

      assert Utils.extract_key(retrieved_seller, :email) == @seller_params.email

      assert is_nil(Utils.extract_key(retrieved_seller, :password))
    end

    test "returns nil when invalid key from populated struct", context do
      seller_result = Utils.extract_key(context[:seller], :fake_key)
      retrieved_seller_result = Utils.extract_key(context[:retrieved].seller, :fake_key)

      assert is_nil(seller_result)
      assert is_nil(retrieved_seller_result)
    end

    test "returns nil when get key from nil" do
      assert is_nil(Utils.extract_key(nil, :email))
    end
  end
end
