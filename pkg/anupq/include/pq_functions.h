/****************************************************************************
**
*A  pq_functions.h              ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: pq_functions.h,v 1.3 2001/06/15 14:39:21 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

/* prototypes for functions used in the p-Quotient Program */

void autgp_order ();
void collect_defining_generator ();
void factor_subgroup ();
void handle_error ();
void is_timelimit_exceeded ();
void CreateGAPLibraryFile ();
void compute_padic ();
void print_pcp_relations ();
int **group_completed ();
int ***read_auts_from_file ();
int **find_allowable_subgroup ();
int **standard_map ();
int **find_stabiliser ();
int **start_pga_run ();
int **finish_pga_run ();
int*** determine_action ();
void write_Magma_matrix ();
void check_input ();
FILE *OpenTemporaryFile ();
void close_queue ();
void setup_relation ();
void enforce_exponent ();
void bubble_sort ();
void complete_echelon ();
void traverse_list ();
void extend ();
void extend_automorphism ();
void extend_power ();
void extend_commutator ();
void collect_image_of_generator ();
void collect_image_of_string ();
int ***reallocate_array ();
int *reallocate_vector ();
void next_class ();
FILE *OpenSystemFile ();
void create_tail ();
int ***setup_identity_auts ();
void extend_tail ();
void enforce_laws ();
void orbit_option ();
void stabiliser_option ();
void calculate_tails ();
void calculate_power ();
void write_CAYLEY_matrix ();
void write_GAP_matrix ();
int *bitstring_to_subset ();
int ***allocate_array ();
int *allocate_vector ();
char *allocate_char_vector ();
int **allocate_matrix ();
char **allocate_char_matrix ();
int **commutator_matrix ();
int ***restore_group ();
void invalid_group ();
void report ();
void print_group_details ();
int*** restore_pga ();
FILE_TYPE OpenFile ();
FILE_TYPE OpenFileOutput ();
void set_defaults ();
void read_subgroup_rank ();
void read_step_size ();
void query_metabelian_law ();
void query_degree_aut_information ();
void query_exponent_law ();
void query_perm_information ();
void query_space_efficiency ();
void query_group_information ();
void query_aut_group_information ();
void query_orbit_information ();
void query_solubility ();
void query_terminal ();
void Extend_Aut ();
void Extend_Comm ();
void Extend_Pow ();
void Collect_Image_Of_Str ();
void Collect_Image_Of_Gen ();
int** label_to_subgroup ();
int** transpose ();
int** multiply_matrix ();
void add_to_list ();
void visit ();
void get_definition_sets ();
int*** central_automorphisms ();
void list_interactive_pga_menu ();
void list_interactive_pq_menu ();
void start_group ();
int* find_orbit_reps ();
int** permute_subgroups ();
void list_pga_menu ();
void image_to_word ();
void Copy_Matrix ();
void CreateName ();
void find_padic ();
void trace_action ();
void update_image ();
void compute_permutation ();
void find_available_positions ();
void compute_images ();
void start_group ();
FILE_TYPE OpenFileInput ();
FILE_TYPE TemporaryFile ();
int*** read_auts ();
int ***invert_automorphisms ();
int ***read_stabiliser_gens ();
char* find_permutation ();
int*** stabiliser_of_rep ();
int*** immediate_descendant ();
void process_rep ();
void evaluate_generators ();
void evaluate_image ();
void stabiliser_generators ();
void image_of_generator ();
void intermediate_stage ();
void list_pqa_menu ();
void space_for_orbits ();
void orbits ();
Logical is_space_exhausted ();
Logical is_genlim_exceeded ();
char *GetString ();
void trace_relation ();
void output_information();
int *compact_description ();
