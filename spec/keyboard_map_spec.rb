RSpec.describe KeyboardMap do
  it "has a version number" do
    expect(KeyboardMap::VERSION).not_to be nil
  end

  let(:alpha) { ("a".."z").to_a.join.freeze }
  let(:kb) { KeyboardMap.new }

  context "#call" do
    specify "if passed a-z, it returns an array containing a string containing 'a'..'z'" do
      expect(kb.call(alpha)).to eq([alpha])
    end

    specify 'if passed "\e[6~", it returns :page_down' do
      expect(kb.call("\e[6~")).to eq([:page_down])
    end

    specify 'if passed "\e", it returns an empty array (incomplete escape)' do
      expect(kb.call("\e")).to eq([])
    end

    specify 'if passed "\e3" it returns an array of KeyboardMap::Event with modifiers :meta, and key "3"' do
      r = kb.call("\e3")
      expect(r).to eq([KeyboardMap.event("3",:meta)])
      expect(r.first.modifiers).to eq(Set[:meta])
      expect(r.first.key).to eq("3")
    end

    specify 'if passed "\e3" it returns a an array containing something comparable to :meta_3' do
      expect(kb.call("\e3").first).to eq(:meta_3)
    end

    specify 'if passed "\e\e", it returns [:esc]' do
      expect(kb.call("\e\e")).to eq([:esc])
    end

    specify 'if passed "\e[Z" it returns something that matches [:shift_tab]' do
      expect(kb.call("\e[Z")).to eq([:shift_tab])
    end

    specify 'if passed "\e[Z" what is returned is actually an Event with modifiers Set[:shift] and key :tab' do
      expect(kb.call("\e[Z")).to eq([KeyboardMap.event(:tab,:shift)])
    end
  end
end
