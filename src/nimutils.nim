##[
========
nimutils
========
Some useful tools when programming with the Nim programming language.
]##
# imports/exports
import  ./nimutils/[
                    # the modules below only import standard modules
                    nuconstants,
                    nuexceptions,
                    numisc,
                    nufpcmp,
                    numath_intersect,
                    # the modules below import the standard  
                    # modules and modules from the list above
                    nudates,
                   ]
export  nuconstants, nuexceptions, numisc, nufpcmp, numath_intersect, nudates

