pushd %~dp0\..
start ganache-cli -s0 --gasLimit 672197500 --gasPrice 100000
call truffle migrate
npm run dev


