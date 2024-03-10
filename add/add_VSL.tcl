# Use this function to creat a vertical shear link and two digonal braces.
#
# ------------ Input arguements -------------------
# NodeA:        Tag of middle node on the top beam
# NodeB:        Tag of the left bottom node
# NodeC:        Tag of the right bottom node
# h:            Shear link height
# A_brace:      Cross section are of the diogonal brace (modoled by truss element)
# shear_link_mat: Material name of the shear link (e.g. Steel01)
# args:         Material parameters of the shear link material. (not include the
#               material name and tag, e.g. 300 300 0.02 for Steel01)
# -------------------------------------------------
#
#  Numberring rules of vertical shear link:
#
#                        o node A ($NodeA)
#                        | twoNodeLink element A (with length of $h)
#                        o node tag = A*100
#                       / \
#                      /   \
#                     /     \
#                    /       \
#           truss   /         \   truss
#          elememt /           \ elememt  
#             B   /             \   C
#                /               \
#               /                 \
#              /                   \
#             /                     \
#            /                       \
#           o node B ($NodeB)         o node C ($NodeC)
#
# Written by: Wenchen Lie, Guangzhou University, Mar 2, 2024



proc add_VSL {NodeA NodeB NodeC h A_breace shear_link_mat args} {

# define node A
set x [nodeCoord $NodeA 1]
set y [expr [nodeCoord $NodeA 2] - $h]
set tag [expr round($NodeA * 100)]
node $tag $x $y 0.0

# define elastic brace
element truss $NodeB $NodeB $tag $A_breace 667
element truss $NodeC $NodeC $tag $A_breace 667

# define shear link
uniaxialMaterial $shear_link_mat $NodeA {*}$args
element twoNodeLink $NodeA $tag $NodeA -mat 9 $NodeA 99 -dir 1 2 3;

}

