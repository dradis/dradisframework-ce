require_relative "../../../lib/text-processing/markup_fields"

describe MarkupFields do
    describe MarkupFields::Field do
        describe '#to_s' do
            it 'returns the correct string format' do
                field = MarkupFields::Field.new('Description', 'This is a description!')
                expect(field.to_s).to eq('#[Description]# This is a description!')
            end
        end
    end

    subject { MarkupFields.new('') }

    context 'before initialization' do
        it 'has a constructor that accepts 1 argument' do
            expect(MarkupFields).to respond_to(:new).with(1).argument
        end
    end

    context 'when successfully initialized' do
        it 'has an interface that responds to messages' do
            expect(subject).to respond_to(:fields)
        end

        describe '#fields' do
            it 'matches final field when line ends in newline' do
                markup = <<~DOC
                #[Title]# Here is a description of the first field.
                #[Description]# Describing the describe! Sweet!

                DOC

                markup_fields = MarkupFields.new(markup)
                last_field = markup_fields.fields.last

                expect(last_field).to eq(MarkupFields::Field.new('Description', 'Describing the describe! Sweet!'))
            end

            it 'matches final field when line ends in end of string' do
                markup = '#[Title]# Here is a description of the first field.\n#[Description]# Describing the describe! Sweet!'

                markup_fields = MarkupFields.new(markup)
                last_field = markup_fields.fields.last

                expect(last_field).to eq(MarkupFields::Field.new('Description','Describing the describe! Sweet!'))
            end

            it 'matches final field when match is between #[ and #]'
            it 'matches two fields on one line'
            it 'matches two fields on separate lines'
            it 'returns an array when one match is present'
            it 'strips leading and trailing whitespace from matches' do
               markup = '#[Title]# Description for a title    ' 
               
               markup_fields = MarkupFields.new(markup)
               first = markup_fields.fields.first

               expect(first.name).to eq('Title')
               expect(first.value).to eq('Description for a title')
            end
        end
    end
end
