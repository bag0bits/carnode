# Notes on cardano-cli

This is mostly how to do stuff vai the cli

## Create a Byron wallet with "address keygen" and "address build". With a byron wallet you can send and recive ADA but that's about it. So not very useful but it's a start

```
cardano-cli address key-gen \
  --verification-key-file wallet01.vkey \
  --signing-key-file wallet01.skey
```

This will create 2 files
* wallet01.vkey the verifying key 
* wallet01.skey the signing key

```
cardano-cli address build \
  --payment-verification-key-file wallet01.vkey
  --out-file wallet01.addr
  --testnet-magic 1097911063
```
you will now have a wallet01.addr file with the address of your wallet that you can send ada to.. cool!

