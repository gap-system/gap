LieAlgDataBase := rec(  );

LADB_1 := 1;	# the unit of the field
LADB_p := [  ];	# the list of parameters


AlgebraByStandardFormatDB := function ( classification, F, dim, number, params )

    local common_data, specific_data, is_the_field_valid, method,
symmetry, sct, non_zero_products, i, ii, A, arguments,
properties_and_attributes ;


    if not IsBound( LieAlgDataBase.(classification) ) then
        Read( Concatenation( classification, ".g" ) );
# # another possibility:
#        ReadPackage( "liealgdb", Concatenation( "some_directory",
#           classification, ".g" ) );
    fi;


    # dim
    if not IsBound( LieAlgDataBase.(classification).(dim) )  then
        Error( "dimension ", dim, " non included in classification ",
               classification );
    fi;
   
    # number
    if not IsBound( LieAlgDataBase.(classification).(dim)[number] )  then
        Error( "dimension ", dim, " number ", number, 
               " non included in classification ", classification );
    fi;


    common_data := LieAlgDataBase.(classification).common_data;
    specific_data := LieAlgDataBase.(classification).(dim)[number];


    # is_the_field_valid

    if IsBound( specific_data.is_the_field_valid )  then
        is_the_field_valid := specific_data.is_the_field_valid;
    elif IsBound( common_data.is_the_field_valid )  then
        is_the_field_valid := common_data.is_the_field_valid;
    else
        is_the_field_valid := ReturnTrue;
    fi;

    if not is_the_field_valid( F )  then
        return fail;
    fi;


    # method

    if IsBound( specific_data.method )  then
        method := specific_data.method;
    elif IsBound( common_data.method )  then
        method := common_data.method;
    else
        Error( "no method specified" );
    fi;


    # method AlgebraByStructureConstants

    if method = AlgebraByStructureConstants  then


        # symmetry

        if IsBound( specific_data.symmetry )  then
            symmetry := specific_data.symmetry;
        elif IsBound( common_data.symmetry )  then
            symmetry := common_data.symmetry;
        fi;

        if IsBound( symmetry)  then
            sct := EmptySCTable( dim, Zero( F ), symmetry );
        else
            sct := EmptySCTable( dim, Zero( F ) );
        fi;


        # non_zero_products

        non_zero_products := [  ];
        if IsBound( common_data.non_zero_products )  then
            Append( non_zero_products, common_data.non_zero_products );
        fi;
        if IsBound( specific_data.non_zero_products )  then
            Append( non_zero_products, specific_data.non_zero_products );
        fi;

        LADB_1 := One( F );
        LADB_p := params;

        for i  in non_zero_products  do

            for ii  in [ 1, 3 .. Length( i[3] )-1 ]  do
                if IsString( i[3][ii] )  then
                    i[3][ii] := EvalString( i[3][ii] );
                fi;
            od;

            SetEntrySCTable( sct, i[1], i[2], i[3] );
        od;


        A := AlgebraByStructureConstants( F, sct );


    # methods Algebra, AlgebraWithOne, LieAlgebra

    elif method = Algebra or method = AlgebraWithOne or
         method = LieAlgebra  then

        arguments := [ F, [  ] ];


        # generators

        if IsBound( common_data.generators )  then
            Append( arguments[2], common_data.generators );
        fi;
        if IsBound( specific_data.generators )  then
            Append( arguments[2], specific_data.generatorss );
        fi;


        # zero

        if IsBound( specific_data.zero )  then
            Append( arguments, specific_data.zero );
        elif IsBound( common_data.zero )  then
            Append( arguments, common_data.zero );
        fi;


        # basis

        if IsBound( specific_data.basis )  then
            Append( arguments, "basis" );
        elif IsBound( common_data.basis )  then
            Append( arguments, "basis" );
        fi;


        A := CallFuncList( method, arguments );


    else

        Error( "method unknown" );

    fi;


    # non_zero_pth_powers

    # to be written


    # grading

    # to be written


    # properties_and_attributes

    properties_and_attributes := [  ];
    if IsBound( specific_data.properties_and_attributes )  then
        Append( properties_and_attributes, 
                specific_data.properties_and_attributes );
    fi;
    if IsBound( common_data.properties_and_attributes )  then
        Append( properties_and_attributes, 
                common_data.properties_and_attributes );
    fi;


    if ValueOption( "test" ) = true  then
        # perform a check
        for i  in properties_and_attributes  do
            if not i[1]( A ) = i[2]  then
                Error( "property or attribute `", i[1], "' is not `", i[2],
                 "'" );
            fi;
        od;
    else
        # simply set
        for i  in properties_and_attributes  do
            Setter( i[1] )( A, i[2] );
        od;
    fi;


    return A;

end;

