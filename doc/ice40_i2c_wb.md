`SB_I2C` wishbone wrapper
=========================

Memory map
----------

### `SB_I2C` registers ( Write Only, `0x00-0x3C` )

This wrapper directly maps each register of `SB_I2C` to a distinct wishbone
word address. In this case for `SB_I2C` since the native bus is only 8 bits wide
this means that each 32 bits word of the wishbone bus has the upper 24 bits unused.
Also, all accesses have to be full width ( 32 bits ).

Refer to Lattice TN1276 for the exact register description.

Note that the upper 4 bits of the native bus address are automatically filled
by the wrapper.
