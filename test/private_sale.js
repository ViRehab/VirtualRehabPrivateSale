const PrivateSale = artifacts.require('./PrivateSale.sol');
const BigNumber = require('bignumber.js');
const EVMRevert = require('./helpers/EVMRevert').EVMRevert;
const ether = require('./helpers/ether').ether;
const latestTime  = require('./helpers/latestTime').latestTime;
const increaseTime = require('./helpers/increaseTime');
const increaseTimeTo = increaseTime.increaseTimeTo;
const duration = increaseTime.duration;
const Token = artifacts.require('./ERC20Mock');

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('Private sale', function(accounts) {
  describe('Private Sale Creation', () => {
    it('should deploy with correct parameters', async () => {
      const tokenPrice = 60;
      const minContributionInUSD = 15000;
      const ETH_USD = 30000;
      const BNB_USD = 1138;
      const startTime = await latestTime() + duration.days(1);
      const endTime = startTime + duration.years(1);
      const BNBToken = accounts[1];
      const ERC20 = accounts[2];
      const privateSale = await PrivateSale.new(startTime, endTime, tokenPrice, ETH_USD, BNB_USD, BNBToken, ERC20, minContributionInUSD);
      assert((await privateSale.tokenPrice()).toNumber() == tokenPrice);
      assert((await privateSale.maxTokensAvailable()).toNumber() == 0);
      assert((await privateSale.minContributionInUSD()).toNumber() == minContributionInUSD);
      assert((await privateSale.openingTime()).toNumber() == startTime);
      assert((await privateSale.closingTime()).toNumber() == endTime);
      assert((await privateSale.ETH_USD()).toNumber() == ETH_USD);
      assert((await privateSale.BNB_USD()).toNumber() == BNB_USD);
      assert((await privateSale.token()) == ERC20);
      assert((await privateSale.BNBToken()) == BNBToken);
      assert((await privateSale.owner()) == accounts[0]);
    });
  });

  describe('Admin Functions', () => {
    let privateSale;
    let erc20;
    beforeEach(async () => {
      const openingTime = await latestTime() + 10;
      const endingTime = openingTime + duration.days(10);
      const tokenPrice = 10;
      const ETH_USD = 30000;
      const BNB_USD = 1100;
      const BNBToken = accounts[1];
      const minContributionInUSD = 100;
      erc20 = await Token.new(accounts[0], ether(7000000));
      privateSale = await PrivateSale.new(openingTime, endingTime, tokenPrice, ETH_USD, BNB_USD, BNBToken, erc20.address, minContributionInUSD);

    })

    it('only admin can change the token price', async () => {
      await privateSale.setTokenPrice(200);
      assert((await privateSale.tokenPrice()).toNumber() == 200);
      await privateSale.setTokenPrice(300, { from: accounts[2] }).should.be.rejectedWith(EVMRevert);
    });

    it('only admin can set ICO End date', async () => {
      const ICOEndDate = (await latestTime()) + 1000;
      await privateSale.setICOEndDate(ICOEndDate);
      assert((await privateSale.ICOEndDate()).toNumber() == ICOEndDate);
      await privateSale.setICOEndDate(ICOEndDate).should.be.rejectedWith(EVMRevert);
    });

    it('only admin can set ETH USD price', async () => {
      const ETH_USD = 25000;
      await privateSale.setETH_USDPrice(ETH_USD);
      assert((await privateSale.ETH_USD()).toNumber() == ETH_USD)
      await privateSale.setETH_USDPrice(ETH_USD, { from: accounts[1] }).should.be.rejectedWith(EVMRevert);
    });

    it('only admin can set BNB USD price', async () => {
      const BNB_USD = 2500;
      await privateSale.setBNB_USDPrice(BNB_USD);
      assert((await privateSale.BNB_USD()).toNumber() == BNB_USD);
      await privateSale.setBNB_USDPrice(BNB_USD, { from : accounts[1] }).should.be.rejectedWith(EVMRevert);
    })

    it('only admin can change the min contribution', async () => {
      const minContributionInUSD = 1000000;
      await privateSale.setMinimumContribution(minContributionInUSD);
      assert((await privateSale.minContributionInUSD()).toNumber() == minContributionInUSD);
      await privateSale.setMinimumContribution(minContributionInUSD, { from: accounts[3] }).should.be.rejectedWith(EVMRevert);
    });

    it('only admin can add address to KYC', async () => {
      const investor =  accounts[4];
      await privateSale.addAddressToKYC(investor);
      assert(await privateSale.KYC(investor));
      await privateSale.addAddressToKYC(accounts[4], { from: accounts[4] }).should.be.rejectedWith(EVMRevert);

      const investors = [accounts[1], accounts[2]];
      await privateSale.addAddressesToKYC(investors);

      for(let i=0;i< investors.length;i++) {
        assert(await privateSale.KYC(investors[i]));
      }
      await privateSale.addAddressesToKYC(investors, { from: accounts[1] }).should.be.rejectedWith(EVMRevert);
    });

    it('only admin can change the max tokens for sale', async () => {
      await erc20.approve(privateSale.address, ether(20));
      const maxTokensAvailable = await privateSale.maxTokensAvailable();
      await privateSale.increaseMaxTokensForSale();
      const expectedMaxTokens = maxTokensAvailable.add(ether(20));
      (await privateSale.maxTokensAvailable()).should.be.bignumber.equal(expectedMaxTokens)
    });

    it('only admin can call initialize', async () => {
      await erc20.approve(privateSale.address, ether(700000))
      const contributions = [1500000, 10000000, 25000000];
      const bonusPercentages = [35, 40, 50];
      await privateSale.initializePrivateSale(contributions, bonusPercentages, {from: accounts[1]}).should.be.rejectedWith(EVMRevert);

      await privateSale.initializePrivateSale(contributions, bonusPercentages);
      assert(await privateSale.initialized());
      const maxTokensAvailable = await privateSale.maxTokensAvailable();
      maxTokensAvailable.should.be.bignumber.equal(ether(700000));

      for(var i=0;i<bonusPercentages.length;i++) {
        assert((await privateSale.bonusPercentages(i)).toNumber() == bonusPercentages[i]);
        assert((await privateSale.bonusContributions(i)).toNumber() == contributions[i]);
      }
      await privateSale.initializePrivateSale(contributions, bonusPercentages)
      .should.be.rejectedWith(EVMRevert);
    });
  })

  describe('constant conversion function', () => {
    let privateSale;
    let erc20;
    beforeEach(async () => {
      const openingTime = await latestTime() + 10;
      const endingTime = openingTime + duration.days(10);
      const tokenPrice = 10;
      const ETH_USD = 30000;
      const BNB_USD = 1100;
      const BNBToken = accounts[1];
      const minContributionInUSD = 100;
      erc20 = await Token.new(accounts[0], ether(7000000));
      privateSale = await PrivateSale.new(openingTime, endingTime, tokenPrice, ETH_USD, BNB_USD, BNBToken, erc20.address, minContributionInUSD);
    })
    it('should convert to USD', async () => {
      const tokenCost = [30000, 20000, 1100, 29340];
      const amount = [ether(1), ether(2), ether(3), ether(0.5)];
      const expectedUSD = [30000, 40000, 3300, 29340/2];
      for(let i=0;i<tokenCost.length;i++) {
        let USD = await privateSale.convertToUSD(amount[i], tokenCost[i]);
        assert(USD.toNumber() == expectedUSD[i]);
      }
    });

    it('calculateBonus for token amount', async () => {
      await privateSale.setBonuses([1500000, 10000000, 25000000], [35, 40, 50]);
      const usd = [1000 * 100, 16000 * 100, 200000 * 100, 260000 * 100 ]
      const tokenAmount = [100, 200, 300, 400];
      const expectedBonus = [
        0,
        200*35/100,
        300 * 40/100,
        400 * 50/100
      ]
      for(let i=0;i<tokenAmount.length; i++) {
        let bonus = await privateSale.calculateBonus(ether(tokenAmount[i]), usd[i]);
        bonus.should.be.bignumber.equal(ether(expectedBonus[i]));
      }
    });

    it('calculate token amount', async () => {
      await privateSale.setETH_USDPrice(50000)
      let tokenPrice = 10;
      const ethPrices = [29850, 32000, 50000, 28904];
      const ethContribution = [1, 0.5, 2, 0.25];
      for(var i=0;i<ethPrices.length;i++) {
        await privateSale.setETH_USDPrice(ethPrices[i]);
        expectedTokenAmount = ether(ethContribution[i] * ethPrices[i]/tokenPrice);
        (await privateSale.getTokenAmountForWei(ether(ethContribution[i])))
        .should.be.bignumber.equal(expectedTokenAmount);
      }
    })
  });

});
