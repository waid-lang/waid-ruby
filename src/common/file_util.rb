require_relative 'waid_exception'

class WaidFile
    attr_accessor :line_indexes
    def initialize(path)
        if not File.exist?(path)
            raise WaidError.new("File '#{File.basename(path)}' doesn't exist.")
        end
        @file_path = path
        @source = File.read(path)
        @line_indexes = Array.new.push(0)
    end

    def get_filename
        File.basename(@file_path)
    end

    def [](i)
        @source[i]
    end
end