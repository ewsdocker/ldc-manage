# ldc-manage


Notes
=====

ldc-manage

	container  
		<container-name>
			run [<parameters>]
			create [<parameters>]
			start [<parameters>]

	template 
		<container-name>
			<template-name>
				add
				edit
				remove

	templates
		list
		load 
			<version>
			latest
		reload 
			<version>
			latest
		remove 
			<version>
		update
		use 
			<version>
			latest
		custom
			<version>-<custom-name>

	utilities
		list
		load 
			<version>
			latest
		reload 
			<version>
			latest
		remove 
			<version>
		update
		use 
			<version>
			latest
			
	utility
		<version>
			custom
				<custom-name>
					addlib <lib-name>
					editlib <lib-name>
					rmlib <lib-name>
					mvlib <lib-name> <new-lib>
					copylib <lib-name> <new-lib>
