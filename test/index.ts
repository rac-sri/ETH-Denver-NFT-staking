import { expect } from "chai";
import { Signer } from "ethers";
import { ethers } from "hardhat";
import { NFTStakingFactory } from "../typechain";

describe("NFTStakingFactory", function () {
  let nftStakingFactory: NFTStakingFactory, owner: Signer;

  before(async () => {
    const nftFactory = await ethers.getContractFactory("NFTStakingFactory");
    nftStakingFactory = await nftFactory.deploy();
    await nftStakingFactory.deployed();
    [owner] = await ethers.getSigners();
  });

  it("Create New Protocol Support", async function () {
    const createNewProtocolTx =
      await nftStakingFactory.createNewProtocolSupport(
        ethers.constants.AddressZero,
        "Dssas",
        "asdsad",
        await owner.getAddress()
      );

    await createNewProtocolTx.wait();
    const details = await nftStakingFactory.getProtocolDetails(
      ethers.constants.AddressZero
    );
    expect(details.Name).to.equal("Dssas");
    expect(details.Description).to.equal("asdsad");
    expect(details.owner).to.equal(await owner.getAddress());
  });
});
