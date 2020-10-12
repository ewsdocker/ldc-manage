# *********************************************************************************
# *********************************************************************************
#
#   lmsLLRBTree.sh
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

declare    lmslib_lmsLLRBTree="0.0.2"	# library version number

# *****************************************************************************

declare -A lmsLLRB_tTable=()					# treeName = treeUid
declare -A lmsLLRB_nTable						# lmsLLRB_nTable[key]=UID

declare    lmsLLRB_tUid=""						# current tree uid (after lookup)
declare    lmsLLRB_tName=""						# current tree name
declare    lmsLLRB_tRoot=""						# current tree root

declare    lmsLLRB_tNode=""						# temporary node for key search/insertion

declare    lmsLLRB_tStack="lmsLLRB_tRecurse"	# name of the recursion stack
declare    lmsLLRB_tStackUid=""					# name of the recursion stack

# *****************************************************************************

#
#	Each tree structure will have the following variables automatically declared:
#
#declare	lmsLLRB_tRoot_UID			# the key for the root node
#declare	lmsLLRB_tNodes_UID			# number of nodes in the tree

# *****************************************************************************

declare -a lmsLLRB_nField=( 'key' 'data' 'left' 'right' 'color' 'uid' )

declare -r lmsLLRB_nRED=1
declare -r lmsLLRB_nBLACK=0

declare -r lmsLLRB_nLEFT=1
declare -r lmsLLRB_nRIGHT=0

declare    lmsLLRB_nVarKey=""

# ***********************************************************************************************************
#
#	lmsLLRBtCreate
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
function lmsLLRBtCreate()
{
	lmsLLRB_tName=$1
	lmsLLRB_tUid=""

	lmsLLRBtLookup "${lmsLLRB_tName}" lmsLLRB_tUid
	if [[ $? -ne 1 ]]
	then
		lmsErrorQWrite $LINENO NodeCreate "Node '${lmsLLRB_tName}' already exists, uid = '${lmsLLRB_tUid}'"
		return 1
	fi

	lmsUIdUnique lmsLLRB_tUid
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeCreate "Unable to get Unique id"
		return $?
	fi

	lmsDynaSetAt ${lmsLLRB_tTable} "${lmsLLRB_tName}" "$lmsLLRB_tUid"

	lmsDeclareStr "lmsLLRB_tRoot_${lmsLLRB_tUid}" "0"                     ############################## what?
	lmsLLRBtRoot "$lmsLLRB_tName"

	lmsStackCreate $lmsLLRB_tStack lmsLLRB_tStackUid
	if [[ $? -ne 0 ]]
	then
		return 1
	fi

	return 0
}

# ***********************************************************************************************************
#
#	lmsLLRBtCreateN
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
function lmsLLRBtCreateN()
{
	llkey="${1}"
	lldata=${2:-0}

	local llUid=""

	lmsLLRBnLookup "${llkey}" llUid
	[[ $? -eq 0 ]] ||
	 {
		lmsLLRBnSet ${llkey} "data" "${lldata}"
		[[ $? -eq 0 ]] || return 1

#		lmsErrorQReset	  # ignore node errors, such as 'not found' before it was created
		return 2
	 }

	lmsLLRBnCreate "${llkey}" llUid "${lldata}"
	[[ $? -eq 0 ]] || return 1
	
	return 0
}

# ***********************************************************************************************************
#
#	lmsLLRBtLookup
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
function lmsLLRBtLookup()
{
	local llrbTName="${1}"

	[[ -z "${lmsLLRBtTable[$llrbTName]}" ]] && return 1

	lmsLLRB_tName="$llrbTName"
	lmsLLRB_tUid="$lmsLLRBtTable[$llrbTName]"
	lmsLLRB_tRoot="$lmsLLRB_tRoot_${lmsLLRB_tUid}"

	if [[ -n "${2}" ]]
	then
		lmsDeclareStr ${2} "${lmsLLRB_tUid}"
	else
		echo "$lmsLLRB_tUid"
	fi

	return 0
}

# *********************************************************************************
#
#	lmsLLRBtRoot
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
function lmsLLRBtRoot()
{
	local lltree="${1:-$lmsLLRB_tName}"
	local llroot="${2}"
	local llUid

	if [[ -n "$llroot" ]]
	then
		eval "lmsLLRB_tRoot_${lmsLLRB_tUid}='${llroot}'"
	else
		eval 'lmsLLRB_tRoot=$'"{lmsLLRB_tRoot_$lmsLLRB_tUid}"
	fi

	return 0
}

# *********************************************************************************
# *********************************************************************************

# *********************************************************************************
#
#	lmsLLRBtFlipC
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
function lmsLLRBtFlipC()
{
	local llnode="$1"
	local llchild
	local llcolor

	lmsLLRBn_Field $llnode "color" llcolor
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeFlipColors "Unable to get color for '$llnode'."
		return 1
	fi

	let llcolor=($llcolor+1)%2
	lmsLLRBn_Field $llnode "color" llcolor $llcolor
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeFlipColors "Unable to set color for '$llnode'."
		return 1
	fi

	lmsLLRBn_Field $llnode "left" llchild
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeFlipColors "Unable to get left child for '$llnode'."
		return 1
	fi

	if [[ "${llchild}" != "0" ]]
	then
		lmsLLRBn_Field $llchild "color" llcolor
		if [[ $? -ne 0 ]]
		then
			lmsErrorQWrite $LINENO TreeFlipColors "Unable to get color for '$llchild'."
			return 1
		fi

		let llcolor=($llcolor+1)%2

		lmsLLRBn_Field $llchild "color" llcolor $llcolor
		if [[ $? -ne 0 ]]
		then
			lmsErrorQWrite $LINENO TreeFlipColors "Unable to set color for '$llchild'."
			return 1
		fi
	fi

	lmsLLRBn_Field $llnode "right" llchild
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeFlipColors "Unable to get right child for '$llnode'."
		return 1
	fi

	if [[ "${llchild}" != "0" ]]
	then
		lmsLLRBn_Field $llchild "color" llcolor
		if [[ $? -ne 0 ]]
		then
			lmsErrorQWrite $LINENO TreeFlipColors "Unable to get color of right child of '$llchild'."
			return 1
		fi

		let llcolor=($llcolor+1)%2
		lmsLLRBn_Field $llchild "color" llcolor $llcolor
		if [[ $? -ne 0 ]]
		then
			lmsErrorQWrite $LINENO TreeFlipColors "Unable to set color of right child of '$llchild'."
			return 1
		fi
	fi

	return 0
}

# *********************************************************************************
#
#	lmsLLRBtInsert
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
function lmsLLRBtInsert()
{
	local llkey="${1}"
	local lldata="${2}"

	local llroot
	local llnode

	lmsLLRBnCreate "$llkey" llnode "$lldata"
	[[ $? -eq 0 ]] || return 1

	lmsLLRBtInsertN $llnode $lmsLLRB_tRoot llroot
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeInsert "Unable to insert node '${llkey}' into the tree"
		return 1
	fi

echo "set $llroot color: $lmsLLRB_nBLACK"
lmsConioDisplay "$( lmsLLRBnTS $llroot )"

errorQueueDisplay 1 0 EndOfTest

	lmsLLRBn_Field $llroot "color" $lmsLLRB_nBLACK
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeInsert "Unable to set '${llroot}' color"
		return 1
	fi

echo "llroot: $llroot, lmsLLRB_tName = $lmsLLRB_tName"
	lmsLLRBtRoot "$lmsLLRB_tName" "$llroot"
echo "lmsLLRB_tRoot: $lmsLLRB_tRoot"

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
#	lmsLLRBtInsertN
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
function lmsLLRBtInsertN()
{
	local llnode=$1
	local llroot=$2

	local llbranch
	local llchild
	local llresult
	local lldata

lmsConioDisplay "Insert Node: llnode: $llnode"
lmsConioDisplay " $( lmsLLRBnTS $llnode ) "

	if [[ "${llroot}" == "0" ]]
	then
		x="uid"
		lmsLLRBn_Field "$llnode" $x llbranch

errorQueueDisplay 1 1 EndOfTest

		lmsConioDisplay "InsertNode copy -- $llnode to $llbranch"

		lmsLLRBn_Field $llroot 'left' "0"
		lmsLLRBn_Field $llroot 'right' "0"
		lmsLLRBn_Field $llroot 'color' $lmsLLRB_nBLACK

lmsConioDisplay "Root: $llroot"
lmsConioDisplay "$( lmsLLRBnTS $llroot )"

		eval "${3}='${llroot}'"
		return 0
	fi

echo "NodeCompare $llnode with $llroot"

	lmsLLRBnCompare $llnode $llroot
	if [[ $? -lt 0  || $? -gt 2 ]]
	then
		lmsErrorQWrite $LINENO TreeInsertNode "lmsLLRBnCompare returned '$?'."
		return 1
	fi

	llresult=$?

	if [ $llresult -eq 0 ]
	then
		lldata=$( lmsLLRBnGet "$llnode" "key" )
		if [[ $? -ne 0 ]]
		then
			lmsErrorQWrite $LINENO TreeInsertNode "lmsLLRBnGet failed for '$llnode'."
			return 1
		fi

		lmsLLRBnSet $llroot "key" $lldata
		if [[ $? -ne 0 ]]
		then
			lmsErrorQWrite $LINENO TreeInsertNode "lmsLLRBnSet failed for '$llroot'."
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

		lmsLLRBt_PushN "$llnode" "$llroot"
		if [[ $? -ne 0 ]]
		then
			lmsErrorQWrite $LINENO TreeInsertNode "Unable to push '$llnode' and '$llroot' on the stack."
			return 1
		fi

		if [ $llresult -eq 1 ]
		then
			llbranch="right"
		else
			llbranch="left"
		fi

		llchild=$( lmsLLRBnGet "$llroot" "$llbranch" )
		if [[ $? -ne 0 ]]
		then
			lmsErrorQWrite $LINENO TreeInsertNode "Unable to get $branch child of '$llroot'."
			return 1
		fi

		lmsLLRBtInsertN $llchild $llnode llchild
		if [[ $? -ne 0 ]]
		then
			lmsErrorQWrite $LINENO TreeInsertNode "Unable to insert '$llchild' node as child of '$llnode'."
			return 1
		fi

		lmsLLRBt_PopN llnode llroot
		if [[ $? -ne 0 ]]
		then
			lmsErrorQWrite $LINENO TreeInsertNode "Unable to pop '$llnode' and '$llroot' from the stack."
			return 1
		fi

		lmsLLRBnSet $llroot "$llbranch" $llchild
		if [[ $? -ne 0 ]]
		then
			lmsErrorQWrite $LINENO TreeInsertNode "lmsLLRBnSet failed for '$llroot'."
			return 1
		fi
	fi

	lmsLLRBtFixUp $llroot llroot
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeInsertNode "lmsLLRBtFixUp failed for '$llroot'."
		return 1
	fi

	eval "${3}='${llroot}'"

	return 0
}

# *********************************************************************************
#
#	lmsLLRBtFixUp
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
function lmsLLRBtFixUp()
{
	local llnode=$1
	local lldelete=${2:-0}

	local llcolor

	local llchild=$( lmsLLRBnGet $llnode "right" )
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeFixUp "lmsLLRBnGet failed to get 'right' child for '$llnode'."
		return 1
	fi

	llcolor=$( lmsLLRBtIsRed $llnode )
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeFixUp "llrbIsRed failed to get 'right' child for '$llnode'."
		return 1
	fi

	if [[ $llcolor -eq $llrbNode_Red ]]
	then
		llchild=$( lmsLLRBnGet $llnode "left" )
		if [[ $? -ne 0 ]]
		then
			lmsErrorQWrite $LINENO TreeFixUp "lmsLLRBnGet failed to get 'left' child for '$llnode'."
			return 1
		fi
	fi

	llcolor=$( lmsLLRBtIsRed $llchild )
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeFixUp "lmsLLRBtIsRed failed to get child for '$llchild'."
		return 1
	fi

	let llcolor=($llcolor+1)%2
	let llcolor+=$lldelete

	if (( ( $lldelete -eq 1) )) || (( ( $llcolor -eq $lmsLLRB_nBLACK ) ))
	then
		lmsLLRBtRotateL $llnode llnode
		if [[ $? -ne 0 ]]
		then
			lmsErrorQWrite $LINENO TreeFixUp "llrbRotateLeft failed to rotate '$llnode'."
			return 1
		fi

		llchild=$( lmsLLRBnGet $llnode "left" )
		if [[ $? -ne 0 ]]
		then
			lmsErrorQWrite $LINENO TreeFixUp "lmsLLRBnGet failed to load left child of '$llnode'."
			return 1
		fi

		llcolor=$( lmsLLRBtIsRed $llchild )
		if [[ $? -ne 0 ]]
		then
			lmsErrorQWrite $LINENO TreeFixUp "llrbIsRedNode failed to get color for '$llnode'."
			return 1
		fi

		if [[ $llcolor -eq $lmsLLRB_nRED ]]
		then
			llchild=$( lmsLLRBnGet $llchild "left" )
			if [[ $? -ne 0 ]]
			then
				lmsErrorQWrite $LINENO TreeFixUp "lmsLLRBnGet failed to get left child for '$llchild'."
				return 1
			fi

			llcolor=$( lmsLLRBtIsRed $llchild )
			if [[ $? -ne 0 ]]
			then
				lmsErrorQWrite $LINENO TreeFixUp "lmsLLRBtIsRed failed for '$llchild'."
				return 1
			fi

			if [[ $llcolor -eq $lmsLLRB_nRED ]]
			then
				lmsLLRBtRotateR $llnode llnode
				if [[ $? -ne 0 ]]
				then
					lmsErrorQWrite $LINENO TreeFixUp "llrbRotateRight failed to rotate '$llnode'."
					return 1
				fi
			fi
		fi
	fi

	llchild=$( lmsLLRBnGet $llnode "left" )
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeFixUp "lmsLLRBnGet failed to load left child of '$llnode'."
		return 1
	fi

	llcolor=$( lmsLLRBtIsRed $llchild )
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeFixUp "llrbIsRedNode failed to get color for '$llnode'."
		return 1
	fi

	if [[ $llcolor -eq $lmsLLRB_nRED ]]
	then
		llchild=$( lmsLLRBnGet $llnode "right" )
		if [[ $? -ne 0 ]]
		then
			lmsErrorQWrite $LINENO TreeFixUp "lmsLLRBnGet failed to load right child of '$llnode'."
			return 1
		fi

		llcolor=$( lmsLLRBtIsRed $llchild )
		if [[ $? -ne 0 ]]
		then
			lmsErrorQWrite $LINENO TreeFixUp "llrbIsRedNode failed to get color for '$llchild'."
			return 1
		fi

		if [[ $llcolor -eq $lmsLLRB_nRED ]]
		then
			lmsLLRBtFlipC $llnode
			if [[ $? -ne 0 ]]
			then
				lmsErrorQWrite $LINENO TreeFixUp "lmsLLRBtFlipC failed to get color for '$llnode'."
				return 1
			fi
		fi
	fi

	eval "${3}='${llnode}'"
	return 0
}

# *********************************************************************************
#
#	lmsLLRBtIsRed
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
function lmsLLRBtIsRed()
{
	local llkey=$1
	local llcolor=0

	if [[ "$llkey" != "0" ]]
	then
		llcolor=$( lmsLLRBnGet "$llkey" "color" )
		if [[ $? -ne 0 ]]
		then
			lmsErrorQWrite $LINENO TreeModifyNode "Unable to get color from node '${llkey}' for tree '${llrbTName}'."
			return 1
		fi
	fi

	echo "${llcolor}"
}

# *********************************************************************************
#
#	lmsLLRBtRotateL
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
function lmsLLRBtRotateL()
{
	local llnode=$1
	local llroot
	local llchild
	local llcolor

	llroot=$( lmsLLRBnGet $llnode "right" )
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeRotate "lmsLLRBtRotateL failed to get RIGHT for '$llnode'."
		return 1
	fi

	llchild=$( lmsLLRBnGet $llroot "left" )
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeRotate "lmsLLRBtRotateL failed to get left child for '$llroot'."
		return 1
	fi

	lmsLLRBnSet $llnode "left" $llchild
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeRotate "lmsLLRBtRotateL failed to get left child for '$llchild'."
		return 1
	fi

	lmsLLRBnSet $llroot "left" $llnode
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeRotate "lmsLLRBtRotateL failed to get left child for '$llroot'."
		return 1
	fi

	llcolor=$( lmsLLRBnGet $llnode "color" )
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeRotate "lmsLLRBtRotateL failed to get left child for '$llroot'."
		return 1
	fi

	lmsLLRBnSet $llroot "color" $llcolor
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeRotate "lmsLLRBtRotateL failed to get left child for '$llroot'."
		return 1
	fi

	lmsLLRBnSet $llnode "color" $lmsLLRB_nRED
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeRotate "lmsLLRBtRotateL failed to get left child for '$llroot'."
		return 1
	fi

	eval '${2}='"llroot"

	return 0
}

# *********************************************************************************
#
#	lmsLLRBtRotateR
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
function lmsLLRBtRotateR()
{
	local llnode=$1
	local llroot
	local llchild
	local llcolor

	llroot=$( lmsLLRBnGet $llnode "left" )
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeRotate "lmsLLRBtRotateR failed to get LEFT for '$llnode'."
		return 1
	fi

	llchild=$( lmsLLRBnGet $llroot "right" )
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeRotate "lmsLLRBtRotateR failed to get RIGHT for '$llroot'."
		return 1
	fi

	lmsLLRBnSet $llnode "left" $llchild
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeRotate "lmsLLRBtRotateR failed to set LEFT for '$llnode'."
		return 1
	fi

	lmsLLRBnSet $llroot "right" $llnode
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeRotate "lmsLLRBtRotateR failed to set IGHT for '$llnode'."
		return 1
	fi

	llcolor=$( lmsLLRBnGet $llnode "color" )
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeRotate "lmsLLRBtRotateR failed to get COLOR for '$llnode'."
		return 1
	fi

	lmsLLRBnSet $llroot "color" $llcolor
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeRotate "lmsLLRBtRotateR failed to get COLOR for '$llnode'."
		return 1
	fi

	lmsLLRBnSet $llnode "color" $lmsLLRB_nRED
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO TreeRotate "lmsLLRBtRotateR failed to get COLOR for '$llnode'."
		return 1
	fi

	eval '${2}='"llroot"
	return 0
}

# *********************************************************************************
# *********************************************************************************

# *********************************************************************************
#
#	lmsLLRBt_PushN
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
function lmsLLRBt_PushN()
{
	local pNode="$1"
	local pRoot="$2"

	lmsStackWrite $lmsLLRB_tStack "$pNode"
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO PushNodes "lmsLLRBt_PushN failed to get LEFT for '$llnode'."
		return 1
	fi

	lmsStackWrite $lmsLLRB_tStack "$pRoot"
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO PushNodes "lmsLLRBt_PushN failed to get LEFT for '$llnode'."
		return 1
	fi

	return 0
}

# *********************************************************************************
#
#	lmsLLRBt_PopN
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
function lmsLLRBt_PopN()
{
	local pNode=$1
	local pRoot=$2

	local pchild

	lmsStackRead $lmsLLRB_tStack pchild
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO PopNodes "lmsLLRBt_PopN failed to POP 'llroot' from the stack."
		return 1
	fi

	eval "${pRoot}='${pchild}'"

	lmsStackRead $lmsLLRB_tStack pchild
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO PopNodes "lmsLLRBt_PopN failed to POP 'llnodes' from the stack."
		return 1
	fi

	eval "${pNode}='${pchild}'"

	return 0
}


