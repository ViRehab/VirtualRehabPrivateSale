const PrivateSale = artifacts.require('./PrivateSale.sol');
const BigNumber = require('bignumber.js');
const EVMRevert = require('./helpers/EVMRevert').EVMRevert;
const ether = require('./helpers/ether').ether;
const latestTime  = require('./helpers/latestTime').latestTime;
const increaseTime = require('./helpers/increaseTime');
const increaseTimeTo = increaseTime.increaseTimeTo;
const duration = increaseTime.duration;
const Token = artifacts.require('./ERC20Mock');
const getBalance = require('./helpers/web3').ethGetBalance

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

    it('token price cannot be set to 0', async () => {
      await privateSale.setTokenPrice(0).should.be.rejectedWith(EVMRevert);
    })


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

    it('ETH USD price cannot be set to 0', async () => {
      const ETH_USD = 0;
      await privateSale.setETH_USDPrice(ETH_USD).should.be.rejectedWith(EVMRevert);
    })

    it('only admin can set BNB USD price', async () => {
      const BNB_USD = 2500;
      await privateSale.setBNB_USDPrice(BNB_USD);
      assert((await privateSale.BNB_USD()).toNumber() == BNB_USD);
      await privateSale.setBNB_USDPrice(BNB_USD, { from : accounts[1] }).should.be.rejectedWith(EVMRevert);
    })

    it('BNB USD price cannot be set to 0', async () => {
      const BNB_USD = 0;
      await privateSale.setBNB_USDPrice(BNB_USD).should.be.rejectedWith(EVMRevert);
    })

    it('only admin can change the min contribution', async () => {
      const minContributionInUSD = 1000000;
      await privateSale.setMinimumContribution(minContributionInUSD);
      assert((await privateSale.minContributionInUSD()).toNumber() == minContributionInUSD);
      await privateSale.setMinimumContribution(minContributionInUSD, { from: accounts[3] }).should.be.rejectedWith(EVMRevert);
    });

    it('min contribution cannot be made 0', async () => {
      const minContributionInUSD = 0;
      await privateSale.setMinimumContribution(minContributionInUSD).should.be.rejectedWith(EVMRevert);
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

    it('only admin can remove address from KYC', async () => {
      const investor =  accounts[4];
      const investor2 = accounts[5];
      await privateSale.addAddressToKYC(investor);
      await privateSale.addAddressToKYC(investor2);

      await privateSale.removeAddressFromKYC(investor, { from: accounts[4] }).should.be.rejectedWith(EVMRevert);
      await privateSale.removeAddressFromKYC(investor);
      assert(await privateSale.KYC(investor) == false);
      await privateSale.removeAddressesFromKYC([investor2], { from: accounts[1] }).should.be.rejectedWith(EVMRevert);
      await privateSale.removeAddressesFromKYC([investor2]);
      assert(await privateSale.KYC(investor2) == false);
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

    it('only admin can withdraw ERC20 token', async () => {
      await erc20.transfer(privateSale.address, ether(1));
      await privateSale.addAdmin(accounts[1]);
      privateSale.withdrawToken(erc20.address, { from: accounts[1] });
      (await erc20.balanceOf(accounts[1])).should.be.bignumber.equal(ether(1));
    })
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

  describe('ETH Contribution', () => {
    let privateSale;
    let erc20;
    let endingTime;
    beforeEach(async () => {
      const openingTime = await latestTime() + 10;
      endingTime = openingTime + duration.days(10);
      const tokenPrice = 10;
      const ETH_USD = 30000;
      const BNB_USD = 1100;
      const BNBToken = accounts[1];
      const minContributionInUSD = 1500000;
      const contributions = [1500000, 10000000, 25000000];
      const bonusPercentages = [35, 40, 50];
      erc20 = await Token.new(accounts[0], ether(2*526500));
      privateSale = await PrivateSale.new(openingTime, endingTime, tokenPrice, ETH_USD, BNB_USD, BNBToken, erc20.address, minContributionInUSD);
      await erc20.approve(privateSale.address, ether(2*526500));
      await privateSale.initializePrivateSale(contributions, bonusPercentages);
      await increaseTimeTo(openingTime + 10);
    });

    it('contribute more than min contribution', async () => {
      await privateSale.addAddressToKYC(accounts[1]);
      await privateSale.sendTransaction({ value: ether(60) , from: accounts[1] });
      let expectedBalance = ether(60*3000);
      let contributionBalance = await erc20.balanceOf(accounts[1]);
      contributionBalance.should.be.bignumber.equal(expectedBalance);
      let expectedBonus = ether(35*60*3000/100);
      let bonus = await privateSale.bonusHolders(accounts[1]);
      bonus.should.be.bignumber.equal(expectedBonus);
      (await privateSale.totalTokensSold()).should.be.bignumber.equal(expectedBonus.add(expectedBalance));
      (await privateSale.bonusTokensSold()).should.be.bignumber.equal(expectedBonus);
    });

    it('should reject contributions from non-kyc address', async () => {
      assert(await privateSale.KYC(accounts[4]) == false);
      await privateSale.sendTransaction({ value: ether(60) , from: accounts[4] }).should.be.rejectedWith(EVMRevert);
    });

    it('validate bonus and total tokens sold for multiple contributors', async () => {
      await privateSale.addAddressToKYC(accounts[2]);
      await privateSale.addAddressToKYC(accounts[3]);
      await privateSale.sendTransaction({ value: ether(60) , from: accounts[2] });
      await privateSale.sendTransaction({ value: ether(70) , from: accounts[3] });
      let expectedBalance = ether((60 + 70) *3000); // 390 000
      let expectedBonus = ether(35*(60+ 70)*3000/100); // 136 500
      (await privateSale.totalTokensSold()).should.be.bignumber.equal(expectedBonus.add(expectedBalance));
      (await privateSale.bonusTokensSold()).should.be.bignumber.equal(expectedBonus);
    });

    it('cannot contribute after the end date', async() => {
      await increaseTimeTo(endingTime + 100);
      await privateSale.addAddressToKYC(accounts[4]);
      await privateSale.sendTransaction({ value: ether(60) , from: accounts[4] }).should.rejectedWith(EVMRevert);
    });

    it('withdraw funds can be called only by admin', async () => {
      await privateSale.addAddressesToKYC([accounts[7]]);
      await privateSale.sendTransaction({ value: ether(60) , from: accounts[7] });
      const balance = await getBalance(privateSale.address);
      balance.should.be.bignumber.equal(ether(60));
      const withdrawAmount = ether(1);
      await privateSale.withdrawFunds(withdrawAmount);
      const newBalance = await getBalance(privateSale.address);
      newBalance.should.be.bignumber.equal(balance.sub(withdrawAmount));
      await privateSale.withdrawFunds(withdrawAmount, { from: accounts[1] })
      .should.be.rejectedWith(EVMRevert);
    });
  });

  describe('Withdraw bonus', async () => {
    let privateSale;
    let erc20;
    let endingTime;
    let bonus;
    beforeEach(async () => {
      const openingTime = await latestTime() + 10;
      endingTime = openingTime + duration.days(10);
      const tokenPrice = 10;
      const ETH_USD = 3000000;
      const BNB_USD = 1100;
      const BNBToken = accounts[1];
      const minContributionInUSD = 15000;
      const contributions = [1500000, 10000000, 25000000];
      const bonusPercentages = [35, 40, 50];
      erc20 = await Token.new(accounts[0], ether(2*526500));
      privateSale = await PrivateSale.new(openingTime, endingTime, tokenPrice, ETH_USD, BNB_USD, BNBToken, erc20.address, minContributionInUSD);
      await erc20.approve(privateSale.address, ether(2*526500));
      await privateSale.initializePrivateSale(contributions, bonusPercentages);
      await increaseTimeTo(openingTime + 10);
      await privateSale.addAddressToKYC(accounts[1]);
      await privateSale.sendTransaction({ value: ether(0.5) , from: accounts[1] });
      bonus = ether(0.35*150000);
    });

    it('bonus cannot be claimed before icoDate is set', async () => {
      ((await privateSale.ICOEndDate()).toNumber() == 0);
      await privateSale.withdrawBonus({from:accounts[1]}).should.be.rejectedWith(EVMRevert);
    });

    it('bonus can be claimed only after 3 months after the ICO date is set', async () => {
      let currentTime = await latestTime();
      let ICOEndDate = currentTime + 10;
      await privateSale.setICOEndDate(ICOEndDate);
      await increaseTimeTo(ICOEndDate);
      await privateSale.withdrawBonus({from: accounts[1]}).should.be.rejectedWith(EVMRevert);
      await increaseTimeTo(ICOEndDate + duration.weeks(4*4));
      let oldBalance = await erc20.balanceOf(accounts[1]);
      await privateSale.withdrawBonus({from: accounts[1]});
      let currentBalance = await erc20.balanceOf(accounts[1]);
      currentBalance.should.bignumber.equal(oldBalance.add(bonus));
      assert((await privateSale.bonusHolders(accounts[1])).toNumber() == 0);
    })

    it('bonus can be claimed only by assigned holders', async () => {
      let currentTime = await latestTime();
      let ICOEndDate = currentTime + 10;
      await privateSale.setICOEndDate(ICOEndDate);
      await increaseTimeTo(ICOEndDate + duration.weeks(4*4));
      let oldBalance = await erc20.balanceOf(accounts[1]);
      await privateSale.withdrawBonus({from: accounts[2]}).should.be.rejectedWith(EVMRevert);
    });
  });

  describe('Finalization', () => {
    let privateSale;
    let erc20;
    let endingTime;
    let bonus;
    beforeEach(async () => {
      const openingTime = await latestTime() + 10;
      endingTime = openingTime + duration.days(10);
      const tokenPrice = 10;
      const ETH_USD = 3000000;
      const BNB_USD = 1100;
      const BNBToken = accounts[1];
      const minContributionInUSD = 15000;
      erc20 = await Token.new(accounts[0], ether(2*526500));
      privateSale = await PrivateSale.new(openingTime, endingTime, tokenPrice, ETH_USD, BNB_USD, BNBToken, erc20.address, minContributionInUSD);
      await increaseTimeTo(openingTime + 10);
      await privateSale.addAddressToKYC(accounts[1]);
    });

    it('rejects contributions before initialize crowdsale', async () => {
      await privateSale.sendTransaction({ value: ether(0.5) , from: accounts[1] }).
      should.be.rejectedWith(EVMRevert);
    });

    it('hasClosed should return true when max Tokens have been sold', async () => {
      await erc20.approve(privateSale.address, ether(150000* 1.35));
      const contributions = [1500000, 10000000, 25000000];
      const bonusPercentages = [35, 40, 50];
      await privateSale.initializePrivateSale(contributions, bonusPercentages);
      let bonus = await privateSale.calculateBonus(ether(150000), 3000000);
      await privateSale.sendTransaction({ value: ether(0.5) , from: accounts[1] });
      let balance = await erc20.balanceOf(accounts[1]);
      balance.should.be.bignumber.equal(ether(150000));
      let totalTokensSold =  await privateSale.totalTokensSold();
      let maxTokensAvailable = await privateSale.maxTokensAvailable();
      let bonus1 = await privateSale.bonusHolders(accounts[1]);
      assert(await privateSale.hasClosed() == true);
    });

    it('hasClosed returns true when time has crossed the closing time', async () => {
      await increaseTimeTo(endingTime);
      assert(await privateSale.hasClosed() == true);
    });

    it('finalize crowdsale can be called only after the hasClosed has returned true', async () => {
      await erc20.approve(privateSale.address, ether(150000* 1.35));
      const contributions = [1500000, 10000000, 25000000];
      const bonusPercentages = [35, 40, 50];
      await privateSale.initializePrivateSale(contributions, bonusPercentages);
      await privateSale.sendTransaction({ value: ether(0.5), from: accounts[1] });
      await increaseTimeTo(endingTime + 10);
      assert(await privateSale.hasClosed());
      await privateSale.addAdmin(accounts[3]);
      let bonusTokensSold = await privateSale.bonusTokensSold();
      let balanceOfPrivateSale = await erc20.balanceOf(privateSale.address);
      await privateSale.finalizeCrowdsale({ from: accounts[3] });
      let balanceOfAdmin = await erc20.balanceOf(accounts[3]);
      balanceOfAdmin.should.be.bignumber.equal(balanceOfPrivateSale.sub(bonusTokensSold));
    });

    it('finalize crowdsale cannot be called by non-admin', async () => {
      await erc20.approve(privateSale.address, ether(150000* 1.35));
      const contributions = [1500000, 10000000, 25000000];
      const bonusPercentages = [35, 40, 50];
      await privateSale.initializePrivateSale(contributions, bonusPercentages);
      await increaseTimeTo(endingTime + 10);
      await privateSale.finalizeCrowdsale( { from: accounts[3] }).should.be.rejectedWith(EVMRevert);
    });

    it('finalize crowdsale cannot be called twice', async () => {
      await erc20.approve(privateSale.address, ether(150000* 1.35));
      const contributions = [1500000, 10000000, 25000000];
      const bonusPercentages = [35, 40, 50];
      await privateSale.initializePrivateSale(contributions, bonusPercentages);
      await increaseTimeTo(endingTime + 10);
      await privateSale.finalizeCrowdsale();
      await privateSale.finalizeCrowdsale().should.be.rejectedWith(EVMRevert);
    });

  });

});
