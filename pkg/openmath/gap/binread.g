###########################################################################
##
#W    binread.g                OpenMath Package                 Max Nicosia
##                                                              
###########################################################################

###########################################################################
##
#F  EnsureCompleteHexNum ( <hexNum> )
##
##  Completes a hexadecimal number to a byte size multiple
## 
BindGlobal( "EnsureCompleteHexNum", function( hexNum )
local hexNumLen, binStri, num, charStri, counter;
hexNumLen := Length(hexNum);
binStri := "0";
if not IsEvenInt(hexNumLen) then
	Append(binStri,hexNum);
	return binStri;
else
	return hexNum;
fi;
end);

#######################################################################
##
#F  ReadTokensToBlist ( <stream> , <length>)
##
##  
## 
BindGlobal( "ReadTokensToBlist", function( stream , length)
local bitList, hexNum, byte, i;
bitList := [];
i := 1;
for i in [1..length] do
hexNum := HexStringInt(ReadByte(stream));
byte := BlistStringDecode(EnsureCompleteHexNum(hexNum));
Append(bitList, byte);
od;
return bitList;
end);

#######################################################################
##
#F  GetObjLength ( <isLong> , <stream> )
##
##  Auxiliary function to get the length of an object. 
##  If isLong is TRUE the length is obtained from reading 4 bytes.
## 
##  Input: isLong (boolean), stream
##
GetObjLength := function(isLong, stream)
	local length, i, temp;
	if isLong then 
		i := 4;
		length := ""; 
		temp := "";
		while i > 0 do
			temp := HexStringInt(ReadByte(stream));
			temp := EnsureCompleteHexNum(temp);
			Append(length, temp);
			i:= i -1;
			od;
		length := IntHexString(length);

		return length;	
	else 
		return ReadByte(stream);
	fi;
end;

#######################################################################
##
#F  ReadAllTokens ( <length>, <stream>, <isUTF16> )
##
##  Auxiliary function to read all tokens for a given 
##  length and ouput them as a string. 
##  If isUTF16 flag is TRUE every second token will be skipped.
## 
##  Input: length (int), stream, isUTF16 (boolean)
##  Output: string	
##
ReadAllTokens := function (length, stream, isUTF16)
	local curByte, stri, out;
	stri := "";
	out := OutputTextString(stri,true);
	while length > 0 do
		curByte := ReadByte(stream);
		WriteByte(out, curByte);
		length := length -1;
		if isUTF16 then
			curByte := ToBlist(curByte);
			if UTF_NOT_SUPP = IntersectionBlist(curByte ,UTF_NOT_SUPP) then
				Error("Characted in string not supported\n");	
			fi;
			ReadByte(stream);
		fi;
	od; 
	CloseStream(out);
	return stri;
end;

#######################################################################
##
#F  ReadFloatToBlist ( <stream> )
##
##  Auxiliary function to 8 bytes and output the 
##  corresponding bit list representation. 
##  
##  Input: stream
##  Output: bit list representation	
##
ReadFloatToBlist := function(stream)
	local curByte, temp, bitList, length;
	temp := [];
	bitList :=[];
	length := 8;
	while length > 0 do
		curByte := ReadByte(stream);
		temp := ToBlist(curByte); 
		Append(bitList,temp);
		length :=  length -1;
	od; 
	return bitList;
end;

#######################################################################
##
#F  CreateRecordFloat ( <fnumber> , <idStri> )
##
##  Auxiliary function to create a record representation of a float
##  
##  Input: fnumber (Float), idStri (string)
##  Output: record	
##
CreateRecordFloat := function(fnumber, idStri)
	fnumber := String(fnumber);
	if idStri <> false then
		return rec( attributes := rec( id:= idStri, dec := fnumber ), name := FLOAT_TAG, content := 0); 
	else
		return rec( attributes := rec( dec := fnumber ), name := FLOAT_TAG, content := 0); 
	fi;
	
end;

#######################################################################
##
#F  CreateRecordString ( <stri> , <idStri> )
##
##  Auxiliary function to create a record representation of a string
##  
##  Input: stri (string), idStri (string)
##  Output: record	
##
CreateRecordString := function(stri, idStri)
	if idStri <> false then
		return rec( attributes := rec( id := idStri )  , name := STR_TAG , content := [ rec( content := stri ) ]); 
	else
		return rec( attributes := rec(  )  , name := STR_TAG , content := [ rec( content := stri ) ]); 
	fi;
end;

#######################################################################
##
#F  CreateRecordInt ( <intNumber>, <sign>, <idStri> )
##
##  Auxiliary function to create a record representation of a integer
##  
##  Input: intNumber (int), sign (boolean), idStri (string)
##  Output: record	
##
CreateRecordInt := function(intNumber, sign, idStri)
	local signedNumber;
	signedNumber := "-";
	intNumber := String(intNumber);
	if sign then #if it's negative
		Append(signedNumber,intNumber);
		intNumber := signedNumber;
	fi;
	if idStri <> false then
		return rec( attributes := rec( id := idStri ), name := INT_TAG, content := [ rec( name := "PCDATA", content := intNumber ) ]); 
	else 
		return rec( attributes := rec(  ), name := INT_TAG, content := [ rec( name := "PCDATA", content := intNumber ) ]);
	fi;
end;

#######################################################################
##
#F  CreateRecordVar ( <stri> , <idStri> )
##
##  Auxiliary function to create a record representation of a variable
##  
##  Input: stri: name of the variable (string), idStri (string)
##  Output: record	
##
CreateRecordVar := function(stri, idStri)
	if idStri <> false then
		return rec( attributes := rec(name := stri,  id := idStri ), name := VAR_TAG, content := 0); 
	else 
		return rec( attributes := rec(name := stri), name := VAR_TAG, content := 0); 
	fi;

end;

#######################################################################
##
#F  CreateRecordSym ( <stri> , <cdStri>, <idStri> )
##
##  Auxiliary function to create a record representation of a variable
##  
##  Input: stri: name of the symbol (string), cdStri: name of the 
##          content dictionary, idStri (string)
##  Output: record	
##
CreateRecordSym := function(stri, cdStri, idStri)
	if idStri <> false then
	  	return rec( attributes := rec( cd := cdStri, name := stri, id := idStri ), name := SYM_TAG, content := 0);
	else
	  	return rec( attributes := rec( cd := cdStri, name := stri ), name := SYM_TAG, content := 0);
	fi;
end;

#######################################################################
##
#F  CreateRecordObject ( <objectRecord>, <cdbase> )
##
##  Auxiliary function to create a record representation of an Object
##  
##  Input: 
##  Output: record	
##
CreateRecordObject := function(objectRecord, cdBaseStri)
	if cdBaseStri <> false then
		return rec( attributes := rec( cdbase := cdBaseStri ), name := "OMOBJ", content :=[ objectRecord ]);
	else
		return rec( attributes := rec( ), name := "OMOBJ", content :=[ objectRecord ]);
	fi;
end;

#######################################################################
##
#F  CreateRecordApp ( <idStri>, <objectList> )
##
##  Auxiliary function to create a record representation of an application
##  
##  Input: idStri (string), objectList (list)
##  Output: record	
##
CreateRecordApp := function(idStri, objectList)
	if idStri <> false then
		return rec( attributes := rec( id := idStri ), name := APP_TAG, content := objectList); 
	else
		return rec( attributes := rec( ), name := APP_TAG, content := objectList); 
	fi;
end;

#######################################################################
##
#F  CreateRecordAtribution ( <objectList> , <idStri> )
##
##  Auxiliary function to create a record representation of an Attribution
##  
##  Input:  objectList (list), idStri (string)
##  Output: record	
##
CreateRecordAtribution := function(objectList, idStri)
	if idStri <> false then
		return rec( attributes := rec( id := idStri ), name := ATT_TAG, content := objectList); 
	else
		return rec( attributes := rec( ), name := ATT_TAG, content := objectList);
	fi;
end;

#######################################################################
##
#F  CreateRecordAttributePairs  ( <objectList> , <idStri> )
##
##  Auxiliary function to create a record representation of attribution pairs
##  
##  Input: objectList (list), idStri (string)
##  Output: record	
##
CreateRecordAttributePairs := function(objectList, idStri)
	if idStri <> false then
		return rec( attributes := rec( id := idStri ), name := ATP_TAG, content := objectList);
	else
		return rec( attributes := rec( ), name := ATP_TAG, content := objectList);
	fi;
end;

#######################################################################
##
#F  CreateRecordError  ( <objectList> , <idStri> )
##
##  Auxiliary function to create a record representation of an error
##  
##  Input: objectList (list), idStri (string)
##  Output: record	
##
CreateRecordError := function (objectList, idStri)
	if idStri <> false then
		return rec( attributes := rec( id:= idStri ), name := ERR_TAG, content := objectList);
	else 
		return rec( attributes := rec( ), name := ERR_TAG, content := objectList);
	fi;

end;

#######################################################################
##
#F  CreateRecordOMBVar  ( <objectList> , <idStri> )
##
##  Auxiliary function to create a record representation of an OMBVAR
##  
##  Input: objectList (list), idStri (string)
##  Output: record	
##
CreateRecordOMBVar := function(objectList, idStri)
	if idStri <> false then
		return rec( attributes := rec( id:= idStri ), name := BVAR_TAG, content := objectList);
	else 
		return rec( attributes := rec( ), name := BVAR_TAG, content := objectList);
	fi;
end;

#######################################################################
##
#F  CreateRecordBinding ( <objectList> , <idStri> )
##
##  Auxiliary function to create a record representation of bindings
##  
##  Input:  objectList (list), idStri (string)
##  Output: record	
##
CreateRecordBinding := function(objectList, idStri)
	if idStri <> false then
		return rec( attributes := rec( id:= idStri ), name := BIND_TAG, content := objectList);
	else 
		return rec( attributes := rec( ), name := BIND_TAG, content := objectList);
	fi;
end;

#######################################################################
##
#F  CreateRecordReference ( <objectRef>, <isInternal> )
##
##  Auxiliary function to create a record representation of a referece,
##  either internal or external 
##  
##  Input: objectRef (string), isInternal (boolean)
##  Output: record	
##
CreateRecordReference := function(objectRef, isInternal)
	if isInternal then
		return rec( attributes := rec( id := "inner", href := objectRef ), name := REF_TAG, content := 0); 
	else
		return rec( attributes := rec( id := "outer", href := objectRef ), name := REF_TAG, content := 0); 
	fi;
end;

#######################################################################
##
#F  CreateRecordForeign ( <forStri>, <encStri>, <idStri> )
##
##  Auxiliary function to create a record representation of an foreign object
##  
##  Input: forStri: format (string), encStri: encoding (string), idStri (string)
##  Output: record	
##
CreateRecordForeign := function(forStri, encStri, idStri)
	if idStri <> false then
		return rec( attributes := rec( id := idStri, encoding:= encStri )  , name := FOR_TAG , content := [ rec( content := forStri ) ]); 
	else
		return rec( attributes := rec( encoding:= encStri )  , name := FOR_TAG , content := [ rec( content := forStri ) ]); 
	fi;

end;

#######################################################################
##
#F  CreateRecordBlist ( <bitList>, <idStri>, <listLen> )
##
##  Auxiliary function to create a record representation of a blist
##  
##  Input: bitList, id, list length
##  Output: record representation of a blist
##
CreateRecordBlist := function(bitList, idStri)
	
	if idStri <> false then
	    return rec( attributes := rec( id:= idStri ), name := "OMB", content := [ rec( name:="PCDATA", content:=bitList) ] );
	else
	    return rec( attributes := rec( ), name := "OMB", content := [ rec( name:="PCDATA", content:=bitList) ] );
	fi;
	
end;


#CreateRecordCDBase := function(cdStri)
#	return rec( attributes := rec( ), name := ERR_TAG, content := objectList);
#end;


#######################################################################
##
#F  GetNextTagObject ( <stream>, <isRecursiveCall> )
##
##  Main function to parse an object. If isRecursiveCall is TRUE no object tags are added
##  
##  Input: stream, isRecursiveCall (boolean)
##  Output: object record	
##
InstallGlobalFunction( GetNextTagObject,
function(stream, isRecursiveCall)
	local omObject, omSymbol, omObject2, token, objLength, sign, isLong, num, i, tempList, 
	      basensign, base, curByte, objectStri, exponent, fraction, hasId, idLength, idStri, idStriAttrPairs, idBVars, cdStri, cdLength, encLength, encStri, objectList, treeObject, bitList, cdBaseStri;
		token := ReadByte(stream);
		cdBaseStri := false;
		token := ToBlist(token);
		isLong := false;
		hasId := false;
		# checking if the long and id flag is on
		if FLAG_LONG = IntersectionBlist(token ,FLAG_LONG) then 
			isLong := true;
		fi;
		if FLAG_ID = IntersectionBlist(token ,FLAG_ID) then
			hasId := true;
		fi;
		#checking for streaming flag
		if FLAG_STATUS = IntersectionBlist(token ,FLAG_STATUS) then
			Error("Streaming flag not supported");
		fi;
		#removing bits that could interfere with type distinction
		token := IntersectionBlist(token ,TYPE_MASK);
		
		#start of type checks
		if (token = TYPE_INT_SMALL) then
			num := 0;
			idStri := false;
			sign := false;
			if(hasId) then 
				idStri := "";
				idLength := GetObjLength(isLong, stream);
				idStri := ReadAllTokens(idLength, stream, false);	
			fi;
			if isLong then #read 4 bytes
				num:= GetObjLength(isLong, stream);
				i := 0;
				if num > 2^31-1 then
					num := 2^32 - num;
					sign := true;
				fi;
			else 
				num := ReadByte(stream);
				if num > 127 then
					num := 256 - num;
					sign := true;
				fi;	
			fi;
			treeObject:= CreateRecordInt(num, sign, idStri);
		
		elif (token = TYPE_INT_BIG) then
			num := 0;
			#get length
			objLength := GetObjLength(isLong, stream);
			#check for id
			idStri := false;
			if(hasId) then 
				idStri := "";
				idLength := GetObjLength(isLong, stream);
			fi;

			# get base and sign
			basensign := ReadByte(stream); 
			basensign := ToBlist(basensign);
			
			#set the sign
			if (MASK_SIGN_POS = IntersectionBlist(basensign, MASK_SIGN_POS)) then
				sign := false; #negative
			else 
				sign := true; #positive
			fi;
			#get the base
			base := IntersectionBlist(basensign ,(UnionBlist(MASK_BASE_256, MASK_BASE_16)));
			if base = MASK_BASE_256 then
				objectStri := "";
				i := objLength;
				# for all the bytes that compose the number
				while i >0 do
					#read the byte
					curByte := ReadByte(stream);
					#converting the values into hex
					curByte := HexStringInt(curByte);
					#adding the hex digits to the string
					Append(objectStri,curByte);
					i := i -1;
				od;
				num := IntHexString(objectStri);		
			else
				objectStri := ReadAllTokens(objLength, stream, false);
				#needs to be converted to a b10 before assigning it	
				if base = MASK_BASE_16 then
					num := IntHexString(objectStri);
				else 
				#just assign the integer
					num := objectStri;
					num := EvalString(num);
				fi;
			fi;
			if hasId then
				idStri := ReadAllTokens(idLength, stream, false);	
			fi;
			treeObject := CreateRecordInt(num, sign, idStri);
					
		elif (token = TYPE_OMFLOAT) then
			idStri := false;
			#check for id
			if hasId then
				idStri := "";
				idLength := GetObjLength(isLong, stream);
				idStri := ReadAllTokens(idLength, stream, false);
			fi;
			
			#obtain a blist representation of the float
			tempList := ReadFloatToBlist(stream);
			#get the sign from the most significant bit
			sign := tempList[1];
			#appending the implicit 1 + 3 false to complete the bytes, this is necessary for HexStringBlist to work correctly
			fraction := [false, false, false, true];
			Append(fraction,tempList{[13..64]});
			#appending 5 false to complete the bytes, this is necessary for HexStringBlist to work correctly
			exponent := [false, false, false, false, false];
			Append(exponent, tempList{[2..12]});

			exponent := HexStringBlist(exponent);
			exponent := IntHexString(exponent);
			fraction := HexStringBlist(fraction);
			fraction := IntHexString(fraction);
			if(sign) then 
				sign := -1; 
			else 
				sign := 1;
			fi;
			num := 	Float(sign*2^(exponent - EXP_BIAS) * fraction*2^-52);
			#call record creator and assign		
			treeObject := CreateRecordFloat(num, idStri);
			
		elif (token = TYPE_VARIABLE) then
			objectStri := "";
			objLength := GetObjLength(isLong, stream);
			idStri := false;			
			if(hasId) then 
				idStri := "";
				idLength := GetObjLength(isLong, stream);
				objectStri := ReadAllTokens(objLength, stream, false);
				idStri := ReadAllTokens(idLength, stream, false);	
			else
				objectStri := ReadAllTokens(objLength, stream, false);
			fi;
			treeObject := CreateRecordVar(objectStri, idStri);
		
		elif (token = TYPE_SYMBOL) then
			objectStri := "";
			cdStri := "";
			cdLength := GetObjLength(isLong, stream);
			objLength := GetObjLength(isLong, stream);
			idStri := false;
			if(hasId) then 
				idStri := "";
				idLength := GetObjLength(isLong, stream);
				cdStri := ReadAllTokens(cdLength, stream, false);
				objectStri := ReadAllTokens(objLength, stream, false);
				idStri := ReadAllTokens(idLength, stream, false);	
			else
				cdStri := ReadAllTokens(cdLength, stream, false);
				objectStri := ReadAllTokens(objLength, stream, false);
			fi;
			treeObject := CreateRecordSym(objectStri, cdStri, idStri);

		elif (token = TYPE_STRING_UTF) then
			#must be twice the length as it is UTF-16 (each char takes 2 bytes, second byte being ignored)
			objLength := GetObjLength(isLong, stream);
			idStri := false;
			if(hasId) then 
				idStri := "";
				idLength := GetObjLength(isLong, stream);
				objectStri := ReadAllTokens(objLength, stream, true);
				idStri := ReadAllTokens(idLength, stream, false);	
			else
				objectStri := ReadAllTokens(objLength, stream, true);
			fi;
			treeObject := CreateRecordString(objectStri, idStri);
		
		elif (token = TYPE_STRING_ISO) then
			objLength := GetObjLength(isLong, stream);
			idStri := false;
			if(hasId) then 
				idStri := "";
				idLength := GetObjLength(isLong, stream);
				objectStri := ReadAllTokens(objLength, stream, false);
				idStri := ReadAllTokens(idLength, stream, false);	
			else
				objectStri := ReadAllTokens(objLength, stream, false);
			fi;	
			treeObject := CreateRecordString(objectStri, idStri);

		elif (token = TYPE_BYTES) then
			objLength := GetObjLength(isLong, stream);
			idStri := false;
			if(hasId) then 
				idStri := "";
				idLength := GetObjLength(isLong, stream);
				bitList := ReadTokensToBlist( stream, objLength);
				idStri := ReadAllTokens(idLength, stream, false);	
			else
				bitList := ReadTokensToBlist( stream, objLength);
			fi;
			treeObject := CreateRecordBlist(bitList, idStri);
		
		elif token = TYPE_FOREIGN then
			encLength := GetObjLength(isLong, stream);
			objLength := GetObjLength(isLong, stream);
			idStri := false;
			if(hasId) then 
				idStri := "";
				idLength := GetObjLength(isLong, stream);
				encStri := ReadAllTokens(encLength, stream, false);
				objectStri := ReadAllTokens(objLength, stream, false);
				idStri := ReadAllTokens(idLength, stream, false);
			else
				encStri := ReadAllTokens(encLength, stream, false);
				objectStri := ReadAllTokens(objLength, stream, false);	
			fi;
			treeObject := CreateRecordForeign(objectStri, encStri, idStri);

		elif (token = TYPE_APPLICATION) then
			idStri := false;
			objectList := [];
			if(hasId) then 
				idStri := "";
				idLength := GetObjLength(isLong, stream);
				idStri := ReadAllTokens(idLength, stream, false);
			fi;
			i := 0;
			while (true) do
				omObject := GetNextTagObject(stream, true); 
				if omObject = fail then
					break;
				fi;
				Add(objectList, omObject);
				i := i+1;
			od;
			treeObject := CreateRecordApp(idStri, objectList);

		elif (token = TYPE_ATTRIBUTION) then
			idStri := false;
			if(hasId) then 
				idStri := "";
				idLength := GetObjLength(isLong, stream);
				idStri := ReadAllTokens(idLength, stream, false);
			fi;
			token := ReadByte(stream);
			token := ToBlist(token);
			isLong := false;
			hasId := false;
			# checking if the long and id flag is on
			if FLAG_LONG = IntersectionBlist(token ,FLAG_LONG) then 
				isLong := true;
			fi;
			if FLAG_ID = IntersectionBlist(token ,FLAG_ID) then
				hasId := true;
			fi;
			#checking for streaming flag
			if FLAG_STATUS = IntersectionBlist(token ,FLAG_STATUS) then
				Error("Streaming flag not supported");
			fi;
			#removing bits that could interfere with type distinction
			token := IntersectionBlist(token ,TYPE_MASK);
			if (token <> TYPE_ATTRPAIRS) then
				Error("Attribution pairs expected");					
			fi;
			#checking if attpairs have id and if isLong 
			idStriAttrPairs := false;
			if(hasId) then 
				idStriAttrPairs := "";
				idLength := GetObjLength(isLong, stream);
				idStriAttrPairs := ReadAllTokens(idLength, stream, false);
			fi;	
				objectList := [];
			#getting pairs till an end token is found
			while (true) do
				omSymbol := GetNextTagObject(stream,true);
				if omSymbol = fail then
					break;
				fi;
				omObject := GetNextTagObject(stream, true);
				Add(objectList, omSymbol);
				Add(objectList, omObject);
			od;
			#creating the attribution pair record
			treeObject := CreateRecordAttributePairs(objectList, idStriAttrPairs);
			#getting the object that is at the end
			omObject2 := GetNextTagObject(stream, true);
			#clearing the list
			objectList := [];
			#adding the pairs and the objects to the list that is to be added to the attribution
			Add(objectList, treeObject);
			Add(objectList, omObject2);
			#creating the final tree
			treeObject := CreateRecordAtribution(objectList, idStri);			
			
		elif (token = TYPE_ERROR) then		
			idStri := false;
			if(hasId) then 
				idStri := "";
				idLength := GetObjLength(isLong, stream);
				idStri := ReadAllTokens(objLength, stream, false);
			fi;
			objectList := [];
			omSymbol := GetNextTagObject(stream, true);
			omObject := GetNextTagObject(stream, true);
			Add(objectList, omSymbol);
			Add(objectList, omObject);
			#creating the final tree
			treeObject := CreateRecordError(objectList, idStri);
		
		elif (token = TYPE_BINDING) then
			idStri := false;
			if(hasId) then 
				idStri := "";
				idLength := GetObjLength(isLong, stream);
				idStri := ReadAllTokens(idLength, stream, false);
			fi;
			omSymbol := GetNextTagObject(stream, true);
			token := ReadByte(stream);
			token := ToBlist(token);
			isLong := false;
			hasId := false;
			# checking if the long and id flag is on
			if FLAG_LONG = IntersectionBlist(token ,FLAG_LONG) then 
				isLong := true;
			fi;
			if FLAG_ID = IntersectionBlist(token ,FLAG_ID) then
				hasId := true;
			fi;
			#checking for streaming flag
			if FLAG_STATUS = IntersectionBlist(token ,FLAG_STATUS) then
				Error("Streaming flag not supported");
			fi;
			#removing bits that could interfere with type distinction
			token := IntersectionBlist(token ,TYPE_MASK);
			if (token <> TYPE_BVARS) then
				Error("Bvars start byte expected");
			fi;
			#checking if bvars have id and if isLong 
			idBVars := false;
			if(hasId) then 
				idBVars := "";
				idLength := GetObjLength(isLong, stream);
				idBVars := ReadAllTokens(idLength, stream, false);
			fi;
			objectList := [];
			#getting pairs till an end token is found
			while (true) do
				omObject := GetNextTagObject(stream, true);
				if omObject = fail then
					break;
				fi;
				Add(objectList, omObject);
			od;
			treeObject := CreateRecordOMBVar(objectList, idBVars);
			omObject2 := GetNextTagObject(stream, true);
			objectList := [];
			Add(objectList, omSymbol);
			Add(objectList, treeObject);
			Add(objectList, omObject2);
			treeObject := CreateRecordBinding(objectList, idStri);

					
		elif (token = TYPE_REFERENCE_INT) then
			objLength := GetObjLength(isLong, stream);
			treeObject := CreateRecordReference(objLength, true);
							
		elif (token = TYPE_REFERENCE_EXT) then
			objLength := GetObjLength(isLong, stream);
			objectStri := ReadAllTokens(objLength, stream, false);
			treeObject := CreateRecordReference(objectStri, false);
					
		elif (token = TYPE_BVARS) then
			Error("Bvars token shouldn't be here'");
		
		elif (token = TYPE_ATTRPAIRS) then
			Error("Attribution pairs token shouldn't be here'");
		elif (token = TYPE_CDBASE) then
			objLength := GetObjLength(isLong, stream);
			objectStri := ReadAllTokens(objLength, stream, false);
			treeObject := GetNextTagObject(stream);
			cdBaseStri := objectStri;
		#END LINE CASES
		elif (token = TYPE_APPLICATION_END) then		
			return fail;
		
		
		elif (token = TYPE_BINDING_END) then		
			return fail;
		
		
		elif (token = TYPE_ATTRIBUTION) then		
			return fail;
		
		
		elif (token = TYPE_ERROR_END) then		
			return fail;
		
		
		elif (token = TYPE_ATTRPAIRS_END) then		
			return fail;	
		
		
		elif (token = TYPE_BVARS_END) then		
			return fail;
		fi;

		#added to allow not removing the end token when called recursively
		if (not isRecursiveCall) then	
			token := ReadByte(stream);
			token := ToBlist(token);
			treeObject:= CreateRecordObject(treeObject, false);
		fi;

	return treeObject;	
end);

#######################################################################
##
#F  GetNextObject ( <stream>, <firstbyte> )
##
##  Acts as a wrapper for GetNextTagObject when getting 
##  objects contained within an object
##  
##  Input: stream, firstbyte: start token (int)
##  Output: object record	
InstallGlobalFunction( GetNextObject, function( stream, firstbyte )
	local btoken;
	# firstbyte contains the start token
	btoken := ToBlist(firstbyte);
	if (btoken <> TYPE_OBJECT) then 
		Error("Object tag expected");
	fi;
	return GetNextTagObject(stream, false);
end);
		

