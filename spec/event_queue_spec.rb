require 'event_queue'
require 'common_log'

describe EventQueue do

  subject(:event_queue) { EventQueue.new(hits_alert_threshold: 5) }
  let(:common_log) { CommonLog.new('127.0.0.1', '-', '-', nil, nil, 200, 42) }

  describe '#check_alerts' do

    context 'given an empty pipeline' do
      before { event_queue.send(:check_alerts) }

      it 'returns no error' do
        expect(event_queue.alerts).to be_empty
      end

    end

    context 'given a full pipeline' do
      before {
        10.times { event_queue.push(event: common_log) }
        event_queue.send(:check_alerts)
      }

      it 'creates only one alert' do
        expect(event_queue.alerts.size).to eq(1)
        expect(event_queue.alerts.first).to be_a(HighTrafficAlert)
      end

      context 'going back under the hits alert threshold' do
        before {
          queue = event_queue.instance_variable_get(:@queue)
          event_queue.instance_variable_set(:@queue, queue.slice(0, 4))
          event_queue.send(:check_alerts)
        }

        it 'creates an end of alert' do
          expect(event_queue.alerts.size).to eq(2)
          expect(event_queue.alerts.last).to be_a(EndHighTrafficAlert)
        end

        it 'creates only one alert for multiple calls' do
          5.times { event_queue.send(:check_alerts) }

          expect(event_queue.alerts.size).to eq(2)
        end
      end
    end
  end

  describe '#push' do

    it 'adds the event to the queue' do
      event_queue.push(event: common_log)
      queue = event_queue.instance_variable_get(:@queue)

      expect(queue.size).to eq(1)
      expect(queue.first).to eq(common_log)
    end

  end

  describe '#last' do

    context 'given a full pipeline' do
      before {
        10.times do |index|
          common_log = CommonLog.new('127.0.0.1', '-', '-', nil, nil, 200, index)
          event_queue.push(event: common_log)
        end
      }

      it 'returns the two last elements' do
        results = event_queue.last(2)

        expect(results.size).to eq(2)
        expect(results.first.bytes).to eq(8)
        expect(results.last.bytes).to eq(9)
      end

      it 'returns an empty array' do
        results = event_queue.last(0)

        expect(results).to be_a(Array)
        expect(results.size).to eq(0)
      end

      it 'returns a maximum of elements' do
        results = event_queue.last(42)

        expect(results.size).to eq(10)
      end

    end

  end

  describe '#flush' do

    context 'given old events in the pipeline' do
      before {
        5.times {
          # Old events
          date = (DateTime.now - 5).strftime(format = '%e/%b/%Y:%H:%M:%S %z')
          common_log = CommonLog.new('127.0.0.1', '-', '-', date.to_s, nil, 200, 42)
          event_queue.push(event: common_log)
        }
        10.times {
          # Fresh events
          date = DateTime.now.strftime(format = '%e/%b/%Y:%H:%M:%S %z')
          common_log = CommonLog.new('127.0.0.1', '-', '-', date.to_s, nil, 200, 42)
          event_queue.push(event: common_log)
        }
      }

      it 'removes events older than the set threshold' do
        queue = event_queue.instance_variable_get(:@queue)

        expect(queue.size).to eq(15)

        event_queue.flush()

        expect(queue.size).to eq(10)
      end

    end

  end

end
