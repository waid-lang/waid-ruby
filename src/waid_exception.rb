class WaidError
    attr_reader :msg
    def initialize(msg, prefix="Error")
        super
        @msg = make_message(msg, prefix)
    end

    def make_message(m, p)
        puts "#{p}: #{m}"
    end
end