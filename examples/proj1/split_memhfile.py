import sys

infilename = sys.argv[1]
filename_parts = infilename.split('.')
outfilename0 = filename_parts[0] + '0.' + filename_parts[1]
outfilename1 = filename_parts[0] + '1.' + filename_parts[1]
outfilename2 = filename_parts[0] + '2.' + filename_parts[1]
outfilename3 = filename_parts[0] + '3.' + filename_parts[1]

infile = open(infilename)
outfile0 = open(outfilename0, 'w')
outfile1 = open(outfilename1, 'w')
outfile2 = open(outfilename2, 'w')
outfile3 = open(outfilename3, 'w')

for line in infile:
    outfile3.write(f'{line[0:2]}\n')
    outfile2.write(f'{line[2:4]}\n')
    outfile1.write(f'{line[4:6]}\n')
    outfile0.write(f'{line[6:8]}\n')

infile.close()
outfile0.close()
outfile1.close()
outfile2.close()
outfile3.close()

