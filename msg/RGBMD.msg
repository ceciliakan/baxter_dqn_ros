Header header
uint32 height         # image height, that is, number of rows
uint32 width          # image width, that is, number of columns

string RGBencoding
string DEPencoding

uint8 is_bigendian    # is this data bigendian?
uint32 step           # Full row length in bytes
uint8[] RGBdata          # actual matrix data, size is (step * rows)
float32[] DEPdata
