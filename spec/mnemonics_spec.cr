require "./spec_helper"
require "base64"

describe Mnemonic::Mnemonic do

  it "works" do
    en = Mnemonic::Mnemonic.new
    en.to_entropy "finger feel food anchor morning benefit stable gesture kiwi tortoise amount glide deputy cake party few canyon title effort gentle route tape gallery over"
    sk = en.get_signing_key "finger feel food anchor morning benefit stable gesture kiwi tortoise amount glide deputy cake party few canyon title effort gentle route tape gallery over"
    
    id = 40
    created = Time.utc.to_unix
    expires = created + 1000
    headers = %((created): #{created}\n)
    headers += %((expires): #{expires}\n)
    headers += %((key-id): #{id})

    signature = Base64.strict_encode(String.new sk.sign_detached(headers))
    auth_header = %(Signature keyId="#{id}",algorithm="hs2019",created="#{created}",expires="#{expires}",headers="(created) (expires) (key-id)",signature="#{signature}")
    puts auth_header

  end
end
