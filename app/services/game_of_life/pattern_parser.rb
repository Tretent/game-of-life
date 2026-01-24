module GameOfLife
  class PatternParser
    class ParseError < StandardError; end

    def initialize(content)
      @content = content.to_s # in case is not yet a string
    end

    def parse
      lines = @content.lines.map(&:chomp)
      raise ParseError, "File is empty" if lines.empty?

      generation = parse_generation_header(lines[0])
      rows, columns = parse_dimensions(lines[1])
      grid = parse_grid(lines[2..], rows, columns)

      {
        generation: generation,
        rows: rows,
        columns: columns,
        grid: grid
      }
    end

    def self.parse(content)
      new(content).parse
    end

    def self.parse_file(file)
      raise ParseError, "No file provided" if file.nil?

      content = file.read
      file.rewind if file.respond_to?(:rewind)
      parse(content)
    end

    private

    def parse_generation_header(line)
      match = line&.match(/\AGeneration\s+(\d+):\z/)
      raise ParseError, "Invalid header format. Expected 'Generation N:'" unless match

      generation = match[1].to_i
      raise ParseError, "Generation must be at least 1" if generation < 1
      raise ParseError, "Generation must be less than 1000" if generation >= 1000

      generation
    end

    def parse_dimensions(line)
      match = line&.match(/\A(\d+)\s+(\d+)\z/)
      raise ParseError, "Invalid dimensions format. Expected 'rows columns'" unless match

      rows = match[1].to_i
      columns = match[2].to_i
      raise ParseError, "Rows must be at least 1" if rows < 1
      raise ParseError, "Rows must be less than 100" if rows >= 100
      raise ParseError, "Columns must be at least 1" if columns < 1
      raise ParseError, "Columns must be less than 100" if columns >= 100

      [ rows, columns ]
    end

    def parse_grid(lines, expected_rows, expected_columns)
      raise ParseError, "Grid has #{lines&.length || 0} rows, expected #{expected_rows}" if lines.nil? || lines.length != expected_rows

      lines.map.with_index do |line, index|
        raise ParseError, "Row #{index + 1} has #{line.length} columns, expected #{expected_columns}" if line.length != expected_columns
        raise ParseError, "Row #{index + 1} contains invalid characters (only . and * allowed)" unless line.match?(/\A[.*]+\z/)

        line.chars.map { |char| char == "*" }
      end
    end
  end
end
