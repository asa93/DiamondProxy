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

    return { Token, token, diamondProxy, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Shouldn't add facet if caller is not owner ", async function () {
      const { diamondProxy, token, otherAccount } = await loadFixture(
        deployFixture
      );

      await expect(
        diamondProxy.connect(otherAccount).addFacet({
          facetAddress: token.address,
          functionSelectors: [],
        })
      ).to.be.reverted;
    });
    it("Should add facet ", async function () {
      const { diamondProxy, token } = await loadFixture(deployFixture);

      diamondProxy.addFacet({
        facetAddress: token.address,
        functionSelectors: [],
      });
      const new_facet = await diamondProxy.facet(0);
      await expect(new_facet.facetAddress).to.equal(token.address);

      let sigHash = await token.interface.getSighash("name");
      await diamondProxy.addSelector(sigHash, token.address);

      sigHash = await token.interface.getSighash("__Token_init");
      await diamondProxy.addSelector(sigHash, token.address);

      //call proxy
      const tokenViaProxy = await ethers.getContractAt(
        "Token",
        diamondProxy.address
      );
      await tokenViaProxy.__Token_init();
      await expect(await tokenViaProxy.name()).to.equal("Gold");
    });
  });
});
