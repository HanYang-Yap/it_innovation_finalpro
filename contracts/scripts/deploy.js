async function main() {
    const KPopNFCAuth = await ethers.getContractFactory("KPopNFCAuth");
    const contract = await KPopNFCAuth.deploy();
    
    await contract.deployed();
    
    console.log("KPopNFCAuth deployed to:", contract.address);
    
    // Register sample cards
    await contract.registerCard("TWICE-001", JSON.stringify({
      idolName: "Tzuyu",
      groupName: "TWICE",
      image: "https://64.media.tumblr.com/bb3a5e8ae80f634268eeb37a8ebf014d/tumblr_ofiw1lN4jS1ujcaa1o1_1280.jpg",
      rarity: "Legendary"
    }));
    
    console.log("Sample card registered");
  }
  
  main().catch(console.error);