class MarkupFields

    # Field regex with capturing groups for name and description
    FIELD_REGEX = /(?<=#\[)([\w\.]+?)(?=\]#).*?(?<=\]#)(.+?)(?=#\[|\z)/im

    Field = Struct.new(:name, :value) do
        def to_s
            "#[#{name}]# #{value}"
        end
    end

    def initialize(markup)
        @markup = markup.to_s
    end

    def fields
        @fields ||= parse
    end

    private

    def markup
        @markup
    end

    def parse
        markup.scan(FIELD_REGEX)
            .map { |match| Field.new(match[0].strip, match[1].strip) }
    end
end
