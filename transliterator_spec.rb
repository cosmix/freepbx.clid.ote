require_relative 'Transliterator'

describe Transliterator do
  describe '#gr_to_lat' do
    context 'when input is Greek' do
      it 'transliterates capitals to Latin' do
        expect(Transliterator.gr_to_lat('ΕΛΛΗΝΙΚΑ')).to eq 'Ellinika'
      end

      it 'capitalizes transliterated strings' do
        expect(Transliterator.gr_to_lat('ελληνικά')).to eq 'Ellinika'
      end

      it 'handles diphthongs correctly' do
        expect(Transliterator.gr_to_lat('ευχαριστώ')).to eq 'Efcharisto'
        expect(Transliterator.gr_to_lat('ευαγγελισμός')).to eq 'Evaggelismos'
      end
    end

    context 'when input is non-Greek' do
      it 'returns the input unchanged for empty strings' do
        expect(Transliterator.gr_to_lat('')).to eq ''
      end

      it 'returns the input unchanged for Latin strings' do
        expect(Transliterator.gr_to_lat('Latin')).to eq 'Latin'
      end

      it 'handles mixed strings (Latin and Greek)' do
        expect(Transliterator.gr_to_lat('ελληνικά and english')).to eq 'Ellinika And English'
      end
    end
  end
end
