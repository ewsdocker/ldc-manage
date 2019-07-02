# ldc-manage


Notes
=====

ldc-manage

	container  
		<container-name>
			run 
				[<parameters>]
			create 
				[<parameters>]
			start 
				[<parameters>]
			template 
				<template-name>
					add 
						<fq-file-name>
					edit
					remove
					copy 
						<fq-destination-file> | <fq-template-name>

	template
		custom
			<version> | latest
				<version>-<custom-name>
		generate
			<version> | latest
				<version>-<custom-name>
		list
		load 
			<version> | latest
		reload 
			<version> | latest
		remove 
			<version> | latest
		update

	utilities
		cp 
			<version> | latest
				<version>-<custom-name>
		generate
			<version> | latest
				<version>-<custom-name>
	    library 
			[ <version> | latest ]
				add  
					<lib-name> <fq-file-name>
				edit 
					<lib-name> 
				rm   
					<lib-name> 
				mv   
					<lib-name> <fq-file-name>
				cp   
					<lib-name> <fq-file-name>
		list
		load 
			[ <version> | latest ]
		reload 
			[ <version> | latest ]
		remove 
			<version>
		script
			[ <version> | latest ]
				add  
					<script-name> <fq-file-name>
				edit 
					<script-name>
				rm   
					<script-name>
				mv   
					<script-name> <fq-file-name>
				cp   
					<script-name> <fq-file-name>
		update
			[ <version> | latest ]
		use 
			[ <version> | <version-<custom-name> | latest ]

