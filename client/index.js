const Web3 = require('Web3');
const Charity = require('./contracts/Charity.json');
// const Token = require('./contracts/Token.json');
// const Voting = require('./contracts/Voting.json');
//const Staking = require('./contracts/Staking.json');
const { Contract } = require('web3-eth-contract');

const init = async() => {
    // You might want to check truffle deploy address for this 
    const web3 = new Web3('http://127.0.0.1:9545/');
    /*
        The address of TokenMinter might different per machine
        Thus, you should check your TokenMinter's address after deploy it and change accordingly
    */
    const charityContract = await new web3.eth.Contract(Charity.abi, '0xD448F1717087092f74096ce9840a663Bc8f1c7d5');
    //different blockchain have different base gas price

    await charityContract.methods.CreateCampaign('name', 'details', 1000, '0x27426a5188c67ae4a839d087445b79410b4d0062').send({
        from: '0x27426a5188c67ae4a839d087445b79410b4d0062',
        gasPrice: 899272991,
        gas: 2310334
    })

    let { name, details, goal, owner, fund, isOpened, isVoting } = await charityContract.methods.get_Campaign_Info(6).call()
    console.log(name, details, goal, owner, fund, isOpened, isVoting);


    /*
        await Contract.methods.transfer('0x75073657b2ff9e6e6b51cdb19dbfb3fc67c8cedf', 10000);





        //const Token = await new web3.eth.Contract(Token.abi, '0x9499e4Fcf505a7Cd1886D169197143fc6F661657');




        const Voting = await new web3.eth.Contract(Voting.abi, '0x0dC8605c991DDBA9747a616277EBf2e2993c180d');
        const _total_voted = await Contract.methods._total_voted().call();
        const _accept_vote = await Contract.methods._accept_vote().call();
        console.log(_total_voted, _accept_vote);
        //     const Staking = await new web3.eth.Contract(Staking.abi, '0x6736dAd4FF46fFF9706C33Da6B2C73bBccdAa5c8');*/
}
init();