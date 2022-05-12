const hre = require("hardhat");


/*
    Blue Hat =      0x00010000000000000000000000000000000000000000000000000000000001
    Red Hat =       0x00010000000000000000000000000000000000000000000000000000000002
    White Hat =     0x00010000000000000000000000000000000000000000000000000000000003

    Blue Shoues =   0x00020000000000000000000000000000000000000000000000000000000001
    Red Shoes =     0x00020000000000000000000000000000000000000000000000000000000002
    White Shoes =   0x00020000000000000000000000000000000000000000000000000000000003

    Blue Glasses =  0x00030000000000000000000000000000000000000000000000000000000001
    Red Glasses =   0x00030000000000000000000000000000000000000000000000000000000002
    White Glasses = 0x00030000000000000000000000000000000000000000000000000000000003

*/
/*
OLD CONTRACTS
GameItem = 0x26aFc7805Aa279fB0E806c2bc1e2bF37A70F995d
GameCharacter = 0x10555B832DE7bAD8459d6de1D8E8F5ad990709A0
*/

async function main() {
  const gameItemAddress = '0x5ff9214c724F2465C543eD6cdA0957dC96940aFe';
  const gameCharacterAddress = '0xCF3723BD1569db783aAB388e91Dd84Eb2B159404';
  const gameItem = await hre.ethers.getContractAt('GameItem', gameItemAddress);
  const gameCharacter = await hre.ethers.getContractAt('GameCharacter', gameCharacterAddress);

  var [account] = await hre.ethers.getSigners();
  account = account.address;
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

  tx = await gameCharacter.safeMint(account);
  await tx.wait();
  console.log('game character minted');
  console.log('transaction hash = ', tx.hash);

  tx = await gameCharacter.safeMint(account);
  await tx.wait();
  console.log('game character minted');
  console.log('transaction hash = ', tx.hash);

  tx = await gameItem.setApprovalForAll(gameCharacterAddress, true);
  await tx.wait();
  console.log('game items approved');
  console.log('transaction hash = ', tx.hash);

  var tokenId = await gameCharacter.tokenOfOwnerByIndex(account, await gameCharacter.balanceOf(account) - 1);
  console.log('minted token = ', tokenId);
  return;

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