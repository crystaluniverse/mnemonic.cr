# mnemonic.cr

Crystal lang implementation for [python-mnemonic](https://github.com/trezor/python-mnemonic)

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     mnemonic:
       github: crystaluniverse/mnemonic.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "mnemonic"

en = Mnemonic::Mnemonic.new
# only get seed
seed = en.to_entropy "finger feel food anchor morning benefit stable gesture kiwi tortoise amount glide deputy cake party few canyon title effort gentle route tape gallery over"

# get Signing key from pass phrase directly 
sk = en.get_signing_key "finger feel food anchor morning benefit stable gesture kiwi tortoise amount glide deputy cake party few canyon title effort gentle route tape gallery over"

# An example on using signing key to sign a message
id = 40
created = Time.utc.to_unix
expires = created + 1000
headers = %((created): #{created}\n)
headers += %((expires): #{expires}\n)
headers += %((key-id): #{id})

signature = Base64.strict_encode(String.new sk.sign_detached(headers))
```
