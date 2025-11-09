# U9-Network-Helper  
Personal/School project to simplify the configuration of Ubuntu 9.04.
## 🤔 Why?  
During the process of configuring an Ubuntu Server 9.04 network I realized that the process could be quite slow and susceptible to human error. In order to streamline as well as mitigate possible mistakes, I intend to make a bash script to help me (and hopefully other people) configure Ubuntu.  
Furthermore, I am focusing only on the old Ubuntu server and I have no plans to support other distros.  
## ⚙️ Current Features
- Ethernet Adapter Configuration Helper(TESTING);
## 🚧 Planned Features:
- Automatically change sources.list so it uses old repositories instead;
- DHCP configuration helper;
- Automatically install dhcp3-package (I may add more network packages in the future...);
- *More features planned...*
## 🧪 For testing:
Download the source code and make sure to change '[instance folder directory](https://github.com/Celephais21/U9-Network-Helper-WIP/blob/dfd2f3a0888d4aeca6226b09b79b6e98bc929eb6/config.sh#L12)' before running  
To use, run main.sh with the command `bash main.sh` in the folder where you downloaded the archive.  
Currently, there is no need to execute the script with sudo (in fact, it will throw a warning if you do).
