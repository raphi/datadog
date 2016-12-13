require 'common_log_parser'

describe CommonLogParser do

  describe '.parse' do

    context 'valid logs' do

      let(:logs) {
        [
          '127.0.0.1 user-identifier frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326',
          '202.237.105.218 - - [07/Dec/2016:17:07:06 +0100] "PUT /app/main/posts HTTP/1.0" 200 5050 "http://barrett.org/" "Mozilla/5.0 (Macintosh; PPC Mac OS X 10_6_1) AppleWebKit/5362 (KHTML, like Gecko) Chrome/13.0.845.0 Safari/5362"'
        ]
      }

      it 'returns a valid CommonLog' do
        logs.each do |log|
          result = CommonLogParser.parse(log)

          expect(result).to be_a(CommonLog)
          expect(result.valid?).to be_truthy
        end
      end

    end

    context 'invalid logs' do

      let(:logs) {
        [
          '127.0.0.1 user-identifier frank [-] "GET /apache_pb.gif HTTP/1.0" 200 2326',
          '127.0.0.1 user-identifier frank [10/Oct/2000:13:55:36 -0700] "-" 200 -'
        ]
      }

      it 'returns a invalid CommonLog' do
        logs.each do |log|
          result = CommonLogParser.parse(log)

          expect(result).to be_a(CommonLog)
          expect(result.valid?).to be_falsy
        end
      end

    end

  end

end
