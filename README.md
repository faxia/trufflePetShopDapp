# Truffle搭建一个简易版的宠物收养Dapp 
**写在前面**
之前一直是在remix-ide上面编写智能合约，然后开发dapp前端，若想通过这种方式可以参考百度云区块链的教程
教程链接：https://cloud.baidu.com/doc/BBE/DevRef.html#.85.E2.02.85.99.E3.AA.D8.B7.75.57.37.C7.67.5D.CE
想在想体验一下通过truffle开发一个DApp，毕竟[https://github.com/trufflesuite/truffle](truffle)致力于让以太坊以太坊上的开发变得简单，有以下特点：
 - 内置智能合约编译、链接、部署和二进制字节码管理 
 - 针对快速迭代开发的自动化合约测试 
 - 可脚本化，可扩展的部署和迁移框架 
 - 网络管理，用于部署到任意数量的公共和私有网络 
 - 使用EthPM和NPM进行包安装管理 
 - 用于直接合约通信的交互式控制台 
 - 支持持续集成的可配置构建管道 
 - 外部脚本运行程序可以在Truffle环境中执行脚本 
 - 提供了合约抽象接口 
 - 提供了控制台，使用框架构建后，可以直接在命令行调用输出结果，可极大方便开发调试

**1. 开发环境配置**
 - Node v9.11.2
 - npm 5.6.0
 拥有以上开发环境后，我们可以使用命令行安装Truffle
```npm install -g truffle```
可以使用下面语句来确认是否安装成功
```truffle version```
另外我们需要Ganache来模拟以太坊本地开发环境。你可以点击下载[http://truffleframework.com/ganache](http://truffleframework.com/ganache)

**2.、 使用Truffle Box创建一个新项目， 在文件夹中初始化Truffle项目**
```
mkdir trufflePetShopDapp
cd trufflePetShopDapp
```
**3. Truffle已经为本教程内置了一份代码，使用truffle unbox来释放这份代码**

```truffle unbox pet-shop```
**4. 编写智能合约**
 在目录 contracts/ 中创建新文件 Adoption.sol
```
pragma solidity ^0.5.0;

contract Adoption {
    address[16] public adopters;
    // 购买一只宠物
    function adopt(uint petId) public returns (uint) {
        require(petId >= 0 && petId <= 15);
        adopters[petId] = msg.sender;
        return petId;
    }
    // 获取购买用户
    function getAdopters() public view returns (address[16] memory) { 
        return adopters; 
    }
}
````
**5.  编译**
1、打开终端并进入项目所在的目录

truffle compile
运行此命令后，你将会看到如下：

Compiling ./contracts/Migrations.sol...
Compiling ./contracts/Adoption.sol...
Writing artifacts to ./build/contracts
**6. 部署**
添加我们的部署脚本。

1、在 migrations/ 目录中创建文件 2_deploy_contracts.js

2、在 2_deploy_contracts.js 文件中添加代码

var Adoption = artifacts.require("Adoption");

module.exports = function(deployer) {
  deployer.deploy(Adoption);
};
3、在我们部署智能合约之前，我们要让区块链运行起来。我们前面提到了Ganache，在这里我们使用它模拟开发环境中的以太坊环境。通常Ganache会运行在7545端口
![图片](http://agroup-bos.cdn.bcebos.com/3f60fd8ad757916148c46582fbe30ff98cd61426)
4、回到我们的终端，部署我们的智能合约
```truffle migrate```
命令运行后我们可以看到：
![图片](http://agroup-bos.cdn.bcebos.com/2b9be662d36b041ee8f7274cda4c0ed399e71ad6)
ps: 如果报再执行truffle migrate 报如下错，可用truffle migrate --reset 解决
![图片](http://agroup-bos.cdn.bcebos.com/fd4cfdcd4f5fed586338c85d018d3a5b164b5314)
**7. 测试合约**
在test文件下新建TestAdoption.sol文件，添加如下代码
```
pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Adoption.sol";

contract TestAdoption {
    Adoption adoption = Adoption(DeployedAddresses.Adoption());

    // Testing the adopt() function
    function testUserCanAdoptPet() public {
        uint returnedId = adoption.adopt(8);

        uint expected = 8;

        Assert.equal(returnedId, expected, "Adoption of pet ID 8 should be recorded.");
    }
    
    // Testing retrieval of a single pet's owner
    function testGetAdopterAddressByPetId() public {
        // Expected owner is this contract
        address expected = address(this);

        address adopter = adoption.adopters(8);

        Assert.equal(adopter, expected, "Owner of pet ID 8 should be recorded.");
    }
}
```
**8.运行测试代码**
```
truffle test
```
效果截图如下
![图片](http://agroup-bos.cdn.bcebos.com/4cc18b9b30c4ba228e628da3f77a90bfc5ed07f4)

**9. 创建用户界面与智能合约交互**

我们已经编写完合约，并且部署在本地测试环境中并缺确定它能在命令行中进行交互。现在我们要开始创建UI界面来使用它。

使用Truffle Box来创建的pet-shop代码中已经包含了前端界面，在 src/ 目录中

**10. web3实例化**
1、打开 /src/js/app.js

2、打开这个文件你会注意到，全局变量App控制着应用，init（）方法加载数据，然后调用了initWeb3（）。web3提供了与以太坊交互的接口

3、删除 initWeb3 中的注释并替换成如下代码
```
// Is there an injected web3 instance? 
if (typeof web3 !== 'undefined') {
  App.web3Provider = web3.currentProvider; 
} else { 
// If no injected web3 instance is detected, fall back to Ganache
  App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545'); 
}
web3 = new Web3(App.web3Provider);
```
**11. 合约实例化**
我们已经能通过web3和以太坊交互了，我们还需要实例化我们的智能合约，这样web3才知道要去哪里找到并执行我们的智能合约。Truffle包含的truffle-contract库文件来帮我们做这件事。它存储了合约部署的信息，所以你不需要手动更改合约部署地址。

1、还是在/src/js/app.js文件中， 删除initContract 中的注释，并替换成以下代码：
```
$.getJSON('Adoption.json', function(data) {
  // Get the necessary contract artifact file and instantiate it with truffle-contract
  var AdoptionArtifact = data;
  App.contracts.Adoption = TruffleContract(AdoptionArtifact);

  // Set the provider for our contract
  App.contracts.Adoption.setProvider(App.web3Provider);

  // Use our contract to retrieve and mark the adopted pets
  return App.markAdopted();
});
```
**12. 获取购买的宠物并更新UI界面**
1、还是在/src/js/app.js文件中，删除markAdopted 中的注释并替换成如下代码：
```
var adoptionInstance;

App.contracts.Adoption.deployed().then(function(instance) {
  adoptionInstance = instance;

  return adoptionInstance.getAdopters.call();
}).then(function(adopters) {
  for (i = 0; i < adopters.length; i++) {
    if (adopters[i] !== '0x0000000000000000000000000000000000000000') {
      $('.panel-pet').eq(i).find('button').text('Success').attr('disabled', true);
    }
  }
}).catch(function(err) {
  console.log(err.message);
}); 
```
**13. 执行adopt（）方法**
1、handleAdopt 下面替换成如下代码
```
var adoptionInstance;

web3.eth.getAccounts(function(error, accounts) {
  if (error) {
    console.log(error);
  }

  var account = accounts[0];

  App.contracts.Adoption.deployed().then(function(instance) {
    adoptionInstance = instance;

    // Execute adopt as a transaction by sending account
    return adoptionInstance.adopt(petId, {from: account});
  }).then(function(result) {
    return App.markAdopted();
  }).catch(function(err) {
    console.log(err.message);
  });
});
```
**14. 在浏览器中使用dapp**
1、使用chrome

2、安装metamask
在chrome扩展程序中加入metamask，根据提示注册账户进入

3、导入钱包，使用Ganache中的助记词（助记词是Ganache里面提）
![图片](http://agroup-bos.cdn.bcebos.com/9ceb91b1c79d8e95dfb134c47d254bf8e8ee5edb)
4、切换网络至自定义RPC
![图片](http://agroup-bos.cdn.bcebos.com/3c0ae7af248dcc8a854c08abaf53ece5edb76a2b)
5、在"New RPC URL"中输入http://127.0.0.1:7545，并保存
![图片](http://agroup-bos.cdn.bcebos.com/8575817a380751ede85a66bc782b998861860014)

**15. 安装配置lite-server**
使用truffle框架时，这些已经配置好了

16. 使用你的app吧
1、在终端中trufflePetShopDapp路径下执行
```npm run dev```
2、会自动打开http://localhost:3000，界面如下所示
![图片](http://agroup-bos.cdn.bcebos.com/da25287f01d72db6d8b2d7fab58afb4759677a8a)
3、点击adopt购买，MetaMask Notification 将允许交易
![图片](http://agroup-bos.cdn.bcebos.com/9498399254b34ceb685614e83f248c6b18b37df9)
4、余额足的情况下确认即可
![图片](http://agroup-bos.cdn.bcebos.com/7082721d2fdea7892b5ad46fdceb68461dbab83b)
5、交易完成后metamask中会有你的交易记录
![图片](http://agroup-bos.cdn.bcebos.com/e6b55a4f194fcae2cc5e88c6ba1d15fa84d7af7c)

相关链接：
truffle搭建DApp： https://zhuanlan.zhihu.com/p/35076425
github：https://github.com/faxia/trufflePetShopDapp
remix-ide + react开发UI版教程链接：https://cloud.baidu.com/doc/BBE/DevRef.html#.85.E2.02.85.99.E3.AA.D8.B7.75.57.37.C7.67.5D.CE