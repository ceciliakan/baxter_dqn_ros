local classic = require 'classic'
--require 'image'

--local BaxterEnv, super = classic.class('BaxterEnv', Env)
--local BaxteEnv = {};
Account = classic.class('Account')

function Account:create(balance)
	self.balance = balance
end

function Account:withdraw(amount)
	self.balance = self.balance - amount
end

acc = Account:create(1000)
print("balance1:")
print(acc.balance)
acc:withdraw(100)
print("balance2:")
print(acc.balance)