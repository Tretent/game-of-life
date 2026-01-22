require "test_helper"

module GameOfLife
  class PatternParserTest < ActiveSupport::TestCase
    test "parses valid pattern file" do
      content = <<~PATTERN
        Generation 3:
        4 8
        ........
        ....*...
        ...**...
        ........
      PATTERN

      result = PatternParser.parse(content)

      assert_equal 3, result[:generation]
      assert_equal 4, result[:rows]
      assert_equal 8, result[:columns]
      assert_equal 4, result[:grid].length
      assert_equal 8, result[:grid].first.length
    end

    test "correctly parses alive and dead cells" do
      content = <<~PATTERN
        Generation 1:
        2 3
        *.*
        .**
      PATTERN

      result = PatternParser.parse(content)

      assert_equal [ [ true, false, true ], [ false, true, true ] ], result[:grid]
    end

    test "raises error for empty content" do
      assert_raises(PatternParser::ParseError) do
        PatternParser.parse("")
      end
    end

    test "raises error for invalid header format" do
      content = <<~PATTERN
        Invalid Header
        4 8
        ........
      PATTERN

      error = assert_raises(PatternParser::ParseError) do
        PatternParser.parse(content)
      end

      assert_match(/Invalid header format/, error.message)
    end

    test "raises error when generation is less than 1" do
      content = <<~PATTERN
        Generation 0:
        2 2
        ..
        ..
      PATTERN

      error = assert_raises(PatternParser::ParseError) do
        PatternParser.parse(content)
      end

      assert_match(/Generation must be at least 1/, error.message)
    end

    test "raises error when generation is 1000 or more" do
      content = <<~PATTERN
        Generation 1000:
        2 2
        ..
        ..
      PATTERN

      error = assert_raises(PatternParser::ParseError) do
        PatternParser.parse(content)
      end

      assert_match(/Generation must be less than 1000/, error.message)
    end

    test "raises error when rows is 100 or more" do
      rows = "." * 10
      grid = ([ rows ] * 100).join("\n")
      content = "Generation 1:\n100 10\n#{grid}"

      error = assert_raises(PatternParser::ParseError) do
        PatternParser.parse(content)
      end

      assert_match(/Rows must be less than 100/, error.message)
    end

    test "raises error when columns is 100 or more" do
      row = "." * 100
      content = "Generation 1:\n2 100\n#{row}\n#{row}"

      error = assert_raises(PatternParser::ParseError) do
        PatternParser.parse(content)
      end

      assert_match(/Columns must be less than 100/, error.message)
    end

    test "raises error for invalid dimensions format" do
      content = <<~PATTERN
        Generation 1:
        invalid
        ........
      PATTERN

      error = assert_raises(PatternParser::ParseError) do
        PatternParser.parse(content)
      end

      assert_match(/Invalid dimensions format/, error.message)
    end

    test "raises error when row count does not match" do
      content = <<~PATTERN
        Generation 1:
        3 4
        ....
        ....
      PATTERN

      error = assert_raises(PatternParser::ParseError) do
        PatternParser.parse(content)
      end

      assert_match(/2 rows, expected 3/, error.message)
    end

    test "raises error when row count is 0" do
      content = <<~PATTERN
        Generation 1:
        3 4
      PATTERN

      error = assert_raises(PatternParser::ParseError) do
        PatternParser.parse(content)
      end

      assert_match(/0 rows, expected 3/, error.message)
    end

    test "raises error when column count does not match" do
      content = <<~PATTERN
        Generation 1:
        2 4
        ....
        ...
      PATTERN

      error = assert_raises(PatternParser::ParseError) do
        PatternParser.parse(content)
      end

      assert_match(/3 columns, expected 4/, error.message)
    end

    test "raises error when column count does not match in the middle" do
      content = <<~PATTERN
        Generation 1:
        3 4
        ....
        .....
        ....
      PATTERN

      error = assert_raises(PatternParser::ParseError) do
        PatternParser.parse(content)
      end

      assert_match(/5 columns, expected 4/, error.message)
    end

    test "parses file upload" do
      content = <<~PATTERN
        Generation 1:
        2 2
        *.
        .*
      PATTERN

      file = StringIO.new(content)
      result = PatternParser.parse_file(file)

      assert_equal 1, result[:generation]
      assert_equal 2, result[:rows]
      assert_equal 2, result[:columns]
    end

    test "raises error when file is nil" do
      error = assert_raises(PatternParser::ParseError) do
        PatternParser.parse_file(nil)
      end

      assert_match(/No file provided/, error.message)
    end
  end
end
