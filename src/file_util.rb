require_relative 'waid_exception'

class WaidFile
    def initialize(path)
        if not File.exist?(path)
            puts ":O"
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