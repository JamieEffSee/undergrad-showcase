Some standout files from my first big foray into VBA.
I had not received formal training in coding at this point,
so I apologize for any redundancy or spaghetti :)

# Document generation is broken, unless you're using Microsoft Word 2011!
# 
# Be sure to enable Macros if you want to see the VBA

INVENTORY
This was used for tracking our (enormous) inventory when we were switching
over inventory control systems. This remained in use for about a month as 
a dynamic inventory tracker that was used as a data dump for when the new 
system arrived. The actual tracking itself is simple top-level Excel but
the VBA enables quick database updating and printing.

BARRED LIST
The bar that operated at the community association needed to keep track of
the patrons that were barred and given warnings. The bartenders also needed
a way to have a fresh list without rewriting it every time. This document
represented an ongoing project aimed at streamlining this system and contains
considerably more VBA code than the inventory management scripts. It tracks
expiration dates, is very sortable, and produces various reports on the patron
activity, allowing for observation of trends or for pulling specific statistics.
