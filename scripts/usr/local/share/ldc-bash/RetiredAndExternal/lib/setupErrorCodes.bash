# *******************************************************
# *******************************************************
#
#	DEPRECATED 05-26-2016 - replaced with startupFunctions 
#								functionality
#
#   setupErrorCodes.bash
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 0.0.1 - 02-24-2016.
#					0.0.2 - 03-20-2016.
#
# *******************************************************
# *******************************************************

declare -r lmslib_setupErrorCodes="0.0.2"	# version of library

# *******************************************************
#
#    lmsErrorInitialize
#
#		add error codes and messages to the proper error
#			arrays
#
# *******************************************************
lmsErrorInitialize()
{
	errorAddCode EndOfTest		"The test has ended successfully."
	errorAddCode EndInError		"The test has ended unsuccessfully."

	errorAddCode None         	"No error occured."
	errorAddCode Unknown   		"Unknown error."
	errorAddCode InvalidCode		"Invalid/unknown error code."

	errorAddCode EmptyParams 	"No parameters were provided."
	errorAddCode MissAssign		"Parameter name missing value assignment"
	errorAddCode ParamErrors  	"Parameter errors were detected."
	errorAddCode NotNumeric		"Parameter is not all numeric."
	errorAddCode DeclareError	"Declaration error."
	
	errorAddCode NotRoot			"Must be run as root."
	errorAddCode NotUser			"Must be run by a sudo user."

	errorAddCode QueueInit		"Unable to initialize error queue."
	errorAddCode QueueCount		"Cannot get error queue size - invalid queue name"
	errorAddCode QueuePop		"Error Queue pop error."
	errorAddCode QueuePeek		"Error Queue peek error."
	errorAddCode QueueReset		"Unable to reset queues."

	errorAddCode StackUnknown	"Unknown stack name"
	errorAddCode StackSize		"Invalid stack size"
	errorAddCode StackCreate 	"Open/create stack error."
	errorAddCode StackSet 		"Set stack error."
	errorAddCode StackDestroy	"Destroy stack error."
	errorAddCode StackEmpty		"Empty stack."
	errorAddCode StackIndex		"Invalid index"
	errorAddCode lmsStackWrite	"Write stack head error."

	errorAddCode NSLength		"Namespace name LENGTH error"
	errorAddCode NSGet			"Namespace GET error"
	errorAddCode NSGenUid		"Namespace generate uid error"

	errorAddCode NsxStackError	"NamespaceExt unable to create a stack"
	errorAddCode NsxParse		"NamespaceExt parse error."
	errorAddCode NsxGet			"NamespaceExt get error."
	errorAddCode NsxSet			"NamespaceExt set error."

	errorAddCode lmsUIdGenerate		"UID Generate error"
	errorAddCode UidEmpty		"UID Register error"
	errorAddCode lmsUIdExists		"UID Register existing id"
	errorAddCode UidNotFound		"UID Not Found"

	errorAddCode MaxLoopXcd		"UID Generate Max loops exceeded"

	errorAddCode XmlError		"XML Error."
	errorAddCode XmlInfo			"XML Information."

	errorAddCode SvnRepository	"SVN Repository error."

	return 0
}

# *******************************************************
# *******************************************************
#
#
#
# *******************************************************
# *******************************************************

