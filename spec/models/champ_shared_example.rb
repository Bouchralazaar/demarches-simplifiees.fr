shared_examples 'champ_spec' do
  describe 'mandatory_blank?' do
    let(:type_de_champ) { build(:type_de_champ, mandatory: mandatory) }
    let(:champ) { build(:champ, type_de_champ: type_de_champ, value: value) }
    let(:value) { '' }
    let(:mandatory) { true }

    context 'when mandatory and blank' do
      it { expect(champ.mandatory_blank?).to be(true) }
    end

    context 'when carte mandatory and blank' do
      let(:type_de_champ) { build(:type_de_champ_carte, mandatory: mandatory) }
      let(:champ) { build(:champ_carte, type_de_champ: type_de_champ, value: value) }
      let(:value) { nil }
      it { expect(champ.mandatory_blank?).to be(true) }
    end

    context 'when multiple_drop_down_list mandatory and blank' do
      let(:type_de_champ) { build(:type_de_champ_multiple_drop_down_list, mandatory: mandatory) }
      let(:champ) { build(:champ_multiple_drop_down_list, type_de_champ: type_de_champ, value: value) }
      let(:value) { '[]' }
      it { expect(champ.mandatory_blank?).to be(true) }
    end

    context 'when repetition blank' do
      let(:type_de_champ) { build(:type_de_champ_repetition) }
      let(:champ) { build(:champ_repetition, type_de_champ: type_de_champ, rows: 0) }

      it { expect(champ.blank?).to be(true) }
    end

    context 'when repetition not blank' do
      let(:type_de_champ) { build(:type_de_champ_repetition) }
      let(:champ) { build(:champ_repetition, type_de_champ: type_de_champ) }

      it { expect(champ.blank?).to be(false) }
    end

    context 'when not blank' do
      let(:value) { 'yop' }
      it { expect(champ.mandatory_blank?).to be(false) }
    end

    context 'when not mandatory' do
      let(:mandatory) { false }
      it { expect(champ.mandatory_blank?).to be(false) }
    end

    context 'when not mandatory or blank' do
      let(:value) { 'u' }
      let(:mandatory) { false }
      it { expect(champ.mandatory_blank?).to be(false) }
    end
  end

  context "when type_champ=date" do
    let(:champ) { build(:champ_date) }

    it "should convert %d/%m/%Y format to ISO" do
      champ.value = "31/12/2017"
      champ.save
      champ.reload
      expect(champ.value).to eq("2017-12-31")
    end

    it "should convert to nil if date parse failed" do
      champ.value = "bla"
      champ.save
      champ.reload
      expect(champ.value).to be(nil)
    end

    it "should convert empty string to nil" do
      champ.value = ""
      champ.save
      champ.reload
      expect(champ.value).to be(nil)
    end
  end
end
