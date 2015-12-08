# ets2sectormover
ETS2 Sector Mover by Narzew
v 1.00 (08.12.2015)

Tool to move map ETS2 map sectors to other place
Author: Narzew
Thanks: ScuL -> for explaining sector structure

Usage:

ruby SectorMover.rb folder swap_x swap_y
where:
folder -> folder containing .desc, .base and .aux files with sectors
swap_x -> sector x value to swap (integer)
swap_y -> sector y value to swap (integer)

For example:

ruby SectorMover.rb europe 200 -100
will move europe map 200 sectors east and 100 sectors north

Sector structure:
sec<+|->XXXX<+|>YYYY.<base|desc|aux>
First sign: - => sectors go West(-)
First sign: + => sectors go East (+)
Second sign: - => sectors go North (-)
Second sign: + => sectors go South (+)

