# Testnet Stuff

This is mostly how to do stuff vai the cli

## Create a Byron wallet with "address keygen" and then 

```
cardano-cli address key-gen \
  --verification-key-file wallet01.vkey \
  --signing-key-file wallet01.skey
```

This will create 2 files
* wallet01.vkey the verifying key 
* wallet01.skey the signing key

cardano-cli address build \
  --payment-verification-key-file wallet01.vkey
  --out-file wallet01.addr
  --testnet-magic 1097911063
