###########################################################################
##
#W    binread.g                OpenMath Package                 Max Nicosia
##                                                              
###########################################################################

###########################################################################
##
#F  ToBlist ( <token> )
##
##  Auxiliary function that creates a bit list representation of an int
## 
##  Input: token (int)
##  Output: bit list	
##
ToBlist := function(token)
	# ensuring that the string to be converted has 2 hex digits, 
	# otherwise the conversion fails
	 local val;
	 val := token;
	 token := HexStringInt(token);
	 if val < 16 then
	 	token := Concatenation("0",token);		
	 fi;
	 return BlistStringDecode(token);
end;

#OMBinary constants
# Flags
BindGlobal("FLAG_STATUS",ToBlist(32));
BindGlobal("FLAG_ID",ToBlist(64));
BindGlobal("FLAG_LONG",ToBlist(128));
# Bit-masks
BindGlobal("TYPE_MASK",ToBlist( 31));
BindGlobal("MASK_SIGN_POS",ToBlist( 43)); # 0x2b "+"
BindGlobal("MASK_SIGN_NEG",ToBlist( 45)); # 0x2d "-"
BindGlobal("MASK_BASE_10",ToBlist(0));
BindGlobal("MASK_BASE_16",ToBlist( 64));
BindGlobal("MASK_BASE_256",ToBlist( 128));
# Atomic objects
BindGlobal("TYPE_INT_SMALL",ToBlist(  1));
BindGlobal("TYPE_INT_BIG",ToBlist(  2));
BindGlobal("TYPE_OMFLOAT",ToBlist(  3));
BindGlobal("TYPE_BYTES",ToBlist(  4));
BindGlobal("TYPE_VARIABLE",ToBlist(  5));
BindGlobal("TYPE_STRING_ISO",ToBlist(  6));
BindGlobal("TYPE_STRING_UTF",ToBlist(  7));
BindGlobal("TYPE_SYMBOL",ToBlist(  8));
BindGlobal("TYPE_CDBASE",ToBlist(  9));
BindGlobal("TYPE_FOREIGN",ToBlist( 12));
# Compound objects
BindGlobal("TYPE_APPLICATION",ToBlist( 16));
BindGlobal("TYPE_APPLICATION_END",ToBlist( 17));
BindGlobal("TYPE_ATTRIBUTION",ToBlist( 18));
BindGlobal("TYPE_ATTRIBUTION_END",ToBlist( 19));
BindGlobal("TYPE_ATTRPAIRS",ToBlist( 20));
BindGlobal("TYPE_ATTRPAIRS_END",ToBlist( 21));
BindGlobal("TYPE_ERROR",ToBlist( 22));
BindGlobal("TYPE_ERROR_END",ToBlist( 23));
BindGlobal("TYPE_OBJECT",ToBlist( 24));
BindGlobal("TYPE_OBJECT_END",ToBlist( 25));
BindGlobal("TYPE_BINDING",ToBlist( 26));
BindGlobal("TYPE_BINDING_END",ToBlist( 27));
BindGlobal("TYPE_BVARS",ToBlist( 28));
BindGlobal("TYPE_BVARS_END",ToBlist( 29));
# References
BindGlobal("TYPE_REFERENCE_INT",ToBlist( 30));
BindGlobal("TYPE_REFERENCE_EXT",ToBlist( 31));
# other
BindGlobal("SHIFT_UNIT",8);
BindGlobal("MOST_SIG_MASK",ToBlist(240));
BindGlobal("LESS_SIG_MASK",ToBlist(15));
BindGlobal("EXP_BIAS", 1023);
BindGlobal("UTF_NOT_SUPP", ToBlist(128));

# OM tags
BindGlobal("INT_TAG","OMI");
BindGlobal("STR_TAG","OMSTR");
BindGlobal("FLOAT_TAG", "OMF");
BindGlobal("VAR_TAG", "OMV");
BindGlobal("SYM_TAG", "OMS");
BindGlobal("APP_TAG", "OMA");
BindGlobal("ATP_TAG", "OMATP");
BindGlobal("ATT_TAG", "OMATTR");
BindGlobal("ERR_TAG", "OME");
BindGlobal("BVAR_TAG", "OMBVAR");
BindGlobal("BIND_TAG", "OMBIND");
BindGlobal("REF_TAG", "OMR");
BindGlobal("FOR_TAG", "OMFOREIGN");

DeclareGlobalFunction("GetNextTagObject");
DeclareGlobalFunction("GetNextObject");

