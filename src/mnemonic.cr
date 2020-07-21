require "openssl"
require "sodium"

class Mnemonic::Mnemonic
  
  RADIX = 2048
  property words : Array(String) 
  def initialize(@lang : String = "en")
    @words = File.read("#{__DIR__}/wordlist/#{@lang}").split.map! {|x| x.strip}
    
    if @words.size != RADIX
      raise Exception.new "Wordlist size must equals #{RADIX}"
    end
  end

  def to_entropy(phrase : String)
    words : Array(String) = phrase.split
    if words.size != 12 && words.size != 15 && words.size != 18 && words.size != 21 && words.size != 24
      raise Exception.new "Number of words must be one of [12, 15, 18, 21, 24]"
    end
    concatLenBits = words.size * 11
    concatBits = [false] * concatLenBits
    
    words.each_index do |i|
      idx = @words.index words[i] 
      if idx.nil?
        raise Exception.new "Can not look up (#{words[i]}) .. not found in dictionary"
      end
      (0..10).to_a.each do |ii|
        concatBits[(i * 11) + ii] = (idx.not_nil! & (1 << (10 - ii))) != 0
      end
    end

    checksumLengthBits = concatLenBits // 33
    entropyLengthBits = concatLenBits - checksumLengthBits
    # Extract original entropy as bytes.
    entropy = Bytes.new(entropyLengthBits // 8, 0)
    
    (0..entropy.size-1).to_a.each do |i|
      (0..7).to_a.each do |n|
        if concatBits[(i * 8) + n]
          entropy[i] |= 1 << (7 - n)
        end
      end
    end
    
    hash = OpenSSL::Digest.new("SHA256")
    hashBytes = hash.update(entropy).final
    hashBits = Array(Bool).new

    hashBytes.each do |c|
      (0..7).to_a.each do |i|
          hashBits.push(c & (1 << (7 - i)) != 0)
      end
    end

    # # Check all the checksum bits.
    (0..checksumLengthBits -1).to_a.each do |i |
      if concatBits[entropyLengthBits + i] != hashBits[i]
        raise Exception.new "Failed Checksum"
      end
    end
    return entropy
  end

  def get_signing_key(phrase : String)
    entropy = self.to_entropy(phrase)
    return Sodium::Sign::SecretKey.new seed: entropy
  end
end
