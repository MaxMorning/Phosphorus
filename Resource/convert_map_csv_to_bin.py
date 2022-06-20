import csv
import struct

with open('Map.csv', 'r') as csv_file:
    reader = csv.reader(csv_file)
    with open('Map.data', 'wb') as result_map:
        for line in reader:
            for idx in line:
                result_map.write(struct.pack('b', int(idx)))
