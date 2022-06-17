tile_per_row = 30
tile_per_col = 40

with open('logo.data', 'rb') as raw_file:
    with open('reformat_logo.data', 'wb') as result_file:
        for row_idx in range(tile_per_row):
            for col_idx in range(tile_per_col):
                for tile_row in range(16):
                    raw_file.seek((row_idx * 16 + tile_row) * tile_per_col * 16 + col_idx * 16)
                    color_value = raw_file.read(16)
                    result_file.write(color_value)

    print("Done.")