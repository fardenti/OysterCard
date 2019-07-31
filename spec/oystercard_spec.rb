require "oystercard"

describe Oystercard do
  let(:entry_station) {double(:station_name)}
  let(:exit_station) {double(:station_name)}

  context "a journey has been completed" do

    before do
      subject.top_up(10)
      subject.touch_in(entry_station)
      subject.touch_out(exit_station)
    end

    describe '#touch_in' do

      it 'when card touched in, journey starts' do
        subject.top_up(5)
        subject.touch_in(entry_station)
        expect(subject).to be_in_journey
      end
      it 'when card touched out, journey ends' do
        expect(subject).not_to be_in_journey
      end
      it 'raises error when touch out if journey hasnt started yet' do
        expect{subject.touch_out(exit_station)}.to raise_error 'you havent started your journey yet, please touch in card to start journey'
      end
      it 'saves station name' do
        subject.top_up(5)
        subject.touch_in(entry_station)
        expect(subject.entry_station).to eq(entry_station)
      end
    
    end

    describe '#top_up' do

      it 'can top up the balance of card with amount of £5' do
        expect{subject.top_up(5)}.to change {subject.balance}.by 5
      end

    end

    describe '#touch_out' do

      it 'deducts amount from balance' do
        subject.top_up(10)
        subject.touch_in(entry_station)
        expect { subject.touch_out(exit_station) }.to change { subject.balance }.by(-Oystercard::FARE_AMOUNT)
      end

      it 'forgets station entry' do
        expect(subject.entry_station).to eq nil
      end

      it "creates a journey" do
        expect(subject.current_journey).to eq({ :entry => entry_station, :exit => exit_station })
      end

    end

    describe "#journey_history" do
      
      it "returns all past journeys" do
        expect(subject.journey_history).to eq([subject.current_journey])
      end
      
    end

  end

  context "the card has just been initialized" do

    describe "#journey_history" do

      it "is an empty array by default" do
        expect(subject.journey_history).to eq []
      end

    end
    
    describe "#balance" do

      it 'raises error when touch in if balance below MIN_VALUE' do
        expect {subject.touch_in(entry_station)}.to raise_error 'Your card balance is below £1, please top up'
      end

    end
    
    describe "#top_up" do

      it 'raises error if topping up results in exceeding the balance limit of £90' do
        max_limit = Oystercard::MAX_VALUE
        subject.top_up(max_limit)
        expect { subject.top_up 1 }.to raise_error 'top up amount has exceeded limit of £90'
      end

    end

  end

end
