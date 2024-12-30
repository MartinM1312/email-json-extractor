require 'rails_helper'

RSpec.describe JsonExtractor, type: :service do
  describe '.call' do
    let!(:response) { JSON.parse('{ "eventSource": "aws:mq",
    "eventSourceArn": "arn:aws:mq:us-west-2:533019413397:broker:shask-test:b-0f5b7522-2b41-4f85-a615-735a4e6d96b5",
    "messages": [
        {
            "messageID": "ID:b-0f5b7522-2b41-4f85-a615-735a4e6d96b5-2.mq.us-west-2.amazonaws.com-34859-1598944546501-4:12:1:1:3",
            "messageType": "jms/text-message",
            "timestamp": 1599863938941,
            "deliveryMode": 1,
            "correlationID": "",
            "replyTo": "null",
            "destination": {
                "physicalName": "testQueue"
            },
            "redelivered": false,
            "type": "",
            "expiration": 0,
            "priority": 0,
            "data": "RW50ZXIgc29tZSB0ZXh0IGhlcmUgZm9yIHRoZSBtZXNzYWdlIGJvZHkuLi4=",
            "brokerInTime": 1599863938943,
            "brokerOutTime": 1599863938944,
            "properties": { "testKey": "testValue" }
        }
    ] }')}
    context 'when the email has a JSON attachment' do
      let(:eml_path) { Rails.root.join('app/assets/test_files/json_attachment.eml') }

      it 'returns the parsed JSON from the attachment' do
        result = described_class.call(eml_path.to_s)

        expect(result).to eq(response)
      end
    end

    context 'when the email has a direct JSON link in the body' do
      let(:eml_path) { Rails.root.join('app/assets/test_files/direct_json_link.eml') }

      before do
        allow(HTTParty).to receive(:get).with("https://raw.githubusercontent.com/aws/aws-lambda-go/refs/heads/main/events/testdata/activemq-event.json")
          .and_return(double(code: 200, body: '{"foo":"bar"}'))
      end

      it 'returns the parsed JSON from the link' do
        result = described_class.call(eml_path.to_s)
        expect(result).to eq({ "foo" => "bar" })
      end
    end

    context 'when the email has an indirect link leading to a JSON link' do
      let(:eml_path) { Rails.root.join('app/assets/test_files/indirect_json_link.eml') }

      before do
        allow(HTTParty).to receive(:get).with("https://example.com/page.html")
          .and_return(double(code: 200, body: <<~HTML))
            <html><body><a href="final.json">Click for JSON</a></body></html>
          HTML

        allow(HTTParty).to receive(:get).with("https://github.com/aws/aws-lambda-go/blob/main/events/testdata/activemq-event.json")
          .and_return(double(code: 200, body: '{"indirect":"success"}'))
      end

      it 'returns the parsed JSON from the final link' do
        result = described_class.call(eml_path.to_s)
        expect(result).to eq({ "indirect" => "success" })
      end
    end

    context 'when there is no JSON present' do
      let(:eml_path) { Rails.root.join('app/assets/test_files/no_json.eml') }

      it 'returns nil' do
        result = described_class.call(eml_path.to_s)
        expect(result).to be_nil
      end
    end
  end
end
