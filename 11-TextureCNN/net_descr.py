import torch.nn as nn
import torch

def print_network(model, name):
	num_params=0
   	for p in model.parameters():
        	num_params+=p.numel()
    	print(name)
    	print(model)
    	print("The number of parameters {}".format(num_params))
	print("Sizes:")
	sizes=[(30,1,128,128), (30,35,63,63), (30,32,10,10), (30,30,1,1), (30,30), (30,28), (30,25)]
	for i in range(7):
		print(sizes[i])

class Net(nn.Module):
	def __init__(self):
		super(Net, self).__init__()
		self.conv1 = nn.Conv2d(1, 35, kernel_size=3) 
		self.relu1 = nn.ReLU()
		self.pool1 = nn.MaxPool2d(kernel_size=2)
		self.btch1 = nn.BatchNorm2d(35)

		self.conv2 = nn.Conv2d(35,32, kernel_size=3,stride=3)
		self.relu2 = nn.ReLU()
		self.pool2 = nn.MaxPool2d(kernel_size=2)
		self.drop1 = nn.Dropout()
		self.btch2 = nn.BatchNorm2d(32)

		self.conv3 = nn.Conv2d(32, 30, kernel_size=5,stride=5)
		self.relu3 = nn.ReLU()
		self.pool3 = nn.MaxPool2d(kernel_size=2)
		self.drop2 = nn.Dropout()
		self.btch3 = nn.BatchNorm2d(30)
      
		self.fc = nn.Linear(30,28)
		self.drop3 = nn.Dropout()
		self.fc2 = nn.Linear(28, 25)


	def training_params(self):
        	self.optimizer = torch.optim.SGD(self.parameters(), lr=0.001, momentum=0.9, weight_decay=0.0)
        	self.Loss = nn.CrossEntropyLoss()

if __name__=='__main__':
       model=Net()

       model.training_params()
       print_network(model, 'Conv network')    

