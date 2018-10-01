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
      // const minContributionInUSDCents  = 15000;
      const startTime = await latestTime() + duration.days(1);
      const endTime = startTime + duration.years(1);
      const binanceCoin = accounts[1];
      const creditsToken = accounts[2];
      const ERC20 = accounts[2];
      const privateSale = await PrivateSale.new(startTime, endTime, binanceCoin, creditsToken, ERC20);
      assert((await privateSale.totalSaleAllocation()).toNumber() == 0);
      assert((await privateSale.openingTime()).toNumber() == startTime);
      assert((await privateSale.closingTime()).toNumber() == endTime);
      assert((await privateSale.token()) == ERC20);
      assert((await privateSale.binanceCoin()) == binanceCoin);
      assert((await privateSale.owner()) == accounts[0]);
    });
  });

  describe('Admin Functions', () => {
    let privateSale;
    let erc20;
    beforeEach(async () => {
      const openingTime = await latestTime() + 10;
      const endingTime = openingTime + duration.days(10);
      const binanceCoin = accounts[1];
      const creditsToken = accounts[2];
      const minContributionInUSDCents  = 100;
      erc20 = await Token.new(accounts[0], ether(7000000));
      privateSale = await PrivateSale.new(openingTime, endingTime, binanceCoin, creditsToken, erc20.address);
    })

    it('only admin can change the token price', async () => {
      await privateSale.setTokenPrice(200);
      assert((await privateSale.tokenPriceInCents()).toNumber() == 200);
      await privateSale.setTokenPrice(300, { from: accounts[2] }).should.be.rejectedWith(EVMRevert);
    });

    it('token price cannot be set to 0', async () => {
      await privateSale.setTokenPrice(0).should.be.rejectedWith(EVMRevert);
    })


    it('only admin can set ICO End date', async () => {
      const releaseDate = (await latestTime()) + 1000;
      await privateSale.setReleaseDate(releaseDate);
      assert((await privateSale.releaseDate()).toNumber() == releaseDate);
      await privateSale.setReleaseDate(releaseDate).should.be.rejectedWith(EVMRevert);
    });

    it('only admin can set ETH USD price', async () => {
      const etherPriceInCents = 25000;
      await privateSale.setEtherPrice(etherPriceInCents);
      assert((await privateSale.etherPriceInCents()).toNumber() == etherPriceInCents)
      await privateSale.setEtherPrice(etherPriceInCents, { from: accounts[1] }).should.be.rejectedWith(EVMRevert);
    });

    it('ETH USD price cannot be set to 0', async () => {
      const etherPriceInCents = 0;
      await privateSale.setEtherPrice(etherPriceInCents).should.be.rejectedWith(EVMRevert);
    })

    it('only admin can set BNB USD price', async () => {
      const binanceCoinPriceInCents = 2500;
      await privateSale.setBinanceCoinPrice(binanceCoinPriceInCents);
      assert((await privateSale.binanceCoinPriceInCents()).toNumber() == binanceCoinPriceInCents);
      await privateSale.setBinanceCoinPrice(binanceCoinPriceInCents, { from : accounts[1] }).should.be.rejectedWith(EVMRevert);
    })

    it('BNB USD price cannot be set to 0', async () => {
      const binanceCoinPriceInCents = 0;
      await privateSale.setBinanceCoinPrice(binanceCoinPriceInCents).should.be.rejectedWith(EVMRevert);
    })

    it('only admin can set credits USD price', async () => {
      const creditsTokenPrice = 2500;
      await privateSale.setCreditsTokenPrice(creditsTokenPrice);
      assert((await privateSale.creditsTokenPriceInCents()).toNumber() == creditsTokenPrice);
      await privateSale.setCreditsTokenPrice(creditsTokenPrice, { from : accounts[1] }).should.be.rejectedWith(EVMRevert);
    })

    it('credits USD Price cannot be set to 0', async () => {
      const creditsTokenPrice = 0;
      await privateSale.setCreditsTokenPrice(creditsTokenPrice).should.be.rejectedWith(EVMRevert);
    })

    it('only admin can change the min contribution', async () => {
      const minContributionInUSDCents  = 1000000;
      await privateSale.setMinimumContribution(minContributionInUSDCents );
      assert((await privateSale.minContributionInUSDCents ()).toNumber() == minContributionInUSDCents );
      await privateSale.setMinimumContribution(minContributionInUSDCents , { from: accounts[3] }).should.be.rejectedWith(EVMRevert);
    });

    it('min contribution cannot be made 0', async () => {
      const minContributionInUSDCents  = 0;
      await privateSale.setMinimumContribution(minContributionInUSDCents ).should.be.rejectedWith(EVMRevert);
    });

    it('only admin can add address to KYC', async () => {
      const investor =  accounts[4];
      await privateSale.addWhitelist(investor);
      assert(await privateSale.whitelist(investor));
      await privateSale.addWhitelist(accounts[4], { from: accounts[4] }).should.be.rejectedWith(EVMRevert);

      const investors = [accounts[1], accounts[2]];
      await privateSale.addManyWhitelist(investors);

      for(let i=0;i< investors.length;i++) {
        assert(await privateSale.whitelist(investors[i]));
      }
      await privateSale.addManyWhitelist(investors, { from: accounts[1] }).should.be.rejectedWith(EVMRevert);
    });

    it('only admin can remove address from KYC', async () => {
      const investor =  accounts[4];
      const investor2 = accounts[5];
      await privateSale.addWhitelist(investor);
      await privateSale.addWhitelist(investor2);

      await privateSale.removeWhitelist(investor, { from: accounts[4] }).should.be.rejectedWith(EVMRevert);
      await privateSale.removeWhitelist(investor);
      assert(await privateSale.whitelist(investor) == false);
      await privateSale.removeManyWhitelist([investor2], { from: accounts[1] }).should.be.rejectedWith(EVMRevert);
      await privateSale.removeManyWhitelist([investor2]);
      assert(await privateSale.whitelist(investor2) == false);
    });



    it('only admin can change the max tokens for sale', async () => {
      await erc20.approve(privateSale.address, ether(20));
      const totalSaleAllocation = await privateSale.totalSaleAllocation();
      await privateSale.increaseTokenSaleAllocation();
      const expectedMaxTokens = totalSaleAllocation.add(ether(20));
      (await privateSale.totalSaleAllocation()).should.be.bignumber.equal(expectedMaxTokens)
    });

    it('only admin can call initialize', async () => {
      let etherPriceInCents = 100;
      let creditsTokenPriceInCents = 101;
      let tokenPriceInCents = 102;
      let binanceCoinPriceInCents = 103;
      let minContributionInUSDCents = 10000;
      await erc20.approve(privateSale.address, ether(700000))

      await privateSale.initializePrivateSale(etherPriceInCents, tokenPriceInCents, binanceCoinPriceInCents, creditsTokenPriceInCents, minContributionInUSDCents, {from: accounts[1]}).should.be.rejectedWith(EVMRevert);
      await privateSale.initializePrivateSale(etherPriceInCents, tokenPriceInCents, binanceCoinPriceInCents, creditsTokenPriceInCents, minContributionInUSDCents);
      assert(await privateSale.initialized());
      assert((await privateSale.creditsTokenPriceInCents()).toNumber() === creditsTokenPriceInCents);
      assert((await privateSale.binanceCoinPriceInCents()).toNumber() === binanceCoinPriceInCents);
      assert((await privateSale.etherPriceInCents()).toNumber() === etherPriceInCents);
      assert((await privateSale.tokenPriceInCents()).toNumber() === tokenPriceInCents);
      assert((await privateSale.minContributionInUSDCents()).toNumber() === minContributionInUSDCents);
      const totalSaleAllocation = await privateSale.totalSaleAllocation();
      totalSaleAllocation.should.be.bignumber.equal(ether(700000));
      await privateSale.initializePrivateSale(etherPriceInCents, tokenPriceInCents, binanceCoinPriceInCents, creditsTokenPriceInCents, minContributionInUSDCents)
      .should.be.rejectedWith(EVMRevert);
    });

    it('only admin can withdraw ERC20 token', async () => {
      await erc20.transfer(privateSale.address, ether(1));
      await privateSale.addAdmin(accounts[1]);
      privateSale.withdrawToken(erc20.address, { from: accounts[1] });
      (await erc20.balanceOf(accounts[1])).should.be.bignumber.equal(ether(1));
    })

    it('only admin can change the closing time', async () => {
      let endTime = await latestTime() + duration.days(1);
      await privateSale.changeClosingTime(endTime);
      assert((await privateSale.closingTime()).toNumber() === endTime);
      await privateSale.changeClosingTime(endTime, {from: accounts[2]})
      .should.be.rejectedWith(EVMRevert);
    });
  })

  describe('constant conversion function', () => {
    let privateSale;
    let erc20;

    beforeEach(async () => {
      const openingTime = await latestTime() + 10;
      const endingTime = openingTime + duration.days(10);
      const binanceCoin = accounts[1];
      const creditsToken = accounts[1];
      erc20 = await Token.new(accounts[0], ether(7000000));
      privateSale = await PrivateSale.new(openingTime, endingTime, binanceCoin, creditsToken, erc20.address);
    })
    it('should convert to USD', async () => {
      const tokenCost = [30000, 20000, 1100, 29340];
      const amount = [ether(1), ether(2), ether(3), ether(0.5432)];
      const expectedUSD = [30000, 40000, 3300, Math.round(29340*0.5432)];
      for(let i=0;i<tokenCost.length;i++) {
        let USD = await privateSale.convertToCents(amount[i], tokenCost[i], 18);
        assert(USD.toNumber() == expectedUSD[i]);
      }
    });

    it('calculateBonus for token amount', async () => {
      const bonusPercentage = [35,45,50]
      const tokenAmount = [100, 200, 350];
      for(let i=0;i<tokenAmount.length; i++) {
        let bonus = await privateSale.calculateBonus(tokenAmount[i], bonusPercentage[i]);
        assert(bonus.toNumber() == tokenAmount[i] * bonusPercentage[i] / 100);
      }
    });

    it('calculate token amount', async () => {
      await privateSale.setEtherPrice(50000);
      let tokenPriceInCents = 10;
      await privateSale.setTokenPrice(tokenPriceInCents);
      const ethPrices = [29850, 32000, 50000, 28904];
      const ethContribution = [1, 0.5, 2, 0.25];
      for(var i=0;i<ethPrices.length;i++) {
        await privateSale.setEtherPrice(ethPrices[i]);
        expectedTokenAmount = ether(ethContribution[i] * ethPrices[i]/tokenPriceInCents);
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
      const tokenPriceInCents = 10;
      const etherPriceInCents = 30000;
      const binanceCoinPriceInCents = 1100;
      const creditsTokenPriceInCents = 1000;
      const binanceCoin = accounts[1];
      const creditsToken = accounts[2];
      const minContributionInUSDCents  = 1500000;
      erc20 = await Token.new(accounts[0], ether(2*526500));
      privateSale = await PrivateSale.new(openingTime, endingTime, binanceCoin, creditsToken, erc20.address);
      await erc20.approve(privateSale.address, ether(2*526500));
      await privateSale.initializePrivateSale(etherPriceInCents, tokenPriceInCents, binanceCoinPriceInCents, creditsTokenPriceInCents, minContributionInUSDCents);
      await increaseTimeTo(openingTime + 10);
    });

    it('contribute more than min contribution', async () => {
      await privateSale.addWhitelist(accounts[1]);
      await privateSale.sendTransaction({ value: ether(60) , from: accounts[1] });
      let expectedBalance = ether(60*3000);
      let contributionBalance = await erc20.balanceOf(accounts[1]);
      contributionBalance.should.be.bignumber.equal(expectedBalance);
      let expectedBonus = ether(35*60*3000/100);
      let bonus = await privateSale.bonusHolders(accounts[1]);
      bonus.should.be.bignumber.equal(expectedBonus);
      (await privateSale.totalTokensSold()).should.be.bignumber.equal(expectedBonus.add(expectedBalance));
      (await privateSale.bonusProvided()).should.be.bignumber.equal(expectedBonus);
    });

    it('should reject contributions from non-kyc address', async () => {
      assert(await privateSale.whitelist(accounts[4]) == false);
      await privateSale.sendTransaction({ value: ether(60) , from: accounts[4] }).should.be.rejectedWith(EVMRevert);
    });

    it('validate bonus and total tokens sold for multiple contributors', async () => {
      await privateSale.addWhitelist(accounts[2]);
      await privateSale.addWhitelist(accounts[3]);
      await privateSale.sendTransaction({ value: ether(60) , from: accounts[2] });
      await privateSale.sendTransaction({ value: ether(70) , from: accounts[3] });
      let expectedBalance = ether((60 + 70) *3000); // 390 000
      let expectedBonus = ether(35*(60+ 70)*3000/100); // 136 500
      (await privateSale.totalTokensSold()).should.be.bignumber.equal(expectedBonus.add(expectedBalance));
      (await privateSale.bonusProvided()).should.be.bignumber.equal(expectedBonus);
    });

    it('cannot contribute after the end date', async() => {
      await increaseTimeTo(endingTime + 100);
      await privateSale.addWhitelist(accounts[4]);
      await privateSale.sendTransaction({ value: ether(60) , from: accounts[4] }).should.rejectedWith(EVMRevert);
    });

    it('withdraw funds can be called only by admin', async () => {
      await privateSale.addManyWhitelist([accounts[7]]);
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
      const tokenPriceInCents = 10;
      const etherPriceInCents = 3000000;
      const binanceCoinPriceInCents = 1100;
      const creditsTokenPriceInCents = 1200;
      const binanceCoin = accounts[1];
      const creditsToken = accounts[2];
      const minContributionInUSDCents  = 15000;
      erc20 = await Token.new(accounts[0], ether(2*526500));
      privateSale = await PrivateSale.new(openingTime, endingTime, binanceCoin, creditsToken, erc20.address);
      await erc20.approve(privateSale.address, ether(2*526500));
      await privateSale.initializePrivateSale(etherPriceInCents, tokenPriceInCents, binanceCoinPriceInCents, creditsTokenPriceInCents, minContributionInUSDCents);
      await increaseTimeTo(openingTime + 10);
      await privateSale.addWhitelist(accounts[1]);
      await privateSale.addWhitelist(accounts[5]);

      await privateSale.sendTransaction({ value: ether(0.5) , from: accounts[1] });
      await privateSale.sendTransaction({ value: ether(0.5), from: accounts[5] });
      bonus = ether(0.35*150000);
    });

    it('bonus cannot be claimed before icoDate is set', async () => {
      ((await privateSale.releaseDate()).toNumber() == 0);
      await privateSale.withdrawBonus({from:accounts[1]}).should.be.rejectedWith(EVMRevert);
    });

    it('bonus can be claimed only release date is set', async () => {

      let ICOEndDate = endingTime + 10;

      await privateSale.setReleaseDate(ICOEndDate);
      await increaseTimeTo(ICOEndDate + 10);
      await privateSale.finalizeCrowdsale();
      let b  = await erc20.balanceOf(accounts[1]);

      let bonus = await privateSale.bonusHolders(accounts[1]);
      await privateSale.withdrawBonus({ from: accounts[1] });
      (await erc20.balanceOf(accounts[1])).should.be.bignumber.equal(b.add(bonus));
      (await privateSale.bonusWithdrawn()).should.be.bignumber.equal(bonus);
      assert((await privateSale.bonusHolders(accounts[1])).toNumber() == 0);
      await erc20.transfer(privateSale.address, 1, { from:accounts[1] });
      await privateSale.addAdmin(accounts[4]);
      await privateSale.withdrawToken(erc20.address, { from: accounts[4] });
      assert((await erc20.balanceOf(accounts[4])).toNumber() == 1);
    })

    it('bonus can be claimed only by assigned holders', async () => {
      let currentTime = await latestTime();
      let ICOEndDate = currentTime + 10;
      await privateSale.setReleaseDate(ICOEndDate);
      await increaseTimeTo(ICOEndDate + duration.weeks(4*4));
      await privateSale.withdrawBonus({from: accounts[2]}).should.be.rejectedWith(EVMRevert);

    });
  });

  describe('BNB and Credits token contribution', () => {
    let privateSale;
    let erc20;
    let endingTime;
    let bonus;
    let binanceCoin;
    let creditsToken;
    beforeEach(async () => {
      const openingTime = await latestTime() + 10;
      endingTime = openingTime + duration.days(10);
      const tokenPriceInCents = 10;
      const etherPriceInCents = 3000000;
      const binanceCoinPriceInCents = 1100;
      const minContributionInUSDCents  = 1100;
      const creditsTokenPriceInCents = 1200;
      binanceCoin = await Token.new(accounts[1], ether(15000/11 + 9090.9090909091 + 250000/11))
      creditsToken = await Token.new(accounts[1], '0x' + BigNumber(10).pow(18).multipliedBy(1400 + 10000 + 22728).toString(16));
      erc20 = await Token.new(accounts[0], ether(17000000));
      privateSale = await PrivateSale.new(openingTime, endingTime, binanceCoin.address, creditsToken.address, erc20.address);
      await erc20.approve(privateSale.address, ether(7000000));
      await privateSale.initializePrivateSale(etherPriceInCents, tokenPriceInCents, binanceCoinPriceInCents, creditsTokenPriceInCents, minContributionInUSDCents);
      await increaseTimeTo(openingTime + 10);
      await privateSale.addWhitelist(accounts[1]);
    });

    it('should accept BNB Token', async () => {
      await binanceCoin.approve(privateSale.address, ether(15000/11), { from: accounts[1] });
      await privateSale.contributeInBNB({ from: accounts[1] });
      let balance = await erc20.balanceOf(accounts[1]);
      balance.should.be.bignumber.equal(ether(150000));
      let totalTokensSold = await privateSale.totalTokensSold();
      let bonus = ether(150000 * 0.35);
      let bonusAssigned = await privateSale.bonusHolders(accounts[1]);
      totalTokensSold.should.be.bignumber.equal(bonus.add(balance));
      let BNB_balance = await binanceCoin.balanceOf(privateSale.address);
      BNB_balance.should.be.bignumber.equal(ether(15000/11));
    });

    it('should accept Credits Token', async () => {

      await creditsToken.approve(privateSale.address, '0x' + BigNumber(10).pow(6).multipliedBy(15000).toString(16), { from: accounts[1] });
      await privateSale.contributeInCreditsToken({ from: accounts[1] });
      let balance = await erc20.balanceOf(accounts[1]);
      balance.should.be.bignumber.equal(ether(15000*12/0.10));
      let totalTokensSold = await privateSale.totalTokensSold();
      let bonus = ether(0.40 * 15000*12/0.10);
      let bonusAssigned = await privateSale.bonusHolders(accounts[1]);
      totalTokensSold.should.be.bignumber.equal(bonus.add(balance));
      let creditsTokenBalance = await creditsToken.balanceOf(privateSale.address);
      assert(creditsTokenBalance.toString(16) == BigNumber(10).pow(6).multipliedBy(15000).toString(16));
    });

    it('different bonus', async () => {
      const _accounts = [accounts[2], accounts[3]];
      const _value = [ether(15000/11),  ether(250000/11)];
      const tokenBalances = [ether(150000), ether(2500000)];
      const bonuses = [ether(150000 * 0.35), ether(2500000 * 0.50)];
      await privateSale.addManyWhitelist(_accounts);
      for(let i=0;i<_accounts.length;i++) {
        await binanceCoin.transfer(_accounts[i], _value[i], { from: accounts[1] });
        await binanceCoin.approve(privateSale.address, _value[i], {from: _accounts[i]});
        await privateSale.contributeInBNB({ from: _accounts[i] });
        let b = await erc20.balanceOf(_accounts[i]);
        b.should.be.bignumber.equal(tokenBalances[i]);
        let bonus = await privateSale.bonusHolders(_accounts[i]);
        bonus.should.be.bignumber.equal(bonuses[i]);
      }

    })

    it('should not accept from non whitelisted', async () => {
      assert(await privateSale.whitelist(accounts[2]) == false);
      await binanceCoin.transfer(accounts[2], ether(3000), { from: accounts[1] });
      await binanceCoin.approve(privateSale.address, ether(3000));
      await privateSale.contributeInBNB({ from: accounts[1] }).should.be.rejectedWith(EVMRevert);
    })

    it('should not accept from non whitelisted', async () => {
      assert(await privateSale.whitelist(accounts[2]) == false);
      await binanceCoin.transfer(accounts[2], ether(3000), { from: accounts[1] });
      await binanceCoin.approve(privateSale.address, ether(3000));
      await privateSale.contributeInBNB({ from: accounts[1] }).should.be.rejectedWith(EVMRevert);
    });
    it('accept eth', async () => {
      await privateSale.setEtherPrice(1500000);
      await privateSale.sendTransaction({ value: ether(1), from: accounts[1] })
      let Balance = await erc20.balanceOf(accounts[1]);
      let Bonus = await privateSale.bonusHolders(accounts[1]);

      await privateSale.sendTransaction({ value: ether(0.25), from: accounts[1] })
      let bonusPercentage = await privateSale.bonusPercentages(accounts[1]);
      let additionalBonus = ether(0.25*150000*0.35)
      let b = await privateSale.bonusHolders(accounts[1]);
      Bonus.add(additionalBonus).should.be.bignumber.equal(b);

    });
  });

  describe('Finalization', () => {
    let privateSale;
    let erc20;
    let endingTime;
    let bonus;
    const tokenPriceInCents = 10;
    const etherPriceInCents = 3000000;
    const binanceCoinPriceInCents = 1100;
    const creditsTokenPriceInCents = 100;
    const minContributionInUSDCents  = 15000;
    beforeEach(async () => {
      const openingTime = await latestTime() + 10;
      endingTime = openingTime + duration.days(10);
      const binanceCoin = accounts[1];
      const creditsToken = accounts[2];
      erc20 = await Token.new(accounts[0], ether(2*526500));
      privateSale = await PrivateSale.new(openingTime, endingTime, binanceCoin, creditsToken, erc20.address);
      await increaseTimeTo(openingTime + 10);
      await privateSale.addWhitelist(accounts[1]);
    });

    it('rejects contributions before initialize crowdsale', async () => {
      await privateSale.sendTransaction({ value: ether(0.5) , from: accounts[1] }).
      should.be.rejectedWith(EVMRevert);
    });

    it('hasClosed should return true when max Tokens have been sold', async () => {
      await erc20.approve(privateSale.address, ether(150000* 1.35));
      await privateSale.initializePrivateSale(etherPriceInCents, tokenPriceInCents, binanceCoinPriceInCents, creditsTokenPriceInCents, minContributionInUSDCents);
      let bonus = await privateSale.calculateBonus(ether(150000), 3000000);
      await privateSale.sendTransaction({ value: ether(0.5) , from: accounts[1] });
      let balance = await erc20.balanceOf(accounts[1]);
      balance.should.be.bignumber.equal(ether(150000));
      let totalTokensSold =  await privateSale.totalTokensSold();
      let totalSaleAllocation = await privateSale.totalSaleAllocation();
      let bonus1 = await privateSale.bonusHolders(accounts[1]);
      assert(await privateSale.hasClosed() == true);
    });

    it('hasClosed returns true when time has crossed the closing time', async () => {
      await increaseTimeTo(endingTime);
      assert(await privateSale.hasClosed() == true);
    });

    it('finalize crowdsale can be called only after the hasClosed has returned true', async () => {
      await erc20.approve(privateSale.address, ether(150000* 1.35));
      await privateSale.initializePrivateSale(etherPriceInCents, tokenPriceInCents, binanceCoinPriceInCents, creditsTokenPriceInCents, minContributionInUSDCents);
      await privateSale.sendTransaction({ value: ether(0.5), from: accounts[1] });
      await increaseTimeTo(endingTime + 10);
      assert(await privateSale.hasClosed());
      await privateSale.addAdmin(accounts[3]);
      let bonusProvided = await privateSale.bonusProvided();
      let balanceOfPrivateSale = await erc20.balanceOf(privateSale.address);
      await privateSale.finalizeCrowdsale({ from: accounts[3] });
      let balanceOfAdmin = await erc20.balanceOf(accounts[3]);
      balanceOfAdmin.should.be.bignumber.equal(balanceOfPrivateSale.sub(bonusProvided));
    });

    it('finalize crowdsale cannot be called by non-admin', async () => {
      await erc20.approve(privateSale.address, ether(150000* 1.35));
      await privateSale.initializePrivateSale(etherPriceInCents, tokenPriceInCents, binanceCoinPriceInCents, creditsTokenPriceInCents, minContributionInUSDCents);
      await increaseTimeTo(endingTime + 10);
      await privateSale.finalizeCrowdsale( { from: accounts[3] }).should.be.rejectedWith(EVMRevert);
    });

    it('finalize crowdsale cannot be called twice', async () => {
      await erc20.approve(privateSale.address, ether(150000* 1.35));
      await privateSale.initializePrivateSale(etherPriceInCents, tokenPriceInCents, binanceCoinPriceInCents, creditsTokenPriceInCents, minContributionInUSDCents);
      await increaseTimeTo(endingTime + 10);
      await privateSale.finalizeCrowdsale();
      await privateSale.finalizeCrowdsale().should.be.rejectedWith(EVMRevert);
    });
  });
});
