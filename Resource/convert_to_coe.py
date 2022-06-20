import sys

if __name__ == "__main__":
    with open(sys.argv[1], 'rb') as bin_file:
        with open(sys.argv[2], 'w') as coe_file:
            bin_content = bin_file.read()

            coe_file.write('memory_initialization_radix = 16;\nmemory_initialization_vector =')

            cnt = 0
            for byte in bin_content:
                if cnt % 4 == 0:
                    coe_file.write('\n')

                hex_str = hex(byte)[2:]
                if len(hex_str) == 1:
                    coe_file.write('0' + hex_str)
                else:
                    coe_file.write(hex_str)

                cnt += 1