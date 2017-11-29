pushd %~dp0\..
start testrpc -s0x0 --gasLimit 672197500 --gasPrice 100000000000
call truffle migrate
npm run dev


