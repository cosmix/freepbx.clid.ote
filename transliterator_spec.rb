require_relative 'Transliterator'

describe Transliterator do
  it 'transliterates greek capitals to latin' do
    input = 'ΕΛΛΗΝΙΚΑ'
    expect(Transliterator.grToLat(input)).to eq 'Ellinika'
  end

  it 'handles empty strings properly' do
    input = ''
    expect(Transliterator.grToLat(input)).to eq ''
  end

  it 'handles latin strings properly' do
    input = 'Latin'
    expect(Transliterator.grToLat(input)).to eq 'Latin'
  end

  it 'properly Capitalises strings' do
    input = 'ελληνικα'
    expect(Transliterator.grToLat(input)).to eq 'Ellinika'
  end

  it 'properly handles mixed strings (latin and greek)' do
    input = 'ελληνικα and english'
    expect(Transliterator.grToLat(input)).to eq 'Ellinika And English'
  end
  
  it 'correctly deals with accented characters' do
    input = 'Ελληνικά'
    expect(Transliterator.grToLat(input)).to eq 'Ellinika'
  end
end
