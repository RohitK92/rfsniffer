#!/usr/bin/env python

# AD3520 VCO Band Observations {{{
# No.  Possible Band Start Points (in MHz)    Possible Band Range (in MHz)    Program Frequency (in MHz)    Corresponding INT    Corresponding FRAC
txt = \
'''
2     2207            44          2214          88         2293
3     2251            44          2260          90         1638
4     2295            52          2310          92         1638
5     2347            44          2350          94         0   
6     2391            48          2400          96         0   
7     2439            52          2450          98         0   
8     2491            51          2500          100        0   
9     2542            48          2550          102        0   
10    2590            52          2600          104        0   
11    2642            60          2650          106        0   
12    2702            56          2710          108        1638
13    2758            56          2770          110        3276
14    2814            68          2850          114        0   
15    2882            46          2890          115        2457
16    2928            50          2950          118        0   
17    2978            36          2990          119        2457
18    3014            60          3030          121        819 
19    3076            48          3090          123        2457
20    3124            52          3140          125        2457
21    3172            62          3190          127        2457
22    3234            60          3250          130        0   
23    3294            62          3310          132        1638
24    3356            60          3370          134        3276
25    3416            62          3430          137        819 
26    3478            72          3490          139        2457
27    3550            62          3570          142        3276
28    3612            70          3630          145        819 
29    3684            62          3700          148        0   
30    3746            50          3760          150        1638
31    3794            62          3810          152        1638
32    3856            60          3870          154        3276
33    3916            62          3930          157        819 
34    3978            60          3990          159        2457
35    4038            62          4050          162        0   
36    4100            72          4120          164        3276
37    4172            62          4190          167        2457
38    4234            72          4250          170        0   
'''

# Notes:
#
# 1. I can say for sure that entries in the first 16 rows are consective band
# start points.

# 2. I can say for sure that entries from row number 16 onwards are band start
# points but they may not be consecutive. Look at the range for some bands! 72
# MHz is bit too much?
# 
# 3. Program frequency is the frequency chosen by adding an arbitrary small
# number to the band start point. The reason I do this is because there is a
# slight variation observed in the start point frequencies as I take multiple
# readings. Adding an arbitrary small number ensures that we always land
# somewhere in that band (not necessarily the start point of that band). 
#
# 4. Program frequency is the frquency we would want to program from our code
# that performs the chirp.
# 
# 5. I have written only INT and FRAC values since other params remain the same
# when RFDiv is fixed. For you reference here are the other params -
# REF=100.00, D=0, T=1, R=2, MOD=4095, RFdiv=1
#}}}

for line in txt:
    print line
