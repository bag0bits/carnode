# Notes on cardano-cli

## This is mostly how to do stuff vai the cli.

Create a Byron wallet with "address keygen" and "address build". With a byron wallet you can send and recive ADA but that's about it. So not very useful but it's a start

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

### Generate the Shelley address with both payment and stake keys
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
If all that went well you should be able to query the wallet
```
cardano-cli query utxo --testnet-magic 1097911063 --mary-era --address $(cat wallet01-shelley.addr)
```

At this point we should have
* wallet01.vkey wallet verify key
* wallet01.skey wallet signing key
* wallet01.addr byron wallet address
* stake.vkey stake verify key
* stake.skey stake signing key
* stake.addr stake address
* wallet01-shelley.addr wallet address with staking

This is all the parts of a wallet.. you can send and recieve to the address and you can stake with it... well.. you first need some ADAs..

## Send some money to your wallet

So lets send some ada to the address in wallet01-shelley.addr. So lets say i have another wallet with 2000 ADAs with the following files.

* wallet77.vkey
* wallet77.skey
* wallet77.addr #shelley address with no byron address
* stake77.vkey
* stake77.skey
* stake77.addr

we are going to send 100 ADAs to our wallet01-shelley.addr

1 get current slot
```
currentSlot=$(cardano-cli query tip --testnet-magic 1097911063 | jq -r '.slotNo')
```
2 set the ammount to send
```
amountToSend=10000000
```
3 set destination
```
destinationAddress=$(cat wallet01-shelley.addr)
```
4 now we get the balance from the source wallet
```
cardano-cli query utxo --address $(cat wallet77.addr) --mary-era --testnet-magic 1097911063 > fullUtxo.out
tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out
```
```
tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo TxHash: ${in_addr}#${idx}
    echo ADA: ${utxo_balance}
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
done < balance.out
txcnt=$(cat balance.out | wc -l)
echo Total ADA balance: ${total_balance}
echo Number of UTXOs: ${txcnt}
```
