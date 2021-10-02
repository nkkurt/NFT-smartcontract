//const { hexStripZeros } = require("ethers/lib/utils")

const main = async () => {
    const nftContractFactory = await hre.ethers.getContractFactory('MyEpicNFT');
    const nftContract = await nftContractFactory.deploy();
    await nftContract.deployed();
    console.log("Contract deployed to:", nftContract.address);

    // Call the makeAnEpicNFT function from our contract
    let txn = await nftContract.makeAnEpicNFT()
    //Wait for it to be mined
    await txn.wait()
    console.log("Minted an NFT")
    
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log (error);
        process.exit(1);
    }
};

runMain();