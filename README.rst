============================================
Autoprovisioning Script for OpenSwitch
============================================

Script used to configure switches on startup


Link to SIG Wiki
============================================

	https://rndwiki.corp.hpecorp.net/confluence/display/hpnevpg/Autoprovisioning+Script


Usage
============================================

	1) Find the mac address of your switch (cat /sys/class/net/eth0/address)
	2) Create a configuration/setup file for your switch and save to http server.
	3) Name the file with your setup (eg. Spine01)
	4) Make sure all the config files provide access permission to all users -777
	5) Edit the Mapping.txt file by adding the mac address (step 1) and the name of your configuration file (step 2)
	6) Make sure the demo.sh, Mapping.txt, and the corresponding configuration files are in the HTTP server folder.
	7) Force autoprovisioining by one of two methods below:
		a) Reset your switch to factory settings (MUST uninstall OS via ONIE) to allow autoprovisioning.
		b) In Linux prompt, issue these commands:
			i. rm /var/local/autoprovision
			ii. reboot
	
~

