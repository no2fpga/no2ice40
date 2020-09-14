`SB_LEDDA_IP` & `SB_RGBA_DRV` wishbone wrapper
==============================================

Memory map
----------

### `SB_LEDDA_IP` registers ( Write Only, `0x00-0x3C` )

This wrapper directly maps each register of `SB_LEDDA_IP` to a distinct wishbone
word address. In this case for `SB_LEDDA_IP` since the native bus is only 8 bits wide
this means that each 32 bits word of the wishbone bus has the upper 24 bits unused.
Also, all accesses have to be full width ( 32 bits ).

Refer to Lattice TN1288 for the exact register description.

### Control word ( Write Only, `0x40` )

Single control word that controls a few control lines on the IP.

```text
,-----------------------------------------------------------------------------------------------,
|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-----------------------------------------------------------------------------------------------|
|                                       /                                           |ce|le|ex| /|
'-----------------------------------------------------------------------------------------------'

 * [3] - ce : SB_RGBA_DRV.CURREN
 * [2] - le : SB_RGBA_DRV.RGBLEDEN
 * [1] - ex : SB_LEDDA_IP.LEDDEXE
```
