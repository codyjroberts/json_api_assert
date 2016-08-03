defmodule AssertLinksTest do
  use ExUnit.Case
  import JsonApiAssert, only: [assert_links: 1, assert_links: 2]
  import JsonApiAssert.TestData, only: [data: 1]

  @links %{
    "links" => %{
      "self" => "http://example.com/posts"
    }
  }

  @valid_members %{
    "links" => %{
      "related" => %{
        "href" => "http://example.com/articles/1/comments",
        "meta" => %{
          "count" => 10
        }
      }
    }
  }

  @invalid_member_1 %{
    "links" => %{
      "related" => %{
        "invalid" => "member",
        "also_invalid" => "member"
      }
    }
  }

  @invalid_member_2 %{
    "links" => %{
      "invalid" => []
    }
  }

  test "assert will return original payload" do
    payload = Map.merge(data(:payload), @links)

    assert payload == assert_links(payload)
  end

  test "assert will raise when links object is not found" do
    msg = "links object not found"

    try do
      assert_links(data(:payload))
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    else
      _ -> flunk """

      Expected Exception

      #{msg}

      """
    end
  end

  test "assert will raise when links object is not a map" do
    msg = "the value of each links member MUST be an object"

    try do
      Map.merge(data(:payload), %{"links" => []})
      |> assert_links
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    else
      _ -> flunk """

      Expected Exception

      #{msg}

      """
    end

    try do
      Map.merge(data(:payload), %{"links" => ""})
      |> assert_links
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    else
      _ -> flunk """

      Expected Exception

      #{msg}

      """
    end
  end

  test "assert will raise when links object contains an invalid link object" do
    msg = """
    A link MUST be represented as either a string or a map containing only `href` and `meta` objects

    The value for key `invalid` must be a string or map
    """

    try do
      Map.merge(data(:payload), @invalid_member_2)
      |> assert_links
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    else
      _ -> flunk """

      Expected Exception

      #{msg}

      """
    end
  end

  test "assert will raise when link object contains an invalid member" do
    msg = """
    A link MUST be represented as either a string or a map containing only `href` and `meta` objects

    Invalid keys: also_invalid, invalid
    """

    try do
      Map.merge(data(:payload), @invalid_member_1)
      |> assert_links
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    else
      _ -> flunk """

      Expected Exception

      #{msg}

      """
    end
  end

  test "assert will not raise when members match" do
    Map.merge(data(:payload), @valid_members)
    |> assert_links(@valid_members["links"])
  end

  test "assert will raise when members do not match" do
    msg = "Assertion with == failed"

    try do
      Map.merge(data(:payload), @valid_members)
      |> assert_links(Map.merge(@links["links"], @valid_members["links"]))
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    else
      _ -> flunk """

      Expected Exception

      #{msg}

      """
    end
  end
end