import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("DiamondProxy", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const DiamondProxy = await ethers.getContractFactory("DiamondProxy");
    const diamondProxy = await DiamondProxy.deploy();

    const Token = await ethers.getContractFactory("Token");
    const token = await Token.deploy();

    console.log("");
    return { Token, token, diamondProxy, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should add facet ", async function () {
      const { diamondProxy, token, Token } = await loadFixture(deployFixture);

      diamondProxy.addFacet({
        facetAddress: token.address,
        functionSelectors: [],
      });
      const new_facet = await diamondProxy.facet(0);
      await expect(new_facet.facetAddress).to.equal(token.address);

      const sigHash = await token.interface.getSighash("name");
      await diamondProxy.addSelector(sigHash, token.address);

      //call proxy
      const tokenViaProxy = await ethers.getContractAt(
        "Token",
        diamondProxy.address
      );

      console.log("name", await tokenViaProxy.name());
    });
    //it("Should fail to delegate if selector has not been added ", async function () {});
  });
});
