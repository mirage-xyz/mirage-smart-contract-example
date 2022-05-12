const hre = require("hardhat");


async function main() {
  const gameItem = await hre.ethers.getContractAt('GameItem', '0x26aFc7805Aa279fB0E806c2bc1e2bF37A70F995d');
  const gameCharacter = await hre.ethers.getContractAt('GameCharacter', '0x10555B832DE7bAD8459d6de1D8E8F5ad990709A0');

  var [account] = await hre.ethers.getSigners();
  account = account.address;
  account = '0x177e68ec74fe65d4484a3c439176f1dda3cb186f';
  console.log('account = ', account)

  let tx = await gameItem.mintBatch(
      account, 
      [
          '0x00010000000000000000000000000000000000000000000000000000000001', //blue hat
          '0x00010000000000000000000000000000000000000000000000000000000002', //red hat
          '0x00020000000000000000000000000000000000000000000000000000000001', //blue shoes
          '0x00020000000000000000000000000000000000000000000000000000000003', //white shoes
          '0x00030000000000000000000000000000000000000000000000000000000002', //red glasses
          '0x00030000000000000000000000000000000000000000000000000000000003', //white glasses
      ],
      [
        1, //blue hat
        2, //red hat
        3, //blue shoes
        4, //white shoes
        5, //red glasses
        6, //white glasses
      ], 
      "0x");
  await tx.wait();
  console.log('game items minted');

  tx = await gameCharacter.safeMint(account);
  await tx.wait();
  console.log('game character minted');
  console.log('transaction hash = ', tx.hash);

  

  tx = await gameItem.setApprovalForAll('0x10555B832DE7bAD8459d6de1D8E8F5ad990709A0', true);
  await tx.wait();
  console.log('game items approved');
  console.log('transaction hash = ', tx.hash);

  return;

  var tokenId = await gameCharacter.tokenOfOwnerByIndex(account, await gameCharacter.balanceOf(account) - 1);
  console.log('minted token = ', tokenId);

  tx = await gameCharacter.changeHat(tokenId, '0x00010000000000000000000000000000000000000000000000000000000001', {gasLimit: 1000000});
  await tx.wait();
  console.log('change hat executed');
  console.log('transaction hash = ', tx.hash);

  var hatId = await gameCharacter.getHat(tokenId);
  console.log('hatId = ', hatId);

  tx = await gameCharacter.changeHat(tokenId, '0x00010000000000000000000000000000000000000000000000000000000002', {gasLimit: 1000000});
  await tx.wait();
  console.log('change hat executed');
  console.log('transaction hash = ', tx.hash);

  hatId = await gameCharacter.getHat(tokenId);
  console.log('hatId = ', hatId);

  tx = await gameCharacter.changeShoes(tokenId, '0x00020000000000000000000000000000000000000000000000000000000003', {gasLimit: 1000000});
  await tx.wait();
  console.log('change shoes executed');
  console.log('transaction hash = ', tx.hash);

  var shoesId = await gameCharacter.getShoes(tokenId);
  console.log('shoesId = ', shoesId);

  console.log('Done.');
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });