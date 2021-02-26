# Notes on cardano-cli

This is mostly how to do stuff vai the cli.

## Create a Byron wallet with "address keygen" and "address build". With a byron wallet you can send and recive ADA but that's about it. So not very useful but it's a start

*WARNING* *WARNING* this will create two wallet key files at currnet directory and will overwrite anything with that name so please be careful. 

```
cardano-cli address key-gen \
  --verification-key-file wallet01.vkey \
  --signing-key-file wallet01.skey
```

This will create 2 files
* wallet01.vkey the verifying key 
* wallet01.skey the signing key

*WARNING* *WARNING* same warning as above.. This will create a wallet01.addr file and will overwirte if exsit in current directory.

```
cardano-cli address build \
  --payment-verification-key-file wallet01.vkey \
  --out-file wallet01.addr \
  --testnet-magic 1097911063
```
you will now have a wallet01.addr file with the address of your wallet that you can send ada to.. cool!

Example byron address
```
addr_test1vq4xge2xqmm67lle8urn9ejlkv0gfgrnhucgqnwgg5yykwq682a83
```
We can do better than just holding ADAs.. lets make it a shelley address using "stake-address key-gen" to gen the keypair and "stake-address build" to get the stake address. With a shelley address you can now stake your ada. but first we need to create a stake address. (*WARNING* bla bla creating 2 files will delete..)
## Creating a stake address for our byron wallet
```
 cardano-cli stake-address key-gen \
  --verification-key-file stake.vkey \
  --signing-key-file stake.skey
```
Now using the stake keys we can create a stake address
```
cardano-cli stake-address build \
  --stake-verification-key-file stake.vkey \
  --out-file stake.addr \
  --testnet-magic 1097911063
```
Example stake address
```
stake_test1uz07gqs44t3qr5ktmp9qseqfzusvv8epva9xyxsdz0h9jnc3335hx
```
## Byron wallet + Stake address = Shelley address

# Generate the Shelley address with both payment and stake keys
```
cardano-cli address build \
  --payment-verification-key-file wallet01.vkey \
  --stake-verification-key-file stake.vkey \
  --out-file wallet01-shelley.addr \
  --testnet-magic 1097911063
```
Example Shelley address
```
addr_test1qq4xge2xqmm67lle8urn9ejlkv0gfgrnhucgqnwgg5yykwylusppt2hzq8fvhkz2ppjqj9eqcc0jze62vgdq6ylwt98swh5q86
```
