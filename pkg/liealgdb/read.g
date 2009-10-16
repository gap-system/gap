#general stuff
ReadPackage( "liealgdb", "gap/liealgdb.gi" );
ReadPackage( "liealgdb", "gap/doc.gi" );

#SLAC
ReadPackage( "liealgdb", "gap/slac/slac.gi" );

#Nilpotent
ReadPackage( "liealgdb", "gap/nilpotent/nilpotent.gi" );  

#Non-solvable
ReadPackage( "liealgdb", "gap/nonsolv/nonsolv.gi" );
ReadPackage( "liealgdb", "gap/nonsolv/dim6char3iter.gi" );
ReadPackage( "liealgdb", "gap/nonsolv/nonsolvcoll.gi" );

DeclareAutoreadableVariables( "liealgdb", "gap/nilpotent/nilpotent_data62.gi", 
        ["_liealgdb_nilpotent_d6f2"] );

DeclareAutoreadableVariables( "liealgdb", "gap/nilpotent/nilpotent_data72.gi", 
        ["_liealgdb_nilpotent_d7f2"] );

DeclareAutoreadableVariables( "liealgdb", "gap/nilpotent/nilpotent_data73.gi", 
        ["_liealgdb_nilpotent_d7f3"] );

DeclareAutoreadableVariables( "liealgdb", "gap/nilpotent/nilpotent_data75.gi", 
        ["_liealgdb_nilpotent_d7f5"] );

DeclareAutoreadableVariables( "liealgdb", "gap/nilpotent/nilpotent_data82.gi", 
        ["_liealgdb_nilpotent_d8f2"] );

DeclareAutoreadableVariables( "liealgdb", "gap/nilpotent/nilpotent_data92.gi", 
        ["_liealgdb_nilpotent_d9f2"] );

