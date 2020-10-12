# *********************************************************************************
# *********************************************************************************
#
#   ldcLLRBTree.sh
#
#		Left-Leaning Red-Black Tree
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.2
# @copyright © 2016, 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage llrbNode
#
# *****************************************************************************
#
#	Copyright © 2016, 2017. EarthWalk Software
#	Licensed under the Academic Free License, version 3.0.
#
#	Refer to the file named License.txt provided with the source,
#	or from
#
#			http://opensource.org/licenses/academic.php
#
# *****************************************************************************
#
#			Version 0.0.1 - 04-01-2016.
#					0.0.2 - 02-25-2017.
#
# *********************************************************************************
# *********************************************************************************

declare    ldclib_ldcLLRBTree="0.0.2"	# library version number

# *****************************************************************************

declare -A ldcLLRB_tTable=()					# treeName = treeUid
declare -A ldcLLRB_nTable						# ldcLLRB_nTable[key]=UID

declare    ldcLLRB_tUid=""						# current tree uid (after lookup)
declare    ldcLLRB_tName=""						# current tree name
declare    ldcLLRB_tRoot=""						# current tree root

declare    ldcLLRB_tNode=""						# temporary node for key search/insertion

declare    ldcLLRB_tStack="ldcLLRB_tRecurse"	# name of the recursion stack
declare    ldcLLRB_tStackUid=""					# name of the recursion stack

# *****************************************************************************

#
#	Each tree structure will have the following variables automatically declared:
#
#declare	ldcLLRB_tRoot_UID			# the key for the root node
#declare	ldcLLRB_tNodes_UID			# number of nodes in the tree

# *****************************************************************************

declare -a ldcLLRB_nField=( 'key' 'data' 'left' 'right' 'color' 'uid' )

declare -r ldcLLRB_nRED=1
declare -r ldcLLRB_nBLACK=0

declare -r ldcLLRB_nLEFT=1
declare -r ldcLLRB_nRIGHT=0

declare    ldcLLRB_nVarKey=""

# ***********************************************************************************************************
#
#	ldcLLRBtCreate
#
#		Create a new llrb tree and initialize the entries
#
#	parameters:
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
function ldcLLRBtCreate()
{
	ldcLLRB_tName=$1
	ldcLLRB_tUid=""

	ldcLLRBtLookup "${ldcLLRB_tName}" ldcLLRB_tUid
	if [[ $? -ne 1 ]]
	then
		ldcErrorQWrite $LINENO NodeCreate "Node '${ldcLLRB_tName}' already exists, uid = '${ldcLLRB_tUid}'"
		return 1
	fi

	ldcUIdUnique ldcLLRB_tUid
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeCreate "Unable to get Unique id"
		return $?
	fi

	ldcDynaSetAt ${ldcLLRB_tTable} "${ldcLLRB_tName}" "$ldcLLRB_tUid"

	ldcDeclareStr "ldcLLRB_tRoot_${ldcLLRB_tUid}" "0"                     ############################## what?
	ldcLLRBtRoot "$ldcLLRB_tName"

	ldcStackCreate $ldcLLRB_tStack ldcLLRB_tStackUid
	if [[ $? -ne 0 ]]
	then
		return 1
	fi

	return 0
}

# ***********************************************************************************************************
#
#	ldcLLRBtCreateN
#
#		Create a new (temporary) node
#
#	parameters:
#		treeName = name of the tree to create keynode for
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
function ldcLLRBtCreateN()
{
	llkey="${1}"
	lldata=${2:-0}

	local llUid=""

	ldcLLRBnLookup "${llkey}" llUid
	[[ $? -eq 0 ]] ||
	 {
		ldcLLRBnSet ${llkey} "data" "${lldata}"
		[[ $? -eq 0 ]] || return 1

#		ldcErrorQReset	  # ignore node errors, such as 'not found' before it was created
		return 2
	 }

	ldcLLRBnCreate "${llkey}" llUid "${lldata}"
	[[ $? -eq 0 ]] || return 1
	
	return 0
}

# ***********************************************************************************************************
#
#	ldcLLRBtLookup
#
#		get the llrbTree key uid
#
#	parameters:
#		name = the name of the tree to search for
#
#	outputs:
#		uid = llrbTree Uid
#
#	returns:
#		0 = found in table, uid is valid
#		1 = not found in table, uid is invalid
#
# *********************************************************************************
function ldcLLRBtLookup()
{
	local llrbTName="${1}"

	[[ -z "${ldcLLRBtTable[$llrbTName]}" ]] && return 1

	ldcLLRB_tName="$llrbTName"
	ldcLLRB_tUid="$ldcLLRBtTable[$llrbTName]"
	ldcLLRB_tRoot="$ldcLLRB_tRoot_${ldcLLRB_tUid}"

	if [[ -n "${2}" ]]
	then
		ldcDeclareStr ${2} "${ldcLLRB_tUid}"
	else
		echo "$ldcLLRB_tUid"
	fi

	return 0
}

# *********************************************************************************
#
#	ldcLLRBtRoot
#
#		Set the root value for the selected tree
#
#	Parameters:
#		treeName = name of the tree to set root for
#		root     = root value to set selected tree root to
#					(if empty, sets root to selected tree root)
#
#	Returns:
#		0 = no error
#		1 = error occurred
#
# *********************************************************************************
function ldcLLRBtRoot()
{
	local lltree="${1:-$ldcLLRB_tName}"
	local llroot="${2}"
	local llUid

	if [[ -n "$llroot" ]]
	then
		eval "ldcLLRB_tRoot_${ldcLLRB_tUid}='${llroot}'"
	else
		eval 'ldcLLRB_tRoot=$'"{ldcLLRB_tRoot_$ldcLLRB_tUid}"
	fi

	return 0
}

# *********************************************************************************
# *********************************************************************************

# *********************************************************************************
#
#	ldcLLRBtFlipC
#
#		Flip the colors of the node and it's 2 children (if they exist)
#
#	parameters:
#		node = the name of the node to flip colors in
#
#	returns:
#		0 = no error
#		1 = error code
#
# *********************************************************************************
function ldcLLRBtFlipC()
{
	local llnode="$1"
	local llchild
	local llcolor

	ldcLLRBn_Field $llnode "color" llcolor
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeFlipColors "Unable to get color for '$llnode'."
		return 1
	fi

	let llcolor=($llcolor+1)%2
	ldcLLRBn_Field $llnode "color" llcolor $llcolor
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeFlipColors "Unable to set color for '$llnode'."
		return 1
	fi

	ldcLLRBn_Field $llnode "left" llchild
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeFlipColors "Unable to get left child for '$llnode'."
		return 1
	fi

	if [[ "${llchild}" != "0" ]]
	then
		ldcLLRBn_Field $llchild "color" llcolor
		if [[ $? -ne 0 ]]
		then
			ldcErrorQWrite $LINENO TreeFlipColors "Unable to get color for '$llchild'."
			return 1
		fi

		let llcolor=($llcolor+1)%2

		ldcLLRBn_Field $llchild "color" llcolor $llcolor
		if [[ $? -ne 0 ]]
		then
			ldcErrorQWrite $LINENO TreeFlipColors "Unable to set color for '$llchild'."
			return 1
		fi
	fi

	ldcLLRBn_Field $llnode "right" llchild
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeFlipColors "Unable to get right child for '$llnode'."
		return 1
	fi

	if [[ "${llchild}" != "0" ]]
	then
		ldcLLRBn_Field $llchild "color" llcolor
		if [[ $? -ne 0 ]]
		then
			ldcErrorQWrite $LINENO TreeFlipColors "Unable to get color of right child of '$llchild'."
			return 1
		fi

		let llcolor=($llcolor+1)%2
		ldcLLRBn_Field $llchild "color" llcolor $llcolor
		if [[ $? -ne 0 ]]
		then
			ldcErrorQWrite $LINENO TreeFlipColors "Unable to set color of right child of '$llchild'."
			return 1
		fi
	fi

	return 0
}

# *********************************************************************************
#
#	ldcLLRBtInsert
#
#		Insert the node into the tree defined by the root, then balance the tree.
#
#	parameters:
#		key = name of the key to insert into the tree
#		data = (optional) data to insert into the node
#
#	returns:
#		0 = no error
#		1 = error code
#
# *********************************************************************************
function ldcLLRBtInsert()
{
	local llkey="${1}"
	local lldata="${2}"

	local llroot
	local llnode

	ldcLLRBnCreate "$llkey" llnode "$lldata"
	[[ $? -eq 0 ]] || return 1

	ldcLLRBtInsertN $llnode $ldcLLRB_tRoot llroot
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeInsert "Unable to insert node '${llkey}' into the tree"
		return 1
	fi

echo "set $llroot color: $ldcLLRB_nBLACK"
ldcConioDisplay "$( ldcLLRBnTS $llroot )"

errorQueueDisplay 1 0 EndOfTest

	ldcLLRBn_Field $llroot "color" $ldcLLRB_nBLACK
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeInsert "Unable to set '${llroot}' color"
		return 1
	fi

echo "llroot: $llroot, ldcLLRB_tName = $ldcLLRB_tName"
	ldcLLRBtRoot "$ldcLLRB_tName" "$llroot"
echo "ldcLLRB_tRoot: $ldcLLRB_tRoot"

	return 0
}

	#protected function insertNode($root, $node)
	#{
	#	if ($root == null)
	#	{
	#		$this->nodes++;
	#		return new LLRBTree\LLRBNode($node->key(), $node->data(), $this->tdetail);
	#	}
	#
	#	switch($root->compare($node))
	#	{
	#	case 0:  // equal
	#		$root->data($node->data());
	#		break;
	#
	#	case -1: // less
	#		$root->left($this->insertNode($root->left(), $node));
	#		break;
	#
	#	case 1:  // greater
	#		$root->right($this->insertNode($root->right(), $node));
	#		break;
	#	}
	#
	#	return $this->fixUp($root);
	#}


# *********************************************************************************
#
#	ldcLLRBtInsertN
#
#		Insert the node into the tree defined by the root, then balance the tree.
#
#	parameters:
#		node = node to insert into the tree
#		root = root node of the tree (or branch)
#		balanced = new root after balancing
#
#	returns:
#		0 = no error
#		1 = error code
#
# *********************************************************************************
function ldcLLRBtInsertN()
{
	local llnode=$1
	local llroot=$2

	local llbranch
	local llchild
	local llresult
	local lldata

ldcConioDisplay "Insert Node: llnode: $llnode"
ldcConioDisplay " $( ldcLLRBnTS $llnode ) "

	if [[ "${llroot}" == "0" ]]
	then
		x="uid"
		ldcLLRBn_Field "$llnode" $x llbranch

errorQueueDisplay 1 1 EndOfTest

		ldcConioDisplay "InsertNode copy -- $llnode to $llbranch"

		ldcLLRBn_Field $llroot 'left' "0"
		ldcLLRBn_Field $llroot 'right' "0"
		ldcLLRBn_Field $llroot 'color' $ldcLLRB_nBLACK

ldcConioDisplay "Root: $llroot"
ldcConioDisplay "$( ldcLLRBnTS $llroot )"

		eval "${3}='${llroot}'"
		return 0
	fi

echo "NodeCompare $llnode with $llroot"

	ldcLLRBnCompare $llnode $llroot
	if [[ $? -lt 0  || $? -gt 2 ]]
	then
		ldcErrorQWrite $LINENO TreeInsertNode "ldcLLRBnCompare returned '$?'."
		return 1
	fi

	llresult=$?

	if [ $llresult -eq 0 ]
	then
		lldata=$( ldcLLRBnGet "$llnode" "key" )
		if [[ $? -ne 0 ]]
		then
			ldcErrorQWrite $LINENO TreeInsertNode "ldcLLRBnGet failed for '$llnode'."
			return 1
		fi

		ldcLLRBnSet $llroot "key" $lldata
		if [[ $? -ne 0 ]]
		then
			ldcErrorQWrite $LINENO TreeInsertNode "ldcLLRBnSet failed for '$llroot'."
			return 1
		fi
	else
		# ##################################################################
		#
		#	llnode > llroot
		#
		#		$root->left($this->insertNode($root->left(), $root));
		#
		#	llnode < llroot
		#
		#		$root->right($this->insertNode($root->right(), $root));
		#
		# ##################################################################

		ldcLLRBt_PushN "$llnode" "$llroot"
		if [[ $? -ne 0 ]]
		then
			ldcErrorQWrite $LINENO TreeInsertNode "Unable to push '$llnode' and '$llroot' on the stack."
			return 1
		fi

		if [ $llresult -eq 1 ]
		then
			llbranch="right"
		else
			llbranch="left"
		fi

		llchild=$( ldcLLRBnGet "$llroot" "$llbranch" )
		if [[ $? -ne 0 ]]
		then
			ldcErrorQWrite $LINENO TreeInsertNode "Unable to get $branch child of '$llroot'."
			return 1
		fi

		ldcLLRBtInsertN $llchild $llnode llchild
		if [[ $? -ne 0 ]]
		then
			ldcErrorQWrite $LINENO TreeInsertNode "Unable to insert '$llchild' node as child of '$llnode'."
			return 1
		fi

		ldcLLRBt_PopN llnode llroot
		if [[ $? -ne 0 ]]
		then
			ldcErrorQWrite $LINENO TreeInsertNode "Unable to pop '$llnode' and '$llroot' from the stack."
			return 1
		fi

		ldcLLRBnSet $llroot "$llbranch" $llchild
		if [[ $? -ne 0 ]]
		then
			ldcErrorQWrite $LINENO TreeInsertNode "ldcLLRBnSet failed for '$llroot'."
			return 1
		fi
	fi

	ldcLLRBtFixUp $llroot llroot
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeInsertNode "ldcLLRBtFixUp failed for '$llroot'."
		return 1
	fi

	eval "${3}='${llroot}'"

	return 0
}

# *********************************************************************************
#
#	ldcLLRBtFixUp
#
#		Balance the tree and fix up the colors on the way up the tree.
#
#	parameters:
#		root = root node of the tree (or branch) to balance
#		deleteOk = 1 if deleting a key node, 0 otherwise
#		fixed = contains the new root of the fixed up tree
#
#	returns:
#		0 = no error
#		1 = error code
#
# *********************************************************************************
function ldcLLRBtFixUp()
{
	local llnode=$1
	local lldelete=${2:-0}

	local llcolor

	local llchild=$( ldcLLRBnGet $llnode "right" )
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeFixUp "ldcLLRBnGet failed to get 'right' child for '$llnode'."
		return 1
	fi

	llcolor=$( ldcLLRBtIsRed $llnode )
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeFixUp "llrbIsRed failed to get 'right' child for '$llnode'."
		return 1
	fi

	if [[ $llcolor -eq $llrbNode_Red ]]
	then
		llchild=$( ldcLLRBnGet $llnode "left" )
		if [[ $? -ne 0 ]]
		then
			ldcErrorQWrite $LINENO TreeFixUp "ldcLLRBnGet failed to get 'left' child for '$llnode'."
			return 1
		fi
	fi

	llcolor=$( ldcLLRBtIsRed $llchild )
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeFixUp "ldcLLRBtIsRed failed to get child for '$llchild'."
		return 1
	fi

	let llcolor=($llcolor+1)%2
	let llcolor+=$lldelete

	if (( ( $lldelete -eq 1) )) || (( ( $llcolor -eq $ldcLLRB_nBLACK ) ))
	then
		ldcLLRBtRotateL $llnode llnode
		if [[ $? -ne 0 ]]
		then
			ldcErrorQWrite $LINENO TreeFixUp "llrbRotateLeft failed to rotate '$llnode'."
			return 1
		fi

		llchild=$( ldcLLRBnGet $llnode "left" )
		if [[ $? -ne 0 ]]
		then
			ldcErrorQWrite $LINENO TreeFixUp "ldcLLRBnGet failed to load left child of '$llnode'."
			return 1
		fi

		llcolor=$( ldcLLRBtIsRed $llchild )
		if [[ $? -ne 0 ]]
		then
			ldcErrorQWrite $LINENO TreeFixUp "llrbIsRedNode failed to get color for '$llnode'."
			return 1
		fi

		if [[ $llcolor -eq $ldcLLRB_nRED ]]
		then
			llchild=$( ldcLLRBnGet $llchild "left" )
			if [[ $? -ne 0 ]]
			then
				ldcErrorQWrite $LINENO TreeFixUp "ldcLLRBnGet failed to get left child for '$llchild'."
				return 1
			fi

			llcolor=$( ldcLLRBtIsRed $llchild )
			if [[ $? -ne 0 ]]
			then
				ldcErrorQWrite $LINENO TreeFixUp "ldcLLRBtIsRed failed for '$llchild'."
				return 1
			fi

			if [[ $llcolor -eq $ldcLLRB_nRED ]]
			then
				ldcLLRBtRotateR $llnode llnode
				if [[ $? -ne 0 ]]
				then
					ldcErrorQWrite $LINENO TreeFixUp "llrbRotateRight failed to rotate '$llnode'."
					return 1
				fi
			fi
		fi
	fi

	llchild=$( ldcLLRBnGet $llnode "left" )
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeFixUp "ldcLLRBnGet failed to load left child of '$llnode'."
		return 1
	fi

	llcolor=$( ldcLLRBtIsRed $llchild )
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeFixUp "llrbIsRedNode failed to get color for '$llnode'."
		return 1
	fi

	if [[ $llcolor -eq $ldcLLRB_nRED ]]
	then
		llchild=$( ldcLLRBnGet $llnode "right" )
		if [[ $? -ne 0 ]]
		then
			ldcErrorQWrite $LINENO TreeFixUp "ldcLLRBnGet failed to load right child of '$llnode'."
			return 1
		fi

		llcolor=$( ldcLLRBtIsRed $llchild )
		if [[ $? -ne 0 ]]
		then
			ldcErrorQWrite $LINENO TreeFixUp "llrbIsRedNode failed to get color for '$llchild'."
			return 1
		fi

		if [[ $llcolor -eq $ldcLLRB_nRED ]]
		then
			ldcLLRBtFlipC $llnode
			if [[ $? -ne 0 ]]
			then
				ldcErrorQWrite $LINENO TreeFixUp "ldcLLRBtFlipC failed to get color for '$llnode'."
				return 1
			fi
		fi
	fi

	eval "${3}='${llnode}'"
	return 0
}

# *********************************************************************************
#
#	ldcLLRBtIsRed
#
#		Check if the node is 'red'
#
#	parameters:
#		name   = the name of the tree to search for
#
#	returns:
#		0 = no error
#		1 = error code
#
# *********************************************************************************
function ldcLLRBtIsRed()
{
	local llkey=$1
	local llcolor=0

	if [[ "$llkey" != "0" ]]
	then
		llcolor=$( ldcLLRBnGet "$llkey" "color" )
		if [[ $? -ne 0 ]]
		then
			ldcErrorQWrite $LINENO TreeModifyNode "Unable to get color from node '${llkey}' for tree '${llrbTName}'."
			return 1
		fi
	fi

	echo "${llcolor}"
}

# *********************************************************************************
#
#	ldcLLRBtRotateL
#
#		Rotate the current to the left
#
#	parameters:
#		name = the name of the tree
#		node = the node to be rotated
#		root = the return value is placed here
#
#	returns:
#		0 = no error
#		1 = error code
#
# *********************************************************************************
function ldcLLRBtRotateL()
{
	local llnode=$1
	local llroot
	local llchild
	local llcolor

	llroot=$( ldcLLRBnGet $llnode "right" )
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeRotate "ldcLLRBtRotateL failed to get RIGHT for '$llnode'."
		return 1
	fi

	llchild=$( ldcLLRBnGet $llroot "left" )
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeRotate "ldcLLRBtRotateL failed to get left child for '$llroot'."
		return 1
	fi

	ldcLLRBnSet $llnode "left" $llchild
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeRotate "ldcLLRBtRotateL failed to get left child for '$llchild'."
		return 1
	fi

	ldcLLRBnSet $llroot "left" $llnode
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeRotate "ldcLLRBtRotateL failed to get left child for '$llroot'."
		return 1
	fi

	llcolor=$( ldcLLRBnGet $llnode "color" )
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeRotate "ldcLLRBtRotateL failed to get left child for '$llroot'."
		return 1
	fi

	ldcLLRBnSet $llroot "color" $llcolor
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeRotate "ldcLLRBtRotateL failed to get left child for '$llroot'."
		return 1
	fi

	ldcLLRBnSet $llnode "color" $ldcLLRB_nRED
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeRotate "ldcLLRBtRotateL failed to get left child for '$llroot'."
		return 1
	fi

	eval '${2}='"llroot"

	return 0
}

# *********************************************************************************
#
#	ldcLLRBtRotateR
#
#		Rotate the current to the right
#
#	parameters:
#		name = the name of the tree
#		node = the node to be rotated
#		root = the return value is placed here
#
#	returns:
#		0 = no error
#		1 = error code
#
# *********************************************************************************
function ldcLLRBtRotateR()
{
	local llnode=$1
	local llroot
	local llchild
	local llcolor

	llroot=$( ldcLLRBnGet $llnode "left" )
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeRotate "ldcLLRBtRotateR failed to get LEFT for '$llnode'."
		return 1
	fi

	llchild=$( ldcLLRBnGet $llroot "right" )
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeRotate "ldcLLRBtRotateR failed to get RIGHT for '$llroot'."
		return 1
	fi

	ldcLLRBnSet $llnode "left" $llchild
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeRotate "ldcLLRBtRotateR failed to set LEFT for '$llnode'."
		return 1
	fi

	ldcLLRBnSet $llroot "right" $llnode
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeRotate "ldcLLRBtRotateR failed to set IGHT for '$llnode'."
		return 1
	fi

	llcolor=$( ldcLLRBnGet $llnode "color" )
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeRotate "ldcLLRBtRotateR failed to get COLOR for '$llnode'."
		return 1
	fi

	ldcLLRBnSet $llroot "color" $llcolor
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeRotate "ldcLLRBtRotateR failed to get COLOR for '$llnode'."
		return 1
	fi

	ldcLLRBnSet $llnode "color" $ldcLLRB_nRED
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO TreeRotate "ldcLLRBtRotateR failed to get COLOR for '$llnode'."
		return 1
	fi

	eval '${2}='"llroot"
	return 0
}

# *********************************************************************************
# *********************************************************************************

# *********************************************************************************
#
#	ldcLLRBt_PushN
#
#		Push the node and root names onto the recursion stack
#
#	parameters:
#		node = node to push
#		root = root to push
#
#	returns:
#		0 = no error
#		1 = error code
#
# *********************************************************************************
function ldcLLRBt_PushN()
{
	local pNode="$1"
	local pRoot="$2"

	ldcStackWrite $ldcLLRB_tStack "$pNode"
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO PushNodes "ldcLLRBt_PushN failed to get LEFT for '$llnode'."
		return 1
	fi

	ldcStackWrite $ldcLLRB_tStack "$pRoot"
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO PushNodes "ldcLLRBt_PushN failed to get LEFT for '$llnode'."
		return 1
	fi

	return 0
}

# *********************************************************************************
#
#	ldcLLRBt_PopN
#
#		Pop the root and node names from the recursion stack
#
#	parameters:
#		node = popped node
#		root = popped root
#
#	returns:
#		0 = no error
#		1 = error code
#
# *********************************************************************************
function ldcLLRBt_PopN()
{
	local pNode=$1
	local pRoot=$2

	local pchild

	ldcStackRead $ldcLLRB_tStack pchild
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO PopNodes "ldcLLRBt_PopN failed to POP 'llroot' from the stack."
		return 1
	fi

	eval "${pRoot}='${pchild}'"

	ldcStackRead $ldcLLRB_tStack pchild
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO PopNodes "ldcLLRBt_PopN failed to POP 'llnodes' from the stack."
		return 1
	fi

	eval "${pNode}='${pchild}'"

	return 0
}


